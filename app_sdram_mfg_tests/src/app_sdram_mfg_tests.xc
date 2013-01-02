#include <platform.h>
#include <stdio.h>
#include <stdlib.h>
#include "sdram.h"

#define MIN_BLOCK_WIDTH_WORDS   1
on tile[0]: sdram_ports ports = {XS1_PORT_16A, XS1_PORT_4F, XS1_PORT_1H, XS1_CLKBLK_2 };

static inline void client_write(chanend server, unsigned bank,
    unsigned start_row, unsigned start_col, unsigned words, unsigned buffer[]) {
  sdram_buffer_write(server, bank, start_row, start_col, words, buffer);
}

static inline void client_read(chanend server, unsigned bank,
    unsigned start_row, unsigned start_col, unsigned words, unsigned buffer[]) {
  sdram_buffer_read(server, bank, start_row, start_col, words, buffer);
}

static inline void client_wait_until_idle(chanend server, unsigned buffer[]) {
  sdram_wait_until_idle(server, buffer);
}

static inline void write_only(chanend server, unsigned bank, unsigned row, unsigned col, unsigned pattern){
	unsigned buf[1];
	buf[0] = pattern;
	client_write(server, bank, row, col, 1, buf);
	client_wait_until_idle(server, buf);
}

static inline void write_only_not(chanend server, unsigned e_bank, unsigned e_row, unsigned e_col){
  unsigned buf[SDRAM_ROW_WORDS];
  for (int word = 0; word < SDRAM_ROW_WORDS; word++)
	buf[word] = 0;
  for (unsigned bank = 0; bank < SDRAM_BANK_COUNT; bank++) {
	for (unsigned row = 0; row < SDRAM_ROW_COUNT; row++) {
	  if (row == e_row && bank == e_bank){
		  client_write(server, bank, row, (col+1)%SDRAM_ROW_WORDS, SDRAM_ROW_WORDS-1, buf);
		  client_wait_until_idle(server, buf);
	  } else {
		  client_write(server, bank, row, 0, SDRAM_ROW_WORDS, buf);
		  client_wait_until_idle(server, buf);
	  }
	}
  }
}

static void test_row_col_bank(chanend server) {
#define PATTERNS 8
  unsigned test_patterns[PATTERNS] = { 0, 1, 2, 3, 4, 5, 6, 7};
  printf("Started test_row_col_bank\n");
  for (unsigned i=0;i<PATTERNS;i++){
	  for(unsigned bank =0; bank < SDRAM_ROW_WORDS; bank++){
		  for(unsigned row =0; row < SDRAM_ROW_WORDS; row++){
			  for(unsigned col =0; col < SDRAM_ROW_WORDS; col++){
				  unsigned read_buf[1];
				  read_buf[0]= 0x0;
				  write_only(server, bank, row, col, test_patterns[i]);
				  write_only_not(server, bank, row, col);
				  client_read(server, bank, row, col, 1, read_buf);
				  client_wait_until_idle(server, read_buf);
				  if(read_buf[0] != pattern){
					  printf("Failed\n");
				  }
			  }
		  }
	  }
  }
  printf("\tPassed\n");
}

static void refresh_test(chanend server) {

  unsigned pattern;
  unsigned wait_multiplier[3] = { 1, 4, 8};
  unsigned patterns[3] = { 0, 0x55555555, 0xffffffff };
  unsigned buf[SDRAM_ROW_WORDS];
  printf("Started refresh_test\n");
  for (unsigned p = 0; p < 3; p++) {
    pattern = patterns[p];
    for (unsigned w = 0; w < 3; w++) {
      timer t;
      unsigned time;
      fillMemory(server, pattern);
      for(unsigned tw = 0; tw < wait_multiplier[w]; tw++){
        t :> time;
        t when timerafter(time+100000000):> int;
      }

      for (unsigned bank = 0; bank < SDRAM_BANK_COUNT; bank++) {
        for (unsigned row = 0; row < SDRAM_ROW_COUNT; row++) {
          client_read(server, bank, row, 0, SDRAM_ROW_WORDS, buf);
          client_wait_until_idle(server, buf);
          for(unsigned word=0;word<SDRAM_ROW_WORDS; word++) {
            unsigned r = buf[word];
            if(r != pattern) {
              printf("Failed row read/write on row %d of bank %d on word %d\n",
                  row, bank, word);
            }
          }
        }
      }
    }
  }
  printf("\tPassed\n");
}

void load_thread(chanend in_t, chanend out_t) {
  set_thread_fast_mode_on();
  in_t  :> int;
  out_t <: 1;
}

void sanity_check(chanend sdram_c) {
#define SANITY_TEST_SIZE 8
#define SANITY_TEST_BANK 1
#define SANITY_TEST_ROW 1
#define SANITY_TEST_COL 0
  unsigned input_buffer[SANITY_TEST_SIZE];
  unsigned output_buffer[SANITY_TEST_SIZE];
  printf("Begin sanity_check\n");
  for (unsigned i = 0; i < SANITY_TEST_SIZE; i++) {
    input_buffer[i] = i;
    output_buffer[i] = 0xaabbccdd;
  }
  client_write(sdram_c, SANITY_TEST_BANK, SANITY_TEST_ROW, SANITY_TEST_COL,
      SANITY_TEST_SIZE, input_buffer);
  client_wait_until_idle(sdram_c, input_buffer);
  client_read(sdram_c, SANITY_TEST_BANK, SANITY_TEST_ROW, SANITY_TEST_COL,
      SANITY_TEST_SIZE, output_buffer);

  client_wait_until_idle(sdram_c, output_buffer);

  for (unsigned i = 0; i < SANITY_TEST_SIZE; i++) {
    if (i != output_buffer[i]) {
      printf("Failed sanity_check on word %d, got word: 0x%08x\n", i,
          output_buffer[i]);
      _Exit(1);
    }
  }
  printf("\tPassed\n");
}

void regression_single_thread(chanend server) {
  reset_super_pattern();
  sanity_check(server);
  single_row_write(server);
  partial_row_write_read(server);
  partial_row_write_align(server);
  whole_mem_write_read(server);
  refresh_test(server);
  refresh_test_2(server);
  ordered_read(server, 4096 * 1024);
  pseudo_random_read(server, 4096 * 64);
}

void regression(chanend server, chanend in_t, chanend out_t) {
  regression_single_thread(server);
  out_t <: 1;
  in_t :> int;
}

void test_2_threads(chanend server) {
  //sdram_server
  printf("2 threaded test suite start\n");
  regression_single_thread(server);
  printf("2 threaded test suite completed\n");
}

void test_3_threads(chanend server) {
  chan c[2];
  printf("3 threaded test suite start\n");
  par {
    regression(server, c[0], c[1]);
    load_thread(c[1], c[0]);
  }
  printf("3 threaded test suite completed\n");
}

void test_4_threads(chanend server) {
  chan c[3];
  printf("4 threaded test suite start\n");
  par {
    regression(server, c[0], c[1]);
    load_thread(c[1], c[2]);
    load_thread(c[2], c[0]);
  }
  printf("4 threaded test suite completed\n");
}

void test_8_threads(chanend server) {
  chan c[7];
  printf("8 threaded test suite start\n");
  par {
    regression(server, c[0], c[1]);
    load_thread(c[1], c[2]);
    load_thread(c[2], c[3]);
    load_thread(c[3], c[4]);
    load_thread(c[4], c[5]);
    load_thread(c[5], c[6]);
    load_thread(c[6], c[0]);
  }
  printf("8 threaded test suite completed\n");
}
void test_7_threads(chanend server) {
  chan c[6];
  printf("7 threaded test suite start\n");
  par {
    regression(server, c[0], c[1]);
    load_thread(c[1], c[2]);
    load_thread(c[2], c[3]);
    load_thread(c[3], c[4]);
    load_thread(c[4], c[5]);
    load_thread(c[5], c[0]);
  }
  printf("7 threaded test suite completed\n");
}
void test_6_threads(chanend server) {
  chan c[5];
  printf("6 threaded test suite start\n");
  par {
    regression(server, c[0], c[1]);
    load_thread(c[1], c[2]);
    load_thread(c[2], c[3]);
    load_thread(c[3], c[4]);
    load_thread(c[4], c[0]);
  }
  printf("6 threaded test suite completed\n");
}
void test_5_threads(chanend server) {
  chan c[4];
  printf("5 threaded test suite start\n");
  par {
    regression(server, c[0], c[1]);
    load_thread(c[1], c[2]);
    load_thread(c[2], c[3]);
    load_thread(c[3], c[0]);
  }
  printf("5 threaded test suite completed\n");
}

void sdram_client(chanend server) {
  set_thread_fast_mode_on();
  while(1){
    printf("Test suite begin\n");
    test_8_threads(server);
    test_7_threads(server);
    test_6_threads(server);
    test_5_threads(server);
    test_4_threads(server);
    test_3_threads(server);
    test_2_threads(server);
    printf("Test suite completed\n");
  }
}

int main() {
  chan sdram_c;
  par {
    on tile[0]:sdram_server(sdram_c, ports);
    on tile[0]:sdram_client(sdram_c);
  }
  return 0;
}

