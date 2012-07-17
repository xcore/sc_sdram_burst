Component Description
=====================

SDRAM component feature
-----------------------

A 16 bit SDRAM module has been implemented for this project. 

The SDRAM component has the following features:

	* Configurable number of banks, number of rows, size of the row, configurable signal levels depending on the SDRAM used
	* Configuration of the SDRAM using the file ``sdram_configuration.h``. Please refer to section 'External files' for more details
	* Supports block read, block write, write a line, read a line, read a line partially and self refresh

The SDRAM (IS42VS16100F) used in this project is a 16 Mb SDRAM. The SDRAM has 2 banks each supporting 512 K words.
Each bank in the SDRAM has 2048 rows. Each row comprises of 256 16 bit data. These configurations can also be seen in the file ``sdram_configuration.h``
The SDRAM structure looks like as shown below

.. only:: html

  .. figure:: images/sdram.png
     :align: center

     SDRAM architecture

.. only:: latex

  .. figure:: images/sdram.pdf
     :figwidth: 50%
     :align: center

     SDRAM architecture

Example of SDRAM usage
----------------------

SDRAM component is widely used to store huge data content like images for LCD, music content for the player and so on.
Some cases might need block reads//writes - example: Audio content
Some cases might need line reads// writes - example: LCD image data

The below example shows how an LCD image is packed in SDRAM.
Consider LCD of size 480 * 272 pixels (480 pixels in each of the 272 rows)
Each row in LCD needs 480 * 2 bytes (for 16 bit 565 RGB colour) = 960 bytes
Each row in SDRAM has 256 (columns) * 2 bytes = 512 bytes
So each LCD row will need nearly 2 rows in the SDRAM.
The images in the SDRAM are packed in such a manner that there is no wastage of space while writing the rows. Thus SDRAM can have 8 full size image buffers. (i.e.) Bank 0 of size 2048 rows can store 4 images, 510 * 4 = 2040 rows. Bank 1 of size 2048 rows can store 4 images, 510 * 4 = 2040 rows.
Of the 8 available image buffers, 2 buffers will be used by the LCD frame. So leaving the LCD frame buffers, the user can store 6 full size images in the SDRAM.

The main function :c:func:`sdram_server` in the file ``sdram_server.xc`` is handled in a thread.
The read and write functions have been described in the section 'API'