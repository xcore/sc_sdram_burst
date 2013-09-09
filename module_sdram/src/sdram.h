#ifndef SDRAM_H_
#define SDRAM_H_

#include <xs1.h>
#include "sdram_geometry.h"
#define SDRAM_USE_HI_PRIORITY_CHANNEL 0

typedef struct {
  unsigned hi_priority_head;
  unsigned hi_priority_pending_cmds;

  unsigned normal_priority_head;
  unsigned normal_pending_cmds;
} s_sdram_state;

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
} sdram_ports;

void sdram_server(
    sdram_ports &p_sdram,
    streaming chanend c_normal_priority
#if SDRAM_USE_HI_PRIORITY_CHANNEL
    , streaming chanend c_hi_priority
#endif
);

#pragma select handler
void sdram_complete(streaming chanend c, unsigned * movable & buffer, s_sdram_state &state);

void sdram_write(streaming chanend c_sdram_server, unsigned bank, unsigned row, unsigned col,
    unsigned words, unsigned * movable buffer, s_sdram_state &state);

void sdram_read(streaming chanend c_sdram_server, unsigned bank, unsigned row, unsigned col,
    unsigned words, unsigned * movable buffer, s_sdram_state &state);

void sdram_shutdown(streaming chanend c);

void sdram_init_state(s_sdram_state &s);

#endif /* SDRAM_H_ */
