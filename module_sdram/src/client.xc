#include "sdram.h"
#include "structs_and_enums.h"

void sdram_init_state(streaming chanend c_sdram_server, s_sdram_state &s){
    unsafe {
        c_sdram_server :> s.cmd[0];
        for(unsigned i=1;i<SDRAM_MAX_CMD_BUFFER;i++)
            s.cmd[i] = s.cmd[i-1] + 1;
    }
    s.head = 0;
    s.pending_cmds = 0;
}

static int send_cmd(streaming chanend c_sdram_server, s_sdram_state &state, unsigned bank, unsigned row, unsigned col,
        unsigned word_count, unsigned * movable buffer, e_command cmd){
    if(state.pending_cmds == SDRAM_MAX_CMD_BUFFER)
        return 1;

    unsigned index = (state.head + state.pending_cmds)%SDRAM_MAX_CMD_BUFFER;

    unsafe {
        sdram_cmd * unsafe c = state.cmd[index];
        c->bank = bank;
        c->row = row;
        c->col = col;
        c->word_count = word_count;
        c->buffer = move(buffer);
        c_sdram_server <: (char)cmd;
    }

    state.pending_cmds++;
    return 0;
}

int sdram_read(streaming chanend c_sdram_server, s_sdram_state &state, unsigned bank, unsigned row, unsigned col,
        unsigned word_count, unsigned * movable buffer){
    return send_cmd(c_sdram_server, state, bank, row, col, word_count, move(buffer), SDRAM_CMD_READ);
}

int sdram_write(streaming chanend c_sdram_server, s_sdram_state &state, unsigned bank, unsigned row, unsigned col,
        unsigned word_count, unsigned * movable buffer){
    return send_cmd(c_sdram_server, state, bank, row, col, word_count, move(buffer), SDRAM_CMD_WRITE);
}

void sdram_complete(streaming chanend c_sdram_server, s_sdram_state &state, unsigned * movable & buffer) {
    char c;
    c_sdram_server :> c;
    state.pending_cmds--;
    unsigned index = state.head%SDRAM_MAX_CMD_BUFFER;
    unsafe {
      buffer = move(state.cmd[index]->buffer);
    }
    state.head++;
}

void sdram_shutdown(streaming chanend c_sdram_server){
    c_sdram_server <: (char)SDRAM_CMD_SHUTDOWN;
}
