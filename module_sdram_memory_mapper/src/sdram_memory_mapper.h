#ifndef MODULE_MEMORY_MAPPER_H_
#define MODULE_MEMORY_MAPPER_H_
#include <stdint.h>
/** \brief Reads words from the SDRAM server on the end of the channel provided.
*
* \param server The channel end connecting to the SDRAM server.
* \param address The virtual byte address of where the read will begin from.
* \param words The count of words to be read
* \param buffer[]  The buffer where the data will be written to.
*/
void mm_read_words(chanend c_server, unsigned address, unsigned words, unsigned buffer[]);

/** \brief Reads words from the SDRAM server on the end of the channel provided.
*
* \param server The channel end connecting to the SDRAM server.
* \param address The virtual byte address of where the read will begin from.
* \param words The count of words to be read
* \param buffer A pointer to the buffer where the data will be written to.
*/
void mm_read_words_p(chanend c_server, unsigned address, unsigned words, intptr_t buffer);

/**  Writes words to the SDRAM server on the end of the channel provided.
*
* \param server The channel end connecting to the SDRAM server.
* \param address The virtual byte address of where the write will begin from.
* \param words The count of words to be written.
* \param buffer[]  The buffer where the data will be written to.
*/
void mm_write_words(chanend c_server, unsigned address, unsigned words, unsigned buffer[]);

/**  Writes words to the SDRAM server on the end of the channel provided.
*
* \param server The channel end connecting to the SDRAM server.
* \param address The virtual byte address of where the write will begin from.
* \param words The count of words to be written.
* \param buffer  A pointer to the buffer where the data will be written to.
*/
void mm_write_words_p(chanend c_server, unsigned address, unsigned words, intptr_t buffer);

/** Returns when the SDRAM server is in the idle state.
 *
 * \param server The channel end connecting to the SDRAM server.
 * \param buffer[]  The buffer which the last command was performed on.
 */
void mm_wait_until_idle(chanend c_server, unsigned buffer[]);

/** Returns when the SDRAM server is in the idle state.
 *
 * \param server The channel end connecting to the SDRAM server.
 * \param buffer A pointer to the  buffer which the last command was performed on.
 */
void mm_wait_until_idle_p(chanend c_server, intptr_t buffer);

#endif /* MODULE_MEMORY_MAPPER_H_ */
