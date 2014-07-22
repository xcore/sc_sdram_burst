Example Applications
====================

The example applications included in the XMOS SDRAM software component demonstrate basic functionality of the API. 
:ref:`sec_hardware_platforms` describes the required hardware setups to run the demos.

app_sdram_demo
--------------

This application demonstrates how the module is used to accesses memory on the SDRAM. The purpose of this application is to show how data is written to and read from the SDRAM in a safe manner.

Getting Started
+++++++++++++++

   #. Plug the XA-SK-SDRAM Slice Card into the 'STAR' slot of the Slicekit Core Board.
   #. Plug the XA-SK-XTAG2 Card into the Slicekit Core Board.
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
  00000006	00000006
  00000007	00000007
  00000008	00000008
  00000009	00000009
  0000000A	0000000A
  0000000B	0000000B
  0000000C	0000000C
  0000000D	0000000D
  0000000E	0000000E
  0000000F	0000000F
  SDRAM demo complete.

Notes
+++++
 - ``sdram_init_state`` must only be called once on the structure that it initialises.
 - There are two SDRAM access functions: ``sdram_read`` and ``sdram_write``. They both take a movable pointer as a parameter. After calling either of these the movable pointer will be null afterwards from the perspictive of the SDRAM client. 
 - The memory is returned to the SDRAM client when a call to ``sdram_complete`` is made. After the call the movable pointer is no longer null and can be used again. 
 - There is no need to explictly refresh the SDRAM as this is managed by the ``sdram_server``.


