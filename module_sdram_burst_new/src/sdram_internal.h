#ifndef _sdram_internal_h_
#define _sdram_internal_h_

/* This list is application specific. Remove any of the commands
 * that are unused and the code will be eliminated from the
 * command handler.
 */

#define SDRAM_CMD_REFRESH                 1
#define SDRAM_CMD_WAIT_UNTIL_IDLE         2
#define SDRAM_CMD_BLOCK_WRITE             3
#define SDRAM_CMD_BLOCK_READ              4
#define SDRAM_CMD_READ_LINE_BLOCKING      5
#define SDRAM_CMD_READ_LINE_NONBLOCKING	  6
#define SDRAM_CMD_WRITE_LINE           	  7

/** \brief The function is used to initialize the SDRAM. 
* 
* \param p This the structure containing the sdram port details. 
*
* \note The function initializes the SDRAM as defined in the SDRAM datasheet. 
* \note It takes of setting the SDRAM signal states and clock.    
*
*/
void init(struct sdram_ports &p);

/** \brief The function is used to write to a row in the SDRAM
* 
* \param row The row number to be written
* \param col The column number to start the write
* \param bank The bank in which the row is present
* \param buffer The buffer containing the data to be written
* \param word_count The number of words to be written
* \param ports The structure containing the SDRAM port details
*
* \note The function performs the write in the SDRAM as defined in the SDRAM datasheet. 
* \note It takes of setting the SDRAM signal states and clock required for the write command
*
*/
void write_row(unsigned row, unsigned col, unsigned bank,
    unsigned buffer, unsigned word_count, struct sdram_ports &ports);

/** \brief The function is used to read a row from the SDRAM
* 
* \param row The row number to be read
* \param col The column number to start the read
* \param bank The bank in which the row is present
* \param buffer The buffer to hold the read data
* \param word_count The number of words to be read
* \param ports The structure containing the SDRAM port details
*
* \note The function performs the read in the SDRAM as defined in the SDRAM datasheet. 
* \note It takes of setting the SDRAM signal states and clock required for the read command
*
*/
void read_row(unsigned row, unsigned col, unsigned bank,
    unsigned buffer, unsigned word_count, struct sdram_ports &ports);
	
#endif
