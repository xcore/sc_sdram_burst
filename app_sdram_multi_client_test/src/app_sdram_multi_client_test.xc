#include <platform.h>
#include <stdio.h>
#include <stdlib.h>
#include "sdram.h"
#include "sdram_slicekit_support.h"

#define MAX_BUFFER_WORDS 128
#define SDRAM_BANK_COUNT    4
#define SDRAM_ROW_COUNT     4096
#define SDRAM_ROW_WORDS     128

#define TOTAL_MEMORY_WORDS (SDRAM_ROW_WORDS*SDRAM_ROW_COUNT*SDRAM_BANK_COUNT)

static int test(streaming chanend c_server, s_sdram_state &sdram_state, int n){
    unsigned buffer[MAX_BUFFER_WORDS];
    unsigned * movable buffer_pointer = buffer;

    unsigned errors = 0;
    for(unsigned addr = 0; addr < TOTAL_MEMORY_WORDS; addr += SDRAM_ROW_WORDS){
        for(unsigned i=0;i<SDRAM_ROW_WORDS;i++)
            buffer_pointer[i] = addr + i;
        int e = sdram_write(c_server, sdram_state, addr, SDRAM_ROW_WORDS, move(buffer_pointer));
        if(e) printf("error\n");
        sdram_complete(c_server, sdram_state, buffer_pointer);
    }

    for(unsigned addr = 0; addr < TOTAL_MEMORY_WORDS - SDRAM_ROW_WORDS; addr += 1){
        sdram_read(c_server, sdram_state, addr, SDRAM_ROW_WORDS, move(buffer_pointer));
        sdram_complete(c_server, sdram_state, buffer_pointer);

        for(unsigned i=0;i<SDRAM_ROW_WORDS;i++){
            if(buffer_pointer[i] != (addr + i))
                errors++;
        }
    }

    if(errors)
        printf("%d tests: %d errors:%d\n",n,  SDRAM_BANK_COUNT*SDRAM_ROW_COUNT*SDRAM_ROW_WORDS, errors);
    return 0;
}

void sdram_client(streaming chanend c_server, int n) {
  set_thread_fast_mode_on();
  s_sdram_state sdram_state;
  sdram_init_state(c_server, sdram_state);
  test(c_server, sdram_state, n);
}

on tile[SDRAM_A16_SQUARE_TILE]: sdram_ports ports = SDRAM_A16_SQUARE_PORTS(XS1_CLKBLK_1);

int main() {
  streaming chan sdram_c[7];
  par {
      on tile[SDRAM_A16_SQUARE_TILE]:{
          par {
              sdram_client(sdram_c[0], 0);
              sdram_client(sdram_c[1], 1);
              sdram_client(sdram_c[2], 2);
              sdram_client(sdram_c[3], 3);
              sdram_client(sdram_c[4], 4);
              sdram_client(sdram_c[5], 5);
              sdram_client(sdram_c[6], 6);
          }
          printf("Success\n");
      }
      on tile[SDRAM_A16_SQUARE_TILE]:sdram_server(sdram_c, 7, ports);
  }
  return 0;
}

