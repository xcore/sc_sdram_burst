SDRAM Testbench Application
============================

:scope: Example
:description: A software testbench to aid implementing new SDRAM interfaces and verifying current ones.
:keywords: Memory,SDRAM
:boards: XA-SK-SDRAM

The demo runs a series of regression tests of increasing difficulty, beginning 
from using a single core for the sdram_server with one core loaded progressing 
to all cores being loaded to simulate an xCORE under full load. Note, this runs
indefinatly, it is meant as a test tool. 
