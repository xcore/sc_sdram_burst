#ifndef _sdram_h_
#define _sdram_h_

#include <stdint.h>
#include "sdram_geometry.h"
#include "sdram_ports.h"
#include "sdram_server_PINOUT_V2_IS42S16400F.h"
#include "sdram_server_PINOUT_V1_IS42S16400F.h"
#include "sdram_server_PINOUT_V1_IS42S16160D.h"
#include "sdram_server_PINOUT_V0.h"

/** \brief The SDRAM server thread.
 *
 * \param client The channel end connecting the application to the server
 * \param ports The structure carrying the SDRAM port details.
 */
void sdram_server(chanend client,  struct sdram_ports_PINOUT_V1_IS42S16400F &ports);

#define sdram_server ADD_SUFFIX(sdram_server, SDRAM_DEFAULT_IMPLEMENTATION)

/** \brief Function to wait until the SDRAM server is idle and ready to accept another command.
 *
 * \param server The channel end connecting the application to the server
 * \param buffer[] The buffer where the data was written or read from in the previous command.
 */
#pragma select handler
void sdram_wait_until_idle(chanend server, unsigned buffer[]);

/** \brief Function to wait until the SDRAM server is idle and ready to accept another command.
 *
 * \param server The channel end connecting the application to the server
 * \param buffer A pointer to the buffer where the data was written or read from in the previous command.
 */
void sdram_wait_until_idle_p(chanend server, intptr_t buffer);

/** \brief Used to read to an arbitrary size buffer of data from the SDRAM.
 *
 * \param server The channel end connecting the application to the server
 * \param bank The bank number in the SDRAM from which the SDRAM data should be read.
 * \param start_row The starting row number in the SDRAM from which the SDRAM data should be read.
 * \param start_col The starting column number in the SDRAM from which the SDRAM data should be read.
 * \param width_words The number of words to be read from the SDRAM.
 * \param buffer[] The buffer where the data will be written to.
 *
 * Note: no buffer overrun checking is performed.
 */
void sdram_buffer_read(chanend server, unsigned bank, unsigned start_row,
    unsigned start_col, unsigned width_words, unsigned buffer[]);

/** \brief Used to read to an arbitrary size buffer of data from the SDRAM.
 *
 * \param server The channel end connecting the application to the server
 * \param bank The bank number in the SDRAM from which the SDRAM data should be read.
 * \param start_row The starting row number in the SDRAM from which the SDRAM data should be read.
 * \param start_col The starting column number in the SDRAM from which the SDRAM data should be read.
 * \param width_words The number of words to be read from the SDRAM.
 * \param buffer A pointer to the buffer where the data will be written to.
 *
 * Note: no buffer overrun checking is performed.
 */
void sdram_buffer_read_p(chanend server, unsigned bank, unsigned start_row,
    unsigned start_col, unsigned width_words, intptr_t buffer);

/** \brief Used to write an arbitrary sized buffer of data to the SDRAM.
 *
 * \param server The channel end connecting the application to the server.
 * \param bank The bank number in the SDRAM into which the buffer of data should be written.
 * \param start_row The starting row number in the SDRAM into which the buffer of data should be written.
 * \param start_col The starting column number in the SDRAM into which the buffer of data should be written.
 * \param width_words The number of words to be written to the SDRAM.
 * \param buffer[] The buffer where the data will be read from.
 *
 * Note: no buffer overrun checking is performed.
 */
void sdram_buffer_write(chanend server, unsigned bank, unsigned start_row,
    unsigned start_col, unsigned width_words, unsigned buffer[]);

/** \brief Used to write an arbitrary sized buffer of data to the SDRAM.
 *
 * \param server The channel end connecting the application to the server.
 * \param bank The bank number in the SDRAM into which the buffer of data should be written.
 * \param start_row The starting row number in the SDRAM into which the buffer of data should be written.
 * \param start_col The starting column number in the SDRAM into which the buffer of data should be written.
 * \param width_words The number of words to be written to the SDRAM.
 * \param buffer[] The buffer where the data will be read from.
 *
 * Note: no buffer overrun checking is performed.
 */
void sdram_buffer_write_p(chanend server, unsigned bank, unsigned start_row,
    unsigned start_col, unsigned width_words, intptr_t buffer);

/** \brief Used read a full row of data from a buffer to the SDRAM
 *
 * \param server The channel end connecting the application to the server.
 * \param bank The bank number in the SDRAM from which the SDRAM data should be read.
 * \param row The row number in the SDRAM from which the SDRAM data should be read.
 * \param buffer[] The buffer where the data will be written to.
 *
 * Note: no buffer overrun checking is performed.
 * Full row accesses are always begin aligned to coloumn 0.
 */
void sdram_full_row_read(chanend server, unsigned bank, unsigned row,
    unsigned buffer[]);

/** \brief Used read a full row of data from a buffer to the SDRAM
 *
 * \param server The channel end connecting the application to the server.
 * \param bank The bank number in the SDRAM from which the SDRAM data should be read.
 * \param row The row number in the SDRAM from which the SDRAM data should be read.
 * \param buffer A pointer to the buffer where the data will be written to.
 *
 * Note: no buffer overrun checking is performed.
 * Full row accesses are always begin aligned to coloumn 0.
 */
void sdram_full_row_read_p(chanend server, unsigned bank, unsigned row,
    intptr_t buffer);

/** \brief Used write a full row of data from a buffer to the SDRAM
 *
 * \param server The channel end connecting the application to the server
 * \param bank The bank number in the SDRAM into which the buffer of data should be written
 * \param row The row number in the SDRAM into which the buffer of data should be written.
 * \param buffer[] The buffer where the data will be read from.
 *
 * Note: no buffer overrun checking is performed.
 * Full row accesses are always begin aligned to coloumn 0.
 */
void sdram_full_row_write(chanend server, unsigned bank, unsigned row,
    unsigned buffer[]);

/** \brief Used write a full row of data from a buffer to the SDRAM
 *
 * \param server The channel end connecting the application to the server
 * \param bank The bank number in the SDRAM into which the buffer of data should be written
 * \param row The row number in the SDRAM into which the buffer of data should be written.
 * \param buffer A pointer to the buffer where the data will be read from.
 *
 * Note: no buffer overrun checking is performed.
 * Full row accesses are always begin aligned to coloumn 0.
 */
void sdram_full_row_write_p(chanend server, unsigned bank, unsigned row,
    intptr_t buffer);

/** \brief Used write a single column of data to the SDRAM
 *
 * \param server The channel end connecting the application to the server
 * \param bank The bank number in the SDRAM into which the data should be written
 * \param row The row number in the SDRAM into which the data should be written.
 * \param col The col number in the SDRAM into which the data should be written.
 * \param data A short of data to write to the SDRAM.
 *
 */
void sdram_col_write(chanend server, unsigned bank, unsigned row, unsigned col, short data);
#endif
