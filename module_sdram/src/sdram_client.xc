#include "sdram.h"
#include <string.h>

void sdram_init_state(sdram_state &s){
   // memset(s, 0, sizeof(sdram_state));
}

int sdram_read(streaming chanend c_server, unsigned bank, unsigned row,
    unsigned col, unsigned word_count, unsigned * movable buffer, sdram_state &s){

    if(s.fill == 2)
        return 1;

    unsafe {
        sdram_cmd * unsafe c = &(s.cmd_queue[0]);
        if(c->inuse) c = &(s.cmd_queue[1]);
        c->bank = bank;
        c->row = row;
        c->col = col;
        c->word_count = word_count;
        c->buffer = move(buffer);
        c->cmd = SDRAM_CMD_READ;
        c->inuse = 1;
        c_server <: c;
    }
    s.fill++;
    return 0;
}

int sdram_write(streaming chanend c_server, unsigned bank, unsigned row,
    unsigned col, unsigned word_count, unsigned * movable buffer, sdram_state &s){

    if(s.fill == 2)
        return 1;

    unsafe {
        sdram_cmd * unsafe c = &(s.cmd_queue[0]);
        if(c->inuse) c = &(s.cmd_queue[1]);
        c->bank = bank;
        c->row = row;
        c->col = col;
        c->word_count = word_count;
        c->buffer = move(buffer);
        c->cmd = SDRAM_CMD_WRITE;
        c->inuse = 1;
        c_server <: c;
    }
    s.fill++;
    return 0;
}

void sdram_return(streaming chanend c_server, unsigned * movable &buffer, sdram_state &s) {
    s.fill--;
    unsafe {
        sdram_cmd * unsafe c;
        c_server :> c;
        c->inuse = 0;
        buffer = move(c->buffer);
    }
}
