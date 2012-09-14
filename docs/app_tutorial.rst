Demo Applications
+++++++++++++++++
This tutorial describes the demo applications included in the XMOS SDRAM software component. 
:ref:`sec_hardware_platforms` describes the required hardware setups to run the demos.
The source for both demos can be found in the top level directory of the sc_sdram component.

A basic knowledge of XC programming is assumed. For information on XMOS programming, 
you can find reference material about XC programming at the 
`XMOS website <http://www.xmos.com/support/documentation>`_.

To write an SDRAM enabled application for an XMOS device requires
several things:

#. Write a Makefile for our application
#. Provide an sdram_conf.h configuration file
#. Write the application code that uses the component

The application must define SDRAM_DEFAULT_IMPLEMENTATION. 

app_sdram_demo
--------------
This application demonstrates how the module is used to accesses memory on the SDRAM. Important notes:
 - ``sdram_buffer_write`` commands the server to begin writing the buffer to SDRAM. The server returns an ack on the server channel as soon as the command has been accepted. This means that the data in the buffer cannot be assumed to have been written to the SDRAM until any other command has been accepted. Typically, ``sdram_wait_until_idle`` is used to confirm the write command completion but any command will do.
 - ``sdram_buffer_read`` commands the server to begin reading the SDRAM into the buffer. The same properites as the ``sdram_buffer_write`` apply to all commands, hence, ``sdram_wait_until_idle`` is used to confirm that the data in now in the buffer.

app_sdram_regress
-----------------
This application serves as a software regression to aid implimenting new SDRAM 
interfaces. The demo runs a series of regression tests of increasing difficulty, 
begining from using a single core for the server and a single core for the sdram_server 
progressing to all cores being loaded to simulate an XCore under full load. 

app_sdram_benchmark
-------------------
This application benchmarks the performace of the module. It does no correctness 
testing but instead tests the throughput of the SDRAM server.  
