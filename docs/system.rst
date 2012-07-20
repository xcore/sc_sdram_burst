Component Description
=====================

Basics of SDRAM
---------------

The Synchronous Dynamic Random Access Memory (SDRAM) types are being widely used in embedded applications due to their cost, speed and synchronous mechanism which helps us develop complex state machines by way of clocking each request.

The basic architecture of SDRAM includes memory cells organized into a two dimensional array of rows and columns.
To address a particular memory cell it is necessary to provide the row address and then select the column in which the cell is present. Once a row is accessed, SDRAM allows access of multiple columns in the same row without the need of providing the row address repeatedly. This helps to achieve higher speeds in SDRAM.
Each array of rows and columns is called a 'bank'. An SDRAM might have more than one bank.

In the example provided in this component, the target specific part is based on IS42S16100F. This SDRAM has the following:
  * 2 banks
  * 2048 rows in each bank
  * 256 columns in each row
  * Each 16 bit column

SDRAM needs a number of lines that controls the timing and operation.
The lines required for the SDRAM control are:

  +-------+------------------------------------------------------------------+
  | Lines |                    Description                                   |
  +=======+==================================================================+
  | /CAS  | Column Address Strobe: This is used alone with /RAS and /WE to   | 
  |       | select one of the 8 commands                                     | 
  +-------+------------------------------------------------------------------+
  | /CKE  | Clock Enable: When the signal is low the SDRAM is inhibited and  | 
  |       | no commands are interpreted                                      |
  +-------+------------------------------------------------------------------+
  | /CS   | Chip Select: An active low line to select a particular SDRAM     | 
  |       | chip                                                             |
  +-------+------------------------------------------------------------------+
  | DQM   | Data Mask: An active high on this line suppresses any I/O data   | 
  |       | Each 8 bit of data needs a DQM line. Example: a 16 bit SDRAM     |
  |       | need 2 DQM lines                                                 |
  +-------+------------------------------------------------------------------+
  | /RAS  | Row Address Strobe: This is used alone with /CAS and /WE to      | 
  |       | select one of the 8 commands                                     |
  +-------+------------------------------------------------------------------+
  | /WE   | Write Enable: This is used alone with /RAS and /CAS to select    | 
  |       | one of the 8 commands. It is mainly used to distinguish read and |
  |       | write commands                                                   |
  +-------+------------------------------------------------------------------+

The common commands supported by SDRAM includes:
  * Read
  * Write
  * Self refresh
  * Precharge
  * Device De-select
  * Clock suspend
  * Power down

SDRAM component feature
-----------------------

The SDRAM component is designed to support various SDRAM available in the market. The component includes the "Configurable code" and the "Fixed code".
The file ``sdram_methods.xc`` is the configurable file which has be edited based on the SDRAM used.
The other files ``sdram_server.xc`` and ``sdram_client.xc`` are the fixed part of the code which can be directly used.

The SDRAM component has the following features:

  * Configurability of 
     * number of banks,
     * number of rows,
     * number of columns,
     * data width of the column,
     * different commands supported,
     * signals used by the SDRAM.
  * Supports
     * Block read,
     * Block write,
     * Line read,
     * Line write,
     * Refresh handled by the SDRAM component itself.
  * The SDRAM configurations should be available in a file called 'sdram_configurations.h'
     * The file should be part of the application using the SDRAM component,
     * The file is included in `sdram.h`,
     * The file includes the configuration defines explained in section 'API',
     * A sample file is given in the section 'External_files',
  * The target specific part is based on SDRAM IS42S16100F
  * Uses one thread
     * The function `sdram_server` is executed in the thread
  * The Rows and columns are numbered from 0.

The structure of SDRAM IS42S16100F looks like as shown below

.. only:: html

  .. figure:: images/sdram.png
     :align: center

     SDRAM architecture

.. only:: latex

  .. figure:: images/sdram.pdf
     :figwidth: 50%
     :align: center

     SDRAM architecture


Example of SDRAM component usage
--------------------------------

The component uses SDRAM Is42S16100F. This SDRAM has the following features:
  * 2 banks,
  * 2048 rows,
  * 256 columns in each row,
  * 16 bit data,
  * This makes 2 banks * 2048 rows * 256 columns * 2 byte = 2 MB SDRAM.

This memory size is huge enough to store images or audio content.

Consider an example where the SDRAM is used to store the image content of size 240 * 320 pixels with 16 bit RGB color code.

This means a single image will need 240 rows * 320 pixels * 2 byte color = 153600 bytes.

Thus this SDRAM can accomodate 6 images of size 240 * 320 pixels in each bank. (Totally 12 images in 2 banks with a remaining space of 126976 bytes in each bank)

