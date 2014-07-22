#include <platform.h>
#include <stdio.h>
#include <stdlib.h>
#include "sdram.h"
#include "sdram_slicekit_support.h"

#define VERBOSE_MSG 1
#define MAX_BUFFER_WORDS 256
#define SDRAM_COL_ADDRESS_BITS 8
#define SDRAM_ROW_ADDRESS_BITS 12
#define SDRAM_BANK_ADDRESS_BITS 2
#define SDRAM_COL_COUNT     256
#define SDRAM_BANK_COUNT    4
#define SDRAM_ROW_COUNT     4096
#define SDRAM_ROW_WORDS     128


static unsigned make_identifier(unsigned bank, unsigned row, unsigned word){
    return ((bank) | (row<<(SDRAM_BANK_ADDRESS_BITS)) | (word<<(SDRAM_BANK_ADDRESS_BITS + SDRAM_ROW_ADDRESS_BITS)))<<1;
}

{unsigned, unsigned, unsigned} decode_identifier(unsigned d){
    unsigned bank, row, word;
    d = d>>1;
    bank = d&((1<<SDRAM_BANK_ADDRESS_BITS)-1);
    row = (d>>(SDRAM_BANK_ADDRESS_BITS))&((1<<SDRAM_ROW_ADDRESS_BITS)-1);
    word = (d>>(SDRAM_BANK_ADDRESS_BITS + SDRAM_ROW_ADDRESS_BITS))&((1<<SDRAM_COL_ADDRESS_BITS)-1);
    return {bank, row, word};
}

static int test(streaming chanend c_server, s_sdram_state &sdram_state, int n){
    unsigned buffer[MAX_BUFFER_WORDS];
    unsigned * movable buffer_pointer = buffer;

    unsigned errors = 0;
    for(unsigned b = 0; b < SDRAM_BANK_COUNT;b++){
        for(unsigned r = 0; r < SDRAM_ROW_COUNT;r++){
            for(unsigned i=0;i<SDRAM_ROW_WORDS;i++)
                buffer_pointer[i] = make_identifier(b, r, i);
            int e = sdram_write(c_server, sdram_state, b, r, 0, SDRAM_ROW_WORDS, move(buffer_pointer));
            if(e) printf("error\n");
            sdram_complete(c_server, sdram_state, buffer_pointer);
        }
    }

    for(unsigned b = 0; b < SDRAM_BANK_COUNT;b++){
        for(unsigned r = 0; r < SDRAM_ROW_COUNT;r++){
            for(unsigned i=0;i<SDRAM_ROW_WORDS;i++)
                buffer_pointer[i] = 0;

            sdram_read(c_server, sdram_state, b, r, 0, SDRAM_ROW_WORDS, move(buffer_pointer));
            sdram_complete(c_server, sdram_state, buffer_pointer);

            for(unsigned i=0;i<SDRAM_ROW_WORDS;i++) {
                if(make_identifier(b, r, i) != buffer_pointer[i])
                    errors++;
            }
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

