Executing The Project
---------------------
The component by itself cannot be build or executed separately.
The component should be linked in an application which needs graphics a 16 bit external SDRAM. Once the component is linked to the application, the application can be built and tested for accessing the SDRAM.

The following should be done in order to link the component to the application project
  #. The SDRAM parameters should be configured according to the 16 bit SDRAM used. The application using the SDRAM is expected to carry a file called sdram_configuration.h which should carry the configuration information
     The contents of the sdram_configuration file can be seen in the section 'External files'
  #. The module name 'module_sdram_burst_new' should be added to the list of MODULES in the application project build options
  #. The object names 'sdram_server' and 'sdram_client' should be added to the list of OBJECT NAMES in the application project build options
  #. The module 'module_sdram_burst_new' should be added in the 'References' section in the application Project settings
  #. Now the module is linked to the application and can be directly used
