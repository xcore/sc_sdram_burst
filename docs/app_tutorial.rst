Example Applications
====================

This tutorial describes the demo applications included in the XMOS SDRAM software component. 
:ref:`sec_hardware_platforms` describes the required hardware setups to run the demos.

app_sdram_demo
--------------

This application demonstrates how the module is used to accesses memory on the SDRAM. The purpose of this application is to show how data is written to and read from the SDRAM in a safe manner. Important notes:

 - ``sdram_buffer_write`` commands the server to begin writing the buffer to SDRAM. The server returns an ack on the server channel as soon as the command has been accepted. This means that the data in the buffer cannot be assumed to have been written to the SDRAM until any other command has been accepted. Typically, ``sdram_wait_until_idle`` is used to confirm the write command completion but any command will do.
 - ``sdram_buffer_read`` commands the server to begin reading the SDRAM into the buffer. The same properties as the ``sdram_buffer_write`` apply to all commands, hence, ``sdram_wait_until_idle`` is used to confirm that the data is in now in the buffer.

Getting Started
+++++++++++++++

   #. Plug the XA-SK-SDRAM Slice Card into any but the the 'TRIANGLE' slot of the Slicekit Core Board 
   #. Open ``app_sdram_demo.xc`` and select the slot the  XA-SK-SDRAM Slice Card was inserted into.
   #. run the program

The output produced should look like::

  SDRAM demo complete.

app_sdram_regress
-----------------

This application serves as a software regression to aid implementing new SDRAM interfaces and verifying current ones. The demo runs a series of regression tests of increasing difficulty, beginning from using a single core for the sdram_server with one core loaded progressing to all cores being loaded to simulate an XCore under full load. 

Getting Started
+++++++++++++++

   #. Plug the XA-SK-SDRAM Slice Card into any but the the 'TRIANGLE' slot of the Slicekit Core Board 
   #. Open ``app_sdram_regress.xc`` and select the slot the  XA-SK-SDRAM Slice Card was inserted into.
   #. run the program

The output produced should look like::

  Test suite begin
  8 threaded test suite start
  Begin sanity_check
  ...

app_sdram_benchmark
-------------------

This application benchmarks the performance of the module. It does no correctness testing but instead tests the throughput of the SDRAM server.  

Getting Started
+++++++++++++++

   #. Plug the XA-SK-SDRAM Slice Card into any but the the 'TRIANGLE' slot of the Slicekit Core Board 
   #. Open ``app_sdram_benchmark.xc`` and select the slot the  XA-SK-SDRAM Slice Card was inserted into.
   #. run the program

The output produced should look like::

	Cores active: 8
	Max write: 70.34 MB/s
	Max read : 66.82 MB/s
	Cores active: 7
	Max write: 71.47 MB/s
	Max read : 68.08 MB/s
	...

