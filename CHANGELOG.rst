sc_sdram_burst Change Log
=========================

1.0.6
-----
  * Fixed init code
  * Fixed bug in refresh timing
  * Renamed regress application to testbench

1.0.5
-----
  * Fixed regression test bug where code was not properly generalised
  * Added manafacture test app

1.0.4
-----
  * Extended control defines to work for 4 bit ports in an arbitrary way

1.0.3
-----
  * Added PINOUT_V2_IS42S16400F target
  * Added cc_tops and bottoms to all the assembly for elimination if unused

1.0.2
-----
  * Added sdram_col_write() for writing to a single column quickly

1.0.1
-----
  * Minor fix to demo apps (declare port structures on the correct tile)

1.0.0
-----
  * Initial Version
