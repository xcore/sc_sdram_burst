#ifndef __SDRAM_PORTS_H__
#define __SDRAM_PORTS_H__

#include "sdram_conf_derived.h"
#include "sdram_ports_PINOUT_V2_IS42S16400F.h"
#include "sdram_ports_PINOUT_V1_IS42S16400F.h"
#include "sdram_ports_PINOUT_V1_IS42S16160D.h"
#include "sdram_ports_PINOUT_V0.h"

#define sdram_ports ADD_SUFFIX(sdram_ports, SDRAM_DEFAULT_IMPLEMENTATION)

#endif // __SDRAM_PORTS_H__
