SDRAM Programming Guide
=======================

This section provides information on how to program applications using
the SDRAM module.

Multiple SDRAM Support
----------------------
It is possible for the application to drive multiple SDRAM devices simultaniously. This is achieved by instantiating the specific implimentation. For example, instead of calling ``sdram_server`` (whilst having SDRAM_DEFAULT_IMPLEMENTATION set) the application would call sdram_server_IMPL_1 and sdram_server_IMPL_2. All uses of the SDRAM servers would need to be refered to by their respective calls, i.e. ``_IMPL`` need to be added to the calls to the server to allow the command to end at the correct SDRAM server.

FIXME: This left me confused.

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

Module Usage
------------

FIXME: How do I go about using actually this module?
