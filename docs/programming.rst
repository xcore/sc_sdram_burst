
SDRAM Programming Guide
=======================

This section provides information on how to program applications using the SDRAM module.

Single SDRAM Support
--------------------

As always a default implementation must be selected in ``sdram_conf.h``. When calling the function ``sdram_server`` it is implied that the default implimentation will be called.

Multiple SDRAM Support
----------------------

It is possible for the application to drive multiple SDRAM devices simultaniously. As with the above a default implimentation must be selected in ``sdram_conf.h``. To use a specific SDRAM implementation, add a suffix to the function you wish to call. For example, to call the server function for the PINOUT_V1_IS42S16160D implementation 
::
	sdram_server_PINOUT_V1_IS42S16160D(server, p);

To declare ports for a particular implementation the same method is used. To follow the above example the ports would be declared as 
::
	struct sdram_ports sdram_ports_PINOUT_V1_IS42S16160D = { 
	  //port declarations here
	};

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

The following header file contain prototypes of all functions required to use use the SDRAM 
module. The API is described in :ref:`sec_api`.

.. list-table:: Key Files
  :header-rows: 1

  * - File
    - Description
  * - ``sdram.h``
    - SDRAM API header file

Module Usage
------------

To use the SDRAM module first set up the directory structure as shown above. Create a file in the ``app`` folder called ``sdram_conf.h`` and into it insert a define for ``SDRAM_DEFAULT_IMPLEMENTATION``.  It should be defined as the implementation you want to use, for example for the Slicekit the following would be correct,
::
	#define SDRAM_DEFAULT_IMPLEMENTATION PINOUT_V1_IS42S16160D

Declare the ``sdram_ports`` structure used by the ``sdram_server``. This will look like:
::
	struct sdram_ports sdram_ports = {
		XS1_PORT_16A, 
		XS1_PORT_1B, 
		XS1_PORT_1G, 
		XS1_PORT_1C, 
		XS1_PORT_1F, 
		XS1_CLKBLK_1 
	}; 

Next create a ``main`` function with a par of both the ``sdram_server`` function and an application function, these will require a channel to connect them. For example,
::

	int main() {
	  chan sdram_c;
	  par {
	    sdram_server(sdram_c, sdram_ports);
	    application(sdram_c);
	  }
	  return 0;
	}

Now the ``application`` function is able to use the SDRAM server.
