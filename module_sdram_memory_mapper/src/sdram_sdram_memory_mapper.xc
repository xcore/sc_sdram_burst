#include "sdram.h"

/*
 * Each address is a bit field of
 * | zeros | bank | row | col |
 *
 */

void mm_read_words(chanend server, unsigned address, unsigned words, unsigned buffer[]){
	unsigned bank = address >> (SDRAM_ROW_ADDRESS_BITS + SDRAM_COL_ADDRESS_BITS) & ((1<<SDRAM_BANK_ADDRESS_BITS)-1);
	unsigned row = address >> (SDRAM_COL_ADDRESS_BITS) & ((1<<SDRAM_ROW_ADDRESS_BITS)-1);
	unsigned col = address & ((1<<SDRAM_COL_ADDRESS_BITS)-1);
	sdram_buffer_read(server, bank, row, col, words, buffer);
}

void mm_write_words(chanend server, unsigned address, unsigned words, unsigned buffer[]){
	unsigned bank = address >> (SDRAM_ROW_ADDRESS_BITS + SDRAM_COL_ADDRESS_BITS) & ((1<<SDRAM_BANK_ADDRESS_BITS)-1);
	unsigned row = address >> (SDRAM_COL_ADDRESS_BITS) & ((1<<SDRAM_ROW_ADDRESS_BITS)-1);
	unsigned col = address & ((1<<SDRAM_COL_ADDRESS_BITS)-1);
	sdram_buffer_write(server, bank, row, col, words, buffer);
}

void mm_receive_ack(chanend server){
	server :> int;
}
