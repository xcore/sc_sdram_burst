Component Description
=====================

Basics of SDRAM
---------------

The Synchronous Dynamic Random Access Memory (SDRAM) types are being widely used in embedded applications due to their cost and speed. 
The basic architecture of SDRAM includes memory cells organised into banks of two dimensional arrays of rows and columns. To address a particular memory cell it is necessary to provide the row and bank address and then select the column in which the desired cell is present. Once a row is accessed, SDRAM allows access of multiple columns in the same row without the need of providing the row and bank address repeatedly. This helps to achieve higher speeds in SDRAM.

SDRAM Component Feature
-----------------------

The SDRAM component is designed to support various SDRAMs available on the market.

The SDRAM component has the following features:

  * Configurability of 
     * SDRAM geometry,
     * clock rate,
     * refresh properties,
     * server commands supported,
     * port mapping of the SDRAM.
  * Supports
     * buffer read,
     * buffer write,
     * full row(page) read,
     * full row(page) write,
     * refresh handled by the SDRAM component itself.
  * Requires a single core for the server.
     * The function ``sdram_server`` requires just one core, the client functions, located in ``sdram.h`` are very low overhead and are called from the application.

