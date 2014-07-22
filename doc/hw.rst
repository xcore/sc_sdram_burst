
Evaluation Platforms
====================

.. _sec_hardware_platforms:

Recommended Hardware
--------------------

Slicekit
++++++++

This module may be evaluated using the Slicekit Modular Development Platform, available from digikey. Required board SKUs are:

   * XP-SKC-L2 (Slicekit L2 Core Board) plus XA-SK-SDRAM plus XA-SK-XTAG2 (Slicekit XTAG adaptor) 

Demonstration Applications
--------------------------

Demo Application
++++++++++++++++

This application demonstrates how the module is used to accesses memory on the SDRAM.

   * Package: sc_sdram_burst
   * Application: app_sdram_demo

Display Controller Application
++++++++++++++++++++++++++++++

This combination demo employs this module along with the module_lcd LCD driver and the module_framebuffer framebuffer framework component to implement a 480x272 display controller.

Required board SKUs for this demo are:

   * XP-SKC-L2 (Slicekit L2 Core Board) plus XA-SK-SDRAM plus XA-SK-LCD480 plus XA-SK-XTAG2 (Slicekit XTAG adaptor) 

   * Package: sw_display_controller
   * Application: app_graphics_demo

