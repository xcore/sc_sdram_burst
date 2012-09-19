#ifndef MODULE_MEMORY_MAPPER_H_
#define MODULE_MEMORY_MAPPER_H_
/**
 *
 */
void mm_read_words(chanend server, unsigned address, unsigned words, unsigned buffer[]);

/**
 *
 */
void mm_write_words(chanend server, unsigned address, unsigned words, unsigned buffer[]);

/**
 *
 */
void mm_receive_ack(chanend server);

#endif /* MODULE_MEMORY_MAPPER_H_ */
