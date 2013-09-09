.text
.cc_top sdram_block_write.function
.align 4
.globl sdram_block_write
.type  sdram_block_write, @function
sdram_block_write:

	//r0    adjusted buffer pointer
	//r1    jump amount
	//r2    resource id of dq
	//r3    resource id of we
	//sp[1] resource id of ras
	//sp[2] stop time

	stw r4, sp[0]

	mkmsk r4, 32
	sub r4, r4, 9
	//r4 = 0xFFFFFFF6 = 0b1111 ... 11110110

	//save the cp (has to be to r11)
	ldaw r11, cp[0]
	set cp, r0
	mov r0, r11

	mov r11 , r1

.align 4
	//get the stop time from the stack
	ldw r1, sp[2]
	bru r11

	#include "sdram_block_write_body.inc"

	//r0	save reg for cp
	//r1	stop time
	//r2	resource id of dq
	//r3	resource id of we
	//r4	burst term inst
	//r11	used as a temp
	//cp	adjusted buffer pointer

    setpt res[r3], r1
    outpw res[r3], r4, 5
    out res[r2], r4
    add r1, r1, 3
    ldw r3, sp[1]
	setpt res[r3], r1
    outpw res[r3], r4, 2

	set cp, r0
	ldw r4, sp[0]
	retsp 0
.globl sdram_block_write.nstackwords
.linkset sdram_block_write.nstackwords, 1
.globl sdram_block_write.maxtimers
.linkset sdram_block_write.maxtimers, 0
.globl sdram_block_write.maxchanends
.linkset sdram_block_write.maxchanends, 0
.globl sdram_block_write.maxthreads
.linkset sdram_block_write.maxthreads, 1
.cc_bottom sdram_block_write.function

.cc_top sdram_fast_read.function
.align 4
.globl sdram_fast_read
.type  sdram_fast_read, @function
sdram_fast_read:

 	//r0 buffer pointer
 	//r1 jump_amount
	//r2 read_time
	//r3 resource id of dq

	ldaw r11, dp[0]
	set dp, r0
	ldaw r0, sp[0]
	ldaw sp, dp[64]

	//it will block on this
	setpt res[r3], r2
	in r2, res[r3]
.align 4
	bru r1

	#include "sdram_fast_read_body.inc"
	//restore the dp
	set dp, r11
	set sp, r0
	mkmsk r1, 32
    out res[r3], r1
	retsp 0

.globl sdram_fast_read.nstackwords
.linkset sdram_fast_read.nstackwords, 5
.globl sdram_fast_read.maxtimers
.linkset sdram_fast_read.maxtimers, 0
.globl sdram_fast_read.maxchanends
.linkset sdram_fast_read.maxchanends, 0
.globl sdram_fast_read.maxthreads
.linkset sdram_fast_read.maxthreads, 1
.cc_bottom sdram_fast_read.function
