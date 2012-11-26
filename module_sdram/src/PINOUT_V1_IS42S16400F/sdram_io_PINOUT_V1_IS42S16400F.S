.text
.cc_top sdram_block_write_PINOUT_V1_IS42S16400F.function
.align 4
.globl sdram_block_write_PINOUT_V1_IS42S16400F
.type  sdram_block_write_PINOUT_V1_IS42S16400F, @function
sdram_block_write_PINOUT_V1_IS42S16400F:

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

	#include "sdram_block_write_body_PINOUT_V1_IS42S16400F.inc"

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
.globl sdram_block_write_PINOUT_V1_IS42S16400F.nstackwords
.linkset sdram_block_write_PINOUT_V1_IS42S16400F.nstackwords, 1
.globl sdram_block_write_PINOUT_V1_IS42S16400F.maxtimers
.linkset sdram_block_write_PINOUT_V1_IS42S16400F.maxtimers, 0
.globl sdram_block_write_PINOUT_V1_IS42S16400F.maxchanends
.linkset sdram_block_write_PINOUT_V1_IS42S16400F.maxchanends, 0
.globl sdram_block_write_PINOUT_V1_IS42S16400F.maxthreads
.linkset sdram_block_write_PINOUT_V1_IS42S16400F.maxthreads, 1
.cc_bottom sdram_block_write_PINOUT_V1_IS42S16400F.function


.cc_top sdram_block_read_PINOUT_V1_IS42S16400F.function
.align 4
.globl sdram_block_read_PINOUT_V1_IS42S16400F
.type  sdram_block_read_PINOUT_V1_IS42S16400F, @function
sdram_block_read_PINOUT_V1_IS42S16400F:
	entsp 5

 	//r0 buffer pointer
	//r1 jump amount
	//r2 resource id of dq
	//r3 resource id of ctrl
	//sp[] stop time

	stw r4, sp[0]
	stw r5, sp[1]
	stw r6, sp[2]
	stw r7, sp[3]
	stw r8, sp[4]

	mov r7, r1

	//get the stop time from the stack
	ldw r4, sp[6]
	add r8, r4, 5
	//save the dp
	ldaw r1, dp[0]

	//set the new dp
	set dp, r0

	ldaw r5, dp[63]
	add r5, r5, 4

	//load the burst term inst
	ldc r0, 0x5e


	ldw r11, sp[7]
	setpt res[r2], r11

.align 4

	in r11, res[r2]
	bru r7

	#include "sdram_block_read_body_PINOUT_V1_IS42S16400F.inc"

	//r0	burst term data
	//r1	save reg for dp
	//r2	resource id of dq
	//r3	resource id of ctrl
	//r4	stop time
	//r5	precomputed buffer pointer increament
	//r6	buffered data
	//r11	used as a temp
	//dp	adjusted buffer pointer

	in r11, res[r2]
	setpt res[r3], r4

	in r4, res[r2]
	outpw res[r3], r0, 7

	in r3, res[r2]

	ldw r0, sp[8]

	in r7, res[r2]

	setpt res[r0], r8
	ldc r8, 2
	outpw res[r0], r8, 2
	mkmsk r0, 32
	out res[r2], r0

    stw r11, dp[60]
    stw r4, dp[61]
	stw r3, dp[62]
	stw r7, dp[63]

	ldaw r11, dp[0]
	eq r5, r11, r5

	bf r5, jump
	extdp 1
	stw r6, dp[0]
jump:
	//restore the dp
	set dp, r1

	ldw r8, sp[4]
	ldw r7, sp[3]
	ldw r6, sp[2]
	ldw r5, sp[1]
	ldw r4, sp[0]
	retsp 5

.globl sdram_block_read_PINOUT_V1_IS42S16400F.nstackwords
.linkset sdram_block_read_PINOUT_V1_IS42S16400F.nstackwords, 5
.globl sdram_block_read_PINOUT_V1_IS42S16400F.maxtimers
.linkset sdram_block_read_PINOUT_V1_IS42S16400F.maxtimers, 0
.globl sdram_block_read_PINOUT_V1_IS42S16400F.maxchanends
.linkset sdram_block_read_PINOUT_V1_IS42S16400F.maxchanends, 0
.globl sdram_block_read_PINOUT_V1_IS42S16400F.maxthreads
.linkset sdram_block_read_PINOUT_V1_IS42S16400F.maxthreads, 1

.cc_bottom sdram_block_read_PINOUT_V1_IS42S16400F.function

.cc_top sdram_short_block_read_PINOUT_V1_IS42S16400F.function
.align 4
.globl sdram_short_block_read_PINOUT_V1_IS42S16400F
.type  sdram_short_block_read_PINOUT_V1_IS42S16400F, @function
sdram_short_block_read_PINOUT_V1_IS42S16400F:
	entsp 4

 	//r0 buffer pointer
	//r1 read amount of buffer in words
	//r2 resource id of dq
	//r3 resource id of ctrl
	//sp[4] stop time 1
	//sp[5] stop time 2

	stw r4, sp[0]
	stw r5, sp[1]
	stw r6, sp[2]
	stw r7, sp[3]


	//get the stop time from the stack
	ldw r4, sp[5]
	add r7, r4, 6

	//load the burst term inst
	ldc r5, 0xbe

	ldw r11, sp[6]
	setpt res[r2], r11

	//junk
	in r11, res[r2]

	//word 0
	in r11, res[r2]
	setpt res[r3], r4

	//word 1
	in r4, res[r2]
	outpw res[r3], r5, 8

	//word 2
	in r5, res[r2]
	mkmsk r3, 32

	//word 3
	in r6, res[r2]
	out res[r2], r3

	ldw r3, sp[7]
	setpt res[r3], r7
	ldc r2, 2
	outpw res[r3], r2, 2

	ldc r2, 4
	sub r1, r2, r1

    bru r1
    stw r6, r0[3]
    stw r5, r0[2]
	stw r4, r0[1]
	stw r11, r0[0]

	ldw r7, sp[3]
	ldw r6, sp[2]
	ldw r5, sp[1]
	ldw r4, sp[0]
	retsp 4

.globl sdram_short_block_read_PINOUT_V1_IS42S16400F.nstackwords
.linkset sdram_short_block_read_PINOUT_V1_IS42S16400F.nstackwords, 4
.globl sdram_short_block_read_PINOUT_V1_IS42S16400F.maxtimers
.linkset sdram_short_block_read_PINOUT_V1_IS42S16400F.maxtimers, 0
.globl sdram_short_block_read_PINOUT_V1_IS42S16400F.maxchanends
.linkset sdram_short_block_read_PINOUT_V1_IS42S16400F.maxchanends, 0
.globl sdram_short_block_read_PINOUT_V1_IS42S16400F.maxthreads
.linkset sdram_short_block_read_PINOUT_V1_IS42S16400F.maxthreads, 1

.cc_bottom sdram_short_block_read_PINOUT_V1_IS42S16400F.function
