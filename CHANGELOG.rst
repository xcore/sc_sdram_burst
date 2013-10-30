sc_sdram_burst Change Log
=========================

1.1.0
-----
  * Fixed init code
  * Fixed bug in refresh timing
  * Renamed regress application to testbench
  * Fixed code so that no warnings are emitted (apart from "bidirectional buffered port not supported ") when compiling with xTIMEcomposer13.
  * Documentation tidy up
  * Fixed regression test bug where code was not properly generalised
  * Added manafacture test app
  * Extended control defines to work for 4 bit ports in an arbitrary way
  * Added PINOUT_V2_IS42S16400F target
  * Added cc_tops and bottoms to all the assembly for elimination if unused
  * Added sdram_col_write() for writing to a single column quickly

1.0.1
-----
  * Minor fix to demo apps (declare port structures on the correct tile)

1.0.0
-----
  * Initial Version
