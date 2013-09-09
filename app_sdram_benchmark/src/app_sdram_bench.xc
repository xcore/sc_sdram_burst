#include <platform.h>
#include <stdio.h>
#include "sdram.h"
#include <print.h>

on tile[0]: sdram_ports ports = {
    XS1_PORT_16A, XS1_PORT_1B, XS1_PORT_1G, XS1_PORT_1C, XS1_PORT_1F, XS1_CLKBLK_1 };
/*
 * Plug XA-SK-SDRAM into the STAR slot.
 * Ensure `XMOS LINK` is off. Build and run.
 */
#define SLOTS 8

#pragma unsafe arrays
void application(streaming chanend c_server) {
#define BUF_WORDS (240)

  unsigned write_buffer[BUF_WORDS][SLOTS];
  unsigned bank = 0, row = 0, col = 0;

  unsigned * movable write_buffer_pointer[SLOTS] = {
      write_buffer[0],
      write_buffer[1],
      write_buffer[2],
      write_buffer[3],
      write_buffer[4],
      write_buffer[5],
      write_buffer[6],
      write_buffer[7],
  };
  s_sdram_state sdram_state;

  sdram_init_state(sdram_state);

  timer t;
  unsigned time;

  unsigned words_since_timeout = 0;
  unsigned best_words_per_second = 0;

  for(unsigned i=0;i<SLOTS-1;i++)
    sdram_read(c_server, bank, row, col, BUF_WORDS, move(write_buffer_pointer[i]), sdram_state);

  t :> time;
  time -= 50000000;
  while(1){
    select {
      case t when timerafter(time + 100000000) :> time:
        if(best_words_per_second < words_since_timeout){
          best_words_per_second = words_since_timeout;
          printintln(words_since_timeout*4);
        }
        words_since_timeout = 0;
        break;
      case sdram_complete(c_server, write_buffer_pointer[0], sdram_state) :{
        words_since_timeout += BUF_WORDS;
        sdram_read(c_server, bank, row, col, BUF_WORDS, move(write_buffer_pointer[0]), sdram_state);
        break;
      }
    }
  }
}

int main() {
  streaming chan sdram_c;
  par {
    on tile[0]:sdram_server(ports, sdram_c);
    on tile[0]:application(sdram_c);
    on tile[0]: par(int i=0;i<6;i++) while(1);
  }
  return 0;
}
