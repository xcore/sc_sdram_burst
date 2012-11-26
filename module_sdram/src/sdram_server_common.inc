#ifndef SDRAM_SERVER_COMMON_H_
#define SDRAM_SERVER_COMMON_H_

#include "sdram_commands.h"
//#include "sdram.h"

#pragma unsafe arrays
static void read_buffer(unsigned start_row, unsigned start_col,
    unsigned bank, unsigned buffer, unsigned word_count,
    struct ADD_SUFFIX(sdram_ports,CUR_IMPL) &ports) {
  unsigned words_to_end_of_line;
  unsigned current_col = start_col, current_row = start_row;
  unsigned remaining_words = word_count;

  while (1) {
    words_to_end_of_line = (ADD_SUFFIX(SDRAM_COL_COUNT,CUR_IMPL) - current_col) / 2;
    if (words_to_end_of_line < remaining_words) {
      ADD_SUFFIX(sdram_read,CUR_IMPL)(current_row, current_col, bank, buffer, words_to_end_of_line, ports);
      current_col = 0;
      current_row++;
      buffer += 4 * words_to_end_of_line;
      remaining_words -= words_to_end_of_line;
    } else {
      ADD_SUFFIX(sdram_read,CUR_IMPL)(current_row, current_col, bank, buffer, remaining_words, ports);
      return;
    }
    if(current_row == ADD_SUFFIX(SDRAM_ROW_COUNT,CUR_IMPL)){
      current_row = 0;
      bank = (bank + 1) % ADD_SUFFIX(SDRAM_BANK_COUNT,CUR_IMPL);
    }
  }
}

#pragma unsafe arrays
static void write_buffer(unsigned start_row, unsigned start_col,
    unsigned bank, unsigned buffer, unsigned word_count,
    struct ADD_SUFFIX(sdram_ports,CUR_IMPL) &ports) {
  unsigned words_to_end_of_line;
  unsigned current_col = start_col, current_row = start_row;
  unsigned remaining_words = word_count;

  while (1) {
    words_to_end_of_line = (ADD_SUFFIX(SDRAM_COL_COUNT,CUR_IMPL) - current_col) / 2;
    if (words_to_end_of_line < remaining_words) {
      ADD_SUFFIX(sdram_write,CUR_IMPL)(current_row, current_col, bank, buffer, words_to_end_of_line, ports);
      current_col = 0;
      current_row++;
      buffer += 4 * words_to_end_of_line;
      remaining_words -= words_to_end_of_line;
    } else {
      ADD_SUFFIX(sdram_write,CUR_IMPL)(current_row, current_col, bank, buffer, remaining_words, ports);
      return;
    }
    if(current_row == ADD_SUFFIX(SDRAM_ROW_COUNT,CUR_IMPL)){
      current_row = 0;
      bank = (bank + 1) % ADD_SUFFIX(SDRAM_BANK_COUNT,CUR_IMPL);
    }
  }
}

static void handle_command(char cmd, chanend client, struct ADD_SUFFIX(sdram_ports,CUR_IMPL) &ports) {
  switch (cmd) {
#if (SDRAM_ENABLE_CMD_BUFFER_READ==1)
    case SDRAM_CMD_BUFFER_READ: {
      unsigned bank, start_row, start_col, width_words, pointer;
      slave {
        client :> bank;
        client :> start_row;
        client :> start_col;
        client :> width_words;
        client :> pointer;
      }
      read_buffer(start_row, start_col, bank, pointer, width_words, ports);
      break;
    }
#endif
#if (SDRAM_ENABLE_CMD_BUFFER_WRITE==1)
    case SDRAM_CMD_BUFFER_WRITE: {
      unsigned bank, start_row, start_col, width_words, pointer;
      slave {
        client :> bank;
        client :> start_row;
        client :> start_col;
        client :> width_words;
        client :> pointer;
      }
      write_buffer(start_row, start_col, bank, pointer, width_words, ports);
      break;
    }
#endif
#if (SDRAM_ENABLE_CMD_FULL_ROW_WRITE==1)
    case SDRAM_CMD_FULL_ROW_WRITE: {
      unsigned bank, start_row, pointer;
      slave {
        client :> bank;
        client :> start_row;
        client :> pointer;
      }
      ADD_SUFFIX(sdram_write,CUR_IMPL)(start_row, 0, bank, pointer, ADD_SUFFIX(SDRAM_ROW_WORDS,CUR_IMPL), ports);
      break;
    }
#endif
#if (SDRAM_ENABLE_CMD_FULL_ROW_READ==1)
    case SDRAM_CMD_FULL_ROW_READ: {
      unsigned bank, start_row, pointer;
      slave {
        client :> bank;
        client :> start_row;
        client :> pointer;
      }
      ADD_SUFFIX(sdram_read,CUR_IMPL)(start_row, 0, bank, pointer, ADD_SUFFIX(SDRAM_ROW_WORDS,CUR_IMPL), ports);
      break;
    }
#endif
#if (SDRAM_ENABLE_CMD_COL_WRITE==1)
    case SDRAM_CMD_COL_WRITE: {
      unsigned bank, row, col;
      short data;
      slave {
        client :> bank;
        client :> row;
        client :> col;
        client :> data;
      }
      ADD_SUFFIX(sdram_col_write,CUR_IMPL)(bank, row, col, data, ports);
      break;
    }
#endif
    default:
#if (XCC_VERSION_MAJOR >= 12)
      __builtin_unreachable();
#endif
      break;
  }
}

#define SDRAM_REF_TICKS_PER_REFRESH ((XCORE_TIMER_TICKS_PER_MS*SDRAM_REFRESH_MS)/SDRAM_REFRESH_CYCLES)
#define XCORE_TIMER_TICKS_PER_MS 100000

void ADD_SUFFIX(sdram_server,CUR_IMPL)(chanend client, struct ADD_SUFFIX(sdram_ports,CUR_IMPL) &ports) {

  unsigned T, now, then;
  ADD_SUFFIX(sdram_init,CUR_IMPL)(ports);
  {
    timer t;
    ADD_SUFFIX(sdram_refresh,CUR_IMPL)(SDRAM_REFRESH_CYCLES, ports);
    t:> then;
    T = then + SDRAM_REF_TICKS_PER_REFRESH * SDRAM_ACCEPTABLE_REFRESH_GAP;
    while (1) {
  #pragma ordered
      select {
        case t when timerafter(T) :> now: {
          unsigned elapsed_ref_ticks = (now-then);
          unsigned num_refreshes = (elapsed_ref_ticks/SDRAM_REF_TICKS_PER_REFRESH) + 1;
          ADD_SUFFIX(sdram_refresh,CUR_IMPL)(num_refreshes, ports);
          then = now;
          T = then + SDRAM_REF_TICKS_PER_REFRESH * SDRAM_ACCEPTABLE_REFRESH_GAP;
          break;
        }
        case client :> char cmd: {
          handle_command(cmd, client, ports);
          outct(client, XS1_CT_END);
          break;
        }
      }
    }
  }
}

#endif /* SDRAM_SERVER_COMMON_H_ */
