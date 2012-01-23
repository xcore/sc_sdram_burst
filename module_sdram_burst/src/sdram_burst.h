// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

                               
/*************************************************************************
 *
 * This is a burst optimised SDRAM driver designed for the
 * Micron SDRAM MT48LC16M16A2P-75
 *
 * It uses a 25 MHz clock with 16 bit data. 
 *
 *************************************************************************/

#ifndef _sdram_h_
#define _sdram_h_

#define CMD_INH 0xF
#define CMD_NOP 0xE
#define CMD_LMR 0X0
#define CMD_PRE 0x8
#define CMD_RD 0x6
#define CMD_WR 0x4
# define CMD_ACT 0xA

/** Configures the ports and clocks for the SDRAM interface and then runs the
 *  initialisation process described on Page 43 of the datasheet.
 * 
 *  Must be called prior to sdram_refresh, write or read.
 */

void sdram_init(chanend server);

/** 
 *  Activates the sdram server which will run until it receives an instruction
 *  to shut down. Must be run prior to calling sdram_read/write/refresh/shutdown
 *  
 */

void sdram_server(chanend client);

/** 
 *  Kills server and turns off the sdram ports and clock blocks.
 */

void sdram_shutdown(chanend server);

/** 
 *  The client is responsible for issuing refresh commands every 15 us
 */

void sdram_refresh(chanend server);

/** 
 * Burst read and write. Minimum burst size 1, maximum burst size 256
 * The MT48LC16M16A2P has 4 banks, 8192 rows, 256 32b columns
 * Total: 32MB, bank size: 8MB, row size: 1KB
 */

void sdram_write(chanend c, int bank, int row, int col, const unsigned words[], int nwords);
void sdram_read(chanend c, int bank, int row, int col, unsigned words[], int nwords);

#endif
