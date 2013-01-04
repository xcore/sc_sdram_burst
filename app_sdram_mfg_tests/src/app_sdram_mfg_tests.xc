#include <platform.h>
#include <print.h>
#include <stdlib.h>
#include "sdram.h"
/*
 * This is the SDRAM manafacture test suite. It requires:
 * WORST_CASE_ACTIVE_CORES - this is the max number of active cores that the sdram
 *                           server must be able to operate during(includes the core
 *                           for the server)
 *
 * Prerequsites
 * The setup should have been tested with app_sdram_regress and app_sdram_benchmark.
 * This test is to confirm pin connections and do basic SDRAM checks not a full
 * correctness/performance test suite.
 *
 * To test:
 * 	- Set the sdram_ports to reflect the pinout under test,
 * 	- Set WORST_CASE_ACTIVE_CORES as described above,
 * 	- Run the app.
 * 	- After approximatly 40 seconds the result should appear.
 */

#define WORST_CASE_ACTIVE_CORES 8

/*
 * Port configuration - This must match the physical pinout of the SDRAM - XCore.
 */
on tile[0]: sdram_ports ports = {
    XS1_PORT_16A, XS1_PORT_1B, XS1_PORT_1G, XS1_PORT_1C, XS1_PORT_1F, XS1_CLKBLK_1 };

/*
 * Below here is the test code - there is no need to edit anything below here.
 */

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

static void refresh_test(chanend server) {
  unsigned pattern;
  unsigned wait_multiplier[3] = { 1, 4, 8};
  unsigned patterns[3] = { 0, 0x55555555, 0xffffffff };
  unsigned buf[SDRAM_ROW_WORDS];
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
          sdram_buffer_read(server, bank, row, 0, SDRAM_ROW_WORDS, buf);
          sdram_wait_until_idle(server, buf);
          for(unsigned word=0;word<SDRAM_ROW_WORDS; word++) {
            unsigned r = buf[word];
            if(r != pattern) {
                printstrln("Failed refresh test.");
                _Exit(1);
            }
          }
        }
      }
    }
  }
}

unsigned makeWord(unsigned bank, unsigned row, unsigned word) {
  return bank + (row << SDRAM_BANK_ADDRESS_BITS) +
		  (word << (SDRAM_BANK_ADDRESS_BITS+SDRAM_ROW_ADDRESS_BITS));
}

{unsigned, unsigned, unsigned} unmakeWord(unsigned word) {
  return {(word) & ((1<<SDRAM_BANK_ADDRESS_BITS)-1),
	  (word>>SDRAM_BANK_ADDRESS_BITS) & ((1<<SDRAM_ROW_ADDRESS_BITS)-1),
	  (word>>(SDRAM_BANK_ADDRESS_BITS+SDRAM_ROW_ADDRESS_BITS))
	  & ((1<<SDRAM_COL_ADDRESS_BITS)-1)};
}

void address_test(chanend server) {
	unsigned max=SDRAM_BANK_COUNT;
	for (unsigned bank = 0; bank < SDRAM_BANK_COUNT; bank++) {
	  for (unsigned row = 0; row < SDRAM_ROW_COUNT; row++) {
		unsigned buffer[SDRAM_ROW_WORDS];
		for (unsigned word = 0; word < SDRAM_ROW_WORDS; word++) {
		  buffer[word] = makeWord(bank, row, word);
		}
		sdram_buffer_write(server, bank, row, 0, SDRAM_ROW_WORDS, buffer);
		sdram_wait_until_idle(server, buffer);
	  }
	}
	if(SDRAM_ROW_COUNT > max)
		max = SDRAM_ROW_COUNT;
	if(SDRAM_COL_COUNT > max)
		max = SDRAM_COL_COUNT;

	for (unsigned v = 0; v < max; v++) {
		unsigned buffer[1];
		unsigned bank = v % SDRAM_BANK_COUNT;
		unsigned row = v % SDRAM_ROW_COUNT;
		unsigned word = v % (SDRAM_ROW_WORDS);

		sdram_buffer_read(server, bank, row, word*2, 1, buffer);
		sdram_wait_until_idle(server, buffer);

		if(makeWord(bank, row, word) != buffer[0]){
		     printstrln("Failed address test.");
		      _Exit(1);
		}
	}
}

void sanity_check(chanend sdram_c) {
#define SANITY_TEST_SIZE 8
#define SANITY_TEST_BANK 1
#define SANITY_TEST_ROW 1
#define SANITY_TEST_COL 0
  unsigned input_buffer[SANITY_TEST_SIZE];
  unsigned output_buffer[SANITY_TEST_SIZE];
  for (unsigned i = 0; i < SANITY_TEST_SIZE; i++) {
    input_buffer[i] = i;
    output_buffer[i] = 0xaabbccdd;
  }
  sdram_buffer_write(sdram_c, SANITY_TEST_BANK, SANITY_TEST_ROW, SANITY_TEST_COL,
      SANITY_TEST_SIZE, input_buffer);
  sdram_wait_until_idle(sdram_c, input_buffer);
  sdram_buffer_read(sdram_c, SANITY_TEST_BANK, SANITY_TEST_ROW, SANITY_TEST_COL,
      SANITY_TEST_SIZE, output_buffer);

  sdram_wait_until_idle(sdram_c, output_buffer);

  for (unsigned i = 0; i < SANITY_TEST_SIZE; i++) {
    if (i != output_buffer[i]) {
      printstrln("Failed sanity check.");
      _Exit(1);
    }
  }
}

static void wait(){
  timer t;
  unsigned w;
  t:> w;
  t when timerafter (w+1000000) :> w;
}

void sdram_client(chanend server) {
  set_thread_fast_mode_on();
  par {
	  {
		  wait();
		  sanity_check(server);
		  address_test(server);
		  refresh_test(server);
		  printstrln("Success");
		  _Exit(0);
	  }
	  par(int i=0;i<WORST_CASE_ACTIVE_CORES-2;i++) while(1);
  }
}

int main() {
  chan sdram_c;
  par {
    on tile[0]:sdram_server(sdram_c, ports);
    on tile[0]:sdram_client(sdram_c);
  }
}
