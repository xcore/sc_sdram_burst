Source code structure
---------------------

.. list-table:: Component structure
  :header-rows: 1
  
  * - Component
    - File
    - Description
  * - module_sdram_burst_new
    - ``sdram_server.h`` 
    - Header file containing the APIs for the SDRAM component
  * - 
    - ``sdram_server.xc``
    - File containing the implementation of the SDRAM component including the SDRAM threads, internal APIs used to handle the SDRAM commands and SDRAM refresh
  * - 
    - ``sdram_internal.h``
    - Header file containing the defines for the SDRAM commands supported. It also includes the declaration of target specific APIs
  * - 
    - ``sdram_client.xc``
    - File containing the implementation of the command APIs which are used to submit request to the SDRAM. 
  * - 
    - ``sdram_methods.xc``
    - File containing the target specific implementation