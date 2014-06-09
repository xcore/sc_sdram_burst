#include <platform.h>
#include <stdio.h>
#include <stdlib.h>
#include "sdram.h"

on tile[0]: sdram_ports ports = {
    XS1_PORT_16A, XS1_PORT_1B, XS1_PORT_1G, XS1_PORT_1C, XS1_PORT_1F, XS1_CLKBLK_1 };

/*
 * Plug XA-SK-SDRAM into the STAR slot.
 * Ensure `XMOS LINK` is off. Build and run.
 */

void application(streaming chanend c_server) {
#define BUF_WORDS (6)
  unsigned read_buffer[BUF_WORDS];
  unsigned write_buffer[BUF_WORDS];
  unsigned bank = 0, row = 0, col = 0;

  sdram_state s;
  sdram_init_state(s);

  unsigned * movable r=read_buffer;
  unsigned * movable w=write_buffer;

  for(unsigned i=0;i<BUF_WORDS;i++){
    w[i] = i;
    r[i] = 0xff;
  }
  // Write the write_buffer out to SDRAM.
  sdram_write(c_server, bank, row, col, BUF_WORDS, move(w), s);

  //Wait until idle, i.e. the sdram had completed writing.
  sdram_return(c_server, w, s);

  // Read the SDRAM into the read_buffer.
  sdram_read(c_server, bank, row, col, BUF_WORDS, move(r), s);

  //Wait until idle, i.e. the sdram had completed reading and hence the data is ready in the buffer.
  sdram_return(c_server, r, s);

  for(unsigned i=0;i<BUF_WORDS;i++){
    printf("%08x\t%08x\n", w[i], r[i]);
    if(r[i] != i){
      printf("SDRAM demo fail.\n");
      _Exit(1);
      return;
    }
  }
  printf("SDRAM demo complete.\n");
  _Exit(0);
}

int main() {
  streaming chan sdram_c[1];
  par {
    on tile[0]:sdram_server(sdram_c, 1, ports);
    on tile[0]:application(sdram_c[0]);
  }
  return 0;
}

