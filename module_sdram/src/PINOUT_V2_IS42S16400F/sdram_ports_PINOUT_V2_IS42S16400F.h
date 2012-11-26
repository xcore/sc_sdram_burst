#ifndef SDRAM_PORTS_PINOUT_V2_IS42S16400F_H_
#define SDRAM_PORTS_PINOUT_V2_IS42S16400F_H_
#include <xs1.h>

/*
 *  Structure containing the resources required for the SDRAM  ports interface.
 */
typedef struct sdram_ports_PINOUT_V2_IS42S16400F
{
  //Data and Address muxed along with bank address
  buffered port:32 dq_ah;

  //Control Signals
  out buffered port:32 ctrl;

  //Clock
  out port clk;

  clock cb;
} sdram_ports_PINOUT_V2_IS42S16400F;
#endif /* SDRAM_PORTS_PINOUT_V2_IS42S16400F_H_ */
