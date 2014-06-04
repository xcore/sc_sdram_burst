#ifndef __sdram_geometry_h__
#define __sdram_geometry_h__

#ifdef __sdram_conf_h_exists__
#include "sdram_conf.h" // This is from the application
#endif

//Define the geometry of the SDRAM
#ifndef SDRAM_COL_BITS
#define SDRAM_COL_BITS (16)
#endif

#ifndef SDRAM_ROW_ADDRESS_BITS
#define SDRAM_ROW_ADDRESS_BITS  12
#endif

#ifndef SDRAM_COL_ADDRESS_BITS
#define SDRAM_COL_ADDRESS_BITS  8
#endif

#ifndef SDRAM_BANK_ADDRESS_BITS
#define SDRAM_BANK_ADDRESS_BITS 2
#endif
#define SDRAM_COL_COUNT (1<<SDRAM_COL_ADDRESS_BITS)
#define SDRAM_ROW_COUNT (1<<SDRAM_ROW_ADDRESS_BITS)
#define SDRAM_BANK_COUNT (1<<SDRAM_BANK_ADDRESS_BITS)

#define SDRAM_ROW_WORDS (SDRAM_COL_COUNT/(32/SDRAM_COL_BITS))

#endif
