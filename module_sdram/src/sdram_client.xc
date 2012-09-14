#include "sdram_commands.h"

#if (SDRAM_ENABLE_CMD_BUFFER_READ)
void sdram_buffer_read(chanend server, unsigned bank, unsigned start_row, unsigned start_col,
    unsigned width_words, unsigned buffer[])
{
  int buffer_pointer;
  asm("mov %0, %1" : "=r"(buffer_pointer) : "r"(buffer));
  server <: (char)SDRAM_CMD_BUFFER_READ;
  master {
    server <: bank;
    server <: start_row;
    server <: start_col;
    server <: width_words;
    server <: buffer_pointer;
  }
}
#endif
#if (SDRAM_ENABLE_CMD_BUFFER_WRITE)
void sdram_buffer_write(chanend server, unsigned bank, unsigned start_row, unsigned start_col,
		unsigned width_words, unsigned buffer[])
{
  int buffer_pointer;
  asm("mov %0, %1" : "=r"(buffer_pointer) : "r"(buffer));
  server <: (char)SDRAM_CMD_BUFFER_WRITE;
  master {
    server <: bank;
    server <: start_row;
    server <: start_col;
    server <: width_words;
    server <: buffer_pointer;
  }
}
#endif

#if (SDRAM_ENABLE_CMD_FULL_ROW_READ)
void sdram_full_row_read(chanend server, unsigned bank, unsigned start_row, unsigned buffer[])
{
  int buffer_pointer;
  asm("mov %0, %1" : "=r"(buffer_pointer) : "r"(buffer));
  server <: (char)SDRAM_CMD_FULL_ROW_READ;
  master {
      server <: bank;
      server <: start_row;
      server <: buffer_pointer;
  }
}
#endif

#if (SDRAM_ENABLE_CMD_FULL_ROW_WRITE)
void sdram_full_row_write(chanend server, unsigned bank, unsigned start_row, unsigned buffer[])
{
	int buffer_pointer;
	asm("mov %0, %1" : "=r"(buffer_pointer) : "r"(buffer));
  server <: (char)SDRAM_CMD_FULL_ROW_WRITE;
  master {
    server <: bank;
    server <: start_row;
    server <: buffer_pointer;
  }
}
#endif
#if (SDRAM_ENABLE_CMD_WAIT_UNTIL_IDLE)
void sdram_wait_until_idle(chanend server)
{
  server <: (char)SDRAM_CMD_WAIT_UNTIL_IDLE;
}
#endif
