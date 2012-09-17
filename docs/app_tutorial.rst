Example Applications
====================

This tutorial describes the demo applications included in the XMOS SDRAM software component. 
:ref:`sec_hardware_platforms` describes the required hardware setups to run the demos.

FIXME: removed generic waffle about what 'we' have to do

app_sdram_demo
--------------

This application demonstrates how the module is used to accesses memory on the SDRAM. Important notes:

FIXME: thus purpose of this application is to show...


 - ``sdram_buffer_write`` commands the server to begin writing the buffer to SDRAM. The server returns an ack on the server channel as soon as the command has been accepted. This means that the data in the buffer cannot be assumed to have been written to the SDRAM until any other command has been accepted. Typically, ``sdram_wait_until_idle`` is used to confirm the write command completion but any command will do.
 - ``sdram_buffer_read`` commands the server to begin reading the SDRAM into the buffer. The same properites as the ``sdram_buffer_write`` apply to all commands, hence, ``sdram_wait_until_idle`` is used to confirm that the data in now in the buffer.

Getting Started
+++++++++++++++

   #. Plug the XA-SK-SDRAM Slice Card into the Triangle slot of the Slicekit Core Board 
   #. Noodle the makefile to select target 'TRIANGLE', or whatever
   #. Import the code or whatever
   #. run the program

The output produced should look like so:

FIXME - what to expect


app_sdram_regress
-----------------

This application serves as a software regression to aid implimenting new SDRAM interfaces. The demo runs a series of regression tests of increasing difficulty, 
begining from using a single core for the server and a single core for the sdram_server 
progressing to all cores being loaded to simulate an XCore under full load. 

FIXME: if multiple sdram slices are needed for this, no customer is ever going to run it. Is it possible to turn off the multi core tests? 

FIXME: add getting started section as per above

app_sdram_benchmark
-------------------

This application benchmarks the performace of the module. It does no correctness testing but instead tests the throughput of the SDRAM server.  

FIXME: add getting started section as per above
