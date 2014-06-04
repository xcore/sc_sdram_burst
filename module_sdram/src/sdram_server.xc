#include <platform.h>

#include "sdram_geometry.h"
#include "sdram_config.h"
#include "sdram_ports.h"
#include "sdram_control.h"

#define TIMER_TICKS_PER_US PLATFORM_REFERENCE_MHZ

void sdram_init(struct sdram_ports &p) {
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

 // set_clock_rise_delay(p.cb, 3);

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

#if (SDRAM_CMDS_PER_REFRESH==2)
#define CAS_SINGLE_REFRESH (CTRL_CAS_REFRESH | (CTRL_CAS_NOP<<1))
#define RAS_SINGLE_REFRESH (CTRL_RAS_REFRESH | (CTRL_RAS_NOP<<1))

#elif (SDRAM_CMDS_PER_REFRESH==3)
#define CAS_SINGLE_REFRESH (CTRL_CAS_REFRESH | (CTRL_CAS_NOP<<1)| (CTRL_CAS_NOP<<2))
#define RAS_SINGLE_REFRESH (CTRL_RAS_REFRESH | (CTRL_RAS_NOP<<1)| (CTRL_RAS_NOP<<2))

#elif (SDRAM_CMDS_PER_REFRESH==4)
#define CAS_SINGLE_REFRESH (CTRL_CAS_REFRESH | (CTRL_CAS_NOP<<1)| (CTRL_CAS_NOP<<2)| (CTRL_CAS_NOP<<3))
#define RAS_SINGLE_REFRESH (CTRL_RAS_REFRESH | (CTRL_RAS_NOP<<1)| (CTRL_RAS_NOP<<2)| (CTRL_RAS_NOP<<3))

#endif

#define CAS_DOUBLE_REFRESH (CAS_SINGLE_REFRESH | (CAS_SINGLE_REFRESH<<SDRAM_CMDS_PER_REFRESH))
#define CAS_QUAD_REFRESH (CAS_DOUBLE_REFRESH | (CAS_DOUBLE_REFRESH<<(SDRAM_CMDS_PER_REFRESH*2)))
#define CAS_OCTUPLE_REFRESH (CAS_QUAD_REFRESH | (CAS_QUAD_REFRESH<<(SDRAM_CMDS_PER_REFRESH*4)))
#define RAS_DOUBLE_REFRESH (RAS_SINGLE_REFRESH | (RAS_SINGLE_REFRESH<<SDRAM_CMDS_PER_REFRESH))
#define RAS_QUAD_REFRESH (RAS_DOUBLE_REFRESH | (RAS_DOUBLE_REFRESH<<(SDRAM_CMDS_PER_REFRESH*2)))
#define RAS_OCTUPLE_REFRESH (RAS_QUAD_REFRESH | (RAS_QUAD_REFRESH<<(SDRAM_CMDS_PER_REFRESH*4)))

#pragma unsafe arrays
static void sdram_refresh(unsigned ncycles, struct sdram_ports &p){
  unsigned t;
  t = partout_timestamped(p.cas, 1, CTRL_CAS_NOP);
  t+=16;
  partout_timed(p.cas, 32, 0xaaaaaaaa, t);
  partout_timed(p.ras, 32, 0xaaaaaaaa, t);
  for (unsigned i = 8; i < ncycles; i+=8){
    p.cas <: 0xaaaaaaaa;
    p.ras <: 0xaaaaaaaa;
  }
}

void sdram_block_write(unsigned buffer, unsigned word_count, buffered port:32 dq,
    out buffered port:8 we, out buffered port:32 ras, unsigned term_time);
void sdram_block_read(unsigned buffer, unsigned word_count, buffered port:32 dq,
    out buffered port:8 ctrl, unsigned term_time, unsigned st, out buffered port:32 ras);
void sdram_short_block_read(unsigned buffer, unsigned word_count, buffered port:32 dq,
    out buffered port:8 ctrl, unsigned term_time, unsigned st, out buffered port:32 ras);

/*
 * These numbers are tuned for 62.5MIPS.
 */
#define WRITE_SETUP_LATENCY (80)
#define WRITE_COL_SETUP_LATENCY (80)
#define READ_SETUP_LATENCY (80)

static unsigned bank_table[SDRAM_BANK_COUNT] =
   {(0<<13) | (0<<(13+16) | 1<<(10+16)),
    (1<<13) | (1<<(13+16) | 1<<(10+16)),
    (2<<13) | (2<<(13+16) | 1<<(10+16)),
    (3<<13) | (3<<(13+16) | 1<<(10+16))};

#pragma unsafe arrays
static inline void sdram_write(unsigned row, unsigned col, unsigned bank,
    unsigned buffer, unsigned word_count, struct sdram_ports &ports) {
  unsigned t;
  unsigned stop_time;
  unsigned jump;
  unsigned rowcol;

 if(SDRAM_EXTERNAL_MEMORY_ACCESSOR){
  if (col)
    col = col - 1;
  else
    col = (SDRAM_COL_COUNT - 1);
 }
  rowcol = (col << 16) | row | bank_table[bank];

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
static inline void sdram_col_write(unsigned bank, unsigned row, unsigned col,
    short data, struct sdram_ports &ports) {
  unsigned t;
  unsigned data_stop;
  unsigned rowcol;

 if(SDRAM_EXTERNAL_MEMORY_ACCESSOR){
  if (col)
    col = col - 1;
  else
    col = (SDRAM_COL_COUNT - 1);
 }
  rowcol = (col << 16) | row | bank_table[bank];
  data_stop = (0xffff << 16) | data;
  t = partout_timestamped(ports.cas, 1, CTRL_CAS_NOP);

  t += WRITE_COL_SETUP_LATENCY;

  partout_timed(ports.cas, 6, CTRL_CAS_ACTIVE | (CTRL_CAS_WRITE<<1) | (CTRL_CAS_NOP<<2) | (CTRL_CAS_TERM<<3) | (CTRL_CAS_PRECHARGE<<4) | (CTRL_CAS_NOP<<5), t);
  partout_timed(ports.ras, 6, CTRL_RAS_ACTIVE | (CTRL_RAS_WRITE<<1) | (CTRL_RAS_NOP<<2) | (CTRL_RAS_TERM<<3) | (CTRL_RAS_PRECHARGE<<4) | (CTRL_RAS_NOP<<5), t);
  partout_timed(ports.we , 6, CTRL_WE_ACTIVE  | (CTRL_WE_WRITE<<1)  | (CTRL_WE_NOP<<2)  | (CTRL_WE_TERM<<3)  | (CTRL_WE_PRECHARGE<<4)  | (CTRL_WE_NOP<<5) , t);
  ports.dq_ah @ t<: rowcol;
  ports.dq_ah <: data_stop;
}

#pragma unsafe arrays
static inline void sdram_read(unsigned row, unsigned col, unsigned bank,
    unsigned buffer, unsigned word_count, struct sdram_ports &ports) {
  unsigned t, stop_time, jump, rowcol;

 if(SDRAM_EXTERNAL_MEMORY_ACCESSOR){
  if (col)
    col = col - 1;
  else
    col = (SDRAM_COL_COUNT - 1);
 }
  rowcol = bank_table[bank] | (col << 16) | row;

  if (word_count < 4) {
    t = partout_timestamped(ports.ras, 1, CTRL_RAS_NOP);
    t += READ_SETUP_LATENCY;
    stop_time = t + (4 << 1) + 4;

    ports.dq_ah @ t <: rowcol;
    partout_timed(ports.cas, 3, CTRL_CAS_ACTIVE | (CTRL_CAS_READ<<1) | (CTRL_CAS_NOP<<2), t);
    partout_timed(ports.ras, 3, CTRL_RAS_ACTIVE | (CTRL_RAS_READ<<1) | (CTRL_RAS_NOP<<2), t);

    sdram_short_block_read(buffer, word_count, ports.dq_ah, ports.we, stop_time, t+3, ports.ras);

  } else {
    buffer -= 4 * (0x3f&(SDRAM_ROW_WORDS - word_count));
    jump = 2 * (SDRAM_ROW_WORDS - word_count);

    t = partout_timestamped(ports.ras, 1, CTRL_RAS_NOP);
    t+= READ_SETUP_LATENCY;
    stop_time = t + (word_count<<1)+4;

    ports.dq_ah @ t <: rowcol;
    partout_timed(ports.cas, 3, CTRL_CAS_ACTIVE | (CTRL_CAS_READ<<1) | (CTRL_CAS_NOP<<2), t);
    partout_timed(ports.ras, 3, CTRL_RAS_ACTIVE | (CTRL_RAS_READ<<1) | (CTRL_RAS_NOP<<2), t);

    sdram_block_read(buffer, jump, ports.dq_ah, ports.we, stop_time, t+3, ports.ras);
  }
}
#ifndef SDRAM_SERVER_COMMON_H_
#define SDRAM_SERVER_COMMON_H_

#include "sdram_commands.h"
//#include "sdram.h"

#pragma unsafe arrays
static void read_buffer(unsigned start_row, unsigned start_col,
    unsigned bank, unsigned buffer, unsigned word_count,
    struct sdram_ports &ports) {
  unsigned words_to_end_of_line;
  unsigned current_col = start_col, current_row = start_row;
  unsigned remaining_words = word_count;

  while (1) {
    words_to_end_of_line = (SDRAM_COL_COUNT - current_col) / 2;
    if (words_to_end_of_line < remaining_words) {
      sdram_read(current_row, current_col, bank, buffer, words_to_end_of_line, ports);
      current_col = 0;
      current_row++;
      buffer += 4 * words_to_end_of_line;
      remaining_words -= words_to_end_of_line;
    } else {
      sdram_read(current_row, current_col, bank, buffer, remaining_words, ports);
      return;
    }
    if(current_row == SDRAM_ROW_COUNT){
      current_row = 0;
      bank = (bank + 1) % SDRAM_BANK_COUNT;
    }
  }
}

#pragma unsafe arrays
static void write_buffer(unsigned start_row, unsigned start_col,
    unsigned bank, unsigned buffer, unsigned word_count,
    struct sdram_ports &ports) {
  unsigned words_to_end_of_line;
  unsigned current_col = start_col, current_row = start_row;
  unsigned remaining_words = word_count;

  while (1) {
    words_to_end_of_line = (SDRAM_COL_COUNT - current_col) / 2;
    if (words_to_end_of_line < remaining_words) {
      sdram_write(current_row, current_col, bank, buffer, words_to_end_of_line, ports);
      current_col = 0;
      current_row++;
      buffer += 4 * words_to_end_of_line;
      remaining_words -= words_to_end_of_line;
    } else {
      sdram_write(current_row, current_col, bank, buffer, remaining_words, ports);
      return;
    }
    if(current_row == SDRAM_ROW_COUNT){
      current_row = 0;
      bank = (bank + 1) % SDRAM_BANK_COUNT;
    }
  }
}

static int handle_command(char cmd, chanend c_client, struct sdram_ports &ports) {
  switch (cmd) {
#if (SDRAM_ENABLE_CMD_BUFFER_READ==1)
    case SDRAM_CMD_BUFFER_READ: {
      unsigned bank, start_row, start_col, width_words, pointer;
      slave {
        c_client :> bank;
        c_client :> start_row;
        c_client :> start_col;
        c_client :> width_words;
        c_client :> pointer;
      }
      read_buffer(start_row, start_col, bank, pointer, width_words, ports);
      break;
    }
#endif
#if (SDRAM_ENABLE_CMD_BUFFER_WRITE==1)
    case SDRAM_CMD_BUFFER_WRITE: {
      unsigned bank, start_row, start_col, width_words, pointer;
      slave {
        c_client :> bank;
        c_client :> start_row;
        c_client :> start_col;
        c_client :> width_words;
        c_client :> pointer;
      }
      write_buffer(start_row, start_col, bank, pointer, width_words, ports);
      break;
    }
#endif
#if (SDRAM_ENABLE_CMD_FULL_ROW_WRITE==1)
    case SDRAM_CMD_FULL_ROW_WRITE: {
      unsigned bank, start_row, pointer;
      slave {
        c_client :> bank;
        c_client :> start_row;
        c_client :> pointer;
      }
      sdram_write(start_row, 0, bank, pointer, SDRAM_ROW_WORDS, ports);
      break;
    }
#endif
#if (SDRAM_ENABLE_CMD_FULL_ROW_READ==1)
    case SDRAM_CMD_FULL_ROW_READ: {
      unsigned bank, start_row, pointer;
      slave {
        c_client :> bank;
        c_client :> start_row;
        c_client :> pointer;
      }
      sdram_read(start_row, 0, bank, pointer, SDRAM_ROW_WORDS, ports);
      break;
    }
#endif
#if (SDRAM_ENABLE_CMD_COL_WRITE==1)
    case SDRAM_CMD_COL_WRITE: {
      unsigned bank, row, col;
      short data;
      slave {
        c_client :> bank;
        c_client :> row;
        c_client :> col;
        c_client :> data;
      }
      sdram_col_write(bank, row, col, data, ports);
      break;
    }
#endif
    case SDRAM_CMD_SHUTDOWN: {
      return 1;
    }

    default:
#if (XCC_VERSION_MAJOR >= 12)
      __builtin_unreachable();
#endif
      break;
  }
  return 0;
}

#define SDRAM_REF_TICKS_PER_REFRESH ((XCORE_TIMER_TICKS_PER_MS*SDRAM_REFRESH_MS)/SDRAM_REFRESH_CYCLES)
#define XCORE_TIMER_TICKS_PER_MS 100000

void sdram_server(chanend c_client[], struct sdram_ports &ports) {

  sdram_init(ports);
  {
    timer t;
    unsigned time;
    sdram_refresh(SDRAM_REFRESH_CYCLES, ports);
    t:> time;
    time += SDRAM_REF_TICKS_PER_REFRESH * SDRAM_ACCEPTABLE_REFRESH_GAP;
    while (1) {
  #pragma ordered
      select {
      case t when timerafter(time) :> unsigned handle_time :{
        unsigned diff = handle_time - time;
        unsigned refreshes_to_refill = diff / SDRAM_REF_TICKS_PER_REFRESH;
        sdram_refresh(refreshes_to_refill, ports);
        time = handle_time + SDRAM_REF_TICKS_PER_REFRESH * SDRAM_ACCEPTABLE_REFRESH_GAP;
        break;
      }
        case (int i = 0; i < SDRAM_CLIENT_COUNT; i ++) c_client[i] :> char cmd: {
          if(!handle_command(cmd, c_client[i], ports))
            outct(c_client[i], XS1_CT_END);
          else
            return;
          break;
        }
      }
    }
  }
}

#endif /* SDRAM_SERVER_COMMON_H_ */

