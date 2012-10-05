.. _sdram_regress_Quickstart:

sc_sdram_burst demo : Quick Start Guide
---------------------------------------

This simple demonstration of xTIMEcomposer Studio functionality uses the XA-SK-SDRAM Slice Card together with the xSOFTip module_sdram to demonstrate how the module is used to read and write to the SDRAM.

Hardware Setup
++++++++++++++

The XP-SKC-L2 Slicekit Core board has four slots with edge conectors: ``SQUARE``, ``CIRCLE``,``TRIANGLE`` and ``STAR``. 

To setup up the system:

   #. Connect XA-SK-SDRAM Slice Card to the XP-SKC-L2 Slicekit Core board using the connector marked with the ``STAR``.
   #. Connect the XTAG Adapter to Slicekit Core board, and connect XTAG-2 to the adapter. 
   #. Connect the XTAG-2 to host PC. Note that the USB cable is not provided with the Slicekit starter kit.
   #. Set the ``XMOS LINK`` to ``OFF`` on the XTAG Adapter.
   #. Switch on the power supply to the Slicekit Core board.

.. figure:: images/hardware_setup.jpg
   :width: 400px
   :align: center

   Hardware Setup for SDRAM Demo
   
	
Import and Build the Application
++++++++++++++++++++++++++++++++

   #. Open xTIMEcomposer and check that it is operating in online mode. Open the edit perspective (Window->Open Perspective->XMOS Edit).
   #. Locate the ``'Slicekit SDRAM Regression'`` item in the xSOFTip pane on the bottom left of the window and drag it into the Project Explorer window in the xTIMEcomposer. This will also cause the modules on which this application depends (in this case, module_sdram) to be imported as well. 
   #. Click on the app_sdram_regress item in the Explorer pane then click on the build icon (hammer) in xTIMEcomposer. Check the console window to verify that the application has built successfully.

For help in using xTIMEcomposer, try the xTIMEcomposer tutorial. FIXME add link.

Note that the Developer Column in the xTIMEcomposer on the right hand side of your screen provides information on the xSOFTip components you are using. Select the module_sdram component in the Project Explorer, and you will see its description together with API documentation. Having done this, click the `back` icon until you return to this quickstart guide within the Developer Column.

Run the Application
+++++++++++++++++++

Now that the application has been compiled, the next step is to run it on the Slicekit Core Board using the tools to load the application over JTAG (via the XTAG2 and Xtag Adaptor card) into the xCORE multicore microcontroller.

   #. Click on the ``Run`` icon (the white arrow in the green circle). The debug console window in xTIMEcomposer should then display the ::

  Test suite begin
  8 threaded test suite start
  Begin sanity_check
  ...
   #. If the above isn't seen then check that the ``XMOS LINK`` is set to ``OFF`` then repeat.
    
Next Steps
++++++++++

Try the Demonstration and Benchmark Demo
........................................

   #. After completing this demo there are two more application to try: 

:ref:``sdram_demo_Quickstart`
:ref:``sdram_benchmark_Quickstart`
   
