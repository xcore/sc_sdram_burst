#include <platform.h>
#include <stdio.h>
#include "sdram.h"

#define CORE 1
#define TYPE 0

#if TYPE
on stdcore[CORE]: struct sdram_ports sdram_ports = {
    XS1_PORT_16B, XS1_PORT_1J, XS1_PORT_1I, XS1_PORT_1K, XS1_PORT_1L, XS1_CLKBLK_1 };
#else
on stdcore[CORE]: struct sdram_ports sdram_ports = {
    XS1_PORT_16A, XS1_PORT_1B, XS1_PORT_1G, XS1_PORT_1C, XS1_PORT_1F, XS1_CLKBLK_1 };
#endif

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
  // This reply is from the server to acknowledge the command.
  server :> int;

  // This will get its ack when the server is idle.
  sdram_wait_until_idle(server);
  server :> int;

  // Read the SDRAM into the read_buffer.
  sdram_buffer_read(server, bank, row, col, BUF_WORDS, read_buffer);
  server :> int;

  //Wait until idle, i.e. the sdram had completed reading and hence the data is ready in the buffer.
  sdram_wait_until_idle(server);
  server :> int;

  for(unsigned i=0;i<BUF_WORDS;i++){
    if(read_buffer[i] != i)
      return;
  }
  printf("jurassic park!\n");
}

int main() {
  chan sdram_c;
  par {
    on stdcore[CORE]:sdram_server(sdram_c, sdram_ports);
    on stdcore[CORE]:application(sdram_c);
  }
  return 0;
}

