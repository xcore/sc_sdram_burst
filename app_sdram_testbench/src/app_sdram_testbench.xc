#include <platform.h>
#include <stdio.h>
#include <stdlib.h>
#include "sdram.h"
#include "sdram_slicekit_support.h"

#define VERBOSE_MSG 1

#define COL_ADDRESS_BITS 8
#define ROW_ADDRESS_BITS 12
#define BANK_ADDRESS_BITS 2
#define COL_COUNT     256
#define BANK_COUNT    4
#define ROW_COUNT     4096
#define ROW_WORDS     128

static unsigned make_identifier(unsigned bank, unsigned row, unsigned word){
    return (bank) | (row<<(BANK_ADDRESS_BITS)) | (word<<(BANK_ADDRESS_BITS + ROW_ADDRESS_BITS));
}

{unsigned, unsigned, unsigned} decode_identifier(unsigned d){
    unsigned bank, row, word;
    bank = d&((1<<BANK_ADDRESS_BITS)-1);
    row = (d>>(BANK_ADDRESS_BITS))&((1<<ROW_ADDRESS_BITS)-1);
    word = (d>>(BANK_ADDRESS_BITS + ROW_ADDRESS_BITS))&((1<<COL_ADDRESS_BITS)-1);
    return {bank, row, word};
}
unsigned c = 0xffffffff;

static void reset_super_pattern(unsigned x) {
  c = x;
}

static unsigned super_pattern() {
  crc32(c, 0xff, 0x82F63B78);
  return c;
}

#define MAX_BUFFER_WORDS 256
static void whole_memory_write_read(streaming chanend c_server, s_sdram_state &sdram_state){
    unsigned buffer[MAX_BUFFER_WORDS];
    unsigned * movable buffer_pointer = buffer;

    int error = 0;
    if (VERBOSE_MSG) printf("Begin   : whole_memory_write_read\n");
    for(unsigned c = 0; c< COL_COUNT;c+=2){
        reset_super_pattern(c);
        for(unsigned b = 0; b < BANK_COUNT;b++){
            for(unsigned r = 0; r < ROW_COUNT;r++){

                for(unsigned i=0;i<c/2;i++)
                    buffer_pointer[i] = 0;

                sdram_write(c_server, sdram_state, b, r, 0, c/2, move(buffer_pointer));
                sdram_complete(c_server, sdram_state, buffer_pointer);

                for(unsigned i=0;i<ROW_WORDS-c/2;i++)
                    buffer_pointer[i] = super_pattern();
                sdram_write(c_server, sdram_state, b, r, c, ROW_WORDS-c/2, move(buffer_pointer));
                sdram_complete(c_server, sdram_state, buffer_pointer);
            }
        }
        reset_super_pattern(c);
        for(unsigned b = 0; b < BANK_COUNT;b++){
            for(unsigned r = 0; r < ROW_COUNT;r++){
                sdram_read(c_server, sdram_state, b, r, c, ROW_WORDS-c/2, move(buffer_pointer));
                sdram_complete(c_server, sdram_state, buffer_pointer);

                for(unsigned i=0;i<ROW_WORDS-c/2;i++){
                    unsigned s = super_pattern();
                    if(buffer_pointer[i] != s){
                        error = 1;
                        if (VERBOSE_MSG) printf("error %08x %08x b:%d r:%d c:%d i:%d\n", buffer_pointer[i] , s, b, r, c, i);
                    }
                }
            }
        }
    }
    if (VERBOSE_MSG) printf("Complete: whole_memory_write_read\t");
    if (VERBOSE_MSG) printf(error?"fail\n":"pass\n");
}

static void refresh_test_1(streaming chanend c_server, s_sdram_state &sdram_state){
    timer t;
    unsigned time;
    unsigned buffer[MAX_BUFFER_WORDS];
    unsigned * movable buffer_pointer = buffer;
    int error = 0;
    if (VERBOSE_MSG) printf("Begin   : refresh_test_1\n");
    //write some data
    reset_super_pattern(0);
    for(unsigned b = 0; b < BANK_COUNT;b++){
        for(unsigned r = 0; r < ROW_COUNT;r++){
            for(unsigned i=0;i<ROW_WORDS;i++)
                buffer_pointer[i] = super_pattern();
            sdram_write(c_server, sdram_state, b, r, 0, ROW_WORDS, move(buffer_pointer));
            sdram_complete(c_server, sdram_state, buffer_pointer);
        }
    }
    //wait for 2 mins
    t:> time;
    for(unsigned j=0;j<2;j++){
        for(unsigned i=0;i<60;i++)
            t when timerafter(time + 100000000) :> time;
    }
    //read it back
    reset_super_pattern(0);
    for(unsigned b = 0; b < BANK_COUNT;b++){
        for(unsigned r = 0; r < ROW_COUNT;r++){
            for(unsigned i=0;i<ROW_WORDS;i++)
                buffer_pointer[i] = 0;
            sdram_read(c_server, sdram_state, b, r, 0, ROW_WORDS, move(buffer_pointer));
            sdram_complete(c_server, sdram_state, buffer_pointer);

            for(unsigned i=0;i<ROW_WORDS;i++){
                unsigned s = super_pattern();
                if(buffer_pointer[i] != s){
                    error = 1;
                    if (VERBOSE_MSG) printf("error %08x %08x b:%d r:%d i:%d\n", buffer_pointer[i] , s, b, r, i);
                }
            }
        }
    }
    if (VERBOSE_MSG) printf("Complete: refresh_test_1\t\t");
    if (VERBOSE_MSG) printf(error?"fail\n":"pass\n");
}

static void refresh_test_2(streaming chanend c_server, s_sdram_state &sdram_state){
    unsigned buffer0[MAX_BUFFER_WORDS];
    unsigned buffer1[MAX_BUFFER_WORDS];
    unsigned buffer2[MAX_BUFFER_WORDS];
    unsigned buffer3[MAX_BUFFER_WORDS];
    unsigned buffer4[MAX_BUFFER_WORDS];
    unsigned buffer5[MAX_BUFFER_WORDS];
    unsigned buffer6[MAX_BUFFER_WORDS];
    unsigned buffer7[MAX_BUFFER_WORDS];
    unsigned * movable buffer_pointer0 = buffer0;
    unsigned * movable buffer_pointer1 = buffer1;
    unsigned * movable buffer_pointer2 = buffer2;
    unsigned * movable buffer_pointer3 = buffer3;
    unsigned * movable buffer_pointer4 = buffer4;
    unsigned * movable buffer_pointer5 = buffer5;
    unsigned * movable buffer_pointer6 = buffer6;
    unsigned * movable buffer_pointer7 = buffer7;

      int error = 0;
      if (VERBOSE_MSG) printf("Begin   : refresh_test_2\n");
      reset_super_pattern(0);
      for(unsigned b = 0; b < BANK_COUNT;b++){
          for(unsigned r = 0; r < ROW_COUNT;r++){
              for(unsigned i=0;i<ROW_WORDS;i++)
                  buffer_pointer0[i] = super_pattern();
              sdram_write(c_server, sdram_state, b, r, 0, ROW_WORDS, move(buffer_pointer0));
              sdram_complete(c_server, sdram_state, buffer_pointer0);
          }
      }

      sdram_read(c_server, sdram_state, 0, 0, 0, ROW_WORDS, move(buffer_pointer0));
      sdram_read(c_server, sdram_state, 0, 0, 0, ROW_WORDS, move(buffer_pointer1));
      sdram_read(c_server, sdram_state, 0, 0, 0, ROW_WORDS, move(buffer_pointer2));
      sdram_read(c_server, sdram_state, 0, 0, 0, ROW_WORDS, move(buffer_pointer3));
      sdram_read(c_server, sdram_state, 0, 0, 0, ROW_WORDS, move(buffer_pointer4));
      sdram_read(c_server, sdram_state, 0, 0, 0, ROW_WORDS, move(buffer_pointer5));
      sdram_read(c_server, sdram_state, 0, 0, 0, ROW_WORDS, move(buffer_pointer6));
      sdram_read(c_server, sdram_state, 0, 0, 0, ROW_WORDS, move(buffer_pointer7));

      for(unsigned i=0;i<8*100000;i++){
          sdram_complete(c_server, sdram_state, buffer_pointer0);
          sdram_read(c_server, sdram_state, 0, 0, 0, ROW_WORDS, move(buffer_pointer0));
      }
      sdram_complete(c_server, sdram_state, buffer_pointer0);
      sdram_complete(c_server, sdram_state, buffer_pointer1);
      sdram_complete(c_server, sdram_state, buffer_pointer2);
      sdram_complete(c_server, sdram_state, buffer_pointer3);
      sdram_complete(c_server, sdram_state, buffer_pointer4);
      sdram_complete(c_server, sdram_state, buffer_pointer5);
      sdram_complete(c_server, sdram_state, buffer_pointer6);
      sdram_complete(c_server, sdram_state, buffer_pointer7);

      //read it back
      reset_super_pattern(0);
      for(unsigned b = 0; b < BANK_COUNT;b++){
          for(unsigned r = 0; r < ROW_COUNT;r++){
              for(unsigned i=0;i<ROW_WORDS;i++)
                  buffer_pointer0[i] = 0;
              sdram_read(c_server, sdram_state, b, r, 0, ROW_WORDS, move(buffer_pointer0));
              sdram_complete(c_server, sdram_state, buffer_pointer0);

              for(unsigned i=0;i<ROW_WORDS;i++){
                  unsigned s = super_pattern();
                  if(buffer_pointer0[i] != s){
                      error = 1;
                      if (VERBOSE_MSG) printf("error %08x %08x b:%d r:%d i:%d\n", buffer_pointer0[i] , s, b, r, i);
                  }
              }
          }
      }
      if (VERBOSE_MSG) printf("Complete: refresh_test_2\t\t");
      if (VERBOSE_MSG) printf(error?"fail\n":"pass\n");
}

static void testbench_single_thread(streaming chanend c_server, s_sdram_state &sdram_state) {
  whole_memory_write_read(c_server, sdram_state);
  refresh_test_1(c_server, sdram_state);
  refresh_test_2(c_server, sdram_state);
}

static void load_thread(chanend in_t, chanend out_t) {
  set_thread_fast_mode_on();
  in_t :> int;
  out_t <: 1;
}

static void testbench(streaming chanend c_server, s_sdram_state &sdram_state, chanend in_t, chanend out_t) {
  testbench_single_thread(c_server, sdram_state);
  out_t <: 1;
  in_t :> int;
}

static void test_4_threads(streaming chanend c_server, s_sdram_state &sdram_state) {
  chan c[3];
  if (VERBOSE_MSG)
    printf("4 threaded test suite start\n");
  par {
    testbench(c_server, sdram_state, c[0], c[1]);
    load_thread(c[1], c[2]);
    load_thread(c[2], c[0]);
  }
  if (VERBOSE_MSG)
    printf("4 threaded test suite completed\n");
}

static void test_8_threads(streaming chanend c_server, s_sdram_state &sdram_state) {
  chan c[7];
  if (VERBOSE_MSG)
    printf("8 threaded test suite start\n");
  par {
    testbench(c_server, sdram_state, c[0], c[1]);
    load_thread(c[1], c[2]);
    load_thread(c[2], c[3]);
    load_thread(c[3], c[4]);
    load_thread(c[4], c[5]);
    load_thread(c[5], c[6]);
    load_thread(c[6], c[0]);
  }
  if (VERBOSE_MSG)
    printf("8 threaded test suite completed\n");
}
static void test_7_threads(streaming chanend c_server, s_sdram_state &sdram_state) {
  chan c[6];
  if (VERBOSE_MSG)
    printf("7 threaded test suite start\n");
  par {
    testbench(c_server, sdram_state, c[0], c[1]);
    load_thread(c[1], c[2]);
    load_thread(c[2], c[3]);
    load_thread(c[3], c[4]);
    load_thread(c[4], c[5]);
    load_thread(c[5], c[0]);
  }
  if (VERBOSE_MSG)
    printf("7 threaded test suite completed\n");
}
static void test_6_threads(streaming chanend c_server, s_sdram_state &sdram_state) {
  chan c[5];
  if (VERBOSE_MSG)
    printf("6 threaded test suite start\n");
  par {
    testbench(c_server, sdram_state, c[0], c[1]);
    load_thread(c[1], c[2]);
    load_thread(c[2], c[3]);
    load_thread(c[3], c[4]);
    load_thread(c[4], c[0]);
  }
  if (VERBOSE_MSG)
    printf("6 threaded test suite completed\n");
}
static void test_5_threads(streaming chanend c_server, s_sdram_state &sdram_state) {
  chan c[4];
  if (VERBOSE_MSG)
    printf("5 threaded test suite start\n");
  par {
    testbench(c_server, sdram_state, c[0], c[1]);
    load_thread(c[1], c[2]);
    load_thread(c[2], c[3]);
    load_thread(c[3], c[0]);
  }
  if (VERBOSE_MSG)
    printf("5 threaded test suite completed\n");
}

void sdram_client(streaming chanend c_server) {

  set_thread_fast_mode_on();
  s_sdram_state sdram_state;
  sdram_init_state(c_server, sdram_state);

  if (VERBOSE_MSG)
    printf("Test suite begin\n");
  test_8_threads(c_server, sdram_state);
  test_7_threads(c_server, sdram_state);
  test_6_threads(c_server, sdram_state);
  test_5_threads(c_server, sdram_state);
  test_4_threads(c_server, sdram_state);
  if (VERBOSE_MSG)
    printf("Test suite completed\n");
  _Exit(0);
}

on tile[SDRAM_A16_TRIANGLE_TILE]: sdram_ports ports = SDRAM_A16_TRIANGLE_PORTS(XS1_CLKBLK_1);
int main() {
  streaming chan sdram_c[1];
  par {
    on tile[SDRAM_A16_TRIANGLE_TILE]:sdram_client(sdram_c[0]);
    on tile[SDRAM_A16_TRIANGLE_TILE]:sdram_server(sdram_c, 1, ports);
  }
  return 0;
}

