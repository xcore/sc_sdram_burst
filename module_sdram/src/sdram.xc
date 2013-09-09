#include <platform.h>
#include <stdint.h>
#include <xs1.h>
#include "sdram.h"
#include "sdram_config.h"
#include "sdram_geometry.h"
#include "sdram_control.h"

#define CHAN_BUFFER_SIZE 8

typedef struct {
  unsigned * unsafe pointer;
  unsigned * unsafe base;
  unsigned size;
} unwrapped_moveable;

typedef struct {
  unsigned command;
  unsigned bank;
  unsigned row;
  unsigned col;
  unsigned words_to_write;

  //This represents a movable pointer
  unwrapped_moveable buffer;
} cmd_struct;

enum {
  cmd_read,
  cmd_write,
  cmd_shutdown
} sdram_cmd;

cmd_struct normal_priority_cmd_data[CHAN_BUFFER_SIZE];

#ifdef SDRAM_USE_HI_PRIORITY_CHANNEL
cmd_struct hi_priority_cmd_data[CHAN_BUFFER_SIZE];
#endif

void sdram_init_impl(sdram_ports &p_sdram);
void sdram_write_impl(sdram_ports &p_sdram, unsigned bank,
    unsigned row, unsigned col, unsigned words, unsigned buffer);

void sdram_read_impl(sdram_ports &p_sdram, unsigned bank,
    unsigned row, unsigned col, unsigned words, unsigned buffer);

#pragma unsafe arrays
void sdram_init_state(s_sdram_state &s){
  s.hi_priority_head = 0;
  s.hi_priority_pending_cmds = 0;
  s.normal_pending_cmds = 0;
  s.normal_priority_head = 0;
}

#pragma unsafe arrays
void sdram_write(chanend c, unsigned bank, unsigned row, unsigned col,
    unsigned words, unsigned * movable buffer, s_sdram_state &state){
  unsigned index = state.normal_priority_head;

  cmd_struct * cmd_object;

  if(state.normal_pending_cmds == CHAN_BUFFER_SIZE){
    //must wait for an ack
    inuchar(c);
    state.normal_pending_cmds--;
  }
  unsafe {
    cmd_struct * unsafe tmp;
    asm("ldaw %0, dp[normal_priority_cmd_data]": "=r"(tmp));
    cmd_object = (cmd_struct *)&tmp[index];
    (*cmd_object).buffer = * (unwrapped_moveable*unsafe) &buffer;
  }

  cmd_object->command = cmd_write;
  cmd_object->bank = bank;
  cmd_object->row = row;
  cmd_object->col = col;
  cmd_object->words_to_write = words;

  if(state.normal_pending_cmds != CHAN_BUFFER_SIZE)
      outuchar(c, index);

  index++;
  if(index == CHAN_BUFFER_SIZE)
    index = 0;
  state.normal_priority_head = index;
  state.normal_pending_cmds++;
}
#pragma unsafe arrays
void sdram_read(chanend c,
    unsigned bank,
    unsigned row,
    unsigned col,
    unsigned words,
    unsigned * movable buffer, s_sdram_state &state){
  unsigned index = state.normal_priority_head;
  cmd_struct * cmd_object;

  if(state.normal_pending_cmds == CHAN_BUFFER_SIZE){
    //must wait for an ack
    inuchar(c);
    state.normal_pending_cmds--;
  }
  unsafe {
    cmd_struct * unsafe tmp;
    asm("ldaw %0, dp[normal_priority_cmd_data]": "=r"(tmp));
    cmd_object = (cmd_struct *)&tmp[index];
    (*cmd_object).buffer = * (unwrapped_moveable*unsafe) &buffer;
  }

  cmd_object->command = cmd_read;
  cmd_object->bank = bank;
  cmd_object->row = row;
  cmd_object->col = col;
  cmd_object->words_to_write = words;

  outuchar(c, index);

  index++;
  if(index == CHAN_BUFFER_SIZE)
    index = 0;
  state.normal_priority_head = index;
  state.normal_pending_cmds++;
}


#pragma unsafe arrays
void sdram_complete(chanend c, unsigned * movable & buffer, s_sdram_state &state){
  unsigned index = inuchar(c);
  cmd_struct * cmd_object;
  unsafe {
     cmd_struct * unsafe tmp;
     asm("ldaw %0, dp[normal_priority_cmd_data]": "=r"(tmp));
     cmd_object = (cmd_struct *)&tmp[index];
     * (unwrapped_moveable*unsafe) &buffer = (*cmd_object).buffer;
   }
  state.normal_pending_cmds--;
}

void sdram_shutdown(chanend c){

}

#pragma unsafe arrays
static void sdram_refresh(unsigned count, sdram_ports &p){
  unsigned t;
  t = partout_timestamped(p.cas, 1, CTRL_CAS_NOP);
  t+=8;
  partout_timed(p.cas, 32, 0xaaaaaaaa, t);
  partout_timed(p.ras, 32, 0xaaaaaaaa, t);
  for (unsigned i = 8; i < count; i+=8){
    p.cas <: 0xaaaaaaaa;
    p.ras <: 0xaaaaaaaa;
  }
}


#pragma unsafe arrays
static void read(sdram_ports &p_sdram,
    unsigned bank,
    unsigned start_row,
    unsigned start_col,
    unsigned word_count,
    unsigned buffer){
  unsigned words_to_end_of_line;
  unsigned current_col = start_col, current_row = start_row;
  unsigned remaining_words = word_count;

  while (1) {
    words_to_end_of_line = (SDRAM_COL_COUNT - current_col) / 2;
    if (words_to_end_of_line < remaining_words) {
      sdram_read_impl(p_sdram, bank, current_row, current_col, words_to_end_of_line, buffer);
      current_col = 0;
      current_row++;
      buffer += 4 * words_to_end_of_line;
      remaining_words -= words_to_end_of_line;
    } else {
      sdram_read_impl(p_sdram, bank, current_row, current_col, remaining_words, buffer);
      return;
    }
    if(current_row == SDRAM_ROW_COUNT){
      current_row = 0;
      bank = (bank + 1) % SDRAM_BANK_COUNT;
    }
  }
}
#pragma unsafe arrays
static void write(sdram_ports &p_sdram,
    unsigned bank,
    unsigned start_row,
    unsigned start_col,
    unsigned word_count,
    unsigned buffer){

  unsigned words_to_end_of_line;
  unsigned current_col = start_col, current_row = start_row;
  unsigned remaining_words = word_count;

  while (1) {
    words_to_end_of_line = (SDRAM_COL_COUNT - current_col) / 2;
    if (words_to_end_of_line < remaining_words) {
      sdram_write_impl(p_sdram, bank, current_row, current_col, words_to_end_of_line, buffer);
      current_col = 0;
      current_row++;
      buffer += 4 * words_to_end_of_line;
      remaining_words -= words_to_end_of_line;
    } else {
      sdram_write_impl(p_sdram, bank, current_row, current_col, remaining_words, buffer);
      return;
    }
    if(current_row == SDRAM_ROW_COUNT){
      current_row = 0;
      bank = (bank + 1) % SDRAM_BANK_COUNT;
    }
  }
}

#pragma unsafe arrays
static int handle_cmd(sdram_ports &p_sdram, unsigned i, cmd_struct cmd_data[CHAN_BUFFER_SIZE]){
  unsigned cmd = cmd_data[i].command;
  switch(cmd){
  case cmd_read:{
    read(p_sdram, cmd_data[i].bank, cmd_data[i].row, cmd_data[i].col,
        cmd_data[i].words_to_write, (unsigned)cmd_data[i].buffer.base);
    return 1;
  }
  case cmd_write:{
    write(p_sdram, cmd_data[i].bank, cmd_data[i].row, cmd_data[i].col,
        cmd_data[i].words_to_write, (unsigned)cmd_data[i].buffer.base);
    return 1;
  }
  case cmd_shutdown:{
    return 0;
  }
  default :{
#if (XCC_VERSION_MAJOR >= 12)
      __builtin_unreachable();
#endif
      return 0;
  }
  }
}

#define XCORE_TIMER_TICKS_PER_MS 100000
#define SDRAM_REF_TICKS_PER_REFRESH ((XCORE_TIMER_TICKS_PER_MS * SDRAM_REFRESH_MS) / SDRAM_REFRESH_CYCLES)

#pragma unsafe arrays
void sdram_server(
    sdram_ports &p_sdram,
    chanend c_normal_priority
#if SDRAM_USE_HI_PRIORITY_CHANNEL
    , chanend c_hi_priority
#endif
){
  timer t;
  unsigned time;
  unsigned running = 1;

  unsigned char val;

  sdram_init_impl(p_sdram);

  sdram_refresh(SDRAM_REFRESH_CYCLES, p_sdram);
  t:> time;
  time += SDRAM_REF_TICKS_PER_REFRESH * SDRAM_ACCEPTABLE_REFRESH_GAP;

  while(running){
#pragma ordered
    select {
      case t when timerafter(time) :> unsigned handle_time :{
        unsigned diff = handle_time - time;
        unsigned refreshes_to_refill = diff / SDRAM_REF_TICKS_PER_REFRESH;
        sdram_refresh(refreshes_to_refill, p_sdram);
        time = handle_time + SDRAM_REF_TICKS_PER_REFRESH * SDRAM_ACCEPTABLE_REFRESH_GAP;
        break;
      }
#if SDRAM_USE_HI_PRIORITY_CHANNEL
      case c_hi_priority :> unsigned p :{
        running = handle_cmd(p_sdram, p, hi_hi_priority_cmd_data);
        outct(c_hi_priority);
        break;
      }
#endif
      case inuchar_byref(c_normal_priority, val):{
        running = handle_cmd(p_sdram, val, normal_priority_cmd_data);
        outuchar(c_normal_priority, val);
        break;
      }

    }
  }
}
