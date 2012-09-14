SDRAM Programming Guide
=======================

This section provides information on how to program applications using
the SDRAM module.

Multiple SDRAM Support
----------------------
It is possible for the application to drive multiple SDRAM devices simultaniously. This is achieved by instantiating the specific implimentation. For example, instead of calling ``sdram_server`` (whilst having SDRAM_DEFAULT_IMPLEMENTATION set) the application would call sdram_server_IMPL_1 and sdram_server_IMPL_2. All uses of the SDRAM servers would need to be refered to by their respective calls, i.e. ``_IMPL`` need to be added to the calls to the server to allow the command to end at the correct SDRAM server.

.. toctree::

   structure
   app_tutorial
   support
