
Evaluation Platforms
====================

.. _sec_hardware_platforms:

Recommended Hardware
--------------------

Slicekit
++++++++

This module may be evaluated using the Slicekit Modular Development Platform, available from digikey. Required board SKUs are:

   * XP-SKC-L2 (Slicekit L16 Core Board) plus XA-SK-SDRAM plus XA-SK-XTAG2 (Slicekit XTAG adaptor) 

Demonstration Applications
--------------------------

Testbench Application
+++++++++++++++++++++

This application serves as a software regression to aid implementing new SDRAM interfaces and verifying current ones. The demo runs a series of regression tests of increasing difficulty, beginning from using a single core for the server and a single core for the sdram_server progressing to all cores being loaded to simulate an xCORE under full load. 

   * Package: sc_sdram_burst
   * Application: app_sdram_regress


Benchmark Application
+++++++++++++++++++++

This application benchmarks the performance of the module. It does no correctness testing but instead tests the throughput of the SDRAM server.

   * Package: sc_sdram_burst
   * Application: app_sdram_benchmark

Demo Application
++++++++++++++++

This application demonstrates how the module is used to access memory on the SDRAM.

   * Package: sc_sdram_burst
   * Application: app_sdram_demo

Display Controller Application
++++++++++++++++++++++++++++++

This combination demo employs this module along with the ``module_lcd`` LCD driver and the ``module_display_controller'' framebuffer framework component to implement a 480x272 display controller.

Required board SKUs for this demo are:

   * XP-SKC-L2 (sliceKIT L16 Core Board) plus XA-SK-SDRAM plus XA-SK-LCD480 plus XA-SK-XTAG2 (sliceKIT XTAG adaptor) 
   * Package: sw_display_controller
   * Application: app_graphics_demo

