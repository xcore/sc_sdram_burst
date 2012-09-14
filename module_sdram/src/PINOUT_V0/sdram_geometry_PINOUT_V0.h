#ifndef SDRAM_GEOMETRY_PINOUT_V0_H_
#define SDRAM_GEOMETRY_PINOUT_V0_H_

#ifdef __sdram_conf_h_exists__
#include "sdram_conf.h" // This is from the application
#endif

//Define the geometry of the SDRAM
#ifndef SDRAM_COL_BITS_PINOUT_V0
#define SDRAM_COL_BITS_PINOUT_V0 (16)
#endif

#ifndef SDRAM_ROW_ADDRESS_BITS_PINOUT_V0
#define SDRAM_ROW_ADDRESS_BITS_PINOUT_V0  11
#endif

#ifndef SDRAM_COL_ADDRESS_BITS_PINOUT_V0
#define SDRAM_COL_ADDRESS_BITS_PINOUT_V0  8
#endif

#ifndef SDRAM_BANK_ADDRESS_BITS_PINOUT_V0
#define SDRAM_BANK_ADDRESS_BITS_PINOUT_V0 2
#endif

#endif /* SDRAM_GEOMETRY_PINOUT_V0_H_ */