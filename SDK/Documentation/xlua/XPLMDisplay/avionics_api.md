<h1>Avionics API</h1>

The Avionics API allows you to customize the drawing and behaviour of the built-in cockpit devices (GNS, G1000, etc.),
and create your own cockpit devices. For built-in devices, you can draw before and/or after X-Plane does, and optionally
prevent X-Plane from drawing the screen at all. Customized built-in devices and custom devices are available in the 3D
cockpit as well as in the form of pop-up/pop-out windows.

The API also allows you to receive mouse interaction events for your device (click down, drag, and up, mouse wheel
scroll, cursor) for both screen and bezel. While these always work when the device is popped-up in its window, you must
add a `ATTR_manip_device` manipulator on top of your screen in order to receive mouse events from the 3D cockpit.

You can also use the avionics API to control the state and location of cockpit devices' pop-up windows.

When working with avionics devices, all co-ordinates you receive when drawing or dealing with click events
are in texels. The x-axis grows right, the y-axis grows up. In bezel callbacks, the origin is at the bottom
left corner of the bezel. In screen callbacks, the origin is at the bottom-left of the screen. X-Plane takes
care of scaling your screen and bezel if the user pops out the device's window: you should always draw your
screen and bezel as if they were at the size you specified when registering callbacks or creating a device.

---

<div class="sym-block sym-enum" data-name="XPLMWindowContentType" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMWindowContentType { .symbol-title }

<span class="sym-badge badge-enum">enum</span> <span class="sym-badge badge-version">XPLM440</span>

</div>

XPLMWindowContentType describes how the content for a window (or an avionics device's screen) is provided.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplm_WindowContentTypePanelGraphics | 1 | The window is drawn by calling back your plugin, which will draw using panel graphics APIs. You provide mouse and keyboard hooks for interaction. |
| xplm_WindowContentTypeBrowser | 2 | The window content is specified using a web page. |

</div>

</div>

---

<div class="sym-block sym-enum" data-name="XPLMDeviceID" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMDeviceID { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

</div>

This constant indicates the device we want to override or enhance. We can get a callback before or after each item.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplm_device_GNS430_1 | 0 | GNS430, pilot side. |
| xplm_device_GNS430_2 | 1 | GNS430, copilot side. |
| xplm_device_GNS530_1 | 2 | GNS530, pilot side. |
| xplm_device_GNS530_2 | 3 | GNS530, copilot side. |
| xplm_device_CDU739_1 | 4 | generic airliner CDU, pilot side. |
| xplm_device_CDU739_2 | 5 | generic airliner CDU, copilot side. |
| xplm_device_G1000_PFD_1 | 6 | G1000 Primary Flight Display, pilot side. |
| xplm_device_G1000_MFD | 7 | G1000 Multifunction Display. |
| xplm_device_G1000_PFD_2 | 8 | G1000 Primary Flight Display, copilot side. |
| xplm_device_CDU815_1 | 9 | Primus CDU, pilot side. |
| xplm_device_CDU815_2 | 10 | Primus CDU, copilot side. |
| xplm_device_Primus_PFD_1 | 11 | Primus Primary Flight Display, pilot side. |
| xplm_device_Primus_PFD_2 | 12 | Primus Primary Flight Display, copilot side. |
| xplm_device_Primus_MFD_1 | 13 | Primus Multifunction Display, pilot side. |
| xplm_device_Primus_MFD_2 | 14 | Primus Multifunction Display, copilot side. |
| xplm_device_Primus_MFD_3 | 15 | Primus Multifunction Display, central. |
| xplm_device_Primus_RMU_1 | 16 | Primus Radio Management Unit, pilot side. |
| xplm_device_Primus_RMU_2 | 17 | Primus Radio Management Unit, copilot side. |
| xplm_device_MCDU_1 | 18 | Airbus MCDU, pilot side. |
| xplm_device_MCDU_2 | 19 | Airbus MCDU, copilot side. |
| xplm_device_MCDU_3 | 24 | Airbus MCDU 3. |

</div>

**Used by:**

- [XPLMAvionicsCallback_f](#xplmavionicscallback_f)
- [XPLMGetAvionicsHandle](#xplmgetavionicshandle)

</div>

---

<div class="sym-block sym-callback" data-name="XPLMAvionicsCallback_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMAvionicsCallback_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

This is the prototype for drawing callbacks for customized built-in device. You are passed in the device
you are enhancing/replacing, and (if this is used for a built-in device that you are customizing) whether
it is before or after X-Plane drawing. If you are before X-Plane, return true to let X-Plane draw or false to
suppress X-Plane drawing. If you are called after X-Plane, the return value is ignored.

Refcon is a unique value that you specify when registering the callback, allowing you
to slip a pointer to your own data to the callback.

Upon entry the OpenGL context will be correctly set up for you and OpenGL will be in
panel coordinates for 2d drawing.  The OpenGL state (texturing, etc.) will be unknown.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_AvionicsCallback_callback(
    inDeviceID,    -- XPLMDeviceID
    inIsBefore,    -- boolean
    inRefcon       -- any Lua var/table
)
    -- your code here
    return true  -- boolean
end</code></pre>
</div>


**See associated types:**

- [XPLMDeviceID](#xplmdeviceid)
</div>

---

<div class="sym-block sym-callback" data-name="XPLMAvionicsMouse_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMAvionicsMouse_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

Mouse click callback for clicks into your screen or (2D-popup) bezel, useful if the device you are making simulates a touch-screen the user can click in the 3d cockpit, or if your pop-up's bezel has buttons that the user can click. Return true to consume the event, or false to let X-Plane process it (for stock avionics devices).

- x, y: the coordinate at which the mouse was clicked.
- inMouse: the type of mouse event - down-click, drag, or up-click.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_AvionicsMouse_callback(
    x,           -- int
    y,           -- int
    inMouse,     -- XPLMMouseStatus
    inRefcon     -- any Lua var/table
)
    -- your code here
    return true  -- boolean
end</code></pre>
</div>

</div>

---

<div class="sym-block sym-callback" data-name="XPLMAvionicsMouseWheel_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMAvionicsMouseWheel_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

Mouse wheel callback for scroll actions into your screen or (2D-popup) bezel, useful if your bezel has knobs that can be turned using the mouse wheel, or if you want to simulate pinch-to-zoom on a touchscreen. Return true to consume the event, or false to let X-Plane process it (for stock avionics devices). The number of "clicks" indicates how far the wheel was turned since the last callback. The wheel is 0 for the vertical axis or 1 for the horizontal axis (for OS/mouse combinations that support this).

- x, y: the coordinate at which the wheel was scrolled.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_AvionicsMouseWheel_callback(
    x,           -- int
    y,           -- int
    wheel,       -- int
    clicks,      -- int
    inRefcon     -- any Lua var/table
)
    -- your code here
    return true  -- boolean
end</code></pre>
</div>

</div>

---

<div class="sym-block sym-callback" data-name="XPLMAvionicsCursor_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMAvionicsCursor_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

Cursor callback that decides which cursor to show when the mouse is over your screen or (2D-popup) bezel. Return xplm_CursorDefault to let X-Plane use which cursor to show, or other values to force the cursor to a particular one (see XPLMCursorStatus).

- x, y: the coordinate at which the mouse is hovering.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_AvionicsCursor_callback(
    x,           -- int
    y,           -- int
    inRefcon     -- any Lua var/table
)
    -- your code here
    return nil  -- XPLMCursorStatus
end</code></pre>
</div>

</div>

---

<div class="sym-block sym-callback" data-name="XPLMAvionicsKeyboard_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMAvionicsKeyboard_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

Key callback called when your device is popped up and you've requested to capture the keyboard.  Return true to consume the event, or false to let X-Plane process it (for stock avionics devices).

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_AvionicsKeyboard_callback(
    inKey,           -- char
    inFlags,         -- XPLMKeyFlags
    inVirtualKey,    -- char
    inRefcon,        -- any Lua var/table
    losingFocus      -- boolean
)
    -- your code here
    return true  -- boolean
end</code></pre>
</div>

</div>

---

<div class="sym-block sym-typedef" data-name="XPLMAvionicsID" data-type="typedef" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMAvionicsID { .symbol-title }

<span class="sym-badge badge-typedef">typedef</span>

</div>

This is an opaque identifier for an avionics display that you enhance or replace.
When you register your callbacks (via XPLMRegisterAvionicsCallbacksEx()) or
create a new device (via XPLMCreateAvionicsDevice()), you will specify drawing
and mouse callbacks, and get back such a handle.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">local my_avionicsID = nil  -- XPLMAvionicsID</code></pre>
</div>


**Used by:**

- [XPLMAvionicsAddBrowserFunction](#xplmavionicsaddbrowserfunction)
- [XPLMAvionicsBrowserCallback_f](#xplmavionicsbrowsercallback_f)
- [XPLMAvionicsBrowserLoadError_f](#xplmavionicsbrowserloaderror_f)
- [XPLMAvionicsBrowserLoadFinished_f](#xplmavionicsbrowserloadfinished_f)
- [XPLMAvionicsInjectScript](#xplmavionicsinjectscript)
- [XPLMAvionicsNeedsDrawing](#xplmavionicsneedsdrawing)
- [XPLMAvionicsRefresh](#xplmavionicsrefresh)
- [XPLMAvionicsSetURL](#xplmavionicsseturl)
- [XPLMClearObjectAvionics](#xplmclearobjectavionics)
- [XPLMDestroyAvionics](#xplmdestroyavionics)
- [XPLMGetAvionicsBrightnessRheo](#xplmgetavionicsbrightnessrheo)
- [XPLMGetAvionicsBusVoltsRatio](#xplmgetavionicsbusvoltsratio)
- [XPLMGetAvionicsGeometry](#xplmgetavionicsgeometry)
- [XPLMGetAvionicsGeometryOS](#xplmgetavionicsgeometryos)
- [XPLMHasAvionicsKeyboardFocus](#xplmhasavionicskeyboardfocus)
- [XPLMIsAvionicsBound](#xplmisavionicsbound)
- [XPLMIsAvionicsMappedToVR](#xplmisavionicsmappedtovr)
- [XPLMIsAvionicsPoppedOut](#xplmisavionicspoppedout)
- [XPLMIsAvionicsPopupVisible](#xplmisavionicspopupvisible)
- [XPLMIsCursorOverAvionics](#xplmiscursoroveravionics)
- [XPLMPopOutAvionics](#xplmpopoutavionics)
- [XPLMSetAvionicsBrightnessRheo](#xplmsetavionicsbrightnessrheo)
- [XPLMSetAvionicsGeometry](#xplmsetavionicsgeometry)
- [XPLMSetAvionicsGeometryOS](#xplmsetavionicsgeometryos)
- [XPLMSetAvionicsMappedToVR](#xplmsetavionicsmappedtovr)
- [XPLMSetAvionicsPopupVisible](#xplmsetavionicspopupvisible)
- [XPLMSetObjectAvionics](#xplmsetobjectavionics)
- [XPLMTakeAvionicsKeyboardFocus](#xplmtakeavionicskeyboardfocus)
- [XPLMUnregisterAvionicsCallbacks](#xplmunregisteravionicscallbacks)
</div>

---

<div class="sym-block sym-struct" data-name="XPLMCustomizeAvionics_t" data-type="struct" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCustomizeAvionics_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span>

</div>

The XPLMCustomizeAvionics_t structure defines all of the parameters used to replace or
enhance built-in simulator avionics devices using XPLMRegisterAvionicsCallbacksEx().
The structure will be expanded in future SDK APIs to include more features.
Always set the structSize member to the size of your struct in bytes!

<div class="lua-code" markdown="1">
<pre><code class="language-lua">local My_CustomizeAvionics_t = {
    structSize                = 0,       -- int
    deviceId                  = nil,     -- XPLMDeviceID
    drawCallbackBefore        = nil,     -- see XPLMAvionicsCallback_f
    drawCallbackAfter         = nil,     -- see XPLMAvionicsCallback_f
    bezelClickCallback        = nil,     -- see XPLMAvionicsMouse_f
    bezelRightClickCallback   = nil,     -- see XPLMAvionicsMouse_f
    bezelScrollCallback       = nil,     -- see XPLMAvionicsMouseWheel_f
    bezelCursorCallback       = nil,     -- see XPLMAvionicsCursor_f
    screenTouchCallback       = nil,     -- see XPLMAvionicsMouse_f
    screenRightTouchCallback  = nil,     -- see XPLMAvionicsMouse_f
    screenScrollCallback      = nil,     -- see XPLMAvionicsMouseWheel_f
    screenCursorCallback      = nil,     -- see XPLMAvionicsCursor_f
    keyboardCallback          = nil,     -- see XPLMAvionicsKeyboard_f
    refcon                    = nil,     -- any Lua var/table
    contentType               = nil,     -- XPLMWindowContentType
}</code></pre>
</div>

<div class="field-table" markdown="1">

| Field | Type | Description |
|:--|:--|:--|
| structSize | int | Used to inform XPLMRegisterAvionicsCallbacksEx() of the SDK version you compiled against; should always be set to sizeof(XPLMCustomizeAvionics_t) |
| deviceId | XPLMDeviceID | The built-in avionics device to which you want your drawing applied. |
| drawCallbackBefore | XPLMAvionicsCallback_f | The draw callback to be called before X-Plane draws. |
| drawCallbackAfter | XPLMAvionicsCallback_f | The draw callback to be called after X-Plane has drawn. |
| bezelClickCallback | XPLMAvionicsMouse_f | The mouse click callback that is called when the user clicks onto the device's bezel. |
| bezelRightClickCallback | XPLMAvionicsMouse_f | The mouse click callback that is called when the user clicks onto the device's bezel. |
| bezelScrollCallback | XPLMAvionicsMouseWheel_f | The callback that is called when the users uses the scroll wheel over the device's bezel. |
| bezelCursorCallback | XPLMAvionicsCursor_f | The callback that lets you determine what cursor should be shown when the mouse is over the device's bezel. |
| screenTouchCallback | XPLMAvionicsMouse_f | The mouse click callback that is called when the user clicks onto the device's screen. |
| screenRightTouchCallback | XPLMAvionicsMouse_f | The right mouse click callback that is called when the user clicks onto the device's screen. |
| screenScrollCallback | XPLMAvionicsMouseWheel_f | The callback that is called when the users uses the scroll wheel over the device's screen. |
| screenCursorCallback | XPLMAvionicsCursor_f | The callback that lets you determine what cursor should be shown when the mouse is over the device's screen. |
| keyboardCallback | XPLMAvionicsKeyboard_f | The key callback that is called when the user types in the device's popup. |
| refcon | any Lua var/table | A reference which will be passed into each of your draw callbacks. Use this to pass information to yourself as needed. |
| contentType | XPLMWindowContentType | How this device's screen is drawn: xplm_WindowContentTypeOpenGL (the legacy OpenGL bridge) or xplm_WindowContentTypePanelGraphics (native panel-graphics rendering). xplm_WindowContentTypeBrowser is not valid for avionics. |

</div>


**See available callback(s):**

- [XPLMAvionicsCallback_f](#xplmavionicscallback_f)
- [XPLMAvionicsCursor_f](#xplmavionicscursor_f)
- [XPLMAvionicsKeyboard_f](#xplmavionicskeyboard_f)
- [XPLMAvionicsMouseWheel_f](#xplmavionicsmousewheel_f)
- [XPLMAvionicsMouse_f](#xplmavionicsmouse_f)
</div>

---

<div class="sym-block sym-function" data-name="XPLMRegisterAvionicsCallbacksEx" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMRegisterAvionicsCallbacksEx { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine registers your callbacks for a built-in device. This returns a
handle. If the returned handle is NULL, there was a problem interpreting your
input, most likely the struct size was wrong for your SDK version.
If the returned handle is not NULL, your callbacks will be called according to schedule
as long as your plugin is not deactivated, or unloaded, or you call XPLMUnregisterAvionicsCallbacks().

Note that you cannot register new callbacks for a device that is not a built-in
one (for example a device that you have created, or a device another plugin
has created).

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns XPLMAvionicsID -> assign to local/var
local my_avionicsID = XPLMRegisterAvionicsCallbacksEx(
    inParams     -- see XPLMCustomizeAvionics_t
)</code></pre>
</div>


**See associated types:**

- [XPLMCustomizeAvionics_t](#xplmcustomizeavionics_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMGetAvionicsHandle" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetAvionicsHandle { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine registers no callbacks for a built-in cockpit device, but returns a handle which allows
you to interact with it using the Avionics Device API. Use this if you do not wish to intercept drawing,
clicks and touchscreen calls to a device, but want to interact with its popup programmatically.
This is equivalent to calling XPLMRegisterAvionicsCallbackEx() with NULL for all callbacks.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns XPLMAvionicsID -> assign to local/var
local my_avionicsID = XPLMGetAvionicsHandle(
    inDeviceID     -- XPLMDeviceID
)</code></pre>
</div>


**See associated types:**

- [XPLMDeviceID](#xplmdeviceid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMUnregisterAvionicsCallbacks" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMUnregisterAvionicsCallbacks { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine unregisters your callbacks for a built-in device. You should only call this
for handles you acquired from XPLMRegisterAvionicsCallbacksEx(). They will no longer be called.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMUnregisterAvionicsCallbacks(
    inAvionicsId     -- XPLMAvionicsID
)</code></pre>
</div>


**See associated types:**

- [XPLMAvionicsID](#xplmavionicsid)
</div>

---

<div class="sym-block sym-callback" data-name="XPLMAvionicsScreenCallback_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMAvionicsScreenCallback_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

This is the prototype for drawing callbacks for custom devices' screens. Refcon is a unique
value that you specify when creating the device, allowing you to slip a pointer to your own
data to the callback.

Upon entry the OpenGL context will be correctly set up for you and OpenGL will be in
panel coordinates for 2d drawing.  The OpenGL state (texturing, etc.) will be unknown.
X-Plane does not clear your screen for you between calls - this means you can re-use
portions to save drawing, but otherwise you must call glClear() to erase the screen's
contents.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_AvionicsScreenCallback_callback(
    inRefcon     -- any Lua var/table
)
    -- your code here
end</code></pre>
</div>

</div>

---

<div class="sym-block sym-callback" data-name="XPLMAvionicsBezelCallback_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMAvionicsBezelCallback_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

This is the prototype for drawing callbacks for custom devices' bezel. You are passed in the
red, green, and blue values you can optinally use for tinting your bezel accoring to ambiant
light.

Refcon is a unique value that you specify when creating the device, allowing you
to slip a pointer to your own data to the callback.

Upon entry the OpenGL context will be correctly set up for you and OpenGL will be in
panel coordinates for 2d drawing.  The OpenGL state (texturing, etc.) will be unknown.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_AvionicsBezelCallback_callback(
    inAmbiantR,    -- float
    inAmbiantG,    -- float
    inAmbiantB,    -- float
    inRefcon       -- any Lua var/table
)
    -- your code here
end</code></pre>
</div>

</div>

---

<div class="sym-block sym-callback" data-name="XPLMAvionicsBrightness_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMAvionicsBrightness_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

This is the prototype for screen brightness callbacks for custom devices. If you provide a callback,
you can return the ratio of the screen's maximum brightness that the simulator should use when
displaying the screen in the 3D cockpit.

inRheoValue is the current ratio value (between 0 and 1) of the instrument brightness rheostat to
which the device is bound.

inAmbientBrightness is the value (between 0 and 1) that the callback should return for the screen
to be at a usable brightness based on ambient light (if your device has a photo cell and
automatically adjusts its brightness, you can return this and your screen will be at the optimal
brightness to be readable, but not blind the pilot).

inBusVoltsRatio is the ratio of the nominal voltage currently present on the electrical bus powering
the device. This is the same value XPLMGetAvionicsBusVoltsRatio() returns, including its handling of
devices wired to several buses: 1.0 if the author assigned the device to no bus at all, and -1 if the
device is not bound to the current aircraft.

Refcon is a unique value that you specify when creating the device, allowing you
to slip a pointer to your own data to the callback.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_AvionicsBrightness_callback(
    inRheoValue,            -- float
    inAmbiantBrightness,    -- float
    inBusVoltsRatio,        -- float
    inRefcon                -- any Lua var/table
)
    -- your code here
    return nil  -- float
end</code></pre>
</div>

</div>

---

<div class="sym-block sym-callback" data-name="XPLMAvionicsBrowserLoadFinished_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMAvionicsBrowserLoadFinished_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span> <span class="sym-badge badge-version">XPLM440</span>

</div>

Called for a browser-content-type avionics device when its main frame finishes
loading a page. This is NOT a guarantee that the load succeeded: a page that
renders an HTTP error response (e.g. a server's 404 page) also "finishes" here.
A navigation that fails before the page renders fires XPLMAvionicsBrowserLoadError_f
instead. If your page needs to know its own HTTP status, have it report that from
JavaScript via a browser function. Set this via browserLoadFinishedFunc in
XPLMCreateAvionics_t.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_AvionicsBrowserLoadFinished_callback(
    inAvionics,    -- XPLMAvionicsID
    inURL,         -- string
    inRefcon       -- any Lua var/table
)
    -- your code here
end</code></pre>
</div>


**See associated types:**

- [XPLMAvionicsID](#xplmavionicsid)
</div>

---

<div class="sym-block sym-callback" data-name="XPLMAvionicsBrowserLoadError_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMAvionicsBrowserLoadError_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span> <span class="sym-badge badge-version">XPLM440</span>

</div>

Called for a browser-content-type avionics device when a navigation fails at the
network level (bad URL, host unreachable, TLS failure, file not found). inError
describes the failure. This may be followed by XPLMAvionicsBrowserLoadFinished_f
for a substitute error page, so treat a load error as the authoritative signal
that the navigation to inURL failed. Set this via browserLoadErrorFunc in
XPLMCreateAvionics_t.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_AvionicsBrowserLoadError_callback(
    inAvionics,    -- XPLMAvionicsID
    inURL,         -- string
    inError,       -- string
    inRefcon       -- any Lua var/table
)
    -- your code here
end</code></pre>
</div>


**See associated types:**

- [XPLMAvionicsID](#xplmavionicsid)
</div>

---

<div class="sym-block sym-struct" data-name="XPLMCreateAvionics_t" data-type="struct" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCreateAvionics_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

The XPLMCreateAvionics_t structure defines all of the parameters used to generate your own glass cockpit
device by using XPLMCreateAvionicsEx(). The structure will be expanded in future SDK APIs to include more
features. Always set the structSize member to the size of your struct in bytes!

<div class="lua-code" markdown="1">
<pre><code class="language-lua">local My_CreateAvionics_t = {
    structSize                = 0,       -- int
    screenWidth               = 0,       -- int
    screenHeight              = 0,       -- int
    bezelWidth                = 0,       -- int
    bezelHeight               = 0,       -- int
    screenOffsetX             = 0,       -- int
    screenOffsetY             = 0,       -- int
    drawOnDemand              = false,   -- boolean
    bezelDrawCallback         = nil,     -- see XPLMAvionicsBezelCallback_f
    drawCallback              = nil,     -- see XPLMAvionicsScreenCallback_f
    bezelClickCallback        = nil,     -- see XPLMAvionicsMouse_f
    bezelRightClickCallback   = nil,     -- see XPLMAvionicsMouse_f
    bezelScrollCallback       = nil,     -- see XPLMAvionicsMouseWheel_f
    bezelCursorCallback       = nil,     -- see XPLMAvionicsCursor_f
    screenTouchCallback       = nil,     -- see XPLMAvionicsMouse_f
    screenRightTouchCallback  = nil,     -- see XPLMAvionicsMouse_f
    screenScrollCallback      = nil,     -- see XPLMAvionicsMouseWheel_f
    screenCursorCallback      = nil,     -- see XPLMAvionicsCursor_f
    keyboardCallback          = nil,     -- see XPLMAvionicsKeyboard_f
    brightnessCallback        = nil,     -- see XPLMAvionicsBrightness_f
    deviceID                  = nil,     -- char const
    deviceName                = nil,     -- char const
    refcon                    = nil,     -- any Lua var/table
    contentType               = nil,     -- XPLMWindowContentType
    windowWithChrome          = 0,       -- int
    browserLoadFinishedFunc   = nil,     -- see XPLMAvionicsBrowserLoadFinished_f
    browserLoadErrorFunc      = nil,     -- see XPLMAvionicsBrowserLoadError_f
}</code></pre>
</div>

<div class="field-table" markdown="1">

| Field | Type | Description |
|:--|:--|:--|
| structSize | int | Used to inform XPLMCreateAvionicsEx() of the SDK version you compiled against; should always be set to sizeof(XPLMCreateAvionics_t) |
| screenWidth | int | Width of the device's screen in pixels. |
| screenHeight | int | Height of the device's screen in pixels. |
| bezelWidth | int | Width of the bezel around your device's screen for 2D pop-ups. |
| bezelHeight | int | Height of the bezel around your device's screen for 2D pop-ups. |
| screenOffsetX | int | The screen's lateral offset into the bezel for 2D pop-ups. |
| screenOffsetY | int | The screen's vertical offset into the bezel for 2D pop-ups. |
| drawOnDemand | boolean | If set to true (1), X-Plane won't call your plugin to re-render the device's screen every frame. Instead, you should tell X-Plane you want to refresh your screen with XPLMAvionicsNeedsDrawing(), and X-Plane will call you before rendering the next simulator frame. |
| bezelDrawCallback | XPLMAvionicsBezelCallback_f | The draw callback you will use to draw the 2D-popup bezel. This is called only when the popup window is visible, and X-Plane is about to draw the bezel in it. |
| drawCallback | XPLMAvionicsScreenCallback_f | The draw callback you will be using to draw into the device's screen framebuffer. |
| bezelClickCallback | XPLMAvionicsMouse_f | The mouse click callback that is called when the user clicks onto your bezel. |
| bezelRightClickCallback | XPLMAvionicsMouse_f | The mouse click callback that is called when the user clicks onto your bezel. |
| bezelScrollCallback | XPLMAvionicsMouseWheel_f | The callback that is called when the users uses the scroll wheel over your avionics' bezel. |
| bezelCursorCallback | XPLMAvionicsCursor_f | The callback that lets you determine what cursor should be shown when the mouse is over your device's bezel. |
| screenTouchCallback | XPLMAvionicsMouse_f | The mouse click callback that is called when the user clicks onto your screen. |
| screenRightTouchCallback | XPLMAvionicsMouse_f | The right mouse click callback that is called when the user clicks onto your screen. |
| screenScrollCallback | XPLMAvionicsMouseWheel_f | The callback that is called when the users uses the scroll wheel over your avionics' screen. |
| screenCursorCallback | XPLMAvionicsCursor_f | The callback that lets you determine what cursor should be shown when the mouse is over your device's screen. |
| keyboardCallback | XPLMAvionicsKeyboard_f | The key callback that is called when the user types in your popup. |
| brightnessCallback | XPLMAvionicsBrightness_f | The callback that is called to determine the absolute brightness of the device's screen. Set to NULL to use X-Plane's default behaviour. |
| deviceID | char const | A null-terminated string of maximum 64 characters to uniquely identify your cockpit device. This must be unique (you cannot re-use an ID that X-Plane or another plugin provides), and it must not contain spaces. This is the string the OBJ file must reference when marking polygons with ATTR_cockpit_device. The string is copied when you call XPLMCreateAvionicsEx, so you don't need to hold this string in memory after the call. |
| deviceName | char const | A null-terminated string to give a user-readable name to your device, which can be presented in UI dialogs. |
| refcon | any Lua var/table | A reference which will be passed into your draw and mouse callbacks. Use this to pass information to yourself as needed. |
| contentType | XPLMWindowContentType | How this device's screen is drawn: xplm_WindowContentTypeOpenGL (the legacy OpenGL bridge), xplm_WindowContentTypePanelGraphics (native panel-graphics rendering), or xplm_WindowContentTypeBrowser (a CEF web view). For a browser device the single web page covers the whole bezel including the screen; X-Plane copies the screen sub-rectangle into the device's framebuffer, so your drawCallback/bezelDrawCallback are not used. Drive the page with XPLMAvionicsSetURL() and friends. Browser content is only valid for devices you create here, not when customising a built-in device. |
| windowWithChrome | int | If set to true (1), X-Plane will draw the chrome with the close and pop-out buttons outside of your bezel, rather than having the buttons steal pixels from your bezel. |
| browserLoadFinishedFunc | XPLMAvionicsBrowserLoadFinished_f | For browser content (xplm_WindowContentTypeBrowser): called when a page's main frame finishes loading. Not a success guarantee --a rendered HTTP error page finishes too. Set to NULL if you don't need it. |
| browserLoadErrorFunc | XPLMAvionicsBrowserLoadError_f | For browser content (xplm_WindowContentTypeBrowser): called when a navigation fails at the network level, with a description of the failure. Set to NULL if you don't need it. |

</div>


**See available callback(s):**

- [XPLMAvionicsBezelCallback_f](#xplmavionicsbezelcallback_f)
- [XPLMAvionicsBrightness_f](#xplmavionicsbrightness_f)
- [XPLMAvionicsBrowserLoadError_f](#xplmavionicsbrowserloaderror_f)
- [XPLMAvionicsBrowserLoadFinished_f](#xplmavionicsbrowserloadfinished_f)
- [XPLMAvionicsCursor_f](#xplmavionicscursor_f)
- [XPLMAvionicsKeyboard_f](#xplmavionicskeyboard_f)
- [XPLMAvionicsMouseWheel_f](#xplmavionicsmousewheel_f)
- [XPLMAvionicsMouse_f](#xplmavionicsmouse_f)
- [XPLMAvionicsScreenCallback_f](#xplmavionicsscreencallback_f)
</div>

---

<div class="sym-block sym-function" data-name="XPLMCreateAvionicsEx" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCreateAvionicsEx { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

Creates a new cockpit device to be used in the 3D cockpit. You can call this at any time: if an aircraft referencing your device is loaded before your plugin, the simulator will make sure to retroactively map your display into it.

            When you are done with the device, and at least before your plugin is unloaded, you should destroy the device using XPLMDestroyAvionics().

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns XPLMAvionicsID -> assign to local/var
local my_avionicsID = XPLMCreateAvionicsEx(
    inParams     -- see XPLMCreateAvionics_t
)</code></pre>
</div>


**See associated types:**

- [XPLMCreateAvionics_t](#xplmcreateavionics_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMDestroyAvionics" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMDestroyAvionics { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

Destroys the cockpit device and deallocates its screen's memory. You should only ever call this for devices that you created using XPLMCreateAvionicsEx(), not X-Plane' built-ine devices you have customised.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMDestroyAvionics(
    inHandle     -- XPLMAvionicsID
)</code></pre>
</div>


**See associated types:**

- [XPLMAvionicsID](#xplmavionicsid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMAvionicsSetURL" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMAvionicsSetURL { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM440</span>

</div>

Loads a URL into a browser-content-type avionics device (one created via
XPLMCreateAvionicsEx() with contentType xplm_WindowContentTypeBrowser). Safe
to call before the underlying webview has finished initialising; the load is
queued and applied as soon as the browser is ready, so you may call this
immediately after XPLMCreateAvionicsEx(). Subsequent calls replace the
pending or current page. Has no effect on non-browser devices.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMAvionicsSetURL(
    inAvionicsID,    -- XPLMAvionicsID
    inURL            -- string
)</code></pre>
</div>


**See associated types:**

- [XPLMAvionicsID](#xplmavionicsid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMAvionicsRefresh" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMAvionicsRefresh { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM440</span>

</div>

Reloads the current URL in a browser-content-type avionics device. Pass true
for inIgnoreCache to bypass the HTTP cache (the equivalent of a shift-reload).
Has no effect on non-browser devices.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMAvionicsRefresh(
    inAvionicsID,     -- XPLMAvionicsID
    inIgnoreCache     -- int
)</code></pre>
</div>


**See associated types:**

- [XPLMAvionicsID](#xplmavionicsid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMAvionicsInjectScript" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMAvionicsInjectScript { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM440</span>

</div>

Executes a JavaScript snippet in the main frame of a browser-content-type
avionics device. The script has access to the same xplane.* namespace exposed
to the page. If injected before the page has finished loading, it may run
against an empty document. Has no effect on non-browser devices.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMAvionicsInjectScript(
    inAvionicsID,    -- XPLMAvionicsID
    inScript         -- string
)</code></pre>
</div>


**See associated types:**

- [XPLMAvionicsID](#xplmavionicsid)
</div>

---

<div class="sym-block sym-callback" data-name="XPLMAvionicsBrowserCallback_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMAvionicsBrowserCallback_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span> <span class="sym-badge badge-version">XPLM440</span>

</div>

Handler invoked when the page in a browser-content-type avionics device calls
xplane.<name>(arg). You receive the device, the argument serialised as a
JSON string, and your refcon; return a JSON string (or NULL) that the JS
Promise resolves to.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_AvionicsBrowserCallback_callback(
    inAvionicsID,    -- XPLMAvionicsID
    inJSON,          -- string
    inRefcon         -- any Lua var/table
)
    -- your code here
    return nil  -- string
end</code></pre>
</div>


**See associated types:**

- [XPLMAvionicsID](#xplmavionicsid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMAvionicsAddBrowserFunction" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMAvionicsAddBrowserFunction { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM440</span>

</div>

Registers a callback that the page running in a browser-content-type avionics
device can invoke as xplane.<inName>(arg). The JS call returns a Promise
that resolves to the value your XPLMAvionicsBrowserCallback_f returns (parsed
as JSON). Registering the same name again replaces the previous callback. Each
device has its own independent xplane.* namespace. Has no effect on non-browser
devices.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMAvionicsAddBrowserFunction(
    inAvionicsID,    -- XPLMAvionicsID
    inName,          -- string
    inFunction,      -- see XPLMAvionicsBrowserCallback_f
    inRefcon         -- any Lua var/table
)</code></pre>
</div>


**See associated types:**

- [XPLMAvionicsBrowserCallback_f](#xplmavionicsbrowsercallback_f)
- [XPLMAvionicsID](#xplmavionicsid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSetObjectAvionics" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetObjectAvionics { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM440</span>

</div>

Glues a cockpit device you created with XPLMCreateAvionicsEx() onto a 3D object you loaded with XPLMLoadObject(), so that the device's screen is drawn on that object - typically one you draw in the world using the instancing API (XPLMCreateInstance()).

The device is matched to the object's screen by ID: the object must declare an `ATTR_cockpit_device` with the same device ID string you passed to XPLMCreateAvionicsEx(). The binding is a property of the object itself, so every instance you draw from that object shows the same device. You may only bind devices you created yourself, not X-Plane's built-in devices.

Brightness on the object follows your device's own brightness callback, independent of any aircraft electrical system.

Returns 1 if the object had a matching device screen and the binding succeeded, or 0 otherwise.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns int -> assign to local/var
local my_result = XPLMSetObjectAvionics(
    inObject,      -- XPLMObjectRef
    inAvionics     -- XPLMAvionicsID
)</code></pre>
</div>


**See associated types:**

- [XPLMAvionicsID](#xplmavionicsid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMClearObjectAvionics" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMClearObjectAvionics { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM440</span>

</div>

Removes a binding previously made with XPLMSetObjectAvionics(), restoring the object's device screen to black and detaching its click handler. Bindings are also cleared automatically when you destroy the device with XPLMDestroyAvionics().

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMClearObjectAvionics(
    inObject,      -- XPLMObjectRef
    inAvionics     -- XPLMAvionicsID
)</code></pre>
</div>


**See associated types:**

- [XPLMAvionicsID](#xplmavionicsid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMIsAvionicsBound" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMIsAvionicsBound { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

Returns true (1) if the cockpit device with the given handle is used by the current aircraft.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns boolean -> assign to local/var
local my_result = XPLMIsAvionicsBound(
    inHandle     -- XPLMAvionicsID
)</code></pre>
</div>


**See associated types:**

- [XPLMAvionicsID](#xplmavionicsid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSetAvionicsBrightnessRheo" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetAvionicsBrightnessRheo { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

Sets the brightness setting's value, between 0 and 1, for the screen of the cockpit device with the given handle.

If the device is bound to the current aircraft, this is a shortcut to setting the brightness rheostat value using the `sim/cockpit2/switches/instrument_brightness_ratio[]` dataref; this sets the slot in the `instrument_brightness_ratio` array to which the device is bound.

If the device is not currently bound, the device keeps track of its own screen brightness rheostat, allowing you to control the brightness even though it isn't connected to the `instrument_brightness_ratio` dataref.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSetAvionicsBrightnessRheo(
    inHandle,      -- XPLMAvionicsID
    brightness     -- float
)</code></pre>
</div>


**See associated types:**

- [XPLMAvionicsID](#xplmavionicsid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMGetAvionicsBrightnessRheo" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetAvionicsBrightnessRheo { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

Returns the brightness setting value, between 0 and 1, for the screen of the cockpit device with the given handle.

		If the device is bound to the current aircraft, this is a shortcut to getting the brightness rheostat value from the `sim/cockpit2/switches/instrument_brightness_ratio[]` dataref; this gets the slot in the `instrument_brightness_ratio` array to which the device is bound.

		If the device is not currently bound, this returns the device's own brightness rheostat value.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns float -> assign to local/var
local my_result = XPLMGetAvionicsBrightnessRheo(
    inHandle     -- XPLMAvionicsID
)</code></pre>
</div>


**See associated types:**

- [XPLMAvionicsID](#xplmavionicsid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMGetAvionicsBusVoltsRatio" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetAvionicsBusVoltsRatio { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

Returns the ratio of the nominal voltage (1.0 means full nominal voltage) of the electrical bus powering the cockpit device with the given handle.

An aircraft author can wire a device to any combination of the six electrical buses. When more than one is selected, this returns the ratio for the highest-numbered selected bus that both exists on the current aircraft and is above the aircraft's low-voltage red line. If no selected bus meets that test, this returns 0 - so 0 means the device has no usable power, not that a bus measured zero volts.

If the device is bound but the author assigned it to no bus at all, this returns 1.0; X-Plane treats such a device as always powered. If the device is not bound to the current aircraft, this returns -1.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns float -> assign to local/var
local my_result = XPLMGetAvionicsBusVoltsRatio(
    inHandle     -- XPLMAvionicsID
)</code></pre>
</div>


**See associated types:**

- [XPLMAvionicsID](#xplmavionicsid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMIsCursorOverAvionics" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMIsCursorOverAvionics { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

Returns true (1) if the mouse is currently over the screen of cockpit device with the given handle. If they are not NULL, the optional x and y arguments are filled with the co-ordinates of the mouse cursor in device co-ordinates.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns boolean, plus a table of out values
local my_result, outs = XPLMIsCursorOverAvionics(
    inHandle     -- XPLMAvionicsID
)
-- outs = { outX, outY }</code></pre>
</div>


**See associated types:**

- [XPLMAvionicsID](#xplmavionicsid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMAvionicsNeedsDrawing" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMAvionicsNeedsDrawing { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

Tells X-Plane that your device's screen needs to be re-drawn. If your device is marked for on-demand drawing, X-Plane will call your screen drawing callback before drawing the next simulator frame. If your device is already drawn every frame, this has no effect.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMAvionicsNeedsDrawing(
    inHandle     -- XPLMAvionicsID
)</code></pre>
</div>


**See associated types:**

- [XPLMAvionicsID](#xplmavionicsid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSetAvionicsPopupVisible" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetAvionicsPopupVisible { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

Shows or hides the popup window for a cockpit device.

Visibility is independent of where the popup is drawn (in the X-Plane window, popped out as an
OS window, or mapped to a VR floating window): the popup always remains in whichever target
mode you most recently selected, and toggling visibility just shows or hides it there.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSetAvionicsPopupVisible(
    inHandle,     -- XPLMAvionicsID
    inVisible     -- boolean
)</code></pre>
</div>


**See associated types:**

- [XPLMAvionicsID](#xplmavionicsid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMIsAvionicsPopupVisible" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMIsAvionicsPopupVisible { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

Returns true (1) if the popup window for a cockpit device is visible.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns boolean -> assign to local/var
local my_result = XPLMIsAvionicsPopupVisible(
    inHandle     -- XPLMAvionicsID
)</code></pre>
</div>


**See associated types:**

- [XPLMAvionicsID](#xplmavionicsid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMPopOutAvionics" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMPopOutAvionics { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

Pops out the window for a cockpit device, making it a first-class window in the
operating system, separate from the X-Plane window.

Popping out and being mapped to VR are mutually exclusive: if the device is currently mapped
to VR (XPLMIsAvionicsMappedToVR() is true), calling this routine clears its VR mapping before
popping out.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMPopOutAvionics(
    inHandle     -- XPLMAvionicsID
)</code></pre>
</div>


**See associated types:**

- [XPLMAvionicsID](#xplmavionicsid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMIsAvionicsPoppedOut" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMIsAvionicsPoppedOut { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

Returns true (1) if the popup window for a cockpit device is popped out as a
first-class OS window.

This is true if and only if you have most recently asked the popup to be popped out (via
XPLMPopOutAvionics()) and it has not since been mapped to VR (via XPLMSetAvionicsMappedToVR()).

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns boolean -> assign to local/var
local my_result = XPLMIsAvionicsPoppedOut(
    inHandle     -- XPLMAvionicsID
)</code></pre>
</div>


**See associated types:**

- [XPLMAvionicsID](#xplmavionicsid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSetAvionicsMappedToVR" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetAvionicsMappedToVR { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM440</span>

</div>

Maps a custom cockpit device's popup window to a VR floating window in the
headset, or returns it from VR back to the X-Plane window. Pass 1 to map to VR, 0 to unmap.

The VR window shows the device's bezel and screen at their intrinsic size, as supplied via
XPLMCreateAvionicsEx(). Avionics in VR are not user-resizable.

Mapping to VR and being popped out as an OS window are mutually exclusive: calling this with
inMapped=1 on a popped-out device clears its pop-out state, and calling XPLMPopOutAvionics()
on a VR-mapped device clears its VR mapping. This mirrors the relationship between
xplm_WindowPopOut and xplm_WindowVR for XPLMWindow.

VR mapping is independent of popup visibility (XPLMSetAvionicsPopupVisible). Mapping a hidden
popup to VR leaves it hidden until you make it visible.

Has no effect (and logs a warning) if VR is not currently running on the headset, or if the
device was not created via XPLMCreateAvionicsEx() (built-in avionics cannot be VR-mapped).

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSetAvionicsMappedToVR(
    inHandle,    -- XPLMAvionicsID
    inMapped     -- boolean
)</code></pre>
</div>


**See associated types:**

- [XPLMAvionicsID](#xplmavionicsid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMIsAvionicsMappedToVR" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMIsAvionicsMappedToVR { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM440</span>

</div>

Returns true (1) if the popup window for a cockpit device is currently mapped
to a VR floating window.

This is true if and only if you have most recently asked the device to be mapped to VR (via
XPLMSetAvionicsMappedToVR()) and it has not since been unmapped, popped out, or had VR shut
down beneath it.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns boolean -> assign to local/var
local my_result = XPLMIsAvionicsMappedToVR(
    inHandle     -- XPLMAvionicsID
)</code></pre>
</div>


**See associated types:**

- [XPLMAvionicsID](#xplmavionicsid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMTakeAvionicsKeyboardFocus" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMTakeAvionicsKeyboardFocus { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

This routine gives keyboard focus to the popup window of a custom cockpit device, if it is visible.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMTakeAvionicsKeyboardFocus(
    inHandle     -- XPLMAvionicsID
)</code></pre>
</div>


**See associated types:**

- [XPLMAvionicsID](#xplmavionicsid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMHasAvionicsKeyboardFocus" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMHasAvionicsKeyboardFocus { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

Returns true (1) if the popup window for a cockpit device has keyboard focus.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns boolean -> assign to local/var
local my_result = XPLMHasAvionicsKeyboardFocus(
    inHandle     -- XPLMAvionicsID
)</code></pre>
</div>


**See associated types:**

- [XPLMAvionicsID](#xplmavionicsid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMGetAvionicsGeometry" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetAvionicsGeometry { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

Returns the bounds of a cockpit device's popup window in the X-Plane coordinate system.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns a table of out values
local outs = XPLMGetAvionicsGeometry(
    inHandle     -- XPLMAvionicsID
)
-- outs = { outLeft, outTop, outRight, outBottom }</code></pre>
</div>


**See associated types:**

- [XPLMAvionicsID](#xplmavionicsid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSetAvionicsGeometry" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetAvionicsGeometry { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

Sets the size and position of a cockpit device's popup window in the X-Plane coordinate system.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSetAvionicsGeometry(
    inHandle,    -- XPLMAvionicsID
    inLeft,      -- int
    inTop,       -- int
    inRight,     -- int
    inBottom     -- int
)</code></pre>
</div>


**See associated types:**

- [XPLMAvionicsID](#xplmavionicsid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMGetAvionicsGeometryOS" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetAvionicsGeometryOS { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

Returns the bounds of a cockpit device's popped-out window.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns a table of out values
local outs = XPLMGetAvionicsGeometryOS(
    inHandle     -- XPLMAvionicsID
)
-- outs = { outLeft, outTop, outRight, outBottom }</code></pre>
</div>


**See associated types:**

- [XPLMAvionicsID](#xplmavionicsid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSetAvionicsGeometryOS" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetAvionicsGeometryOS { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

Sets the size and position of a cockpit device's popped-out window.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSetAvionicsGeometryOS(
    inHandle,    -- XPLMAvionicsID
    inLeft,      -- int
    inTop,       -- int
    inRight,     -- int
    inBottom     -- int
)</code></pre>
</div>


**See associated types:**

- [XPLMAvionicsID](#xplmavionicsid)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>