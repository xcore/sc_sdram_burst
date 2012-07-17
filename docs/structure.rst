Source code structure
---------------------

.. list-table:: Project structure
  :header-rows: 1
  
  * - Project
    - File
    - Description
  * - module_sdram_burst_new
    - ``sdram_server.h`` 
    - Header file containing the APIs for the SDRAM component
  * - 
    - ``sdram_server.xc``
    - File containing the implementation of the SDRAM component including the SDRAM threads, SDRAM reads and writes
  * - 
    - ``sdram_internal.h``
    - Header file containing the internal defines used by the SDRAM component
  * - 
    - ``sdram_client.xc``
    - File containing the implementation of the internal APIs used by the SDRAM component. These APIs are used by the ``sdram_server.xc``