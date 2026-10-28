<h1>Finding Plugins</h1>

These APIs allow you to find another plugin or yourself, or iterate
across all plugins.  For example, if you wrote an FMS plugin that needed to talk to
an autopilot plugin, you could use these APIs to locate the autopilot plugin.

---

<div class="sym-block sym-function" data-name="XPLMGetMyID" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetMyID { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns the plugin ID of the calling plug-in.  Call this to
get your own ID.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns XPLMPluginID -> assign to local/var
local my_pluginID = XPLMGetMyID(
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMCountPlugins" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCountPlugins { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns the total number of plug-ins that are loaded, both disabled and enabled.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns int -> assign to local/var
local my_result = XPLMCountPlugins(
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetNthPlugin" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetNthPlugin { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns the ID of a plug-in by index.  Index is 0 based from 0 to XPLMCountPlugins-1, inclusive.
Plugins may be returned in any arbitrary order.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns XPLMPluginID -> assign to local/var
local my_pluginID = XPLMGetNthPlugin(
    inIndex     -- int
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMFindPluginByPath" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMFindPluginByPath { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns the plug-in ID of the plug-in whose file exists at the passed in absolute file system
path.  XPLM_NO_PLUGIN_ID is returned if the path does not point to a currently loaded plug-in.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns XPLMPluginID -> assign to local/var
local my_pluginID = XPLMFindPluginByPath(
    inPath     -- string
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMFindPluginBySignature" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMFindPluginBySignature { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns the plug-in ID of the plug-in whose signature matches what is passed in or XPLM_NO_PLUGIN_ID
if no running plug-in has this signature.  Signatures are the best way to identify another plug-in as they are
independent of the file system path of a plug-in or the human-readable plug-in name, and should be unique for all
plug-ins.  Use this routine to locate another plugin that your plugin interoperates with

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns XPLMPluginID -> assign to local/var
local my_pluginID = XPLMFindPluginBySignature(
    inSignature     -- string
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetPluginInfo" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetPluginInfo { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns information about a plug-in.  Each parameter should be a pointer to a buffer of at least
256 characters, or NULL to not receive the information.

outName - the human-readable name of the plug-in.
outFilePath - the absolute file path to the file that contains this plug-in.
outSignature - a unique string that identifies this plug-in.
outDescription - a human-readable description of this plug-in.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns a table of out values
local outs = XPLMGetPluginInfo(
    inPlugin     -- XPLMPluginID
)
-- outs = { outName, outFilePath, outSignature, outDescription }</code></pre>
</div>

</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>