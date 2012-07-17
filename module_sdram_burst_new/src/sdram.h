#ifndef _sdram_h_
#define _sdram_h_

#include <platform.h>

/* application header */
#include "sdram_configuration.h"

/* ctrl word shorthands */
#define CTRL_NOP_8X (CTRL_NOP_4X | (CTRL_NOP_4X << 16))
#define CTRL_NOP_7X (CTRL_NOP_4X | (CTRL_NOP_3X << 16))
#define CTRL_NOP_4X (CTRL_NOP_2X | (CTRL_NOP_2X << 8))
#define CTRL_NOP_3X (CTRL_NOP | (CTRL_NOP_2X << 4))
#define CTRL_NOP_2X (CTRL_NOP | (CTRL_NOP << 4))

#ifndef TIMER_TICKS_PER_US
#define TIMER_TICKS_PER_US 100
#endif

/** Structure containing the resources required for the SDRAM  ports interface.
*
* It consists of 32 bit address line, Control lines, Clock line,
* Clock enable line, Data lines
* The variable of this structure type should be configured in the application project
* and passed as a parameter to the thread sdram_server
*
*/
struct sdram_ports
{
  port dq;
  out buffered port:32 a0;
  out buffered port:32 ctrl;
  out port clk;
  out buffered port:4 dqm0;
  out buffered port:4 dqm1;
  out port cke;
  clock cb;
};
/** \brief The SDRAM thread. The thread is invoked in the lcd_sdram_manager
* 
* \param client_hip The channel end number
* \param ports The structure carrying the SDRAM port details
*/
void sdram_server(chanend client_hip, struct sdram_ports &ports);
/** \brief The function to write a block of SDRAM data
* 
* \param server The channel end number
* \param bank The bank number in the SDRAM in which the block of data should be written
* \param start_row The starting row number which is to be written in the SDRAM
* \param start_col The starting column number from which the data should be written
* \param num_rows The number of rows to be written
* \param block_width_words The number of words to be written in the block
* \param buffer[] The buffer containing the data to be written to the SDRAM
*
* \note The block write can be done starting from any row number and with any offset for the column in each row. It is possible to update partial rows
*/
void sdram_block_write(chanend server, int bank, int start_row, int start_col, int num_rows,
		int block_width_words, const unsigned buffer[]);
/** \brief The function to read a block of SDRAM data
* 
* \param server The channel end number
* \param bank The bank number in the SDRAM from which the block of data should be read
* \param start_row The starting row number which is to be read from the SDRAM
* \param start_col The starting column number from which the data should be read
* \param num_rows The number of rows to be read
* \param block_width_words The number of words to be read from the block
* \param buffer[] The buffer to hold the read data from SDRAM
*
* \note The block read can be done starting from any row number and with any offset for the column in each row. It is possible to read partial rows
*/
void sdram_block_read(chanend server, int bank, int start_row, int start_col, int num_rows,
		int block_width_words, unsigned buffer[]);

void sdram_wait_until_idle(chanend server);
/** \brief The function is used to read a line of data from the SDRAM. 
* 
* \param server The channel end number
* \param bank The bank number in the SDRAM from which the line of data should be read
* \param start_row The starting row number which is to be read from the SDRAM
* \param start_col The starting column number from which the data should be read
* \param width_words The number of words to be read from the block. This parameter indicates the length of the line to be read
* \param buffer_pointer The pointer to the buffer which can hold the read data
*
* \note The line read can be done starting from any row number and with any offset for the column in each row. It is possible to read partial rows inorder to obtain a line of data
* \note This is blocking function where the application has to wait till the SDRAM read is over
*/
void sdram_line_read_blocking(chanend server, int bank, int start_row, int start_col,
		int width_words, unsigned buffer_pointer);
/** \brief The function is used to read a line of data from the SDRAM. 
* 
* \param server The channel end number
* \param bank The bank number in the SDRAM from which the line of data should be read
* \param start_row The starting row number which is to be read from the SDRAM
* \param start_col The starting column number from which the data should be read
* \param width_words The number of words to be read from the block. This parameter indicates the length of the line to be read
* \param buffer_pointer The pointer to the buffer which can hold the read data
*
* \note The line read can be done starting from any row number and with any offset for the column in each row. It is possible to read partial rows inorder to obtain a line of data
* \note This is a non-blocking function where the application can submit request to SDRAM and carry on which someother actions. Once the SDRAM has read the data the application can use it
*/
void sdram_line_read_nonblocking(chanend server, int bank, int start_row, int start_col,
		int width_words, unsigned buffer_pointer);
/** \brief The function to write a line of data to the SDRAM
* 
* \param server The channel end number
* \param bank The bank number in the SDRAM in which the line of data should be written
* \param start_row The starting row number which is to be written in the SDRAM
* \param start_col The starting column number from which the data should be written
* \param width_words The number of words to be written in the line. This parameter indicates the length of the line to be written
* \param buffer_pointer The pointer to the buffer which holds the data to be written
*
* \note The line write can be done starting from any row number and with any offset for the column in each row. It is possible to update partial rows
*/
void sdram_line_write(chanend server, int bank, int start_row, int start_col,
		int width_words, unsigned buffer_pointer);

#endif
