#include <platform.h>
#include <stdio.h>
#include "sdram.h"
#include "sdram_slicekit_support.h"

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

static int test(streaming chanend c_server, s_sdram_state &sdram_state, char name[9]){
    unsigned buffer[MAX_BUFFER_WORDS];
    unsigned * movable buffer_pointer = buffer;

    unsigned errors = 0;
    for(unsigned b = 0; b < SDRAM_BANK_COUNT;b++){
        for(unsigned r = 0; r < SDRAM_ROW_COUNT;r++){
            for(unsigned i=0;i<SDRAM_ROW_WORDS;i++)
                buffer_pointer[i] = make_identifier(b, r, i);
            sdram_write(c_server, sdram_state, b, r, 0, SDRAM_ROW_WORDS, move(buffer_pointer));
            sdram_complete(c_server, sdram_state, buffer_pointer);
        }
    }

    for(unsigned b = 0; b < SDRAM_BANK_COUNT;b++){
        for(unsigned r = 0; r < SDRAM_ROW_COUNT;r++){
            for(unsigned i=0;i<SDRAM_ROW_WORDS;i++)
                buffer_pointer[i] = 0;

            sdram_read(c_server, sdram_state, b, r, 0, SDRAM_ROW_WORDS, move(buffer_pointer));
            sdram_complete(c_server, sdram_state, buffer_pointer);

            for(unsigned i=0;i<SDRAM_ROW_WORDS;i++){
                unsigned c = make_identifier(b, r, i);
                if(c != buffer_pointer[i]){
                   unsigned bank, row, word;
                    {bank, row, word} = decode_identifier(buffer_pointer[i]);
                    printf("%d\t%d\t%d\t%d\t%d\t%d\t%08x\t%08x\n", b, r, i, bank, row, word, buffer_pointer[i], make_identifier(b, r, i));
                    //printf("%08x %d\n", buffer_pointer[i]^ c, i);
                    errors++;
                }
            }
        }
    }
    if(errors)
        printf("%s tests: %d errors:%d\n", name, SDRAM_BANK_COUNT*SDRAM_ROW_COUNT*SDRAM_ROW_WORDS, errors);
    return 0;
}
void sdram_client(streaming chanend c_server, char name[9]) {
  set_thread_fast_mode_on();
  s_sdram_state sdram_state;
  sdram_init_state(c_server, sdram_state);
  while (1) test(c_server, sdram_state, name);
}

on tile[SDRAM_A16_SQUARE_TILE]:   sdram_ports square_ports   = SDRAM_A16_SQUARE_PORTS(XS1_CLKBLK_1);
on tile[SDRAM_A16_CIRCLE_TILE]:   sdram_ports circle_ports   = SDRAM_A16_CIRCLE_PORTS(XS1_CLKBLK_2);
on tile[SDRAM_A16_TRIANGLE_TILE]: sdram_ports triangle_ports = SDRAM_A16_TRIANGLE_PORTS(XS1_CLKBLK_3);
on tile[SDRAM_A16_STAR_TILE]:     sdram_ports star_ports     = SDRAM_A16_STAR_PORTS(XS1_CLKBLK_4);

int main() {
    streaming chan sdram_c0[1];
    streaming chan sdram_c1[1];
    streaming chan sdram_c2[1];
    streaming chan sdram_c3[1];
  par {
#if 1
    on tile[SDRAM_A16_SQUARE_TILE]:  sdram_client(sdram_c0[0], "Square  ");
    on tile[SDRAM_A16_SQUARE_TILE]:  sdram_server(sdram_c0, 1, square_ports);
#else
    on tile[1]: par(int i=0;i<2;i++) while(1);
#endif
#if 1
    on tile[SDRAM_A16_CIRCLE_TILE]:  sdram_client(sdram_c1[0], "Circle  ");
    on tile[SDRAM_A16_CIRCLE_TILE]:  sdram_server(sdram_c1, 1, circle_ports);
#else
    on tile[1]: par(int i=0;i<2;i++) while(1);
#endif
    on tile[1]: par(int i=0;i<4;i++) while(1);

#if 1
    on tile[SDRAM_A16_TRIANGLE_TILE]:sdram_client(sdram_c2[0], "Triangle");
    on tile[SDRAM_A16_TRIANGLE_TILE]:sdram_server(sdram_c2, 1, triangle_ports);
#else
    on tile[0]: par(int i=0;i<2;i++) while(1);
#endif
#if 0
    on tile[SDRAM_A16_STAR_TILE]:    sdram_client(sdram_c3[0], "Star    ");
    on tile[SDRAM_A16_STAR_TILE]:    sdram_server(sdram_c3, 1, star_ports);
#else
    on tile[0]: par(int i=0;i<2;i++) while(1);
#endif
    on tile[0]: par(int i=0;i<4;i++)  while(1);
  }
  return 0;
}

