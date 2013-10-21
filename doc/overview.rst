Overview
========

SDRAM Controller Component
--------------------------

The SDRAM module is designed for 16 bit read and write access of arbitrary length at up to 50MHz clock rates. It uses an optimal pinout with address and data lines overlaid to implement 16 bit read/write with up to 13 address lines in just 20 pins.

The module currently targets the ISSI 6400 SDRAM but may easily any single data rate SDRAM memory from other manufacturers.

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
     * full row(page) read,
     * full row(page) write,
     * refresh handled by the SDRAM component itself.
  * Requires a single core for the server.
     * The function ``sdram_server`` requires just one core, the client functions, located in ``sdram.h`` are very low overhead and are called from the application.



Memory Requirements
+++++++++++++++++++

+------------------+----------------------------------------+
| Resource         | Usage                            	    |
+==================+========================================+
| Stack            | 256 bytes                              |
+------------------+----------------------------------------+
| Program          | 10272 bytes                            |
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

The achievable effective bandwidth varies according to the available xCORE MIPS. This information has been obtained by testing on real hardware.

+------------+-------+--------------+----------------+------------------+
| xCORE MIPS | Cores | System Clock |Max Read (MB/s) | Max Write (MB/s) | 
+============+=======+==============+================+==================+
| 50         | 8     | 400MHz       | 66.84          | 70.75            | 
+------------+-------+--------------+----------------+------------------+
| 57         | 7     | 400MHz       | 68.13          | 71.68            | 
+------------+-------+--------------+----------------+------------------+
| 66         | 6     | 400MHz       | 69.83          | 73.41            | 
+------------+-------+--------------+----------------+------------------+
| 80         | 5     | 400MHz       | 71.68          | 74.99            | 
+------------+-------+--------------+----------------+------------------+
| 100        | 4     | 400MHz       | 71.89          | 75.22            | 
+------------+-------+--------------+----------------+------------------+
| 100        | 3     | 400MHz       | 71.89          | 75.22            | 
+------------+-------+--------------+----------------+------------------+
| 100        | 2     | 400MHz       | 71.89          | 75.22            | 
+------------+-------+--------------+----------------+------------------+
| 62.5       | 8     | 500MHz       | 66.82          | 70.34            | 
+------------+-------+--------------+----------------+------------------+
| 83         | 7     | 500MHz       | 68.08          | 71.47            | 
+------------+-------+--------------+----------------+------------------+
| 100        | 6     | 500MHz       | 69.83          | 73.19            | 
+------------+-------+--------------+----------------+------------------+
| 125        | 5     | 500MHz       | 71.68          | 74.76            | 
+------------+-------+--------------+----------------+------------------+
| 125        | 4     | 500MHz       | 71.89          | 74.99            | 
+------------+-------+--------------+----------------+------------------+
| 125        | 3     | 500MHz       | 71.89          | 74.99            | 
+------------+-------+--------------+----------------+------------------+
| 125        | 2     | 500MHz       | 71.89          | 74.99            | 
+------------+-------+--------------+----------------+------------------+

SDRAM Memory Mapper
-------------------

A memory mapper module called ``module_sdram_memory_mapper`` may be used in order to abstract the physical geometry of the SDRAM from the application. Its only function is to map the physical geometry of the SDRAM to a virtual byte addresses that the application can use. 

Memory Requirements
+++++++++++++++++++

+------------------+----------------------------------------+
| Resource         | Usage                            	    |
+==================+========================================+
| Stack            | 0 bytes                                |
+------------------+----------------------------------------+
| Program          | 32 bytes                               |
+------------------+----------------------------------------+

Resource Requirements
+++++++++++++++++++++

+---------------+-------+
| Resource      | Usage |
+===============+=======+
| Channels      |   0   |
+---------------+-------+
| Timers        |   0   |
+---------------+-------+
| Clocks        |   0   |
+---------------+-------+
| Logical Cores |   0   |
+---------------+-------+


