#ifndef SDRAM_H_
#define SDRAM_H_

#include "ports.h"
#include "structs_and_enums.h"

/* \fn void sdram_server(streaming chanend c_client[client_count], unsigned client_count, sdram_ports &p_sdram);
 * \brief The actual SDRAM server providing a software interface plus services to access the SDRAM.
 *
 * This provides the software interface to the physical SDRAM. It provides services including:
 *  - Automatic SDRAM refresh,
 *  - Multi-client interface,
 *  - Client prioritisation,
 *  - Client command buffering,
 *  - Automatic multi-line SDRAM access.
 *
 *  \param c_client      This is an ordered array of the streaming channels to the clients. It is in client
 *                       priority order(element 0 being the highest priority).
 *  \param client_count  The number of clients.
 *  \param p_sdram       The structure containing all the SDRAM ports.
 *
 */
void sdram_server(streaming chanend c_client[client_count], const static unsigned client_count, sdram_ports &p_sdram);

/*
 * \fn void sdram_init_state(streaming chanend c_sdram_server, s_sdram_state &s)
 * \brief This is used to initialise the sdram_state that follows the channel to the SDRAM server.
 *
 * This is used to initialise the sdram_state that follows the channel to the SDRAM server. It must only be called
 * once on the s_sdram_state that it is initialising. A client must have only one s_sdram_state that exists for the
 * lift time of the use of the SDRAM.
 *
 * \param c_sdram_server    Chanel to the SDRAM server.
 * \param sdram_state       State structure.
 *
 * \return                  None.
 */
void sdram_init_state(streaming chanend c_sdram_server, s_sdram_state &sdram_state);

/*
 * This is a blocking call that may be used as a select handler. It returns an array
 * to a movable pointer. It will complete when a command has been completed by the
 * server.
 */
#pragma select handler
void sdram_complete(streaming chanend c_sdram_server, s_sdram_state &state, unsigned * movable & buffer);

/* \fn int sdram_write   (streaming chanend c_sdram_server, s_sdram_state &state, unsigned bank, unsigned row, unsigned col, unsigned word_count, unsigned * movable buffer);
 * \brief Request the SDRAM server to perform a write operation.
 *
 *	This function will place a write command into the SDRAM command buffer if the command buffer is not full. This is a
 *	non-blocking call with a return value to indicate the successful issuing of the write to the SDRAM server.
 *
 *  \param c_sdram_server	Chanel to the SDRAM server.
 *  \param state			State structure.
 *  \param bank				The bank number that the write operation should begin from.
 *  \param row				The row number that the write operation should begin from.
 *  \param col				The col number that the write operation should begin from.
 *  \param word_count		The number of words to write to the SDRAM.
 *  \param buffer			A movable pointer from which the data to be written to the SDRAM will be
 *  						read. Note, that the ownership of the pointer will pass to the SDRAM server.
 *  \return 				0 for write command has successfully be added to SDRAM command queue.
 *  \return 				1 for SDRAM command queue is full, write command has not been added.
 *
 */
int sdram_write   (streaming chanend c_sdram_server, s_sdram_state &state, unsigned bank, unsigned row, unsigned col,
    unsigned word_count, unsigned * movable buffer);

/* \fn int sdram_read   (streaming chanend c_sdram_server, s_sdram_state &state, unsigned bank, unsigned row, unsigned col, unsigned word_count, unsigned * movable buffer);
 * \brief Request the SDRAM server to perform a write operation.
 *
 *	This function will place a read command into the SDRAM command buffer if the command buffer is not full. This is a
 *	non-blocking call with a return value to indicate the successful issuing of the read to the SDRAM server.
 *
 *  \param c_sdram_server	Chanel to the SDRAM server.
 *  \param state			State structure.
 *  \param bank				The bank number that the read operation should begin from.
 *  \param row				The row number that the read operation should begin from.
 *  \param col				The col number that the read operation should begin from.
 *  \param word_count		The number of words to read from the SDRAM.
 *  \param buffer			A movable pointer from which the data to be read from the SDRAM will be
 *  						written. Note, that the ownership of the pointer will pass to the SDRAM server.
 *  \return 				0 for read command has successfully be added to SDRAM command queue.
 *  \return 				1 for SDRAM command queue is full, read command has not been added.
 *
 */
int sdram_read    (streaming chanend c_sdram_server, s_sdram_state &state, unsigned bank, unsigned row, unsigned col,
    unsigned word_count, unsigned * movable buffer);


void sdram_shutdown(streaming chanend c_sdram_server);

#endif /* SDRAM_H_ */
