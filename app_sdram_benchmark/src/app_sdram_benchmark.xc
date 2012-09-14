#include <platform.h>
#include <stdio.h>
#include <stdlib.h>
#include "sdram.h"

#define VERBOSE 0

#define CORE 1
#define TYPE 0

#if TYPE
on stdcore[CORE]: struct sdram_ports sdram_ports = {
    XS1_PORT_16B, XS1_PORT_1J, XS1_PORT_1I, XS1_PORT_1K, XS1_PORT_1L, XS1_CLKBLK_1 };
#else
on stdcore[CORE]: struct sdram_ports sdram_ports = {
    XS1_PORT_16A, XS1_PORT_1B, XS1_PORT_1G, XS1_PORT_1C, XS1_PORT_1F, XS1_CLKBLK_1 };
#endif

static float readWords(chanend server, unsigned count, unsigned page_alignment){
  unsigned buf[SDRAM_ROW_WORDS];
  timer t;
  unsigned now, then;
  sdram_wait_until_idle(server);
  t :> then;
  for (unsigned row = 0; row < SDRAM_ROW_COUNT; row++) {
    server  :> int;
    sdram_buffer_read(server, 0, row, page_alignment, count, buf);
  }
  server  :> int;
  sdram_wait_until_idle(server);
  server  :> int;
  t :> now;
  return (float)(SDRAM_ROW_COUNT * ((4*100000000/1024)/1024) * count) / (now-then);
}

static float writeWords(chanend server, unsigned count, unsigned page_alignment){
  unsigned buf[SDRAM_ROW_WORDS];
  timer t;
  unsigned now, then;
  for (unsigned word = 0; word < count; word++) {
    buf[word] = 0xaaaaaaaa;
  }
  sdram_wait_until_idle(server);
  t :> then;
  for (unsigned row = 0; row < SDRAM_ROW_COUNT; row++) {
    server  :> int;
    sdram_buffer_write(server, 0, row, page_alignment, count, buf);
  }
  server  :> int;
  sdram_wait_until_idle(server);
  server  :> int;
  t :> now;
  return (float)(SDRAM_ROW_COUNT * ((4*100000000/1024)/1024) * count) / (now-then);
}

static float maxWriteWords(chanend server){
  unsigned buf[SDRAM_ROW_WORDS];
  timer t;
  unsigned now, then;
  for (unsigned word = 0; word < SDRAM_ROW_WORDS; word++) {
    buf[word] = 0xaaaaaaaa;
  }
  sdram_wait_until_idle(server);
  t :> then;
  for (unsigned row = 0; row < SDRAM_ROW_COUNT; row++) {
    server  :> int;
    sdram_full_row_write(server,0, row, buf);
  }
  server  :> int;
  sdram_wait_until_idle(server);
  server  :> int;
  t :> now;
  return (float)(SDRAM_ROW_COUNT * SDRAM_ROW_WORDS * ((4*100000000/1024)/1024)) / (now-then);
}
static float maxReadWords(chanend server){
  unsigned buf[SDRAM_ROW_WORDS];
  timer t;
  unsigned now, then;
  sdram_wait_until_idle(server);
  t :> then;
  for (unsigned row = 0; row < SDRAM_ROW_COUNT; row++) {
    server  :> int;
    sdram_full_row_read(server,0, row, buf);
  }
  server  :> int;
  sdram_wait_until_idle(server);
  server  :> int;
  t :> now;
  return (float)(SDRAM_ROW_COUNT * SDRAM_ROW_WORDS * ((4*100000000/1024)/1024)) / (now-then);
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
  if(VERBOSE)
    printf("Begin sanity_check\n");
  for (unsigned i = 0; i < SANITY_TEST_SIZE; i++) {
    input_buffer[i] = i;
    output_buffer[i] = 0xaabbccdd;
  }
  sdram_buffer_write(sdram_c, SANITY_TEST_BANK, SANITY_TEST_ROW, SANITY_TEST_COL, SANITY_TEST_SIZE, input_buffer);
  sdram_c :> int;
  sdram_wait_until_idle(sdram_c);
  sdram_c :> int;
  sdram_buffer_read(sdram_c, SANITY_TEST_BANK, SANITY_TEST_ROW, SANITY_TEST_COL, SANITY_TEST_SIZE, output_buffer);
  sdram_c :> int;
  sdram_wait_until_idle(sdram_c);
  sdram_c :> int;

  for (unsigned i = 0; i < SANITY_TEST_SIZE; i++) {
    if (i != output_buffer[i]) {
      printf("Failed sanity_check on word %d, got word: 0x%08x\n", i,
          output_buffer[i]);
      exit(0);
    }
  }
  if(VERBOSE)
    printf("\tPassed\n");
}
void regression_single_thread(chanend server, unsigned cores) {
  sanity_check(server);
  if(VERBOSE){
    printf("Words\tWrite\tWrite\tRead\tRead\n");
    printf("\tsingle\tmulti\tsingle\tmulti\n");
  }
  for(unsigned word_count = 1; word_count <= SDRAM_ROW_WORDS; word_count++){
    float single_page_write = writeWords(server, word_count, 0);
    float multi_page_write = writeWords(server, word_count, SDRAM_ROW_WORDS-1);
    float single_page_read = writeWords(server, word_count, 0);
    float multi_page_read = writeWords(server, word_count, SDRAM_ROW_WORDS-1);
    if(VERBOSE)
      printf("%d\t%.2f\t%.2f\t%.2f\t%.2f\n", word_count, single_page_write, multi_page_write, single_page_read, multi_page_read);
  }
  printf("Cores active: %d\n", cores);
  printf("Max write: %.2f MB/s\n", maxWriteWords(server));
  printf("Max read : %.2f MB/s\n", maxReadWords(server));
}

void regression(chanend server, chanend in_t, chanend out_t, unsigned cores) {
  regression_single_thread(server, cores);
  out_t <: 1;
  in_t :> int;
}

void test_2_threads(chanend server) {
  //sdram_server
  regression_single_thread(server, 2);
}

void test_3_threads(chanend server) {
  chan c[2];
  par {
    //sdram_server
    regression(server, c[0], c[1], 3);
    load_thread(c[1], c[0]);
  }
}

void test_4_threads(chanend server) {
  chan c[3];
  par {
    //sdram_server
    regression(server, c[0], c[1], 4);
    load_thread(c[1], c[2]);
    load_thread(c[2], c[0]);
  }
}

void test_5_threads(chanend server) {
  chan c[4];
  par {
    //sdram_server
    regression(server, c[0], c[1], 5);
    load_thread(c[1], c[2]);
    load_thread(c[2], c[3]);
    load_thread(c[3], c[0]);
  }
}
void test_6_threads(chanend server) {
  chan c[5];
  par {
    //sdram_server
    regression(server, c[0], c[1], 6);
    load_thread(c[1], c[2]);
    load_thread(c[2], c[3]);
    load_thread(c[3], c[4]);
    load_thread(c[4], c[0]);
  }
}

void test_7_threads(chanend server) {
  chan c[6];
  par {
    //sdram_server
    regression(server, c[0], c[1], 7);
    load_thread(c[1], c[2]);
    load_thread(c[2], c[3]);
    load_thread(c[3], c[4]);
    load_thread(c[4], c[5]);
    load_thread(c[5], c[0]);
  }
}

void test_8_threads(chanend server) {
  chan c[7];
  par {
    //sdram_server
    regression(server, c[0], c[1], 8);
    load_thread(c[1], c[2]);
    load_thread(c[2], c[3]);
    load_thread(c[3], c[4]);
    load_thread(c[4], c[5]);
    load_thread(c[5], c[6]);
    load_thread(c[6], c[0]);
  }
}

void sdram_client(chanend server) {
  test_8_threads(server);
  test_7_threads(server);
  test_6_threads(server);
  test_5_threads(server);
  test_4_threads(server);
  test_3_threads(server);
  test_2_threads(server);
}

int main() {
  chan sdram_c;
  par {
    on stdcore[CORE]:
    sdram_server(sdram_c, sdram_ports);
    on stdcore[CORE]:
    sdram_client(sdram_c);
  }
  return 0;
}
