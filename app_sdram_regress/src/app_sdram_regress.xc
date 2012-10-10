#include <platform.h>
#include <stdio.h>
#include <stdlib.h>
#include "sdram.h"

#define MIN_BLOCK_WIDTH_WORDS   1
sdram_ports ports = {
    XS1_PORT_16A, XS1_PORT_1B, XS1_PORT_1G, XS1_PORT_1C, XS1_PORT_1F, XS1_CLKBLK_1 };

unsigned c = 0xffffffff;

void reset_super_pattern() {
  c = 0xffffffff;
}

unsigned super_pattern() {
  crc32(c, 0xff, 0x82F63B78);
  return c;
}

unsigned pseudo_random_number(unsigned min, unsigned max) {
  return super_pattern() % (max + 1 - min) + min;
}

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

static void fillMemoryUnique(chanend server) {
  unsigned buf[SDRAM_ROW_WORDS];
  for (unsigned bank = 0; bank < SDRAM_BANK_COUNT; bank++) {
    for (unsigned row = 0; row < SDRAM_ROW_COUNT; row++) {
      for (unsigned word = 0; word < SDRAM_ROW_WORDS; word++)
        buf[word] = super_pattern();
      client_write(server, bank, row, 0, SDRAM_ROW_WORDS, buf);
      client_wait_until_idle(server, buf);
    }
  }
}

static void fillMemory(chanend server, unsigned fill_pattern) {
  unsigned buf[SDRAM_ROW_WORDS];
  for (unsigned word = 0; word < SDRAM_ROW_WORDS; word++)
    buf[word] = fill_pattern;

  for (unsigned bank = 0; bank < SDRAM_BANK_COUNT; bank++) {
    for (unsigned row = 0; row < SDRAM_ROW_COUNT; row++) {
      sdram_full_row_write(server, bank, row, buf);
      sdram_wait_until_idle(server, buf);
    }
  }
}

static void fillMemoryExcludingRow(chanend server, unsigned fill_pattern,
    unsigned exclusion_bank, unsigned exclusion_row) {
  unsigned buf[SDRAM_ROW_WORDS];
  for (int word = 0; word < SDRAM_ROW_WORDS; word++)
    buf[word] = fill_pattern;
  for (unsigned bank = 0; bank < SDRAM_BANK_COUNT; bank++) {
    for (unsigned row = 0; row < SDRAM_ROW_COUNT; row++) {
      if (row == exclusion_row && bank == exclusion_bank)
        continue;
      client_write(server, bank, row, 0, SDRAM_ROW_WORDS, buf);
      client_wait_until_idle(server, buf);
    }
  }
}

static void single_row_write(chanend server) {
  unsigned buf[SDRAM_ROW_WORDS];
  unsigned data = 1;
  unsigned test_row_count = 8;
  unsigned test_rows[8] = { 0, 1, 2, 3, SDRAM_ROW_COUNT - 4, SDRAM_ROW_COUNT
      - 3, SDRAM_ROW_COUNT - 2, SDRAM_ROW_COUNT - 1 };
  printf("Started single_row_write\n");
  for (int word = 0; word < SDRAM_ROW_WORDS; word++)
    buf[word] = data;

  fillMemory(server, 0xffffffff);
  for (unsigned bank = 0; bank < SDRAM_BANK_COUNT; bank++) {
    for (unsigned test_row = 0; test_row < test_row_count; test_row++) {
      unsigned row = test_rows[test_row];
      client_write(server, bank, row, 0, SDRAM_ROW_WORDS, buf);
      client_wait_until_idle(server, buf);
      fillMemoryExcludingRow(server, 0xffffffff, bank, row);
      client_read(server, bank, row, 0, SDRAM_ROW_WORDS, buf);
      client_wait_until_idle(server, buf);
      for (unsigned word = 0; word < SDRAM_ROW_WORDS; word++) {
        unsigned b = buf[word];
        if (b != data) {
          printf("Failed row read on row %d of bank %d: 0x%x != 0\n", row,
              bank, b);
          _Exit(1);
        }
      }
    }
  }
  printf("\tPassed\n");
}

static void partial_row_write_read(chanend server) {
  unsigned reset_buf[SDRAM_ROW_WORDS];
  unsigned write_buf[SDRAM_ROW_WORDS];
  unsigned read_buf[SDRAM_ROW_WORDS];

  //There is no need to test all the rows
  unsigned test_rows[8] = { 0, 1, 2, 3, SDRAM_ROW_COUNT - 4, SDRAM_ROW_COUNT
      - 3, SDRAM_ROW_COUNT - 2, SDRAM_ROW_COUNT - 1 };

  printf("Started partial_row_write_read\n");
  for (unsigned word = 0; word < SDRAM_ROW_WORDS; word++) {
    reset_buf[word] = 0xffffffff;
  }
  fillMemory(server, 0xffffffff);
  for (unsigned bank = 0; bank < SDRAM_BANK_COUNT; bank++) {
    for (unsigned r_index = 0; r_index < 8; r_index++) {
      unsigned row = test_rows[r_index];
      for (unsigned start_col = 0; start_col < SDRAM_COL_COUNT; start_col++) {
        for (unsigned word_count = MIN_BLOCK_WIDTH_WORDS; word_count
            < (SDRAM_COL_COUNT - start_col) / 2; word_count++) {
          client_write(server, bank, row, 0, SDRAM_ROW_WORDS, reset_buf);
          client_wait_until_idle(server, reset_buf);
          for (int word = 0; word < word_count; word++) {
            write_buf[word] = super_pattern();
            read_buf[word] = 0xaabbccdd;
          }
          client_write(server, bank, row, start_col, word_count, write_buf);
          client_wait_until_idle(server, write_buf);
          client_read(server, bank, row, start_col, word_count, read_buf);
          client_wait_until_idle(server, read_buf);

          for (int word = 0; word < word_count; word++) {
            unsigned r = read_buf[word];
            unsigned w = write_buf[word];
            if (r != w) {
              printf("Failed row read/write on row %d of bank %d at start_col %d with word_count %d on word %d: read:%08x wrote:%08x\n",
                  row, bank, start_col, word_count, word, r, w);
              _Exit(1);
            }
          }
        }
      }
    }
  }
  printf("\tPassed\n");
}

//Check that when we write a section of a row then we are writing to the correct place.
static void partial_row_write_align(chanend server) {
  unsigned reset_buf[SDRAM_ROW_WORDS];
  unsigned write_buf[SDRAM_ROW_WORDS];
  unsigned read_buf[SDRAM_ROW_WORDS];
  unsigned verify_buf[SDRAM_ROW_WORDS];

  //There is no need to test all the rows
  unsigned test_rows[8] = { 0, 1, 2, 3, SDRAM_ROW_COUNT - 4, SDRAM_ROW_COUNT
      - 3, SDRAM_ROW_COUNT - 2, SDRAM_ROW_COUNT - 1 };

  printf("Started partial_row_write_align\n");

  for (unsigned word = 0; word < SDRAM_ROW_WORDS; word++) {
    reset_buf[word] = 0xffffffff;
  }

  fillMemory(server, 0xffffffff);

  for (unsigned bank = 0; bank < SDRAM_BANK_COUNT; bank++) {
    for (unsigned r_index = 0; r_index < 8; r_index++) {
      unsigned row = test_rows[r_index];
      for (unsigned start_col = 0; start_col < SDRAM_COL_COUNT; start_col += 2) {
        for (unsigned word_count = MIN_BLOCK_WIDTH_WORDS; word_count
            < (SDRAM_COL_COUNT - start_col) / 2; word_count++) {

          for (unsigned word = 0; word < SDRAM_ROW_WORDS; word++) {
            reset_buf[word] = 0xffffffff;
            verify_buf[word] = 0xffffffff;
          }
          for (int word = 0; word < word_count; word++) {
            unsigned sp = super_pattern();
            write_buf[word] = sp;
            verify_buf[word + start_col / 2] = sp;
          }

          client_write(server, bank, row, 0, SDRAM_ROW_WORDS, reset_buf);
          client_wait_until_idle(server, reset_buf);
          client_write(server, bank, row, start_col, word_count, write_buf);
          client_wait_until_idle(server, write_buf);
          client_read(server, bank, row, 0, SDRAM_ROW_WORDS, read_buf);
          client_wait_until_idle(server, read_buf);

          for (int word = 0; word < word_count; word++) {
            unsigned r = read_buf[word];
            unsigned v = verify_buf[word];
            if (r != v) {
              printf(
                  "Failed row read/write on row %d of bank %d at start_col %d with word_count %d on word %d\n",
                  row, bank, start_col, word_count, word);
              _Exit(1);
            }
          }
        }
      }
    }
  }
  printf("\tPassed\n");
}
static void whole_mem_write_read(chanend server) {

  unsigned pattern;
  unsigned patterns[4] = { 0, 0x55555555, 0xaaaaaaaa, 0xffffffff };
  unsigned buf[SDRAM_ROW_WORDS];
  printf("Started whole_mem_write_read\n");
  for (unsigned p = 0; p < 4; p++) {
    pattern = patterns[p];
    fillMemory(server, pattern);
    for (unsigned bank = 0; bank < SDRAM_BANK_COUNT; bank++) {
      for (unsigned row = 0; row < SDRAM_ROW_COUNT; row++) {
        client_read(server, bank, row, 0, SDRAM_ROW_WORDS, buf);
        client_wait_until_idle(server, buf);
        for (unsigned word = 0; word < SDRAM_ROW_WORDS; word++) {
          unsigned r = buf[word];
          if (r != pattern) {
            printf("Failed row read/write on row %d of bank %d on word %d\n",
                row, bank, word);
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

unsigned makeWord(unsigned bank, unsigned row, unsigned word) {
  return bank + (row << 1) + (word << 13);
}

{unsigned, unsigned, unsigned} unmakeWord(unsigned word) {
  return {word & 1, (word >> 1) & 0xfff, (word >> 13) & 0xff};
}
void pseudo_random_read(chanend server, unsigned test_limit) {
  printf("Started pseudo_random_read\n");
  {
    //Init all memory to something unique and predicatable.
    for (unsigned bank = 0; bank < SDRAM_BANK_COUNT; bank++) {
      for (unsigned row = 0; row < SDRAM_ROW_COUNT; row++) {
        unsigned buffer[SDRAM_ROW_WORDS];
        for (unsigned word = 0; word < SDRAM_ROW_WORDS; word++) {
          buffer[word] = makeWord(bank, row, word);
        }
        client_write(server, bank, row, 0, SDRAM_ROW_WORDS, buffer);
        client_wait_until_idle(server, buffer);
      }
    }
  }
  {
    //Now do the testing
    unsigned wordsChecked = 0;
    while (test_limit--) {
      unsigned buffer[SDRAM_ROW_WORDS];
      unsigned block_width_words = pseudo_random_number(MIN_BLOCK_WIDTH_WORDS,
          SDRAM_ROW_WORDS - 1);
      unsigned bank = pseudo_random_number(0, SDRAM_BANK_COUNT - 1);
      unsigned start_row = pseudo_random_number(0, SDRAM_ROW_COUNT - 1);
      unsigned start_col = (pseudo_random_number(0,
          SDRAM_COL_COUNT - 2 * block_width_words - 1)) & (~1);
      unsigned start_word = start_col / 2;
      unsigned i = 0;

      for (unsigned x = 0; x < block_width_words; x++) {
        buffer[x] = 0;
      }

      client_read(server, bank, start_row, start_col, block_width_words, buffer);
      client_wait_until_idle(server, buffer);

      for (unsigned word = start_word; word < start_word + block_width_words; word++) {
        unsigned expected = makeWord(bank, start_row, word);
        unsigned actual = buffer[i++];
        if (expected != actual) {
          unsigned r, w, b;
          b = actual & 1;
          r = (actual >> 1) & 0xfff;
          w = (actual >> 13) & 0xff;
          printf("fail pseudo_random_read\n");
          _Exit(1);
        }
        wordsChecked++;
      }
    }
  }
  printf("\tCompleted\n");
}

void ordered_read(chanend server, unsigned test_limit) {
  unsigned pass = 0;
  printf("Started ordered_read\n");
  {
    //Init all memory to something unique and predicatable.
    for (unsigned bank = 0; bank < SDRAM_BANK_COUNT; bank++) {
      for (unsigned row = 0; row < SDRAM_ROW_COUNT; row++) {
        unsigned buffer[SDRAM_ROW_WORDS];
        for (unsigned word = 0; word < SDRAM_ROW_WORDS; word++) {
          buffer[word] = makeWord(bank, row, word);
        }
        client_write(server, bank, row, 0, SDRAM_ROW_WORDS, buffer);
        client_wait_until_idle(server, buffer);
      }
    }
  }

  {
    //Now do the testing
    unsigned wordsChecked = 0;
    unsigned buffer[SDRAM_ROW_WORDS];
    for (unsigned bank = 0; bank < SDRAM_BANK_COUNT - 1; bank++) {
      for (unsigned width = MIN_BLOCK_WIDTH_WORDS; width < SDRAM_ROW_WORDS - 1; width++) {
        for (unsigned start_row = 0; start_row < SDRAM_ROW_COUNT - 1; start_row++) {
          for (unsigned start_col = 0; start_col < SDRAM_COL_COUNT - 2 * width; start_col += 2) {

            unsigned start_word = start_col / 2;
            unsigned i = 0;

            for (unsigned x = 0; x < width; x++)
              buffer[x] = 0;

            client_read(server, bank, start_row, start_col, width, buffer);
            client_wait_until_idle(server, buffer);

            for (unsigned word = start_word; word < start_word + width; word++) {
              unsigned expected = makeWord(bank, start_row, word);
              unsigned actual = buffer[i++];
              if (expected != actual) {
                unsigned r, w, b;
                b = actual & 1;
                r = (actual >> 1) & 0xfff;
                w = (actual >> 13) & 0xff;
                printf("fail ordered_read %d\n", wordsChecked);
                _Exit(1);
              }
              wordsChecked++;
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

static void refresh_test_2(chanend server) {

  unsigned pattern;
  unsigned wait_multiplier[3] = { 1, 2, 3};
  unsigned patterns[3] = { 0, 0x55555555, 0xffffffff };
  unsigned test_rows[8] = { 0, 1, 2, 3, SDRAM_ROW_COUNT - 4, SDRAM_ROW_COUNT
      - 3, SDRAM_ROW_COUNT - 2, SDRAM_ROW_COUNT - 1 };
  unsigned buf[SDRAM_ROW_WORDS];
  printf("Started refresh_test_2\n");
  for (unsigned p = 0; p < 3; p++) {
    pattern = patterns[p];
    for (unsigned w = 0; w < 3; w++) {

      fillMemory(server, pattern);
      for (unsigned bank = 0; bank < SDRAM_BANK_COUNT; bank++) {

        for (unsigned t = 0; t < 8; t++) {
          timer T;
          unsigned time;
          unsigned row = test_rows[t];
          client_read(server, bank, row, 0, SDRAM_ROW_WORDS, buf);
		  T :> time;
		  T when timerafter(time+100000000):> int;
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
    on tile[0]: sdram_client(sdram_c);
  }
  return 0;
}

