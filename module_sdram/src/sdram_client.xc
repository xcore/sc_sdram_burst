#include "sdram_commands.h"
#include "sdram.h"

#if (SDRAM_ENABLE_CMD_BUFFER_READ)
void sdram_buffer_read_p(chanend server, unsigned bank, unsigned start_row, unsigned start_col,
    unsigned width_words, intptr_t buffer) {
  server <: (char)SDRAM_CMD_BUFFER_READ;
  master {
    server <: bank;
    server <: start_row;
    server <: start_col;
    server <: width_words;
    server <: buffer;
  }
}

void sdram_buffer_read(chanend server, unsigned bank, unsigned start_row, unsigned start_col,
    unsigned width_words, unsigned buffer[]) {
  intptr_t buffer_pointer;
  asm("mov %0, %1" : "=r"(buffer_pointer) : "r"(buffer));
  sdram_buffer_read_p( server, bank, start_row, start_col, width_words,  buffer_pointer);
}

#endif

#if (SDRAM_ENABLE_CMD_BUFFER_WRITE)
void sdram_buffer_write_p(chanend server, unsigned bank, unsigned start_row, unsigned start_col,
    unsigned width_words, intptr_t buffer) {
  server <: (char)SDRAM_CMD_BUFFER_WRITE;
  master {
    server <: bank;
    server <: start_row;
    server <: start_col;
    server <: width_words;
    server <: buffer;
  }
}
void sdram_buffer_write(chanend server, unsigned bank, unsigned start_row, unsigned start_col,
    unsigned width_words, unsigned buffer[]){
  intptr_t buffer_pointer;
  asm("mov %0, %1" : "=r"(buffer_pointer) : "r"(buffer));
  sdram_buffer_write_p( server, bank, start_row, start_col, width_words,  buffer_pointer);
}
#endif

#if (SDRAM_ENABLE_CMD_FULL_ROW_READ)
void sdram_full_row_read_p(chanend server, unsigned bank, unsigned start_row,  intptr_t buffer) {
  server <: (char)SDRAM_CMD_FULL_ROW_READ;
  master {
      server <: bank;
      server <: start_row;
      server <: buffer;
  }
}

void sdram_full_row_read(chanend server, unsigned bank, unsigned start_row, unsigned buffer[]) {
  intptr_t buffer_pointer;
  asm("mov %0, %1" : "=r"(buffer_pointer) : "r"(buffer));
  sdram_full_row_read_p(server, bank, start_row,  buffer_pointer);
}
#endif

#if (SDRAM_ENABLE_CMD_FULL_ROW_WRITE)
void sdram_full_row_write_p(chanend server, unsigned bank, unsigned start_row, intptr_t buffer) {
  server <: (char)SDRAM_CMD_FULL_ROW_WRITE;
  master {
    server <: bank;
    server <: start_row;
    server <: buffer;
  }
}

void sdram_full_row_write(chanend server, unsigned bank, unsigned start_row, unsigned buffer[]) {
  intptr_t buffer_pointer;
  asm("mov %0, %1" : "=r"(buffer_pointer) : "r"(buffer));
  sdram_full_row_write_p(server, bank, start_row, buffer_pointer);
}
#endif

#if (SDRAM_ENABLE_CMD_COL_WRITE)
void sdram_col_write(chanend server, unsigned bank, unsigned row, unsigned col, short data) {
  server <: (char)SDRAM_CMD_COL_WRITE;
  master {
	server <: bank;
	server <: row;
	server <: col;
	server <: data;
  }
}
#endif

void sdram_wait_until_idle_p(chanend server, intptr_t buffer) {
  chkct(server, XS1_CT_END);
}
void sdram_wait_until_idle(chanend server, unsigned buffer[]) {
  chkct(server, XS1_CT_END);
}
