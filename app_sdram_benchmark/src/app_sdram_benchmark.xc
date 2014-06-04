#include <platform.h>
#include <stdio.h>
#include <stdlib.h>
#include "sdram.h"

#define VERBOSE 0

on tile[0]: sdram_ports ports = {
    XS1_PORT_16A, XS1_PORT_1B, XS1_PORT_1G, XS1_PORT_1C, XS1_PORT_1F, XS1_CLKBLK_1 };

/*
 * Plug XA-SK-SDRAM into the STAR slot. Ensure `XMOS LINK` is off. Build and run.
 */

static float readWords(chanend c_server, unsigned count, unsigned page_alignment){
  unsigned buf[SDRAM_ROW_WORDS];
  timer t;
  unsigned now, then;
  t :> then;
  for (unsigned row = 0; row < SDRAM_ROW_COUNT; row++) {
    sdram_buffer_read(c_server, 0, row, page_alignment, count, buf);
    sdram_wait_until_idle(c_server, buf);
  }
  t :> now;
  return (float)(SDRAM_ROW_COUNT * ((4*100000000/1024)/1024) * count) / (now-then);
}

static float writeWords(chanend c_server, unsigned count, unsigned page_alignment){
  unsigned buf[SDRAM_ROW_WORDS];
  timer t;
  unsigned now, then;
  for (unsigned word = 0; word < count; word++) {
    buf[word] = 0xaaaaaaaa;
  }
  t :> then;
  for (unsigned row = 0; row < SDRAM_ROW_COUNT; row++) {
    sdram_buffer_write(c_server, 0, row, page_alignment, count, buf);
    sdram_wait_until_idle(c_server, buf);
  }

  t :> now;
  return (float)(SDRAM_ROW_COUNT * ((4*100000000/1024)/1024) * count) / (now-then);
}

static float maxWriteWords(chanend c_server){
  unsigned buf[SDRAM_ROW_WORDS];
  timer t;
  unsigned now, then;
  for (unsigned word = 0; word < SDRAM_ROW_WORDS; word++) {
    buf[word] = 0xaaaaaaaa;
  }
  t :> then;
  for (unsigned row = 0; row < SDRAM_ROW_COUNT; row++) {
    sdram_full_row_write(c_server,0, row, buf);
    sdram_wait_until_idle(c_server, buf);
  }
  t :> now;
  return (float)(SDRAM_ROW_COUNT * SDRAM_ROW_WORDS * ((4*100000000/1024)/1024)) / (now-then);
}
static float maxReadWords(chanend c_server){
  unsigned buf[SDRAM_ROW_WORDS];
  timer t;
  unsigned now, then;
  t :> then;
  for (unsigned row = 0; row < SDRAM_ROW_COUNT; row++) {
    sdram_full_row_read(c_server, 0, row, buf);
    sdram_wait_until_idle(c_server, buf);
  }
  t :> now;
  return (float)(SDRAM_ROW_COUNT * SDRAM_ROW_WORDS * ((4*100000000/1024)/1024)) / (now-then);
}

static void load_thread(chanend in_t, chanend out_t) {
  set_thread_fast_mode_on();
  in_t  :> int;
  out_t <: 1;
}

static void sanity_check(chanend sdram_c) {
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
  sdram_wait_until_idle(sdram_c, input_buffer);

  sdram_buffer_read(sdram_c, SANITY_TEST_BANK, SANITY_TEST_ROW, SANITY_TEST_COL, SANITY_TEST_SIZE, output_buffer);
  sdram_wait_until_idle(sdram_c, output_buffer);

  for (unsigned i = 0; i < SANITY_TEST_SIZE; i++) {
    if (i != output_buffer[i]) {
      printf("Failed sanity_check on word %d, got word: 0x%08x\n", i, output_buffer[i]);
      exit(0);
    }
  }
  if(VERBOSE)
    printf("\tPassed\n");
}
static void speed_regression_single_thread(chanend c_server, unsigned cores) {
  sanity_check(c_server);
  if(VERBOSE){
    printf("Words\tWrite\tWrite\tRead\tRead\n");
    printf("\tsingle\tmulti\tsingle\tmulti\n");
  }
  for(unsigned word_count = 1; word_count <= SDRAM_ROW_WORDS; word_count++){
    float single_page_write = writeWords(c_server, word_count, 0);
    float multi_page_write = writeWords(c_server, word_count, SDRAM_ROW_WORDS-1);
    float single_page_read = writeWords(c_server, word_count, 0);
    float multi_page_read = writeWords(c_server, word_count, SDRAM_ROW_WORDS-1);
    if(VERBOSE)
      printf("%d\t%.2f\t%.2f\t%.2f\t%.2f\n", word_count, single_page_write, multi_page_write, single_page_read, multi_page_read);
  }
  printf("Cores active: %d\n", cores);
  printf("Max write: %.2f MB/s\n", maxWriteWords(c_server));
  printf("Max read : %.2f MB/s\n", maxReadWords(c_server));
}

{unsigned, unsigned} varWriteWords(chanend c_server, unsigned count){
  unsigned buf[SDRAM_ROW_WORDS];
  timer t;
  unsigned now, then;
  unsigned min = -1, max = 0;
  for (unsigned word = 0; word < count; word++) {
    buf[word] = 0xaaaaaaaa;
  }

  for (unsigned row = 0; row < 10000; row++) {
	unsigned time;
	t :> then;
    sdram_buffer_write(c_server, 0, row, 0, count, buf);
    sdram_wait_until_idle(c_server, buf);
    t :> now;
    time = now - then;
    if (time < min) min = time;
    if (time > max) max = time;
  }
  return {min, max};
}


static void latency_regression_single_thread(chanend c_server, unsigned cores) {
  unsigned total = 0;
  unsigned min_results[SDRAM_ROW_WORDS+1];
  unsigned max_results[SDRAM_ROW_WORDS+1];
  float min_latency=0;
  float max_latency=0;

  sanity_check(c_server);
  for(unsigned word_count = 1; word_count <= SDRAM_ROW_WORDS; word_count++){
	  unsigned min, max;
    {min, max} = varWriteWords(c_server, word_count);
    total += max;
    min_results[word_count] = min;
    max_results[word_count] = max;
  }

  for(unsigned word_count = 1; word_count <= SDRAM_ROW_WORDS; word_count++){
	min_latency += (min_results[word_count] - 4*word_count);
	max_latency += (max_results[word_count] - 4*word_count);
  }
  min_latency /= SDRAM_ROW_WORDS;
  max_latency /= SDRAM_ROW_WORDS;

  printf("Min Latency: %.2f\nMax Latency: %.2f\n", min_latency, max_latency);
}

static void regression(chanend c_server, chanend in_t, chanend out_t, unsigned cores) {
  speed_regression_single_thread(c_server, cores);
  latency_regression_single_thread(c_server, cores);
  out_t <: 1;
  in_t :> int;
}

static void test_4_threads(chanend c_server) {
  chan c[3];
  par {
    //sdram_c_server
    regression(c_server, c[0], c[1], 4);
    load_thread(c[1], c[2]);
    load_thread(c[2], c[0]);
  }
}

static void test_5_threads(chanend c_server) {
  chan c[4];
  par {
    //sdram_c_server
    regression(c_server, c[0], c[1], 5);
    load_thread(c[1], c[2]);
    load_thread(c[2], c[3]);
    load_thread(c[3], c[0]);
  }
}
static void test_6_threads(chanend c_server) {
  chan c[5];
  par {
    //sdram_c_server
    regression(c_server, c[0], c[1], 6);
    load_thread(c[1], c[2]);
    load_thread(c[2], c[3]);
    load_thread(c[3], c[4]);
    load_thread(c[4], c[0]);
  }
}

static void test_7_threads(chanend c_server) {
  chan c[6];
  par {
    //sdram_c_server
    regression(c_server, c[0], c[1], 7);
    load_thread(c[1], c[2]);
    load_thread(c[2], c[3]);
    load_thread(c[3], c[4]);
    load_thread(c[4], c[5]);
    load_thread(c[5], c[0]);
  }
}

static void test_8_threads(chanend c_server) {
  chan c[7];
  par {
    //sdram_c_server
    regression(c_server, c[0], c[1], 8);
    load_thread(c[1], c[2]);
    load_thread(c[2], c[3]);
    load_thread(c[3], c[4]);
    load_thread(c[4], c[5]);
    load_thread(c[5], c[6]);
    load_thread(c[6], c[0]);
  }
}

static void sdram_client(chanend c_server) {
  test_8_threads(c_server);
  test_7_threads(c_server);
  test_6_threads(c_server);
  test_5_threads(c_server);
  test_4_threads(c_server);
}

int main() {
  chan sdram_c[1];
  par {
    on tile[0]:sdram_server(sdram_c, ports);
    on tile[0]:sdram_client(sdram_c[0]);
  }
  return 0;
}

