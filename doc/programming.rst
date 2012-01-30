SDRAM Programming Guide
=======================

The component is divided into a server component which runs in a single thread and receives requests for SDRAM refresh and a client library. The server provides shutdown, burst read and burst write and a separate function to initialise the required ports and clock blocks and perform initial setup of the SDRAM. The client library is provided for the basic functions and communicates with the sdram server thread over a single channel end. Only one client is supported.

Key Files
---------

+---------------------------------------+-----------------------------------------------------------------+
| File                                  | Description                                                     |
+=======================================+=================================================================+
| module_sdram_burst/src/sdram_burst.h  | Header File for sdram server API.                               |
+---------------------------------------+-----------------------------------------------------------------+
| module_sdram_burst/src/sdram_burst.xc | sdram init and server functionalit                              |
+---------------------------------------+-----------------------------------------------------------------+
| app_sdram_burst_example/src/client.c  | Client API. Includes sdram_burst.h                              |
+---------------------------------------+-----------------------------------------------------------------+
| app_sdram_burst_example/src/test.xc   | XC program that runs a simple series of read and write tests    |
+---------------------------------------+-----------------------------------------------------------------+


Ports and Clocks Setup
----------------------

Two clock blocks are used for the main SDRAM driver. Clkblk **b_sdram_clk** outputs a 12.5 MHz clock on port 1A. Clkblk **b_sdram_io** creates a delayed version of the sdram_clk (via p_sdram_clk) to drive the IO while meeting required setup and hold timings. 

All the ports besides clk, bank address and cke are buffered ports clocked by the delayed sdram clock and operating in strobed slave mode, slaved to a single 1 bit port, p_sdram_gate. When the latter is 0 all the buffered ports will be stalled.
 

+---------------+----------------+--------+--------------------------------------------------------------------+
| Signal        | Port Name      | Ports  | Notes                                                              |
+===============+================+========+====================================================================+
| clk           | p_sdram_clk    | 1A     | 25 MHz                                                             |
+---------------+----------------+--------+--------------------------------------------------------------------+
| IO strobe     | p_sdram_gate   | 1I     | slaved perts below will update output each clk cycle               |
+---------------+----------------+--------+--------------------------------------------------------------------+
| delayed clock | p_sdram_io     |  -     | Delayed version of clk                                             |
+---------------+----------------+--------+--------------------------------------------------------------------+
| cke           | p_sdram_cke    |  1B    |                                                                    |
+---------------+----------------+--------+--------------------------------------------------------------------+
| data          | p_sdram_dq     |  16B   | 32b transfer reg for word aligned access                           |
+---------------+----------------+--------+--------------------------------------------------------------------+
| dqm0/1        | p_sdram_dqm0/1 |  1E/1F |                                                                    |
+---------------+----------------+--------+--------------------------------------------------------------------+
| cmd           | p_sdram_cmd    |  4D    | {CAS_N,RAS_N,WE_N,CE_N}. 32b transfer reg holds a 8 command cycles |
+---------------+----------------+--------+--------------------------------------------------------------------+
| bank address  | p_sdram_ba0/1  |  1C/1D |                                                                    |
+---------------+----------------+--------+--------------------------------------------------------------------+
| addr[12:1]    | p_sdram_addr   |  32A   | drives bits 12:1 of address                                        |
+---------------+----------------+--------+--------------------------------------------------------------------+
| addr[0]       | p_sdram_addr0  |  1G    | drives bit 0 on port 1G. 4b transfer reg for 4 cycles of address   |
+---------------+----------------+--------+--------------------------------------------------------------------+

Note that two warnings are produced in XDE 11.2 related to buffered port for DQ which has its direction reversed. This warning can be safely ignored but not eliminated.

Client API 
-----------

This is the API to be utilised by client threads to access the SDRA via the server thread.

.. doxygenfunction:: sdram_server
.. doxygenfunction:: sdram_init
.. doxygenfunction:: sdram_refresh
.. doxygenfunction:: sdram_shutdown
.. doxygenfunction:: sdram_read
.. doxygenfunction:: sdram_write

Server Functionality
--------------------

The server threads accepts commands over its channelend as follows:

+-----+-----------------------------+
| cmd | Description                 |
+-----+-----------------------------+
| 1   | Shutdown Server             |
+-----+-----------------------------+
| 2   | Refresh                     |
+-----+-----------------------------+
| 1   | Burst Write                 |
+-----+-----------------------------+
| 1   | Burst Read                  |
+-----+-----------------------------+

Initialisation
++++++++++++++

When sdram_server is called it calls init() in sdram_burst.xc to configure the ports as above and then executes the specified initialisation sequence (see page 43 of the datasheet) on the memory.

The SDRAM Mode Register is setup during this process as follows:

   * CAS Latency = 3
   * Burst Type = Sequential
   * Continuous Burst, programmed length =8

Burst Write
+++++++++++

The sdram_write function uses a timstamped output to the p_sdram_gate port which in turn enables a precise number of cycles of output to the command, address and data ports. There are essentially two phases to the write burst explained below and also related in the comments in sdram_burst.xc:

**Phase 1** begins at time 't' with p_sdram_gate being set low to disabled slaved ports, after the cmd port has been loaded with  NOP, ACT(A), WR, NOP. 

p_sdram_gate is scheduled to be set high 12 sdram_clk cycles later. During this 12 cycles the following operations are performed:

   #. Prepare dqm ports to be asserted on the cycle the burst is terminiated, and prepare cmd port to issue precharge command on cycle the burst is to terminate
   #. Load the address port with the column address port for the burst write, to be output co-incident with the WRITE command.
   #. Obtain the first two half-words to be written from the client and output the first of them on DQ.

**Phase 2** begins at time t+12, after which p_sdram_gate is high and slaved ports are enabled. This phase lasts time 'dt' clock cycles, defined as twice the number of 32bit words to be written plus 2 (to accomodate burst termination). This phase is ended by the issuance of the precharge command from the cmd port which terminates the burst.

Burst Read
++++++++++

The sdram_read function uses a timstamped output to the p_sdram_gate port which in turn enables a precise number of cycles of output to the command, address and data ports. As with the write, there are essentially two phases to the read burst.

**Phase 1** begins at time 't' with p_sdram_gate being set low to disabled slaved ports, after the cmd port has been loaded with  NOP, ACT(A), WR, NOP. 

p_sdram_gate is scheduled to be set high 12 sdram_clk cycles later. During this 12 cycles the following operations are performed:

   #. Prepare dqm ports to be asserted on the cycle the burst is terminiated, and prepare cmd port to issue precharge command on cycle the burst is to terminate
   #. Load the address port with the column address port for the burst write, to be output co-incident with the WRITE command.

**Phase 2** begins at time t+12, after which p_sdram_gate is high and slaved ports are enabled. This phase lasts time 'dt' clock cycles, defined as twice the number of 32bit words to be read plus 2 (to accomodate burst termination). This phase is ended by the issuance of the precharge command from the cmd port which terminates the burst. 4 cycles after the initiation of this phase the DQ port is turned to input to receive the read burst. The 4 cycles derives from the CAS latency which is set to 3. The burst is then input and sent to the client.






 


 
