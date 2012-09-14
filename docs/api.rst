.. _sec_api:

SDRAM API
=========

.. _sec_conf_defines:

Configuration Defines
---------------------
The file sdram_conf.h can be provided in the application source code, without it 
the default values specified in 

IMPL/sdram_config_IMPL.h
IMPL/sdram_geometry_IMPL.h
sdram_commands_IMPL.h

where IMPL is the implimentation that is in use. These files can set the following defines:

Implimentation Specific Defines
+++++++++++++++++++++++++++++++
This is implimentation specific. When overriding one of these defines a suffix of "_IMPL" need 
to be added. For example, to override SDRAM_CLOCK_DIVIDER to 2 for the PINOUT_V1_IS42S16100F target the 
line:

#define SDRAM_CLOCK_DIVIDER_PINOUT_V1_IS42S16100F 2

to sdram_conf.h.

SDRAM Config Defines
++++++++++++++++++++
These are implimentation specific.

**SDRAM_REFRESH_MS**
**SDRAM_REFRESH_CYCLES**
	These specify that SDRAM_REFRESH_MS milliseconds may elapse during which 
	SDRAM_REFRESH_CYCLES refresh instructions must have been issued 
	to maintain the contents of the SDRAM. 

**SDRAM_ACCEPTABLE_REFRESH_GAP**
	Define the amount of time that the SDRAM is allowed to go before the server
	refreshes. The unit is given in refresh periods. For example, the value N
	would mean that the SDRAM is allowed to go

        	SDRAM_REFRESH_MS/SDRAM_REFRESH_CYCLES*N milliseconds

 	before refreshing. The larger the number (up to SDRAM_REFRESH_CYCLES) the
 	smaller the constant time impact but the larger the overall impact. If set
	above SDRAM_REFRESH_CYCLES then the SDRAM will fail.
	The default is (SDRAM_REFRESH_CYCLES/8).

**SDRAM_CMDS_PER_REFRESH**
	Define the minimum time between refreshes in SDRAM Clk cycles. Must be in 
	the range from 2 to 4 inclusive.

**SDRAM_EXTERNAL_MEMORY_ACCESSOR**
	Define if the memory is accessed by another device(other than the XCore).
	If not defined then faster code will be produced.

**SDRAM_CLOCK_DIVIDER**
	Set SDRAM_CLOCK_DIVIDER to divide down the reference clock to get the desired
	SDRAM Clock. The reference clock is divided by 2^SDRAM_CLOCK_DIVIDER.

**SDRAM_MODE_REGISTER**
	Define the configuration of the SDRAM. This is the value to be loaded
	into the mode register.

SDRAM Geometry Defines
++++++++++++++++++++++
These are implimentation specific.
**SDRAM_ROW_ADDRESS_BITS**
	This defines the number of row address bits.

**SDRAM_COL_ADDRESS_BITS**
	This defines the number of column address bits.
	
**SDRAM_BANK_ADDRESS_BITS**
	This defines the number of bank address bits.
	
**SDRAM_COL_BITS**
	This defines the number of bits per column, i.e. the data width. This should only be changed if
	an SDRAM of bus width other than 16 is used. 

SDRAM Commands Defines
++++++++++++++++++++++
These are non-implimentation specific.
**SDRAM_ENABLE_CMD_WAIT_UNTIL_IDLE**
**SDRAM_ENABLE_CMD_BUFFER_READ**
**SDRAM_ENABLE_CMD_BUFFER_WRITE**
**SDRAM_ENABLE_CMD_FULL_ROW_READ**
**SDRAM_ENABLE_CMD_FULL_ROW_WRITE**
	These defines switch commands on and off in the server and client. Set to 0 for disable,
	set to 1 for enable.

Port Config
+++++++++++
The port config is given in sdram_ports_IMPL.h. 


SDRAM API
---------
These are the functions that are called from the application and are included in sdram.h.
.. _sec_conf_functions:

Server Functions
++++++++++++++++
.. doxygenfunction:: sdram_server
.. doxygenfunction:: sdram_wait_until_idle

SDRAM Write Functions
+++++++++++++++++++++
.. doxygenfunction:: sdram_buffer_write
.. doxygenfunction:: sdram_full_row_write

SDRAM Read Functions
++++++++++++++++++++
.. doxygenfunction:: sdram_buffer_read
.. doxygenfunction:: sdram_full_row_read


SDRAM Target API
----------------
These are the functions that are called from the server to perform target specific implimentations on the SDRAM.
.. _sec_conf_functions:

.. doxygenfunction:: sdram_init_IMPL
.. doxygenfunction:: sdram_refresh_IMPL
.. doxygenfunction:: sdram_read_IMPL
.. doxygenfunction:: sdram_write_IMPL
