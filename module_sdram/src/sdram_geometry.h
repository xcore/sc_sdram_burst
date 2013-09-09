#ifndef SDRAM_GEOMETRY_H_
#define SDRAM_GEOMETRY_H_

#ifdef __sdram_conf_h_exists__
#include "sdram_conf.h" // This is from the application
#endif

//Define the geometry of the SDRAM
#define SDRAM_COL_BITS (16)
#define SDRAM_ROW_ADDRESS_BITS  12
#define SDRAM_COL_ADDRESS_BITS  8
#define SDRAM_BANK_ADDRESS_BITS 2

#define SDRAM_COL_COUNT (1<<SDRAM_COL_ADDRESS_BITS)
#define SDRAM_ROW_COUNT (1<<SDRAM_ROW_ADDRESS_BITS)
#define SDRAM_BANK_COUNT (1<<SDRAM_BANK_ADDRESS_BITS)

#define SDRAM_ROW_WORDS (SDRAM_COL_COUNT*SDRAM_COL_BITS/32)

#endif /* SDRAM_GEOMETRY_H_ */
