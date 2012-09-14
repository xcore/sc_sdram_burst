Source code structure
---------------------

Directory Structure
+++++++++++++++++++

A typical SDRAM application will have at least three top level directories. The application 
will be contained in a directory starting with ``app_``, the sdram module source is in 
the ``module_sdram`` directory and the directory ``module_xcommon`` contains files required 
to build the application.

::
    
    app_[my_app_name]/
    module_sdram/
    module_xcommon/

Of course the application may use other modules which can also be directories at this level. 
Which modules are compiled into the application is controlled by the ``USED_MODULES`` define 
in the application Makefile.

Key Files
+++++++++

The following header file contain prototypes of all functions required to use use the SDRAM 
module. The API is described in :ref:`sec_api`.

.. list-table:: Key Files
  :header-rows: 1

  * - File
    - Description
  * - ``sdram.h``
    - SDRAM API header file
