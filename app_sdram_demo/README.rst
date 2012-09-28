Demonstration application
=========================

:scope: Example
:description: A demo of how the module is used to accesses memory on the SDRAM.
:keywords: memory, SDRAM
:boards: XA-SK-SDRAM

The purpose of this application is to show how data is written to and read from 
the SDRAM in a safe manner. Important notes:

 - ``sdram_buffer_write`` commands the server to begin writing the buffer to SDRAM. 
   The buffer cannot be assumed to have been written to the SDRAM until the 
   ``wait_until_idle`` command returns.
 - ``sdram_buffer_read`` commands the server to begin reading the SDRAM into the 
   buffer. The same properties as the ``sdram_buffer_write`` apply to all commands, 
   hence, ``sdram_wait_until_idle`` is used to confirm that the data is in now in 
   the buffer.
