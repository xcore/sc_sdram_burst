Example Applications
====================

This tutorial describes the demo applications included in the XMOS SDRAM software component. 
:ref:`sec_hardware_platforms` describes the required hardware setups to run the demos.

app_sdram_demo
--------------

This application demonstrates how the module is used to accesses memory on the SDRAM. The purpose of this application is to show how data is written to and read from the SDRAM in a safe manner.

Getting Started
+++++++++++++++

   #. Plug the XA-SK-SDRAM Slice Card into the 'STAR' slot of the sliceKIT Core Board.
   #. Plug the XA-SK-XTAG2 Card into the sliceKIT Core Board.
   #. Ensure the XMOS LINK switch on the XA-SK-XTAG2 is set to "off".
   #. Open ``app_sdram_demo.xc`` and build it.
   #. run the program on the hardware.

The output produced should look like::

  00000000	00000000
  00000001	00000001
  00000002	00000002
  00000003	00000003
  00000004	00000004
  00000005	00000005
  SDRAM demo complete.

Notes
+++++
 - There are 4 SDRAM I/O commands: ``sdram_buffer_write``, ``sdram_buffer_read``, ``sdram_full_page_write``, ``sdram_full_page_read``. They must all be followed by a ``sdram_wait_until_idle`` before another I/O command may be issued. When the ``sdram_wait_until_idle`` returns then the data is now at it destination. This functionality allows the application to be getting on with something else whilst the SDRAM server is busy with the I/O. 
 - There is no need to explictly refresh the SDRAM as this is managed by the ``sdram_server``.

app_sdram_testbench
-------------------

This application serves as a software regression to aid implementing new SDRAM interfaces and verifying current ones. The testbench runs a series of regression tests of increasing difficulty, beginning from using a single core for the sdram_server with one core loaded progressing to all cores being loaded to simulate an xCORE under full load. 

Getting Started
+++++++++++++++

   #. Plug the XA-SK-SDRAM Slice Card into the 'STAR' slot of the sliceKIT Core Board.
   #. Plug the XA-SK-XTAG2 Card into the sliceKIT Core Board.
   #. Ensure the XMOS LINK switch on the XA-SK-XTAG2 is set to "off".
   #. Open ``app_sdram_testbench.xc`` and build it.
   #. run the program on the hardware.

With verbose output turned on (controlled by VERBOSE_MSG and VERBOSE_ERR), the output produced should look like::

  Test suite begin
  8 threaded test suite start
  Begin sanity_check
  ...

app_sdram_benchmark
-------------------

This application benchmarks the performance of the module. It does no correctness testing but instead tests the throughput of the SDRAM server.  

Getting Started
+++++++++++++++

   #. Plug the XA-SK-SDRAM Slice Card into the 'STAR' slot of the sliceKIT Core Board.
   #. Plug the XA-SK-XTAG2 Card into the sliceKIT Core Board.
   #. Ensure the XMOS LINK switch on the XA-SK-XTAG2 is set to "off".
   #. Open ``app_sdram_benchmark.xc`` and build it.
   #. run the program on the hardware.

The output produced should look like::

	Cores active: 8
	Max write: 70.34 MB/s
	Max read : 66.82 MB/s
	Cores active: 7
	Max write: 71.47 MB/s
	Max read : 68.08 MB/s
	...

