#include <platform.h>
#include "sdram.h"
#include "sdram_config.h"
#include "sdram_geometry.h"
#include "sdram_control.h"
#include <print.h>

#define TIMER_TICKS_PER_US PLATFORM_REFERENCE_MHZ

void sdram_init_impl(sdram_ports &p){
  timer T;
  int time, t;

  p.cas <: 0;
  p.ras <: 0;
  p.we <: 0;
  p.dq_ah <: 0;

  sync(p.dq_ah);
  stop_clock(p.cb);

  T :> time;
  T when timerafter(time + 100 * TIMER_TICKS_PER_US) :> time;

  set_clock_div(p.cb, SDRAM_CLOCK_DIVIDER);
  set_port_clock(p.clk, p.cb);
  set_port_mode_clock(p.clk);

  set_port_clock(p.dq_ah, p.cb);
  set_port_clock(p.cas, p.cb);
  set_port_clock(p.ras, p.cb);
  set_port_clock(p.we, p.cb);
  set_port_sample_delay(p.dq_ah);

  //set_clock_rise_delay(p.cb, 3);

  start_clock(p.cb);

  p.dq_ah @ t <: 0 ;
  t+=20;

  partout(p.cas,1, 0);
  partout(p.we, 1, 0);

  T :> time;
  T when timerafter(time + 100 * TIMER_TICKS_PER_US) :> time;

  p.dq_ah <: 0 @ t;
  sync(p.dq_ah);

  t+=20;
  partout_timed(p.ras,1, CTRL_RAS_NOP, t);
  partout_timed(p.cas,1, CTRL_CAS_NOP, t);
  partout_timed(p.we, 1, CTRL_WE_NOP,  t);

  T :> time;
  T when timerafter(time + 50 * TIMER_TICKS_PER_US) :> time;

  p.dq_ah <: 0x04000400 @ t;
  sync(p.dq_ah);
  t+=60;

  partout_timed(p.ras, 2, CTRL_RAS_PRECHARGE | (CTRL_RAS_NOP<<1), t);
  partout_timed(p.we, 2,  CTRL_WE_PRECHARGE  | (CTRL_WE_NOP<<1),  t);
  t+=8;

  for(unsigned i=0;i<128;i++){
    partout_timed(p.cas, 2, CTRL_CAS_REFRESH | (CTRL_CAS_NOP<<1), t);
    partout_timed(p.ras, 2, CTRL_RAS_REFRESH | (CTRL_RAS_NOP<<1), t);
    t+=8;
  }

  // set mode register
  p.dq_ah @ t<: (SDRAM_MODE_REGISTER << 16)|SDRAM_MODE_REGISTER;
  sync(p.dq_ah);
  t+=48;

  partout_timed(p.cas, 2, CTRL_CAS_LOAD_MODEREG | (CTRL_CAS_NOP<<1), t);
  partout_timed(p.ras, 2, CTRL_RAS_LOAD_MODEREG | (CTRL_RAS_NOP<<1), t);
  partout_timed(p.we, 2,  CTRL_WE_LOAD_MODEREG  | (CTRL_WE_NOP<<1),  t);
}

void sdram_block_write(unsigned buffer, unsigned word_count, out buffered port:32 dq,
    out buffered port:8 we, out buffered port:32 ras, unsigned term_time);


void sdram_fast_read(unsigned, unsigned, unsigned, out buffered port:32 dq);

#define WRITE_SETUP_LATENCY (38)
#define READ_SETUP_LATENCY (38)

/*
 * BA bits DQ_AH[14:13]
 * AH bits DQ_AH[11:0]
 */

static const unsigned bank_table[SDRAM_BANK_COUNT] =
{
    (0<<(13+16) | 1<<(10+16)) | (0 << 13),
    (1<<(13+16) | 1<<(10+16)) | (1 << 13),
    (2<<(13+16) | 1<<(10+16)) | (2 << 13),
    (3<<(13+16) | 1<<(10+16)) | (3 << 13)
};

#pragma unsafe arrays
void sdram_write_impl(
    sdram_ports &ports,
    unsigned bank,
    unsigned row,
    unsigned col,
    unsigned word_count,
    unsigned buffer){

  unsigned t;
   unsigned stop_time;
   unsigned jump;
   unsigned rowcol = (col << 16) | row | bank_table[bank];

   //adjust the buffer
   buffer -= 4 * (SDRAM_ROW_WORDS - word_count);
   jump = 2 * (SDRAM_ROW_WORDS - word_count);

   t = partout_timestamped(ports.cas, 1, CTRL_WE_NOP);

   t += WRITE_SETUP_LATENCY;
   stop_time = t + (word_count << 1) + 2;

   ports.dq_ah @ t<: rowcol;

   partout_timed(ports.cas, 3, CTRL_CAS_ACTIVE | (CTRL_CAS_WRITE<<1) | (CTRL_CAS_NOP<<2), t);
   partout_timed(ports.ras, 3, CTRL_RAS_ACTIVE | (CTRL_RAS_WRITE<<1) | (CTRL_RAS_NOP<<2), t);
   partout_timed(ports.we , 3, CTRL_WE_ACTIVE  | (CTRL_WE_WRITE<<1)  | (CTRL_WE_NOP<<2), t);

   sdram_block_write(buffer, jump, ports.dq_ah, ports.we, ports.ras, stop_time);
}

#pragma unsafe arrays
void sdram_read_impl(
    sdram_ports &ports,
    unsigned bank,
    unsigned row,
    unsigned col,
    unsigned word_count,
    unsigned buffer){

  unsigned rowcol = bank_table[bank] | (col << 16) | row;
  unsigned t = partout_timestamped(ports.ras, 1, CTRL_RAS_NOP);

  t += READ_SETUP_LATENCY;

  ports.dq_ah @ t <: rowcol;
  partout_timed(ports.cas, 3, CTRL_CAS_ACTIVE | (CTRL_CAS_READ<<1) | (CTRL_CAS_NOP<<2), t);
  partout_timed(ports.ras, 3, CTRL_RAS_ACTIVE | (CTRL_RAS_READ<<1) | (CTRL_RAS_NOP<<2), t);
  partout_timed(ports.we,  2, CTRL_WE_TERM    | (CTRL_WE_NOP<<1),  t +  (word_count<<1)+4);

  sdram_fast_read( buffer- (4 * (SDRAM_ROW_WORDS - word_count)),
      (SDRAM_ROW_WORDS - word_count)*2, t+3, ports.dq_ah);

  partout_timed(ports.ras,  2, CTRL_RAS_PRECHARGE | (CTRL_RAS_NOP<<1),  t +  (word_count<<1)+16);
  partout_timed(ports.we,   2, CTRL_WE_PRECHARGE  | (CTRL_WE_NOP<<1),   t +  (word_count<<1)+16);

}
