#ifndef SDRAM_PORTS_PINOUT_V0_H_
#define SDRAM_PORTS_PINOUT_V0_H_
#include <xs1.h>

/*
 *  Structure containing the resources required for the SDRAM  ports interface.
 */
typedef struct sdram_ports_PINOUT_V0
{
  //Data and Address muxed
  port dq_ah;

  //Control Signals
  out buffered port:32 cas;
  out buffered port:32 ras;
  out buffered port:8 we;

  //Clock and Clock Enable
  out port cke;
  out port clk;

  //Data Mask
  out buffered port:4 dqm;

  clock cb;
} sdram_ports_PINOUT_V0;
#endif /* SDRAM_PORTS_PINOUT_V0_H_ */
