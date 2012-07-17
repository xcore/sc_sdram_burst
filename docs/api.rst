Project structure
=================

The 'module_sdram_burst_new' is a standalone component and has no dependancy. The component can be linked to any project which needs an 16 bit external SDRAM.

Configuration Defines
---------------------

The following defines must be configured for the SDRAM component based on the SDRAM used.
The current implementation supports 16 bit SDRAM IS42S16100F. The configurations are based for this SDRAM.
The defines can be seen in the file ``sdram_configuration.h``

.. list-table:: SDRAM Defines
   :header-rows: 1
   :widths: 3 2 1
  
   * - Define
     - Description
     - Default
   * - **SDRAM_COL_BITS**
     - The number of bits in each column. The value indicates the data width.
     - 16
   * - **SDRAM_ROW_LENGTH**
     - Number of columns in each row of the SDRAM
     - 256
   * - **SDRAM_ROW_COUNT**
     - Number of rows in each bank of the SDRAM
     - 2048
   * - **SDRAM_BANK_COUNT**
     - Number of banks supported by the SDRAM
     - 2
   * - **SDRAM_REFRESH_MS**
     - The period of refresh required for the SDRAM. The value is given in terms of milliseconds 
     - 16
   * - **SDRAM_REFRESH_CYCLES**
     - Number of times the SDRAM to be refreshed for every SDRAM_REFRESH_MS
     - 2048
   * - **SDRAM_MODE_REGISTER**
     - Defines the configuration of the SDRAM. The user should go through the SDRAM datasheet to find the configuration of the SDRAM
     - 0x0027
   * - Control words
     - The control words is a combination of 4 lines  CS, WE, CAS, RAS. The user can change the control word values depending on the 
       SDRAM. The control words define the operation required for the SDRAM.
     - The below picture shows the default configuration of the SDRAM
.. only:: html

  .. figure:: images/sdram_config.png
     :align: center

     SDRAM configuration

.. only:: latex

  .. figure:: images/sdram_config.pdf
     :figwidth: 50%
     :align: center

     SDRAM configuration


API
---

The SDRAM module handles the 16 bit reads, writes and refresh of the SDRAM. The application using this SDRAM component can call the SDRAM APIs accordingly.

Note that to enable the application use the SDRAM module, the module should be added to the build options of the project 
To achieve that, the following is done

  #. The SDRAM component should be configured based on the SDRAM used.
  #. The name ``module_sdram_burst_new`` is added to list of  'MODULES' in the project build options. This will enable the application project to use the SDRAM module		    
  #. The object names 'sdram_server' and 'sdram_client' are added to the option 'OBJECT NAMES' in the project build option
  #. The module ``module_sdram_burst_new`` is added to the ``References`` option in the project settings of the application project
  #. Now the component is linked to the application and ready to use

The SDRAM code can be seen in

    * ``sdram_server.xc``
    * ``sdram.h``
    * ``sdram_client.xc``

This sections explains only the important APIs frequently used in the application. Other static APIs are not discussed in this section.
The other APIs can be found in the files mentioned above.   
The SDRAM APIs by themselves take care of the SDRAM refresh. The thread :c:func:`sdram_server` should be invoked in a 'par' statement for it to execute.


.. doxygenfunction:: sdram_server
.. doxygenfunction:: sdram_block_write
.. doxygenfunction:: sdram_block_read
.. doxygenfunction:: sdram_line_read_blocking
.. doxygenfunction:: sdram_line_read_nonblocking
.. doxygenfunction:: sdram_line_write
