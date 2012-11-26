#include <platform.h>

#include "sdram_geometry_PINOUT_V2_IS42S16400F.h"
#include "sdram_config_PINOUT_V2_IS42S16400F.h"
#include "sdram_ports_PINOUT_V2_IS42S16400F.h"

#include "sdram_control.h"
#include "sdram_conf_derived.h"

#define TIMER_TICKS_PER_US PLATFORM_REFERENCE_MHZ

void sdram_init_PINOUT_V2_IS42S16400F(struct sdram_ports_PINOUT_V2_IS42S16400F &p) {
  timer T;
  int time, t;

  p.ctrl  <: 0;
  p.dq_ah <: 0;

  stop_clock(p.cb);

  T :> time;
  T when timerafter(t + 100 * TIMER_TICKS_PER_US) :> time;

  set_clock_div(p.cb, SDRAM_CLOCK_DIVIDER);
  set_port_clock(p.clk, p.cb);
  set_port_mode_clock(p.clk);

  set_port_clock(p.dq_ah, p.cb);
  set_port_clock(p.ctrl, p.cb);
  set_port_sample_delay(p.dq_ah);

  //set_clock_rise_delay(p.cb, 3);

  start_clock(p.cb);
  p.ctrl  <: 0b1000;
  p.dq_ah <: 0 @ t;
  t+=20;

  T :> time;
  T when timerafter(t + 100 * TIMER_TICKS_PER_US) :> time;

  p.dq_ah <: 0 @ t;
  t+=20;
  partout_timed(p.ctrl,4, CTRL_NOP, t);

  T :> time;
  T when timerafter(t + 50 * TIMER_TICKS_PER_US) :> time;

  p.dq_ah <: 0x04000400 @ t;

  t+=60;

  partout_timed(p.ctrl,8, CTRL_PRECHARGE | (CTRL_NOP<<4), t);
  t+=8;

  for(unsigned i=0;i<128;i++){
    partout_timed(p.ctrl, 8, CTRL_REFRESH | (CTRL_NOP<<4), t);
    t+=8;
  }

  // set mode register
  p.dq_ah @ t<: (SDRAM_MODE_REGISTER << 16)|SDRAM_MODE_REGISTER;
  t+=32;

  //do 16 nops
  t+=16;

  partout_timed(p.ctrl, 8, CTRL_LOAD_MODEREG | (CTRL_NOP<<4), t);

}

#if (SDRAM_CMDS_PER_REFRESH==2)
#define SINGLE_REFRESH (CTRL_REFRESH | (CTRL_NOP<<4))
#elif (SDRAM_CMDS_PER_REFRESH==3)
#define SINGLE_REFRESH (CTRL_REFRESH | (CTRL_NOP<<4)| (CTRL_NOP<<8))
#elif (SDRAM_CMDS_PER_REFRESH==4)
#define SINGLE_REFRESH (CTRL_REFRESH | (CTRL_NOP<<4)| (CTRL_NOP<<8)| (CTRL_NOP<<12))
#endif

#define DOUBLE_REFRESH (SINGLE_REFRESH | (SINGLE_REFRESH<<(SDRAM_CMDS_PER_REFRESH*4)))
#define QUAD_REFRESH (DOUBLE_REFRESH | (DOUBLE_REFRESH<<(SDRAM_CMDS_PER_REFRESH*8)))

static inline void sdram_refresh_PINOUT_V2_IS42S16400F(unsigned ncycles, struct sdram_ports_PINOUT_V2_IS42S16400F &p) {
  unsigned t;
  t = partout_timestamped(p.ctrl, 4, CTRL_NOP);
  t+=8;
  partout_timed(p.ctrl, 16*SDRAM_CMDS_PER_REFRESH, QUAD_REFRESH, t);
  for (unsigned i = 4; i < ncycles; i+=4){
    partout(p.ctrl, 16*SDRAM_CMDS_PER_REFRESH, QUAD_REFRESH);
  }
}

void sdram_block_write_PINOUT_V2_IS42S16400F(unsigned buffer, unsigned word_count, buffered port:32 dq,
    out buffered port:32 ctrl, unsigned term_time);
void sdram_block_read_PINOUT_V2_IS42S16400F(unsigned buffer, unsigned word_count, buffered port:32 dq,
    out buffered port:32 ctrl, unsigned term_time, unsigned st);
void sdram_short_block_read_PINOUT_V2_IS42S16400F(unsigned buffer, unsigned word_count, buffered port:32 dq,
    out buffered port:32 ctrl, unsigned term_time, unsigned st);

/*
 * These numbers are tuned for 50MIPS.
 */
//#define WRITE_SETUP_LATENCY (39)
//#define READ_SETUP_LATENCY (48)

/*
 * These numbers are tuned for 62.5MIPS.
 */
#define WRITE_SETUP_LATENCY (42)
#define WRITE_COL_SETUP_LATENCY (50)
#define READ_SETUP_LATENCY (50)

static unsigned bank_table[SDRAM_BANK_COUNT_PINOUT_V2_IS42S16400F] =
   {(0<<12) | (0<<(12+16) | 1<<(10+16)),
    (1<<12) | (1<<(12+16) | 1<<(10+16)),
    (2<<12) | (2<<(12+16) | 1<<(10+16)),
    (3<<12) | (3<<(12+16) | 1<<(10+16))};

#pragma unsafe arrays
static inline void sdram_write_PINOUT_V2_IS42S16400F(unsigned row, unsigned col, unsigned bank,
    unsigned buffer, unsigned word_count, struct sdram_ports_PINOUT_V2_IS42S16400F &ports) {
  unsigned t;
  unsigned stop_time;
  unsigned jump;
  unsigned rowcol;

 if(SDRAM_EXTERNAL_MEMORY_ACCESSOR)
  if (col)
    col = col - 1;
  else
    col = (SDRAM_COL_COUNT_PINOUT_V2_IS42S16400F - 1);

  rowcol = (col << 16) | row | bank_table[bank];

  //adjust the buffer
  buffer -= 4 * (SDRAM_ROW_WORDS_PINOUT_V2_IS42S16400F - word_count);
  jump = 2 * (SDRAM_ROW_WORDS_PINOUT_V2_IS42S16400F - word_count);

  t = partout_timestamped(ports.ctrl, 4, CTRL_NOP);

  t += WRITE_SETUP_LATENCY;
  stop_time = t + (word_count << 1) + 2;

  ports.dq_ah @ t<: rowcol;

  partout_timed(ports.ctrl, 12, CTRL_ACTIVE | (CTRL_WRITE<<4) | (CTRL_NOP<<8), t);

  sdram_block_write_PINOUT_V2_IS42S16400F(buffer, jump, ports.dq_ah, ports.ctrl, stop_time);


}

#pragma unsafe arrays
static inline void sdram_col_write_PINOUT_V2_IS42S16400F(unsigned bank, unsigned row, unsigned col,
    short data, struct sdram_ports_PINOUT_V2_IS42S16400F &ports) {
  unsigned t;
  unsigned data_stop;
  unsigned rowcol;

 if(SDRAM_EXTERNAL_MEMORY_ACCESSOR)
  if (col)
    col = col - 1;
  else
    col = (SDRAM_COL_COUNT_PINOUT_V2_IS42S16400F - 1);

  rowcol = (col << 16) | row | bank_table[bank];
  data_stop = (0xffff << 16) | data;
  t = partout_timestamped(ports.ctrl, 4, CTRL_NOP);

  t += 50;

  partout_timed(ports.ctrl, 6*4, CTRL_ACTIVE | (CTRL_WRITE<<4) | (CTRL_NOP<<8) | (CTRL_TERM<<12) | (CTRL_PRECHARGE<<16) | (CTRL_NOP<<20), t);
  ports.dq_ah @ t<: rowcol;
  ports.dq_ah <: data_stop;
}

#pragma unsafe arrays
static inline void sdram_read_PINOUT_V2_IS42S16400F(unsigned row, unsigned col, unsigned bank,
    unsigned buffer, unsigned word_count, struct sdram_ports_PINOUT_V2_IS42S16400F &ports) {
  unsigned t, stop_time, jump, rowcol;

 if(SDRAM_EXTERNAL_MEMORY_ACCESSOR)
  if (col)
    col = col - 1;
  else
    col = (SDRAM_COL_COUNT_PINOUT_V2_IS42S16400F - 1);

  rowcol = bank_table[bank] | (col << 16) | row;

  if (word_count < 4) {
    t = partout_timestamped(ports.ctrl, 4, CTRL_NOP);
    t += READ_SETUP_LATENCY;
    stop_time = t + (4 << 1) + 4;

    ports.dq_ah @ t <: rowcol;
    partout_timed(ports.ctrl, 12, CTRL_ACTIVE | (CTRL_READ<<4) | (CTRL_NOP<<8), t);

    sdram_short_block_read_PINOUT_V2_IS42S16400F(buffer, word_count, ports.dq_ah, ports.ctrl, stop_time, t+3);

  } else {
    buffer -= 4 * (0x3f&(SDRAM_ROW_WORDS_PINOUT_V2_IS42S16400F - word_count));
    jump = 2 * (SDRAM_ROW_WORDS_PINOUT_V2_IS42S16400F - word_count);

    t = partout_timestamped(ports.ctrl, 4, CTRL_NOP);
    t+= READ_SETUP_LATENCY;
    stop_time = t + (word_count<<1)+4;

    ports.dq_ah @ t <: rowcol;
    partout_timed(ports.ctrl, 12, CTRL_ACTIVE | (CTRL_READ<<4) | (CTRL_NOP<<8), t);

    sdram_block_read_PINOUT_V2_IS42S16400F(buffer, jump, ports.dq_ah, ports.ctrl, stop_time, t+3);
  }
}

#define CUR_IMPL PINOUT_V2_IS42S16400F
#include "../sdram_server_common.inc"
