<h1>DLL Definitions</h1>

These definitions control the importing and exporting of functions within the DLL.

You can prefix your five required callbacks with the PLUGIN_API macro to declare
them as exported C functions.  The XPLM_API macro identifies functions that are
provided to you via the plugin SDK.  (Link against XPLM.lib to use these functions.)

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>