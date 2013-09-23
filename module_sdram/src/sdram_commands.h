#ifndef SDRAM_COMMANDS_H_
#define SDRAM_COMMANDS_H_

#include <stdint.h>

#ifdef __sdram_conf_h_exists__
#include "sdram_conf.h" // This is from the application
#endif

typedef struct sdram_cmd {
	unsigned cmd;
	unsigned bank;
	unsigned row;
	unsigned col;
	unsigned words;
	intptr_t buffer;
	short data;
} sdram_cmd;

enum {
  SDRAM_CMD_BUFFER_READ,
  SDRAM_CMD_BUFFER_WRITE,
  SDRAM_CMD_FULL_ROW_READ,
  SDRAM_CMD_FULL_ROW_WRITE,
  SDRAM_CMD_COL_WRITE,
  SDRAM_CMD_SHUTDOWN
};

/*
 * This list is application specific. Remove any of the commands
 * that are unused and the code will be eliminated from the
 * command handler and the SDRAM client.
 */

#ifndef SDRAM_ENABLE_CMD_BUFFER_READ
#define SDRAM_ENABLE_CMD_BUFFER_READ 1
#endif

#ifndef SDRAM_ENABLE_CMD_BUFFER_WRITE
#define SDRAM_ENABLE_CMD_BUFFER_WRITE 1
#endif

#ifndef SDRAM_ENABLE_CMD_FULL_ROW_READ
#define SDRAM_ENABLE_CMD_FULL_ROW_READ 1
#endif

#ifndef SDRAM_ENABLE_CMD_FULL_ROW_WRITE
#define SDRAM_ENABLE_CMD_FULL_ROW_WRITE 1
#endif

#ifndef SDRAM_ENABLE_CMD_COL_WRITE
#define SDRAM_ENABLE_CMD_COL_WRITE 1
#endif

#endif /* SDRAM_COMMANDS_H_ */
