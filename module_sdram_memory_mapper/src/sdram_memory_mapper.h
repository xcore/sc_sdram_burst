#ifndef MODULE_MEMORY_MAPPER_H_
#define MODULE_MEMORY_MAPPER_H_

/** \brief Reads words from the SDRAM server on the end of the channel provided.
*
* \param server The channel end connecting to the SDRAM server.
* \param address The virtual address of where the read will begin from.
* \param words The count of words to be read
* \param buffer[]  The buffer where the data will be written to.
*/
void mm_read_words(chanend server, unsigned address, unsigned words, unsigned buffer[]);

/**  Writes words to the SDRAM server on the end of the channel provided.
*
* \param server The channel end connecting to the SDRAM server.
* \param address The virtual address of where the write will begin from.
* \param words The count of words to be written.
* \param buffer[]  The buffer where the data will be written to.
*/
void mm_write_words(chanend server, unsigned address, unsigned words, unsigned buffer[]);

/** Receives the ack token from the SDRAM server.
 *
 * \param server The channel end connecting to the SDRAM server.
 */
void mm_receive_ack(chanend server);

/** Returns when the SDRAM server is in the dile state.
 *
 * \param server The channel end connecting to the SDRAM server.
 */
void mm_wait_until_idle(chanend server);

#endif /* MODULE_MEMORY_MAPPER_H_ */
