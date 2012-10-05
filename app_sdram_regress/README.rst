SDRAM Regression Application
============================

:scope: Example
:description: A software regression to aid implementing new SDRAM interfaces and verifying current ones.
:keywords: SDRAM, memory
:boards: XA-SK-SDRAM

The demo runs a series of regression tests of increasing difficulty, beginning 
from using a single core for the sdram_server with one core loaded progressing 
to all cores being loaded to simulate an XCore under full load. 
