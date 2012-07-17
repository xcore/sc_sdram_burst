Overview
========

The SDRAM component is used to access a 16 bit external SDRAM used in the system. The component is designed to do read/ write from/to the SDRAM. 
The component has been based on the SDRAM IS42S16100F.

Component Summary
+++++++++++++++++

+----------------------------------------------------------------+
| 	               ** Functionality **	      		 |
+----------------------------------------------------------------+
|  To perfom read and write operation on a 16 bit external SDRAM |
+----------------------------------------------------------------+
| 		      ** Supported Device **		         |
+-------------------------------+--------------------------------+
| | XMOS devices	        | | XS1-L1                       |
|			        | | XS1-L2		         |
| 			        | | XS1-G4			 |
+-------------------------------+--------------------------------+
|  	               ** Requirements ** 		         |
+-------------------------------+--------------------------------+
| XMOS Desktop Tools		| V11.11.0 or later	         |
+-------------------------------+--------------------------------+
| XMOS LCD component	        | 1v0  	         	         |
+-------------------------------+--------------------------------+
| XMOS SDRAM component		| 1v0	              		 |
+-------------------------------+--------------------------------+
|                     **Licensing and Support**                  |
+----------------------------------------------------------------+
| Component code provided without charge from XMOS.              |
| Component code is maintained by XMOS.                          |
+----------------------------------------------------------------+


SDRAM component properties
++++++++++++++++++++++++++

	* SDRAM component can be configured for number of banks, rows and columns in the SDRAM
	* Proper packing of the data so that no space is left unused. This helps the user to effectively store more images in the SDRAM
	* Has 2 SDRAM banks. The "self-refresh" mode in also supported
	* Uses one thread

Resource requirements
=====================


The resource requirements for the SDRAM component are:

+--------------+-----------------------------------------------+
| Resource     | Usage                            	       |
+==============+===============================================+
| Channels     | 1 		                               |
+--------------+-----------------------------------------------+
| Timers       | 1 (for deciding the SDRAM setup, read,        |
|	       |    write delays)			       |
+--------------+-----------------------------------------------+
| Clocks       | 1 (the SDRAM clock)                           |
+--------------+-----------------------------------------------+
| Threads      | 1                                             |
+--------------+-----------------------------------------------+
