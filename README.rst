SDRAM Repository
................

:Latest release: 1.0.0alpha5
:Maintainer: andrewstanfordjason
:Description: Various modules related to controlling external sdram


Key Features
============

   * SDRAM read and write 
   * Automatically managed refresh
   * 20 pins used
   * 16 bit data bus
   * 50MHz clock

Firmware Overview
=================

The SDRAM module is designed for 16 bit read and write access of arbitrary length at up to 50MHz clock rates. It uses an optimised pinout with address and data lines overlaid along with other pinout optimisations in order to implement 16 bit read/write with up to 13 address lines in just 20 pins.

Documentation can be found at http://github.xcore.com/sc_sdram/docs/index.html

Known Issues
============

none

Support
=======

Issues may be submitted via the Issues tab in this github repo. Response to any issues submitted as at the discretion of the maintainer for this line.

Required software (dependencies)
================================

  * sc_util (git@github.com:xcore/sc_util)

