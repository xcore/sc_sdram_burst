Using the component
-------------------
The component by itself cannot be build or executed separately.
The component should be linked to an application which needs a SDRAM. Once the component is linked to the application, the application can be built and tested for accessing the SDRAM.

To achieve that, the following is done

  #. The SDRAM component is downloaded from the repository 'sc_sdram_burst',,
  #. The module 'module_sdram_burst_new' is added to the workspace,
  #. The SDRAM component is configured according to the target used,
  #. The name 'module_sdram_burst_new' is added to list of  'MODULES' in the project build options. This will enable the application project to use the SDRAM module,
  #. The object names 'sdram_server','sdram_client','sdram_methods' and 'sdram_io' are added to the option 'OBJECT NAMES' in the project build option,
  #. The module 'module_sdram_burst_new' is added to the 'References' option in the project settings of the application project,
  #. Now the component is linked to the application and ready to use.



Testing The Component
---------------------
The project needs the SDRAM module for its testing.
Currently the project was tested on a customer hardware which uses the SDRAM for storing the LCD images.
To test the component, the hardware incluing the SDRAM should be built with the XMOS core on it.