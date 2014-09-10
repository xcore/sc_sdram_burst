#include <platform.h>
#include <stdio.h>
#include <stdlib.h>
#include "sdram.h"
#include "sdram_slicekit_support.h"

void application(streaming chanend c_server) {
#define BUF_WORDS (16)
  unsigned read_buffer[BUF_WORDS];
  unsigned write_buffer[BUF_WORDS];
  unsigned * movable read_buffer_pointer = read_buffer;
  unsigned * movable write_buffer_pointer = write_buffer;

  s_sdram_state sdram_state;
  sdram_init_state(c_server, sdram_state);

  for(unsigned i=0;i<BUF_WORDS;i++){
    write_buffer_pointer[i] = i;
    read_buffer_pointer[i] = 0;
  }

  sdram_write(c_server, sdram_state, 0, BUF_WORDS, move(write_buffer_pointer));
  sdram_read (c_server, sdram_state, 0, BUF_WORDS, move( read_buffer_pointer));

  sdram_complete(c_server, sdram_state, write_buffer_pointer);
  sdram_complete(c_server, sdram_state,  read_buffer_pointer);

  for(unsigned i=0;i<BUF_WORDS;i++){
    printf("%08x %d\n", read_buffer_pointer[i], i);
    if(read_buffer_pointer[i] != write_buffer_pointer[i]){
      printf("SDRAM demo fail.\n");
     _Exit(0);
    }
  }
  printf("SDRAM demo complete.\n");
  _Exit(0);
}

on tile[SDRAM_A16_SQUARE_TILE]: sdram_ports ports = SDRAM_A16_SQUARE_PORTS(XS1_CLKBLK_1);
int main() {
  streaming chan sdram_c[1];
  par {
    on tile[SDRAM_A16_SQUARE_TILE]: sdram_server(sdram_c, 1, ports);
    on tile[SDRAM_A16_SQUARE_TILE]: application(sdram_c[0]);
    on tile[SDRAM_A16_SQUARE_TILE]: par(int i=0;i<6;i++) while(1);
  }
  return 0;
}
