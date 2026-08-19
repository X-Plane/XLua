<h1>Enabling/Disabling Plug-Ins</h1>

These routines are used to work with plug-ins and manage them.  Most plugins will
not need to use these APIs.

---

<div class="sym-block sym-function" data-name="XPLMIsPluginEnabled" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMIsPluginEnabled { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Returns whether the specified plug-in is enabled for running.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API int XPLMIsPluginEnabled(
                         XPLMPluginID         inPluginID
                    );
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMEnablePlugin" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMEnablePlugin { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine enables a plug-in if it is not already enabled.
It returns true if the plugin was enabled or successfully enables itself,
false if it does not.  Plugins may fail to enable (for example, if resources
cannot be acquired) by returning false from their XPluginEnable callback.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API int XPLMEnablePlugin(
                         XPLMPluginID         inPluginID
                    );
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMDisablePlugin" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMDisablePlugin { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine disables an enabled plug-in.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMDisablePlugin(
                         XPLMPluginID         inPluginID
                    );
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMReloadPlugins" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMReloadPlugins { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine reloads all plug-ins.  Once this routine is called and
you return from the callback you were within (e.g. a menu select callback)
you will receive your XPluginDisable and XPluginStop callbacks and your
DLL will be unloaded, then the start process happens as if the sim was
starting up.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMReloadPlugins(void);
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMReloadThisPlugin" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMReloadThisPlugin { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM440</span>

</div>

This routine reloads the plug-ins which calls it. If you pass true for 'forReplacement',
a dialog will be shown after the .xpl has been unloaded to allow you to replace it with a
newer one manually. In other respects it works identically to XPLMReloadPlugins().

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMReloadThisPlugin(
                         int                  forReplacement
                    );
```

</div>

</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>