
SDRAM Programming Guide
=======================

This section provides information on how to program applications using the SDRAM module.

SDRAM Default implementation
----------------------------
For convenience the ``module_sdram`` can use a default implementation. When the define ``SDRAM_DEFAULT_IMPLEMENTATION`` is set in ``sdram_conf.h`` to one of the supported targets then the ``sdram_server`` function will act as a call to the specified implementation. The same applies for the ``sdram_ports`` structure. The currently supported targets are:
	* PINOUT_V1_IS42S16400F - This corresponds to the ISSI part IS42S16400F in a 20 pin configuration.
	* PINOUT_V1_IS42S16160D - This corresponds to the ISSI part IS42S16160D in a 20 pin configuration.
	* PINOUT_V0 - This is for a legacy 22 pin configuration.

Single SDRAM Support
--------------------

For a application with a single SDRAM the default implementation should be set. If it is not set then the explicit ``sdram_server`` and ``sdram_ports`` must be used. The same applied for all the implementation specific defines.

Multiple Homogeneous SDRAM Support
----------------------------------
For a application with a single SDRAM the default implementation should be set. For example, to drive two IS42S16400F parts, set the ``SDRAM_DEFAULT_IMPLEMENTATION`` to ``PINOUT_V1_IS42S16400F`` then the following will create the servers::

	chan c,d;
	par {
		sdram_server(c, ports_0);
		sdram_server(d, ports_1);
		app_0(c);
		app_1(d);
	}

and the ports for the above would have been created by::

	struct sdram_ports ports_0 = {
    		XS1_PORT_16A, 
		XS1_PORT_1B, 
		XS1_PORT_1G, 
		XS1_PORT_1C, 
		XS1_PORT_1F, 
		XS1_CLKBLK_1
	};
	struct sdram_ports ports_1 = {
    		XS1_PORT_16B, 
		XS1_PORT_1J, 
		XS1_PORT_1I, 
		XS1_PORT_1K, 
		XS1_PORT_1L, 
		XS1_CLKBLK_1 
	};

Multiple Heterogeneous SDRAM Support
------------------------------------

It is possible for the application to drive multiple heterogeneous SDRAM devices simultaneously. In this case each ``sdram_server`` and ``sdram_ports`` usage must be explicit to the implementation. For example, to drive an IS42S16400F part and an IS42S16160D part, then the following will create the servers::

	chan c,d;
	par {
		sdram_server_PINOUT_V1_IS42S16400F(c, ports_0);
		sdram_server_PINOUT_V1_IS42S16160D(d, ports_1);
		app_0(c);
		app_1(d);
	}

and the ports for the above would have been created by::
	
	struct sdram_ports_PINOUT_V1_IS42S16400F ports_0 = {
    		XS1_PORT_16A, 
		XS1_PORT_1B, 
		XS1_PORT_1G, 
		XS1_PORT_1C, 
		XS1_PORT_1F, 
		XS1_CLKBLK_1
	};
	struct sdram_ports_PINOUT_V1_IS42S16160D ports_1 = {
    		XS1_PORT_16B, 
		XS1_PORT_1J, 
		XS1_PORT_1I, 
		XS1_PORT_1K, 
		XS1_PORT_1L, 
		XS1_CLKBLK_1 
	};

Notes
-----

The ``sdram_server`` and application must be on the same tile.


Source code structure
---------------------

Directory Structure
+++++++++++++++++++

A typical SDRAM application will have at least three top level directories. The application will be contained in a directory starting with ``app_``, the sdram module source is in 
the ``module_sdram`` directory and the directory ``module_xcommon`` contains files required to build the application. ::
    
    app_[my_app_name]/
    module_sdram/
    module_xcommon/

Of course the application may use other modules which can also be directories at this level. Which modules are compiled into the application is controlled by the ``USED_MODULES`` define in the application Makefile.

Key Files
+++++++++

The following header file contains prototypes of all functions required to use use the SDRAM 
module. The API is described in :ref:`sec_api`.

.. list-table:: Key Files
  :header-rows: 1

  * - File
    - Description
  * - ``sdram.h``
    - SDRAM API header file

Module Usage
------------

To use the SDRAM module first set up the directory structure as shown above. Create a file in the ``app`` folder called ``sdram_conf.h`` and into it insert a define for ``SDRAM_DEFAULT_IMPLEMENTATION``.  It should be defined as the implementation you want to use, for example for the Slicekit the following would be correct::

	#define SDRAM_DEFAULT_IMPLEMENTATION PINOUT_V1_IS42S16160D

Declare the ``sdram_ports`` structure used by the ``sdram_server``. This will look like::

	struct sdram_ports sdram_ports = {
		XS1_PORT_16A, 
		XS1_PORT_1B, 
		XS1_PORT_1G, 
		XS1_PORT_1C, 
		XS1_PORT_1F, 
		XS1_CLKBLK_1 
	}; 

Next create a ``main`` function with a par of both the ``sdram_server`` function and an application function, these will require a channel to connect them. For example::

	int main() {
	  chan sdram_c;
	  par {
	    sdram_server(sdram_c, sdram_ports);
	    application(sdram_c);
	  }
	  return 0;
	}

Now the ``application`` function is able to use the SDRAM server.

SDRAM Memory Mapper Programming Guide
=====================================

The SDRAM memory mapper has a simple interface where to the ``mm_read_words`` and ``mm_write_words`` a virtual address is passes, this virtual address is mapped to a physical address and the I/O is performed there. The ``mm_wait_until_idle`` exists so that the application can run the I/O commands in a non-blocking manner then confirm that the command has when the ``mm_wait_until_idle`` returns.


Software Requirements
---------------------

The component is built on xTIMEcomposer Tools version 12.0.
The component can be used in version 12.0 or any higher version of xTIMEcomposer Tools.
