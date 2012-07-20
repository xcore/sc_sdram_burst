Overview
========

The SDRAM component is designed to access a 16 bit SDRAM. The component is used to read data from the SDRAM and to write data to the SDRAM.
SDRAM memory types are widely used in embedded applications which need huge memory space to store data. Most practical applications include storing audio content, image content and so on. The SDRAM component is designed in such a way that it can be easily configured according to the SDRAM used.

The target specific part of the component is based on SDRAM IS42S16100F.

Component Summary
+++++++++++++++++

+----------------------------------------------------------------+
|                     ** Functionality **                        |
+----------------------------------------------------------------+
|  To perform read and write on SDRAM                            |
+----------------------------------------------------------------+
|                    ** Supported Devices**                      |
+-------------------------------+--------------------------------+
| | XMOS devices                | | XS1-L1                       |
|                               | | XS1-L2                       |
|                               | | XS1-G4                       |
+-------------------------------+--------------------------------+
|                     ** Requirements **                         |
+-------------------------------+--------------------------------+
| XMOS Desktop Tools            | V11.11.0 or later              |
+-------------------------------+--------------------------------+
| XMOS SDRAM component          | 1v0                            |
+-------------------------------+--------------------------------+
|                     **Licensing and Support**                  |
+----------------------------------------------------------------+
| Component code provided without charge from XMOS.              |
| Component code is maintained by XMOS.                          |
+----------------------------------------------------------------+

SDRAM component properties
++++++++++++++++++++++++++

An SDRAM's architecture includes having banks, data stored in the format of rows with each row having certain number of column. The component can be configured in order to support various SDRAM available in the market. 
The component can be configured for 
  * Number of banks,
  * Number of rows in each bank,
  * Number of columns in each row,
  * The width of each column (8/16/32 etc),
  * Number of refresh cycles required by the SDRAM,
  * Control commands needed for read, write, refresh and so on.

The SDRAM component uses one thread.

Resource requirements
=====================


The resource requirements for the SDRAM component are:

+--------------+-----------------------------------------------+
| Resource     | Usage                            	       |
+==============+===============================================+
| Channels     | 1 		                               |
+--------------+-----------------------------------------------+
| Timers       | 1 (for deciding the SDRAM setup, read,        |
|	       |    write delays)			       |
+--------------+-----------------------------------------------+
| Clocks       | 1 (the SDRAM clock)                           |
+--------------+-----------------------------------------------+
| Threads      | 1                                             |
+--------------+-----------------------------------------------+

Memory usage for the SDRAM component is:


+------------------+----------------------------------------+
| Resource         | Usage                            	    |
+==================+========================================+
| Stack            | 32 bytes                               |
+------------------+----------------------------------------+
| Program          | 2700 bytes                             |
+------------------+----------------------------------------+
