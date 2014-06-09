#ifndef _sdram_h_
#define _sdram_h_

#include "sdram_geometry.h"
#include "sdram_ports.h"

enum {
  SDRAM_CMD_READ,
  SDRAM_CMD_WRITE
};

typedef struct {
    unsigned bank;
    unsigned row;
    unsigned col;
    unsigned * movable buffer;
    unsigned word_count;
    unsigned cmd;
    unsigned inuse;
} sdram_cmd;

typedef struct {
    sdram_cmd cmd_queue[2];
    unsigned fill;
} sdram_state;


/** \brief The SDRAM server.
 *
 * \param c_client The channel end connecting the application to the server
 * \param ports The structure carrying the SDRAM port details.
 */
void sdram_server(streaming chanend c_client[count], unsigned count, sdram_ports &ports);

/** \brief Function to wait until the SDRAM server is idle and ready to accept another command.
 *
 * \param c_server The channel end connecting the application to the server
 * \param buffer[] The buffer where the data was written or read from in the previous command.
 */
#pragma select handler
void sdram_return(streaming chanend c_server, unsigned * movable &buffer, sdram_state &s);

/** \brief Used to read to an arbitrary size buffer of data from the SDRAM.
 *
 * \param c_server The channel end connecting the application to the server
 * \param bank The bank number in the SDRAM from which the SDRAM data should be read.
 * \param start_row The starting row number in the SDRAM from which the SDRAM data should be read.
 * \param start_col The starting column number in the SDRAM from which the SDRAM data should be read.
 * \param width_words The number of words to be read from the SDRAM.
 * \param buffer[] The buffer where the data will be written to.
 *
 * Note: no buffer overrun checking is performed.
 */
int sdram_read(streaming chanend c_server, unsigned bank, unsigned row,
    unsigned col, unsigned word_count, unsigned * movable buffer, sdram_state &s);

/** \brief Used to write an arbitrary sized buffer of data to the SDRAM.
 *
 * \param c_server The channel end connecting the application to the server.
 * \param bank The bank number in the SDRAM into which the buffer of data should be written.
 * \param start_row The starting row number in the SDRAM into which the buffer of data should be written.
 * \param start_col The starting column number in the SDRAM into which the buffer of data should be written.
 * \param width_words The number of words to be written to the SDRAM.
 * \param buffer[] The buffer where the data will be read from.
 *
 * Note: no buffer overrun checking is performed.
 */
int sdram_write(streaming chanend c_server, unsigned bank, unsigned row,
    unsigned col, unsigned word_count, unsigned * movable buffer, sdram_state &s);

void sdram_init_state(sdram_state &s);

#endif
