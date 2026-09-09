<h1>Plugin Features API</h1>

The plugin features API allows your plugin to "sign up" for additional capabilities and plugin system features
that are normally disabled for backward compatibility or performance.  This allows advanced plugins to "opt-in"
to new behavior.

Each feature is defined by a permanent string name.  The feature string names will vary with the particular
installation of X-Plane, so plugins should not expect a feature to be guaranteed present.

XPLM_WANTS_REFLECTIONS
----------------------

Available in the SDK 2.0 and later for X-Plane 9, enabling this capability causes your plugin to receive drawing
hook callbacks when X-Plane builds its off-screen reflection and shadow rendering passes. Plugins should enable this
and examine the dataref sim/graphics/view/plane_render_type to determine whether the drawing callback is for a reflection,
shadow calculation, or the main screen. Rendering can be simlified or omitted for reflections, and non-solid drawing
should be skipped for shadow calculations.

**Note**: direct drawing via draw callbacks is not recommended; use the XPLMInstance API to create object models instead.

XPLM_USE_NATIVE_PATHS
---------------------

available in the SDK 2.1 and later for X-Plane 10, this modifies the plugin system to use Unix-style paths on all operating
systems. With this enabled:

* OS X paths will match the native OS X Unix.
* Windows will use forward slashes but preserve C:\ or another drive letter when using complete file paths.
* Linux uses its native file system path scheme.

Without this enabled:

* OS X will use CFM file paths separated by a colon.
* Windows will use back-slashes and conventional DOS paths.
* Linux uses its native file system path scheme.

All plugins should enable this feature on OS X to access the native file system.

XPLM_USE_NATIVE_WIDGET_WINDOWS
------------------------------

Available in the SDK 3.0.2 SDK, this capability tells the widgets library to use new, modern X-Plane backed XPLMDisplay windows
to anchor all widget trees.  Without it, widgets will always use legacy windows.

Plugins should enable this to allow their widget hierarchies to respond to the user's UI size settings and to map widget-based
windwos to a VR HMD.

Before enabling this, make sure any custom widget code in your plugin is prepared to cope with the UI coordinate system not
being th same as the OpenGL window coordinate system.

XPLM_WANTS_DATAREF_NOTIFICATIONS
--------------------------------

Available in the SDK 4.0.0, this capability tells X-Plane to to send the enabling plugin
the new XPLM_MSG_DATAREFS_ADDED message any time new datarefs are added. The SDK will
coalesce consecutive dataref registrations to minimize the number of messages sent.

---

<div class="sym-block sym-callback" data-name="XPLMFeatureEnumerator_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMFeatureEnumerator_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

You pass an XPLMFeatureEnumerator_f to get a list of all features supported by a given version running version of
X-Plane.  This routine is called once for each feature.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_FeatureEnumerator_callback(
    inFeature,    -- string
    inRef         -- any Lua var/table
)
    -- your code here
end</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMHasFeature" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMHasFeature { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This returns 1 if the given installation of X-Plane supports a feature, or 0 if it does not.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns boolean -> assign to local/var
local my_result = XPLMHasFeature(
    inFeature     -- string
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMIsFeatureEnabled" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMIsFeatureEnabled { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This returns 1 if a feature is currently enabled for your plugin, or 0 if it is not enabled.  It is
an error to call this routine with an unsupported feature.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns boolean -> assign to local/var
local my_result = XPLMIsFeatureEnabled(
    inFeature     -- string
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMEnableFeature" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMEnableFeature { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine enables or disables a feature for your plugin.  This will change the running behavior
of X-Plane and your plugin in some way, depending on the feature.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMEnableFeature(
    inFeature,    -- string
    inEnable      -- boolean
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMEnumerateFeatures" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMEnumerateFeatures { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine calls your enumerator callback once for each feature that this running version of X-Plane supports.
Use this routine to determine all of the features that X-Plane can support. Callbacks are synchronous.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMEnumerateFeatures(
    inEnumerator,    -- see XPLMFeatureEnumerator_f
    inRef            -- any Lua var/table
)</code></pre>
</div>


**See associated types:**

- [XPLMFeatureEnumerator_f](#xplmfeatureenumerator_f)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>