Overview
========

SDRAM Controller Component
--------------------------

The SDRAM module is designed for 16 bit read and write access of arbitrary length at up to 62.5MHz clock rates. It uses an optimised pinout with address and data lines overlaid along with other pinout optimisations in order to implement 16 bit read/write with up to 13 address lines in just 20 pins.

The module currently targets the ISSI 6400 SDRAM but is easily specialised for the smaller and larger members of this family as well as single data rate SDRAM memory from other manufacturers.

SDRAM Component Features
++++++++++++++++++++++++

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
     * one or more clients
     * asynchronous command decoupling with a command queue of length 8 for each client
     * refresh handled by the SDRAM component itself.
  * Requires a single core for the server.
  * Up to 7 clients to the SDRAM server.

Memory requirements
+++++++++++++++++++

+------------------+----------------------------------------+
| Resource         | Usage                            	    |
+==================+========================================+
| Stack            | xxx bytes                              |
+------------------+----------------------------------------+
| Program          | xxxxx bytes                            |
+------------------+----------------------------------------+

Resource requirements
+++++++++++++++++++++

+---------------+-------+
| Resource      | Usage |
+===============+=======+
| Channels      |   1   |
+---------------+-------+
| Timers        |   1   |
+---------------+-------+
| Clocks        |   1   |
+---------------+-------+
| Logical Cores |   1   |
+---------------+-------+

Performance
+++++++++++

The achievable effective bandwidth varies according to the available XCore MIPS. This information has been obtained by testing on real hardware.

+------------+--------------+----------------+------------------+
| XCore MIPS | System Clock |Max Read (MB/s) | Max Write (MB/s) | 
+============+==============+================+==================+
| 62.5       | 500MHz       | 66.82          | 70.34            | 
+------------+--------------+----------------+------------------+
| 83         | 500MHz       | 68.08          | 71.47            | 
+------------+--------------+----------------+------------------+
| 100        | 500MHz       | 69.83          | 73.19            | 
+------------+--------------+----------------+------------------+
| 125        | 500MHz       | 71.68          | 74.76            | 
+------------+--------------+----------------+------------------+

