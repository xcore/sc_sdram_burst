#include "sdram_commands.h"
#include "sdram.h"

#if (SDRAM_ENABLE_CMD_BUFFER_READ)
void sdram_buffer_read_p(chanend c_server, unsigned bank, unsigned start_row, unsigned start_col,
    unsigned width_words, intptr_t buffer) {
	c_server <: (char)SDRAM_CMD_BUFFER_READ;
  master {
	  c_server <: bank;
    c_server <: start_row;
    c_server <: start_col;
    c_server <: width_words;
    c_server <: buffer;
  }
}

void sdram_buffer_read(chanend c_server, unsigned bank, unsigned start_row, unsigned start_col,
    unsigned width_words, unsigned buffer[]) {
  intptr_t buffer_pointer;
  asm("mov %0, %1" : "=r"(buffer_pointer) : "r"(buffer));
  sdram_buffer_read_p( c_server, bank, start_row, start_col, width_words,  buffer_pointer);
}

#endif

#if (SDRAM_ENABLE_CMD_BUFFER_WRITE)
void sdram_buffer_write_p(chanend c_server, unsigned bank, unsigned start_row, unsigned start_col,
    unsigned width_words, intptr_t buffer) {
  c_server <: (char)SDRAM_CMD_BUFFER_WRITE;
  master {
    c_server <: bank;
    c_server <: start_row;
    c_server <: start_col;
    c_server <: width_words;
    c_server <: buffer;
  }
}
void sdram_buffer_write(chanend c_server, unsigned bank, unsigned start_row, unsigned start_col,
    unsigned width_words, unsigned buffer[]){
  intptr_t buffer_pointer;
  asm("mov %0, %1" : "=r"(buffer_pointer) : "r"(buffer));
  sdram_buffer_write_p( c_server, bank, start_row, start_col, width_words,  buffer_pointer);
}
#endif

#if (SDRAM_ENABLE_CMD_FULL_ROW_READ)
void sdram_full_row_read_p(chanend c_server, unsigned bank, unsigned start_row,  intptr_t buffer) {
  c_server <: (char)SDRAM_CMD_FULL_ROW_READ;
  master {
      c_server <: bank;
      c_server <: start_row;
      c_server <: buffer;
  }
}

void sdram_full_row_read(chanend c_server, unsigned bank, unsigned start_row, unsigned buffer[]) {
  intptr_t buffer_pointer;
  asm("mov %0, %1" : "=r"(buffer_pointer) : "r"(buffer));
  sdram_full_row_read_p(c_server, bank, start_row,  buffer_pointer);
}
#endif

#if (SDRAM_ENABLE_CMD_FULL_ROW_WRITE)
void sdram_full_row_write_p(chanend c_server, unsigned bank, unsigned start_row, intptr_t buffer) {
  c_server <: (char)SDRAM_CMD_FULL_ROW_WRITE;
  master {
    c_server <: bank;
    c_server <: start_row;
    c_server <: buffer;
  }
}

void sdram_full_row_write(chanend c_server, unsigned bank, unsigned start_row, unsigned buffer[]) {
  intptr_t buffer_pointer;
  asm("mov %0, %1" : "=r"(buffer_pointer) : "r"(buffer));
  sdram_full_row_write_p(c_server, bank, start_row, buffer_pointer);
}
#endif

#if (SDRAM_ENABLE_CMD_COL_WRITE)
void sdram_col_write(chanend c_server, unsigned bank, unsigned row, unsigned col, short data) {
  c_server <: (char)SDRAM_CMD_COL_WRITE;
  master {
	c_server <: bank;
	c_server <: row;
	c_server <: col;
	c_server <: data;
  }
}
#endif

void sdram_shutdown(chanend c_server){
  c_server <: (char)SDRAM_CMD_SHUTDOWN;
}

void sdram_wait_until_idle_p(chanend c_server, intptr_t buffer) {
  chkct(c_server, XS1_CT_END);
}
void sdram_wait_until_idle(chanend c_server, unsigned buffer[]) {
  chkct(c_server, XS1_CT_END);
}
