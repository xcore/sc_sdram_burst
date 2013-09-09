SliceKit Support
================

Port Map
--------

The XA-SK-SDRAM Slice Card implements PINOUT_V1_IS42S16400F implementation of the SDRAM server. The options a SliceKit user has for interfacing with a XA-SK-SDRAM Slice Card are as follows:

+-----------+-----------------------------------------------------------+
|           |                          XP-SKC-L2                        |
+           +-----------------------------------------------------------+
| Port Name |    CIRCLE    |    SQUARE    |    TRIANGLE  |      STAR    |
+===========+===========================================================+
| DQ_AH     | XS1_PORT_16A | XS1_PORT_16A | XS1_PORT_16B | XS1_PORT_16A |
+-----------+--------------+--------------+--------------+--------------+
| CAS       | XS1_PORT_1J  | XS1_PORT_1B  | XS1_PORT_1J  | XS1_PORT_1B  |
+-----------+--------------+--------------+--------------+--------------+
| RAS       | XS1_PORT_1I  | XS1_PORT_1G  | XS1_PORT_1I  | XS1_PORT_1G  |
+-----------+--------------+--------------+--------------+--------------+
| WE        | XS1_PORT_1K  | XS1_PORT_1C  | XS1_PORT_1K  | XS1_PORT_1C  |
+-----------+--------------+--------------+--------------+--------------+
| CLK       | XS1_PORT_1L  | XS1_PORT_1F  | XS1_PORT_1L  | XS1_PORT_1F  |
+-----------+--------------+--------------+--------------+--------------+

Caveats
-------

XP-SKC-L2 CIRCLE   - Only the first 12 bits of 16A avaliable, hence standard SDRAM server wont work.
XP-SKC-L2 STAR     - ``XMOS LINK`` must be off, this will disable the use of xscope.
XP-SKC-L2 TRIANGLE - SPI flash must be disbaled after boot (include module_slicekit_support).




