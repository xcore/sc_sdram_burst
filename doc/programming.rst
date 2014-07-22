
SDRAM programming guide
=======================

This section provides information on how to program applications using the SDRAM module.

SDRAM default implementation
----------------------------
By default the SDRAM module is configured for the IS42S16400F by ISSI. 


Port declaration
----------------

The required ports to access the physical SDRAM are shown in :ref:`sec_physical`. All the ports are to be declared in a structure called ``sdram_ports`` which can be found in :ref:`sec_api`. This is tile specific and will require ``on tile[N]: `` in multi-tile solutions. 


Client/Server model
-------------------

The SDRAM server must be instantiated at the same level as its clients. For example::

chan c_sdram[1];
par {
	sdram_server(c_sdram, 1, sdram_ports);
	client_of_the_sdram_server(c_sdram[0]);
}

would be the mimimum required to correctly setup the SDRAM server and connect it to a client. An example of a multi-client system would be::

chan c_sdram[4];
par {
	sdram_server(c_sdram, 4, sdram_ports);
	client_of_the_sdram_server_0(c_sdram[0]);
	client_of_the_sdram_server_1(c_sdram[1]);
	client_of_the_sdram_server_2(c_sdram[2]);
	client_of_the_sdram_server_3(c_sdram[3]);
} 

Note: The ``sdram_server`` and application(s) must be on the same tile.

Command buffering
-----------------

The SDRAM server implements a 8 slot command buffer per client. This means that the client can queue up to 8 commands to the SDRAM server through calls to ``sdram_read`` or ``sdram_write``. A successful call to ``sdram_read`` or ``sdram_write``will return 0 and issue the command to the command buffer. When the command buffer is full then a call to ``sdram_read`` or ``sdram_write`` will return 1 and not issue the command.  Commands are completed, i.e. a slot is freed, when ``sdram_complete`` returns. Commands are processed as in a first in first out ordering.


Initialisation
--------------

Each client of the SDRAM server must declare the structure ``s_sdram_state`` once and only once and with it call ``sdram_init_state``. This will do all the required setup for the command buffering. From here on the client is able to call ``sdram_read`` and ``sdram_write`` to access the physical memory. For example::

   s_sdram_state sdram_state;
   sdram_init_state(c_server, sdram_state);

where ``c_server`` is the channel to the ``sdram_server``.


Safety through the use of movable pointers
------------------------------------------
The API makes use of movable pointer to aid correct multi-threaded memory handeling. ``sdram_read`` and ``sdram_write`` pass ownership of the memory from the client to the server. The client is now longer able to access the memory. The memory ownership is returned to the client on a call return from ``sdram_complete``. For example::

   unsigned buffer[N];
   unsigned * movable buffer_pointer = buffer;

   //buffer_pointer is fully accessable

   sdram_read (c_server, sdram_state, bank, row, col, words, move(buffer_pointer));

   //during this region the buffer_pointer is null and cannot be read from or written to

   sdram_complete(c_server, sdram_state, buffer_pointer);

   //now buffer_pointer is accessable again

During the scope of the movable pointer variable it is permissible that the pointer points at any memory location, however, at the end of the scope the pointer must point at its original instination. 

For example::

{
   unsigned buffer_0[N];
   unsigned buffer_1[N];
   unsigned * movable buffer_pointer_0 = buffer_0;
   unsigned * movable buffer_pointer_1 = buffer_1;

   sdram_read (c_server, sdram_state, bank, row, col, words, move(buffer_pointer_0));
   sdram_write (c_server, sdram_state, bank, row, col, words, move(buffer_pointer_1));

   //both buffer_pointer_0 and buffer_pointer_1 are null here

   sdram_complete(c_server, sdram_state, buffer_pointer_0);
   sdram_complete(c_server, sdram_state, buffer_pointer_1);
}

Would be acceptable but the following would not::

{
   unsigned buffer_0[N];
   unsigned buffer_1[N];
   unsigned * movable buffer_pointer_0 = buffer_0;
   unsigned * movable buffer_pointer_1 = buffer_1;

   sdram_read (c_server, sdram_state, bank, row, col, words, move(buffer_pointer_0));
   sdram_write (c_server, sdram_state, bank, row, col, words, move(buffer_pointer_1));

   //both buffer_pointer_0 and buffer_pointer_1 are null here

   sdram_complete(c_server, sdram_state, buffer_pointer_1);	//return to opposite pointer
   sdram_complete(c_server, sdram_state, buffer_pointer_0);
}

as the movable pointers are no longer point at the same memory when leaving scope as they were when the were instianted. 

Shutdown
--------

The ``sdram_server`` may be shutdown, i.e. the thread and all its resources may be freed, with a call to ``sdram_shutdown``.


Source code structure
---------------------

Directory Structure
+++++++++++++++++++

A typical SDRAM application will have at least two top level directories. The application will be contained in a directory starting with ``app_`` and the SDRAM module source is in 
the ``module_sdram`` directory. ::
    
    app_[my_app_name]/
    module_sdram/

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

Software Requirements
---------------------

The component is built on xTIMEcomposer Tools version 13.1.
The component can be used in version 13.1 or any higher version of xTIMEcomposer Tools.
