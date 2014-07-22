#include <platform.h>
#include <xclib.h>
#include "sdram.h"
#include "control.h"

#define TIMER_TICKS_PER_US 250000000

#define MINIMUM_REFRESH_COUNT 8

static void refresh(unsigned ncycles, sdram_ports &p){
    unsigned t;
    t = partout_timestamped(p.cas, 1, CTRL_CAS_NOP);
    t+=12;
#define REFRESH_MASK 0xeeeeeeee
    p.cas @ t <: REFRESH_MASK;
    p.ras @ t <: REFRESH_MASK;
    for (unsigned i = 8; i < ncycles; i+=8){
      p.cas <: REFRESH_MASK;
      p.ras <: REFRESH_MASK;
    }
}

void sdram_init(sdram_ports &p) {
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

  asm("setclk res[%0], %1"::"r"(p.cb), "r"(XS1_CLK_XCORE));
  set_clock_div(p.cb, p.clock_divider);

  set_port_clock(p.clk, p.cb);
  set_port_mode_clock(p.clk);

  set_port_clock(p.dq_ah, p.cb);
  set_port_clock(p.cas, p.cb);
  set_port_clock(p.ras, p.cb);
  set_port_clock(p.we, p.cb);

  set_pad_delay(p.dq_ah,0);
  set_port_sample_delay(p.dq_ah);

  start_clock(p.cb);

  p.dq_ah @ t <: 0 ;
  t+=200;

  partout(p.cas,1, 0);
  partout(p.we, 1, 0);

  T :> time;
  T when timerafter(time + 100 * TIMER_TICKS_PER_US) :> time;

  p.dq_ah <: 0 @ t;
  sync(p.dq_ah);

  t+=200;
  partout_timed(p.ras,1, CTRL_RAS_NOP, t);
  partout_timed(p.cas,1, CTRL_CAS_NOP, t);
  partout_timed(p.we, 1, CTRL_WE_NOP,  t);

  T :> time;
  T when timerafter(time + 50 * TIMER_TICKS_PER_US) :> time;

  p.dq_ah <: 0x04000400 @ t;
  sync(p.dq_ah);
  t+=600;

  partout_timed(p.ras, 2, CTRL_RAS_PRECHARGE | (CTRL_RAS_NOP<<1), t);
  partout_timed(p.we, 2,  CTRL_WE_PRECHARGE  | (CTRL_WE_NOP<<1),  t);
  t+=16;

  refresh(256, p);

  // set mode register
  unsigned mode_reg;
  if(p.cas_latency == 2){
      mode_reg = 0x00270027;
  } else {
      mode_reg = 0x00370037;
  }

  p.dq_ah  <: mode_reg @ t;
  sync(p.dq_ah);
  t+=256;
  partout_timed(p.cas, 2, CTRL_CAS_LOAD_MODEREG | (CTRL_CAS_NOP<<1), t);
  partout_timed(p.ras, 2, CTRL_RAS_LOAD_MODEREG | (CTRL_RAS_NOP<<1), t);
  partout_timed(p.we, 2,  CTRL_WE_LOAD_MODEREG  | (CTRL_WE_NOP<<1),  t);
  refresh(256, p);

}

void sdram_block_read(unsigned * buffer, sdram_ports &ports, unsigned t0, unsigned word_count);
void sdram_block_write(unsigned * buffer, sdram_ports &ports, unsigned t0, unsigned word_count);

/*
 * These numbers are tuned for 62.5MIPS.
 */
#define WRITE_SETUP_LATENCY (80)
#define READ_SETUP_LATENCY  (70)

#define BANK_SHIFT          (13)

#define SDRAM_EXTERNAL_MEMORY_ACCESSOR 0

static inline void write_impl(unsigned row, unsigned col, unsigned bank,
        unsigned *  buffer, unsigned word_count, sdram_ports &ports) {
    if(SDRAM_EXTERNAL_MEMORY_ACCESSOR){
        if (col)
            col = col - 1;
        else
            col = ((1<<ports.col_address_bits) - 1);
    }

    unsigned rowcol = (col << 16) | row | (bank<<BANK_SHIFT) | bank<<(BANK_SHIFT+16) | 1<<(10+16);

    unsigned t = partout_timestamped(ports.cas, 1, CTRL_WE_NOP);
    t += WRITE_SETUP_LATENCY;

    ports.dq_ah @ t<: rowcol;

    partout_timed(ports.cas, 3, CTRL_CAS_ACTIVE | (CTRL_CAS_WRITE<<1) | (CTRL_CAS_NOP<<2), t);
    partout_timed(ports.ras, 3, CTRL_RAS_ACTIVE | (CTRL_RAS_WRITE<<1) | (CTRL_RAS_NOP<<2), t);
    partout_timed(ports.we , 3, CTRL_WE_ACTIVE  | (CTRL_WE_WRITE<<1)  | (CTRL_WE_NOP<<2), t);

    sdram_block_write(buffer, ports, t, word_count);
}

static inline void read_impl(unsigned row, unsigned col, unsigned bank,
        unsigned *  buffer, unsigned word_count, sdram_ports &ports) {

    if(SDRAM_EXTERNAL_MEMORY_ACCESSOR){
        if (col)
            col = col - 1;
        else
            col = ((1<<ports.col_address_bits) - 1);
    }

    unsigned rowcol = (col << 16) | row | (bank<<BANK_SHIFT) | bank<<(BANK_SHIFT+16) | 1<<(10+16);

    unsigned t = partout_timestamped(ports.ras, 1, CTRL_RAS_NOP);
    t += READ_SETUP_LATENCY;

    ports.dq_ah @ t <: rowcol;
    partout_timed(ports.cas, 3, CTRL_CAS_ACTIVE | (CTRL_CAS_READ<<1) | (CTRL_CAS_NOP<<2), t);
    partout_timed(ports.ras, 3, CTRL_RAS_ACTIVE | (CTRL_RAS_READ<<1) | (CTRL_RAS_NOP<<2), t);
    sdram_block_read( buffer, ports, t, word_count);
}

static void read(unsigned start_row, unsigned start_col,
    unsigned bank, unsigned *  buffer, unsigned word_count,
    sdram_ports &ports) {

  unsigned words_to_end_of_line;
  unsigned current_col = start_col, current_row = start_row;
  unsigned remaining_words = word_count;

  while (1) {
    unsigned col_count = (1<<ports.col_address_bits);
    words_to_end_of_line = (col_count - current_col) / 2;
    if (words_to_end_of_line < remaining_words) {
      read_impl(current_row, current_col, bank, buffer, words_to_end_of_line, ports);
      current_col = 0;
      current_row++;
      buffer += 4 * words_to_end_of_line;//FIXME
      remaining_words -= words_to_end_of_line;
    } else {
      read_impl(current_row, current_col, bank, buffer, remaining_words, ports);
      return;
    }
    if(current_row>>ports.row_address_bits){
      current_row = 0;
      bank = (bank + 1) & ((1<<ports.bank_address_bits)-1);
    }
  }
}

static void write(unsigned start_row, unsigned start_col,
    unsigned bank, unsigned * buffer, unsigned word_count,
    sdram_ports &ports) {

  unsigned words_to_end_of_line;
  unsigned current_col = start_col, current_row = start_row;
  unsigned remaining_words = word_count;

  while (1) {
      unsigned col_count = (1<<ports.col_address_bits);
    words_to_end_of_line = (col_count - current_col) / 2;
    if (words_to_end_of_line < remaining_words) {
      write_impl(current_row, current_col, bank, buffer, words_to_end_of_line, ports);
      current_col = 0;
      current_row++;
      buffer += 4 * words_to_end_of_line;//?
      remaining_words -= words_to_end_of_line;
    } else {
      write_impl(current_row, current_col, bank, buffer, remaining_words, ports);
      return;
    }
    if(current_row>>ports.row_address_bits){
      current_row = 0;
      bank = (bank + 1) & ((1<<ports.bank_address_bits)-1);
    }
  }
}

static int handle_command(e_command cmd, sdram_cmd &c, sdram_ports &ports) {
  switch (cmd) {
    case SDRAM_CMD_READ: {
      read(c.row, c.col, c.bank, c.buffer, c.word_count, ports);
      break;
    }
    case SDRAM_CMD_WRITE: {
      write(c.row, c.col, c.bank, c.buffer, c.word_count, ports);
      break;
    }
    default:
#if (XCC_VERSION_MAJOR >= 12)
      __builtin_unreachable();
#endif
      break;
  }
  return 0;
}

#define XCORE_CLOCKS_PER_MS 100000

#include <stdio.h>
#include <stdlib.h>

#pragma unsafe arrays
void sdram_server(streaming chanend c_client[count], const static unsigned count, sdram_ports &p_sdram){

    timer t;
    unsigned time;
    sdram_cmd cmd_buffer[7][SDRAM_MAX_CMD_BUFFER];
    unsigned head[8] = {0};

    sdram_init(p_sdram);

    unsafe {
        for(unsigned i=0;i<count;i++)
            c_client[i] <: (sdram_cmd * unsafe)&(cmd_buffer[i][0]);
    }

    refresh(p_sdram.refresh_cycles, p_sdram);
    t:> time;

    unsigned clocks_per_refresh_burst = (XCORE_CLOCKS_PER_MS*p_sdram.refresh_ms*MINIMUM_REFRESH_COUNT) / p_sdram.refresh_cycles;

    unsigned bits = 31  - clz(clocks_per_refresh_burst);

    unsafe {
       char c;
       int running = 1;
       while (running) {
          #pragma ordered
          select {
          case t when timerafter(time) :> unsigned handle_time :{
            unsigned diff = handle_time - time;
            unsigned bursts = diff>>bits;
            refresh(MINIMUM_REFRESH_COUNT*bursts, p_sdram);
            time = handle_time + (1<<bits);
            break;
          }

          case c_client[int i] :> c: {
            e_command cmd = (e_command)c;
            if(cmd == SDRAM_CMD_SHUTDOWN){
                running = 0;
                break;
            }
            handle_command(cmd, cmd_buffer[i][head[i]%SDRAM_MAX_CMD_BUFFER], p_sdram);
            head[i]++;
            c_client[i] <: c;
            break;
          }
       }
     }
   }
}
