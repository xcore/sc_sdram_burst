.. _sec_api:

SDRAM API
=========

.. _sec_conf_defines:

Configuration Defines
---------------------

The file ``sdram_conf.h`` must be provided in the application source code, and it must define:

SDRAM_DEFAULT_IMPLEMENTATION

It can also be used to overrife the default values specified in 

	* IMPL/sdram_config_IMPL.h
	* IMPL/sdram_geometry_IMPL.h
	* sdram_commands_IMPL.h

where IMPL is the SDRAM implimentation to be overridden. These files can set the following defines:

Implementation Specific Defines
+++++++++++++++++++++++++++++++
When overriding one of these defines a suffix of ``_IMPL`` needs to be added. For example, to override ``SDRAM_CLOCK_DIVIDER`` to 2 for the ``PINOUT_V1_IS42S16100F`` target add the line::

#define SDRAM_CLOCK_DIVIDER_PINOUT_V1_IS42S16100F 2

to ``sdram_conf.h``.

**SDRAM_REFRESH_MS**
   This specifies that during a period of ``SDRAM_REFRESH_MS`` milliseconds a total of ``SDRAM_REFRESH_CYCLES`` refresh instructions must be issued to maintain the contents of the SDRAM.

**SDRAM_REFRESH_CYCLES**
  As above.

**SDRAM_ACCEPTABLE_REFRESH_GAP**
  This define specifies how long the ``sdram_server`` can go between issuing bursts of refreshes. The SDRAM server issues refreshes in bursts when it is not servicing a read/write command. The number of refresh commands for a burst is automatically calculated, hence, if a read or write command is being serviced when a refresh burst should start then it will wait until the service is over then increase its burst size appropatly. If set above ``SDRAM_REFRESH_CYCLES`` then the SDRAM will fail. The default is (``SDRAM_REFRESH_CYCLES/8``). The unit is given in refresh periods. For example, the value would mean that the SDRAM is allowed to go ``SDRAM_REFRESH_MS/SDRAM_REFRESH_CYCLES*N`` milliseconds before refreshing. The larger the number (up to ``SDRAM_REFRESH_CYCLES``) the smaller the constant time impact but the larger the overall impact. 

**SDRAM_CMDS_PER_REFRESH**
  This defines the minimum time between refreshes in SDRAM Clk cycles. Must be in the range from 2 to 4 inclusive.

**SDRAM_EXTERNAL_MEMORY_ACCESSOR**
  This defines if the memory is accessed by another device(other than the XCore). If not defined then faster code will be produced.

**SDRAM_CLOCK_DIVIDER**
  Set ``SDRAM_CLOCK_DIVIDER`` to divide down the reference clock to get the desired SDRAM Clock. The reference clock is divided by 2*SDRAM_CLOCK_DIVIDER.

**SDRAM_MODE_REGISTER**
  This defines the configuration of the SDRAM. This is the value to be loaded into the mode register.

SDRAM Geometry Defines
++++++++++++++++++++++

These are implementation specific.

**SDRAM_ROW_ADDRESS_BITS**
  This defines the number of row address bits.

**SDRAM_COL_ADDRESS_BITS**
  This defines the number of column address bits.
	
**SDRAM_BANK_ADDRESS_BITS**
  This defines the number of bank address bits.
	
**SDRAM_COL_BITS**
  This defines the number of bits per column, i.e. the data width. This should only be changed if an SDRAM of bus width other than 16 is used. 

SDRAM Commands Defines
++++++++++++++++++++++
These are non-implimentation specific.

**SDRAM_ENABLE_CMD_WAIT_UNTIL_IDLE**
  Enable/Disable the wait until idle command.

**SDRAM_ENABLE_CMD_BUFFER_READ**
  Enable/Disable the buffer read command.

**SDRAM_ENABLE_CMD_BUFFER_WRITE**
  Enable/Disable the buffer write command.

**SDRAM_ENABLE_CMD_FULL_ROW_READ**
  Enable/Disable the full row read command.

**SDRAM_ENABLE_CMD_FULL_ROW_WRITE**
  Enable/Disable the full row write command.

These defines switch commands on and off in the server and client. Set to 0 for disable, set to 1 for enable. Disabling unused commands will cause a code size decrease.

Port Config
+++++++++++
The port config is given in ``\IMPL\sdram_ports_IMPL.h`` and is implementation specific.

SDRAM API
---------

These are the functions that are called from the application and are included in ``sdram.h``.

Server Functions
++++++++++++++++

.. doxygenfunction:: sdram_server
.. doxygenfunction:: sdram_wait_until_idle
.. doxygenfunction:: sdram_buffer_write
.. doxygenfunction:: sdram_full_row_write
.. doxygenfunction:: sdram_buffer_read
.. doxygenfunction:: sdram_full_row_read

SDRAM Memory Mapper API
-----------------------

These are the functions that are called from the application and are included in ``sdram_memory_mapper.h``.

Server Functions
++++++++++++++++

.. doxygenfunction:: mm_read_words
.. doxygenfunction:: mm_write_words
.. doxygenfunction:: mm_receive_ack

