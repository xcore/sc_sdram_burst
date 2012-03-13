XCORE.com SDRAM SOFTWARE COMPONENT
..................................

:Latest release: 2.0.0rc0
:Maintainer: djpwilk
:Description: SDRAM driver software component





Key Features
============

  * One thread reads/writes data to SDRAM
  * Optimised for burst access of blocks of 32 bit words (not for random access) with 12.5 MHz sdram clock.
  * Application retains control of refresh by calling sdram_refresh at
    appropriate to prevent unexpected delays
  * 16-bit - Peak write: 25MB/s, read 25MB/s. 
  * Code size: 2KB
  * Thread count: 1

To Do
=====

* Add build options for 8 and 4 bit data bus width
* Improve clock speed to 25 MHz
* Rework sdram burst write and read code to used fully timestamped IO and deprecate the p_sdram_gate mechanism

Firmware Overview
=================

 * module_sdram_burst: the burst mode driver
 * app_sdram_burst_example: contains a c client and an xc test harness
 
Documentation
=============

Full documentation can be found at: http://xcore.github.com/sc_sdram_burst/

Known Issues
============

* Two warnings produced in XDE 11.2 related to buffered port for DQ which has its direction reversed. This warning can be ignored.

Support
=======

Issues may be submitted via the Issues tab in this github repo. Response to any issues submitted are at the discretion of the maintainer of this component.

Required software (dependencies)
================================

  * xcommon (if using development tools earlier than 11.11.0)

