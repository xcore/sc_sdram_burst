#ifndef PORTS_H_
#define PORTS_H_
#include <platform.h>

typedef struct {
  //Data and Address muxed along with bank address
  out buffered port:32 dq_ah;

  //Control Signals
  out buffered port:32 cas;
  out buffered port:32 ras;
  out buffered port:8 we;

  //Clock
  out port clk;

  clock cb;

  unsigned cas_latency;
  unsigned row_words;   //derived from row_address_bits and col_bits plus xcore word length

  unsigned col_bits;            //the bits at each coloum address (16)
  unsigned col_address_bits;    //  8
  unsigned row_address_bits;    //  12
  unsigned bank_address_bits;   //  2
  unsigned refresh_ms;
  unsigned refresh_cycles;
  unsigned clock_divider;
} sdram_ports;

#endif /* PORTS_H_ */