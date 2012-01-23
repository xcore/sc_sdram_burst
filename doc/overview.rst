SDRAM Overview
==============

This is a burst optimised SDRAM driver (16 bit data bus) designed for the Micron SDRAM MT48LC16M16A2P-75, and is primarily designed for an off-chip data store for audio, packet and video buffering. It is probably not suitable for random access.

MT48LC16M16A2P-75
-----------------

This component has been designed for the Micron part above, which is featured on an add-on module for the XMOS XDK development kit. XDK users wanting to try this component should contact their FAE to request an SDRAM add-on card. The code can be modified for other SDRAM parts and/or for 4 or 8 bit data access.

Part Details:
 * 4 banks, 8192 rows, 256 32b columns
 * Total: 32MB, bank size: 8MB, row size: 1KB

