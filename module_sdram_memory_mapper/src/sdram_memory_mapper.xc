#include "sdram.h"

/*
 * Each address is a bit field of
 * | zeros | bank | row | col |
 *
 */

void mm_read_words_p(chanend server, unsigned address, unsigned words, intptr_t buffer){
	unsigned bank = address >> (SDRAM_ROW_ADDRESS_BITS + SDRAM_COL_ADDRESS_BITS) & ((1<<SDRAM_BANK_ADDRESS_BITS)-1);
	unsigned row = address >> (SDRAM_COL_ADDRESS_BITS) & ((1<<SDRAM_ROW_ADDRESS_BITS)-1);
	unsigned col = address & ((1<<SDRAM_COL_ADDRESS_BITS)-1);
	sdram_buffer_read_p(server, bank, row, col, words, buffer);
}

void mm_read_words(chanend server, unsigned address, unsigned words, unsigned buffer[]){
	intptr_t buffer_pointer;
	asm("mov %0, %1" : "=r"(buffer_pointer) : "r"(buffer));
	mm_read_words_p(server, address, words, buffer_pointer);
}

void mm_write_words_p(chanend server, unsigned address, unsigned words, intptr_t buffer){
	unsigned bank = address >> (SDRAM_ROW_ADDRESS_BITS + SDRAM_COL_ADDRESS_BITS) & ((1<<SDRAM_BANK_ADDRESS_BITS)-1);
	unsigned row = address >> (SDRAM_COL_ADDRESS_BITS) & ((1<<SDRAM_ROW_ADDRESS_BITS)-1);
	unsigned col = address & ((1<<SDRAM_COL_ADDRESS_BITS)-1);
	sdram_buffer_write_p(server, bank, row, col, words, buffer);
}

void mm_write_words(chanend server, unsigned address, unsigned words, unsigned buffer[]){
	intptr_t buffer_pointer;
	asm("mov %0, %1" : "=r"(buffer_pointer) : "r"(buffer));
	mm_write_words_p(server, address, words, buffer_pointer);
}

void mm_wait_until_idle_p(chanend server, intptr_t buffer){
	sdram_wait_until_idle_p(server, buffer);
}

void mm_wait_until_idle(chanend server, unsigned buffer[]){
	sdram_wait_until_idle(server, buffer);
}
