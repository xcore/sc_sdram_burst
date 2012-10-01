#include <platform.h>
#include <stdio.h>
#include "sdram.h"

sdram_ports ports = {
    XS1_PORT_16A, XS1_PORT_1B, XS1_PORT_1G, XS1_PORT_1C, XS1_PORT_1F, XS1_CLKBLK_1 };

void application(chanend server) {
#define BUF_WORDS (10)
  unsigned read_buffer[BUF_WORDS];
  unsigned write_buffer[BUF_WORDS];
  unsigned bank = 0, row = 0, col = 0;

  for(unsigned i=0;i<BUF_WORDS;i++){
    write_buffer[i] = i;
    read_buffer[i] = 0;
  }

  // Write the write_buffer out to SDRAM.
  sdram_buffer_write(server, bank, row, col, BUF_WORDS, write_buffer);

  //Wait until idle, i.e. the sdram had completed writing.
  sdram_wait_until_idle(server, write_buffer);

  // Read the SDRAM into the read_buffer.
  sdram_buffer_read(server, bank, row, col, BUF_WORDS, read_buffer);

  //Wait until idle, i.e. the sdram had completed reading and hence the data is ready in the buffer.
  sdram_wait_until_idle(server, read_buffer);

  for(unsigned i=0;i<BUF_WORDS;i++){
    if(read_buffer[i] != i){
      printf("SDRAM demo fail.\n");
      return;
    }
  }
  printf("SDRAM demo complete.\n");
}

int main() {
  chan sdram_c;
  par {
    sdram_server(sdram_c, ports);
    application(sdram_c);
  }
  return 0;
}

