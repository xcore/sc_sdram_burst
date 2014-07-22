#include <platform.h>
#include <stdio.h>
#include "sdram.h"
#include "sdram_slicekit_support.h"
#include <print.h>

#define SLOTS 8
#define MAX_BUFFER_WORDS 256
#define SDRAM_COL_ADDRESS_BITS 8
#define SDRAM_ROW_ADDRESS_BITS 12
#define SDRAM_BANK_ADDRESS_BITS 2
#define SDRAM_COL_COUNT     256
#define SDRAM_BANK_COUNT    4
#define SDRAM_ROW_COUNT     4096
#define SDRAM_ROW_WORDS     128

#pragma unsafe arrays
void application(streaming chanend c_server, s_sdram_state sdram_state) {
#define BUF_WORDS (240)

    unsigned buffer_0[SDRAM_ROW_WORDS];
    unsigned buffer_1[SDRAM_ROW_WORDS];
    unsigned buffer_2[SDRAM_ROW_WORDS];
    unsigned buffer_3[SDRAM_ROW_WORDS];
  unsigned bank = 0, row = 0, col = 0;

  unsigned * movable buffer_pointer_0 = buffer_0;
  unsigned * movable buffer_pointer_1 = buffer_1;
  unsigned * movable buffer_pointer_2 = buffer_2;
  unsigned * movable buffer_pointer_3 = buffer_3;

  timer t;
  unsigned time;

  unsigned words_since_timeout = 0;
  t :> time;
  sdram_read(c_server, sdram_state, bank, row, col, SDRAM_ROW_WORDS, move(buffer_pointer_0));
  sdram_read(c_server, sdram_state, bank, row, col, SDRAM_ROW_WORDS, move(buffer_pointer_1));
  sdram_read(c_server, sdram_state, bank, row, col, SDRAM_ROW_WORDS, move(buffer_pointer_2));
  sdram_read(c_server, sdram_state, bank, row, col, SDRAM_ROW_WORDS, move(buffer_pointer_3));
  while(1){
    select {
      case t when timerafter(time + 100000000) :> time:
        printintln(words_since_timeout*4++);
        words_since_timeout = 0;
        break;
      case sdram_complete(c_server, sdram_state, buffer_pointer_0):{
        words_since_timeout += SDRAM_ROW_WORDS;
        sdram_read(c_server, sdram_state, bank, row, col, SDRAM_ROW_WORDS, move(buffer_pointer_0));
        break;
      }
    }
  }
}

void sdram_client(streaming chanend c_server) {
  set_thread_fast_mode_on();
  s_sdram_state sdram_state;
  sdram_init_state(c_server, sdram_state);
  application(c_server, sdram_state);
}
on tile[SDRAM_A16_SQUARE_TILE]:   sdram_ports square_ports   = SDRAM_A16_SQUARE_PORTS(XS1_CLKBLK_1);

int main() {
    streaming chan sdram_c0[1];
  par {
        on tile[SDRAM_A16_SQUARE_TILE]:  sdram_client(sdram_c0[0]);
        on tile[SDRAM_A16_SQUARE_TILE]:  sdram_server(sdram_c0, 1, square_ports);
        on tile[0]: par(int i=0;i<6;i++) while(1);
  }
  return 0;
}
