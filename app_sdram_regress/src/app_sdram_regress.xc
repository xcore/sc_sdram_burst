#include <platform.h>
#include <stdio.h>
#include "sdram.h"

on tile[0]: sdram_ports ports = {
    XS1_PORT_16A, XS1_PORT_1B, XS1_PORT_1G, XS1_PORT_1C, XS1_PORT_1F, XS1_CLKBLK_1 };
/*
 * Plug XA-SK-SDRAM into the STAR slot.
 * Ensure `XMOS LINK` is off. Build and run.
 */
unsigned c = 0xffffffff;

static unsigned super_pattern() {
  crc32(c, 0xff, 0x82F63B78);
  return c;
}

void application(chanend c_server) {
#define BUF_WORDS (SDRAM_ROW_WORDS)

  unsigned read_buffer[BUF_WORDS];
  unsigned write_buffer[BUF_WORDS];

  unsigned * movable read_buffer_pointer = read_buffer;
  unsigned * movable write_buffer_pointer = write_buffer;

  s_sdram_state sdram_state;
  sdram_init_state(sdram_state);

  for(unsigned words = 1; words < SDRAM_ROW_WORDS;words++){
    for(unsigned row = 0; row < SDRAM_ROW_COUNT;row++){
      for(unsigned col = 0; col < SDRAM_COL_COUNT;col+=2){
        for(unsigned bank = 0; bank < SDRAM_BANK_COUNT;bank++){

          for(unsigned i=0;i<words;i++){
            write_buffer_pointer[i] = super_pattern();
            read_buffer_pointer[i] = 0;
          }
          sdram_write(c_server, bank, row, col, words, move(write_buffer_pointer), sdram_state);
          sdram_read(c_server, bank, row, col, words, move(read_buffer_pointer), sdram_state);
          sdram_complete(c_server, write_buffer_pointer, sdram_state);
          sdram_complete(c_server, read_buffer_pointer, sdram_state);

          for(unsigned i=0;i<words;i++){
            if(read_buffer_pointer[i] != write_buffer_pointer[i])
            printf("%08x %08x %08x %d\n", read_buffer_pointer[i], write_buffer_pointer[i],
                 read_buffer_pointer[i] ^ write_buffer_pointer[i], i);
          }
        }
      }
    }
  }
  printf("SDRAM regression complete.\n");
}

int main() {
  chan sdram_c;
  par {
    on tile[0]: sdram_server(ports, sdram_c);
    on tile[0]: application(sdram_c);
    on tile[0]: par(int i=0;i<6;i++) while(1);
  }
  return 0;
}

