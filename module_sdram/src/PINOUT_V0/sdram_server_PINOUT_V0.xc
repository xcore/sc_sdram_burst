#include <platform.h>

#include "sdram_geometry_PINOUT_V0.h"
#include "sdram_config_PINOUT_V0.h"
#include "sdram_ports_PINOUT_V0.h"

#include "sdram_control.h"
#include "sdram_conf_derived.h"

#define TIMER_TICKS_PER_US PLATFORM_REFERENCE_MHZ

void sdram_init_PINOUT_V0(struct sdram_ports_PINOUT_V0 &p) {
  timer T;
  int t, time;

  asm("setc res[%0], 0x200F" :: "r"(p.dq_ah));
  asm("settw res[%0], %1" :: "r"(p.dq_ah), "r"(32));

  p.cke <: 0 @ t;

  partout_timed(p.cas, 1, CTRL_CAS_NOP, t+32);
  partout_timed(p.ras, 1, CTRL_RAS_NOP, t+32);
  partout_timed(p.we, 1, CTRL_WE_NOP, t+32);
  stop_clock(p.cb);

  T :> time;
  T when timerafter(t + 100 * TIMER_TICKS_PER_US) :> time;

  set_clock_div(p.cb, 1);
  set_port_clock(p.clk, p.cb);
  set_port_mode_clock(p.clk);

  set_port_clock(p.dq_ah, p.cb);
  set_port_clock(p.cas, p.cb);
  set_port_clock(p.ras, p.cb);
  set_port_clock(p.we, p.cb);
  set_port_clock(p.dqm, p.cb);

  start_clock(p.cb);

  p.dqm <: 0;

  T :> t;

  T when timerafter(t + 50 * TIMER_TICKS_PER_US) :> t;

  p.cke <: 1;

  T when timerafter(t + 100 * TIMER_TICKS_PER_US) :> t;

  p.dq_ah <: 0x04000400 @ t;

  t+=60;

  partout_timed(p.ras, 2, CTRL_RAS_PRECHARGE | (CTRL_RAS_NOP<<1), t);
  partout_timed(p.we, 2,  CTRL_WE_PRECHARGE  | (CTRL_WE_NOP<<1),  t);
  t+=8;

  partout_timed(p.cas, 2, CTRL_CAS_REFRESH | (CTRL_CAS_NOP<<1), t);
  partout_timed(p.ras, 2, CTRL_RAS_REFRESH | (CTRL_RAS_NOP<<1), t);
  t+=8;

  partout_timed(p.cas, 2, CTRL_CAS_REFRESH | (CTRL_CAS_NOP<<1), t);
  partout_timed(p.ras, 2, CTRL_RAS_REFRESH | (CTRL_RAS_NOP<<1), t);
  t+=8;

  partout_timed(p.cas, 2, CTRL_CAS_REFRESH | (CTRL_CAS_NOP<<1), t);
  partout_timed(p.ras, 2, CTRL_RAS_REFRESH | (CTRL_RAS_NOP<<1), t);
  t+=8;

  partout_timed(p.cas, 2, CTRL_CAS_REFRESH | (CTRL_CAS_NOP<<1), t);
  partout_timed(p.ras, 2, CTRL_RAS_REFRESH | (CTRL_RAS_NOP<<1), t);
  t+=8;

  // set mode register
  p.dq_ah @ t<: (SDRAM_MODE_REGISTER << 16)|SDRAM_MODE_REGISTER;
  t+=32;

  //do 16 nops
  t+=16;

  partout_timed(p.cas, 2, CTRL_CAS_LOAD_MODEREG | (CTRL_CAS_NOP<<1), t);
  partout_timed(p.ras, 2, CTRL_RAS_LOAD_MODEREG | (CTRL_RAS_NOP<<1), t);
  partout_timed(p.we, 2,  CTRL_WE_LOAD_MODEREG  | (CTRL_WE_NOP<<1),  t);
}

#define CAS_SINGLE_REFRESH (CTRL_CAS_REFRESH | (CTRL_CAS_NOP<<1)| (CTRL_CAS_NOP<<2)| (CTRL_CAS_NOP<<3))
#define CAS_DOUBLE_REFRESH (CAS_SINGLE_REFRESH | (CAS_SINGLE_REFRESH<<4))
#define CAS_QUAD_REFRESH (CAS_DOUBLE_REFRESH | (CAS_DOUBLE_REFRESH<<8))
#define CAS_OCTUPLE_REFRESH (CAS_QUAD_REFRESH | (CAS_QUAD_REFRESH<<16))

#define RAS_SINGLE_REFRESH (CTRL_RAS_REFRESH | (CTRL_RAS_NOP<<1)| (CTRL_RAS_NOP<<2)| (CTRL_RAS_NOP<<3))
#define RAS_DOUBLE_REFRESH (RAS_SINGLE_REFRESH | (RAS_SINGLE_REFRESH<<4))
#define RAS_QUAD_REFRESH (RAS_DOUBLE_REFRESH | (RAS_DOUBLE_REFRESH<<8))
#define RAS_OCTUPLE_REFRESH (RAS_QUAD_REFRESH | (RAS_QUAD_REFRESH<<16))

static inline void sdram_refresh_PINOUT_V0(unsigned ncycles, struct sdram_ports_PINOUT_V0 &p) {
  unsigned t;
  t = partout_timestamped(p.cas, 1, CTRL_CAS_NOP);
  t+=20;
  for (unsigned i = 0; i < ncycles; i+=8){
	t+=32;
	partout_timed(p.cas, 32, CAS_OCTUPLE_REFRESH, t);
	partout_timed(p.ras, 32, RAS_OCTUPLE_REFRESH, t);
  }
}

void sdram_block_write_PINOUT_V0(unsigned buffer, unsigned word_count, out port dq,
		out buffered port:8 we, out buffered port:32 ras, unsigned term_time);
void sdram_block_read_PINOUT_V0(unsigned buffer, unsigned word_count, out port dq,
    out buffered port:8 ctrl, unsigned term_time, unsigned st, out buffered port:32 ras);
void sdram_short_block_read_PINOUT_V0(unsigned buffer, unsigned word_count, out port dq,
    out buffered port:8 ctrl, unsigned term_time, unsigned st, out buffered port:32 ras);

/*
 * These numbers are tuned for 50MIPS.
 */
#define WRITE_SETUP_LATENCY (50)
#define WRITE_COL_SETUP_LATENCY (50)
#define READ_SETUP_LATENCY (50)

static unsigned bank_table[SDRAM_BANK_COUNT_PINOUT_V0] =
   {(0<<13) | (0<<(13+16) | 1<<(10+16)),
    (1<<13) | (1<<(13+16) | 1<<(10+16)),
    (2<<13) | (2<<(13+16) | 1<<(10+16)),
    (3<<13) | (3<<(13+16) | 1<<(10+16))};

#pragma unsafe arrays
static inline void sdram_write_PINOUT_V0(unsigned row, unsigned col, unsigned bank,
    unsigned buffer, unsigned word_count, struct sdram_ports_PINOUT_V0 &ports) {

	  unsigned t;
	  unsigned stop_time;
	  unsigned jump;
	  unsigned rowcol;

	#ifdef EXTERNAL_MEMORY_ACCESSOR
	  if (col) {
	    col = col - 1;
	  } else {
	    col = (SDRAM_COL_COUNT - 1);
	  }
	#endif

	  rowcol = (col << 16) | row | bank_table[bank];

	  //adjust the buffer
	  buffer -= 4 * (SDRAM_ROW_WORDS_PINOUT_V0 - word_count);
	  jump = 2 * (SDRAM_ROW_WORDS_PINOUT_V0 - word_count);

	  t = partout_timestamped(ports.dqm, 1, 0);

	  t += WRITE_SETUP_LATENCY;
	  stop_time = t + (word_count << 1) + 2;

	  ports.dq_ah @ t<: rowcol;

	  partout_timed(ports.cas, 3, CTRL_CAS_ACTIVE | (CTRL_CAS_WRITE<<1) | (CTRL_CAS_NOP<<2), t);
	  partout_timed(ports.ras, 3, CTRL_RAS_ACTIVE | (CTRL_RAS_WRITE<<1) | (CTRL_RAS_NOP<<2), t);
	  partout_timed(ports.we , 3, CTRL_WE_ACTIVE  | (CTRL_WE_WRITE<<1)  | (CTRL_WE_NOP<<2), t);

	  ports.dqm @ t <: 0x2;

	  sdram_block_write_PINOUT_V0(buffer, jump, ports.dq_ah, ports.we, ports.ras, stop_time);
}

#pragma unsafe arrays
static inline void sdram_col_write_PINOUT_V0(unsigned bank, unsigned row, unsigned col,
    short data, struct sdram_ports_PINOUT_V0 &ports) {
  unsigned t;
  unsigned data_stop;
  unsigned rowcol;

 if(SDRAM_EXTERNAL_MEMORY_ACCESSOR)
  if (col)
    col = col - 1;
  else
    col = (SDRAM_COL_COUNT_PINOUT_V0 - 1);

  rowcol = (col << 16) | row | bank_table[bank];
  data_stop = (data << 16) | 0xffff;
  t = partout_timestamped(ports.cas, 1, CTRL_WE_NOP);

  t += WRITE_COL_SETUP_LATENCY;

  partout_timed(ports.cas, 6, CTRL_CAS_ACTIVE | (CTRL_CAS_WRITE<<1) | (CTRL_CAS_NOP<<2) | (CTRL_CAS_TERM<<3) | (CTRL_CAS_PRECHARGE<<4) | (CTRL_CAS_NOP<<5), t);
  partout_timed(ports.ras, 6, CTRL_RAS_ACTIVE | (CTRL_RAS_WRITE<<1) | (CTRL_RAS_NOP<<2) | (CTRL_RAS_TERM<<3) | (CTRL_RAS_PRECHARGE<<4) | (CTRL_RAS_NOP<<5), t);
  partout_timed(ports.we , 6, CTRL_WE_ACTIVE  | (CTRL_WE_WRITE<<1)  | (CTRL_WE_NOP<<2)  | (CTRL_WE_TERM<<3)  | (CTRL_WE_PRECHARGE<<4)  | (CTRL_WE_NOP<<5) , t);
  ports.dqm @ t <: 0x2;
  ports.dq_ah @ t<: rowcol;
  ports.dq_ah <: data_stop;
}

#pragma unsafe arrays
static inline void sdram_read_PINOUT_V0(unsigned row, unsigned col, unsigned bank,
    unsigned buffer, unsigned word_count, struct sdram_ports_PINOUT_V0 &ports) {

  unsigned t;
  unsigned stop_time;
  unsigned jump;
  unsigned rowcol;

#ifdef EXTERNAL_MEMORY_ACCESSOR
  if (col) {
	col = col - 1;
  } else {
	col = (SDRAM_COL_COUNT - 1);
  }
#endif

  rowcol = bank_table[bank] | (col << 16) | row;

  if (word_count < 4) {

	t = partout_timestamped(ports.dqm, 1, 0);
	t += READ_SETUP_LATENCY;
	stop_time = t + (4 << 1) + 4;

	ports.dq_ah @ t <: rowcol;

	partout_timed(ports.cas, 3, CTRL_CAS_ACTIVE | (CTRL_CAS_READ<<1) | (CTRL_CAS_NOP<<2), t);
	partout_timed(ports.ras, 3, CTRL_RAS_ACTIVE | (CTRL_RAS_READ<<1) | (CTRL_RAS_NOP<<2), t);

	sdram_short_block_read_PINOUT_V0(buffer, word_count, ports.dq_ah, ports.we, stop_time, t+3, ports.ras);

  } else {

	//adjust the buffer
	buffer -= 4 * (0x3f&(SDRAM_ROW_WORDS_PINOUT_V0 - word_count));
	jump = 2 * (SDRAM_ROW_WORDS_PINOUT_V0 - word_count);

	t = partout_timestamped(ports.dqm, 1, 0);
	t+= READ_SETUP_LATENCY;
	stop_time = t + (word_count<<1)+4;

	ports.dq_ah @ t <: rowcol;
	partout_timed(ports.cas, 3, CTRL_CAS_ACTIVE | (CTRL_CAS_READ<<1) | (CTRL_CAS_NOP<<2), t);
	partout_timed(ports.ras, 3, CTRL_RAS_ACTIVE | (CTRL_RAS_READ<<1) | (CTRL_RAS_NOP<<2), t);

	sdram_block_read_PINOUT_V0(buffer, jump, ports.dq_ah, ports.we, stop_time, t+3, ports.ras);

  }
}

#define CUR_IMPL PINOUT_V0
#include "../sdram_server_common.inc"
