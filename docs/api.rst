Project structure
=================

The SDRAM component is available in the repository sc_sdram_burst (www.github.com/xcore/sc_sdram_burst) in the GitHub.
This is a standalone component and can be linked to any project which needs a 16 bit SDRAM.
The coomponent includes the module 'module_sdram_burst_new'.


Configuration Defines
---------------------

The following defines must be configured for the SDRAM component based on the SDRAM used.
The target used in this component is IS42S16100F and the default configuration shown here are based on this SDRAM.

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
     - Defines the configuration of the SDRAM. The value is given in the SDRAM datasheet
     - 0x0027
   * - Control words
     - The control words is a combination of 3 lines  WE, CAS, RAS. The user can change the control word values depending on the 
       commands supported by the SDRAM. 
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

The component should be linked to the application so that the application can use the component.
To achieve that, the following is done

  #. The SDRAM component is downloaded from the repository 'sc_sdram_burst',
  #. The module 'module_sdram_burst_new' is added to the workspace,
  #. The SDRAM component is configured according to the target used,
  #. The name 'module_sdram_burst_new' is added to list of  'MODULES' in the project build options. This will enable the application project to use the SDRAM module,
  #. The object names 'sdram_server','sdram_client','sdram_methods' and 'sdram_io' are added to the option 'OBJECT NAMES' in the project build option,
  #. The module 'module_sdram_burst_new' is added to the 'References' option in the project settings of the application project,
  #. Now the component is linked to the application and ready to use.

The SDRAM code can be seen in

  * ``sdram_server.xc``,
  * ``sdram.h``,
  * ``sdram_client.xc``,
  * ``sdram_methods.xc``.

The file ``sdram_methods.xc`` includes the configurable code which should be configured based on the target code. The current implementation is based on SDRAM IS42S16100F.


.. doxygenfunction:: sdram_server
.. only:: html

   .. figure:: images/sdram_server.png
      :align: center
     
.. only:: latex

   .. figure:: images/sdram_server.pdf
      :figwidth: 50%
      :align: center

.. doxygenfunction:: sdram_block_write
.. only:: html

   .. figure:: images/sdram_block_write.png
      :align: center

      
.. only:: latex

   .. figure:: images/sdram_block_write.pdf
      :figwidth: 50%
      :align: center

.. doxygenfunction:: sdram_block_read
.. only:: html

   .. figure:: images/sdram_block_read.png
      :align: center

      
.. only:: latex

   .. figure:: images/sdram_block_read.pdf
      :figwidth: 50%
      :align: center

.. doxygenfunction:: sdram_line_read_blocking
.. only:: html

   .. figure:: images/sdram_line_read_blocking.png
      :align: center

      
.. only:: latex

   .. figure:: images/sdram_line_read_blocking.pdf
      :figwidth: 50%
      :align: center

.. doxygenfunction:: sdram_line_read_nonblocking
.. only:: html

   .. figure:: images/sdram_line_read_nonblocking.png
      :align: center

      
.. only:: latex

   .. figure:: images/sdram_line_read_nonblocking.pdf
      :figwidth: 50%
      :align: center

.. doxygenfunction:: sdram_line_write
.. only:: html

   .. figure:: images/sdram_line_write.png
      :align: center

      
.. only:: latex

   .. figure:: images/sdram_line_write.pdf
      :figwidth: 50%
      :align: center


Target specific APIs
--------------------

The component includes the target specific APIs which are based on the SDRAM used.
These APIs are available in the file ``sdram_methods.xc`` and these APIs should be modified according to the SDRAM used.


.. doxygenfunction:: init
.. doxygenfunction:: write_row
.. doxygenfunction:: read_row
