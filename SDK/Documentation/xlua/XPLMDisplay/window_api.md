<h1>Window API</h1>

The window API provides a high-level abstraction for drawing with UI interaction.

Windows may operate in one of two modes: legacy (for plugins compiled against old versions of the XPLM,
as well as windows created via the deprecated XPLMCreateWindow() function, rather than XPLMCreateWindowEx()),
or modern (for windows compiled against the XPLM300 or newer API, and created via XPLMCreateWindowEx()).

Modern windows have access to new X-Plane 11 windowing features, like support for new positioning modes
(including being "popped out" into their own first-class window in the operating system).
They can also optionally be decorated in the style of X-Plane 11 windows (like the map).

Modern windows operate in "boxel" units. A boxel ("box of pixels") is a unit of virtual pixels which,
depending on X-Plane's scaling, may correspond to an arbitrary NxN "box" of real pixels on screen. Because
X-Plane handles this scaling automatically, you can effectively treat the units as though you were
simply drawing in pixels, and know that when X-Plane is running with 150% or 200% scaling, your drawing
will be automatically scaled (and likewise all mouse coordinates, screen bounds, etc. will also be auto-scaled).

In contrast, legacy windows draw in true screen pixels, and thus tend to look quite small when X-Plane is
operating in a scaled mode.

Legacy windows have their origin in the lower left of the main X-Plane window. In contrast, since modern windows
are not constrained to the main window, they have their origin in the lower left of the entire global desktop space, and the
lower left of the main X-Plane window is not guaranteed to be (0, 0). In both cases, x increases as you move left, and y increases as you move up.

---

<div class="sym-block sym-typedef" data-name="XPLMWindowID" data-type="typedef" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMWindowID { .symbol-title }

<span class="sym-badge badge-typedef">typedef</span>

</div>

This is an opaque identifier for a window.  You use it to control your window.
When you create a window (via either XPLMCreateWindow() or XPLMCreateWindowEx()),
you will specify callbacks to handle drawing, mouse interaction, etc.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">local my_windowID = nil  -- XPLMWindowID</code></pre>
</div>


**Used by:**

- [XLuaDestroyImguiWindow](#xluadestroyimguiwindow)
- [XPLMBringWindowToFront](#xplmbringwindowtofront)
- [XPLMBrowserCallback_f](#xplmbrowsercallback_f)
- [XPLMBrowserLoadError_f](#xplmbrowserloaderror_f)
- [XPLMBrowserLoadFinished_f](#xplmbrowserloadfinished_f)
- [XPLMDestroyWindow](#xplmdestroywindow)
- [XPLMDrawWindow_f](#xplmdrawwindow_f)
- [XPLMGetWindowGeometry](#xplmgetwindowgeometry)
- [XPLMGetWindowGeometryOS](#xplmgetwindowgeometryos)
- [XPLMGetWindowGeometryVR](#xplmgetwindowgeometryvr)
- [XPLMGetWindowIsVisible](#xplmgetwindowisvisible)
- [XPLMGetWindowRefCon](#xplmgetwindowrefcon)
- [XPLMHandleCursor_f](#xplmhandlecursor_f)
- [XPLMHandleKey_f](#xplmhandlekey_f)
- [XPLMHandleMouseClick_f](#xplmhandlemouseclick_f)
- [XPLMHandleMouseWheel_f](#xplmhandlemousewheel_f)
- [XPLMHasKeyboardFocus](#xplmhaskeyboardfocus)
- [XPLMIsWindowInFront](#xplmiswindowinfront)
- [XPLMSetWindowGeometry](#xplmsetwindowgeometry)
- [XPLMSetWindowGeometryOS](#xplmsetwindowgeometryos)
- [XPLMSetWindowGeometryVR](#xplmsetwindowgeometryvr)
- [XPLMSetWindowGravity](#xplmsetwindowgravity)
- [XPLMSetWindowIsVisible](#xplmsetwindowisvisible)
- [XPLMSetWindowPositioningMode](#xplmsetwindowpositioningmode)
- [XPLMSetWindowRefCon](#xplmsetwindowrefcon)
- [XPLMSetWindowResizingLimits](#xplmsetwindowresizinglimits)
- [XPLMSetWindowTitle](#xplmsetwindowtitle)
- [XPLMTakeKeyboardFocus](#xplmtakekeyboardfocus)
- [XPLMWindowAddBrowserFunction](#xplmwindowaddbrowserfunction)
- [XPLMWindowInjectScript](#xplmwindowinjectscript)
- [XPLMWindowIsInVR](#xplmwindowisinvr)
- [XPLMWindowIsPoppedOut](#xplmwindowispoppedout)
- [XPLMWindowRefresh](#xplmwindowrefresh)
- [XPLMWindowSetURL](#xplmwindowseturl)
</div>

---

<div class="sym-block sym-callback" data-name="XPLMDrawWindow_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMDrawWindow_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

A callback to handle 2-D drawing of your window.  You are passed in your window and its refcon.
Draw the window.  You can use other XPLM functions from this header to find the current dimensions of your
window, etc.  When this callback is called, the OpenGL context will be set properly
for 2-D window drawing.

**Note**:
Because you are drawing your window over a background, you can make a translucent
window easily by simply not filling in your entire window's bounds.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_DrawWindow_callback(
    inWindowID,    -- XPLMWindowID
    inRefcon       -- any Lua var/table
)
    -- your code here
end</code></pre>
</div>


**See associated types:**

- [XPLMWindowID](#xplmwindowid)
</div>

---

<div class="sym-block sym-callback" data-name="XPLMHandleKey_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMHandleKey_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

This function is called when a key is pressed or keyboard focus is taken away from
your window.  If losingFocus is 1, you are losing the keyboard focus, otherwise a key
was pressed and inKey contains its character.

The window ID passed in will be your window for key presses, or the other window taking focus
when losing focus. Note that in the modern plugin system, often focus is taken by the window
manager itself; for this resaon, the window ID may be zero when losing focus, and you should
not write code that depends onit.

The refcon passed in will be the one from registration, for both key presses and losing focus.

Warning: this API declares virtual keys as a signed character; however the VKEY #define macros
in XPLMDefs.h define the vkeys using unsigned values (that is 0x80
instead of -0x80).  So you may need to cast the incoming vkey to an unsigned char
to get correct comparisons in C.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_HandleKey_callback(
    inWindowID,      -- XPLMWindowID
    inKey,           -- char
    inFlags,         -- XPLMKeyFlags
    inVirtualKey,    -- char
    inRefcon,        -- any Lua var/table
    losingFocus      -- boolean
)
    -- your code here
end</code></pre>
</div>


**See associated types:**

- [XPLMWindowID](#xplmwindowid)
</div>

---

<div class="sym-block sym-callback" data-name="XPLMHandleMouseClick_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMHandleMouseClick_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

You receive this call for one of three events:

- when the user clicks the mouse button down
- (optionally) when the user drags the mouse after a down-click, but before the up-click
- when the user releases the down-clicked mouse button.

You receive the x and y of the click, your window,
and a refcon.  Return 1 to consume the click, or 0 to pass it through.

WARNING: passing clicks through windows (as of this writing) causes mouse tracking
problems in X-Plane; do not use this feature!

The units for x and y values match the units used in your window. Thus, for "modern" windows
(those created via XPLMCreateWindowEx() and compiled against the XPLM300 library), the units are boxels,
while legacy windows will get pixels. Legacy windows have their origin in the lower left of the main
X-Plane window, while modern windows have their origin in the lower left of the global desktop space.
In both cases, x increases as you move right, and y increases as you move up.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_HandleMouseClick_callback(
    inWindowID,    -- XPLMWindowID
    x,             -- int
    y,             -- int
    inMouse,       -- XPLMMouseStatus
    inRefcon       -- any Lua var/table
)
    -- your code here
    return 0  -- int
end</code></pre>
</div>


**See associated types:**

- [XPLMWindowID](#xplmwindowid)
</div>

---

<div class="sym-block sym-callback" data-name="XPLMHandleCursor_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMHandleCursor_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span> <span class="sym-badge badge-version">XPLM200</span>

</div>

The SDK calls your cursor status callback when the mouse is over your plugin window.  Return a cursor status code
to indicate how you would like X-Plane to manage the cursor.  If you return xplm_CursorDefault, the SDK will try
lower-Z-order plugin windows, then let the sim manage the cursor.

Note: you should never show or hide the cursor yourself---these APIs are typically reference-counted and thus
cannot safely and predictably be used by the SDK.  Instead return one of xplm_CursorHidden to hide the cursor or
xplm_CursorArrow/xplm_CursorCustom to show the cursor.

If you want to implement a custom cursor by drawing a cursor in OpenGL, use xplm_CursorHidden to hide the OS cursor
and draw the cursor using a 2-d drawing callback (after xplm_Phase_Window is probably a good choice, but see deprecation
warnings on the drawing APIs!).  If you want to use a custom OS-based cursor, use xplm_CursorCustom to ask
X-Plane to show the cursor but not affect its image.  You can then use an OS specific call like
SetThemeCursor (Mac) or SetCursor/LoadCursor (Windows).

The units for x and y values match the units used in your window. Thus, for "modern" windows
(those created via XPLMCreateWindowEx() and compiled against the XPLM300 library), the units are boxels,
while legacy windows will get pixels. Legacy windows have their origin in the lower left of the main
X-Plane window, while modern windows have their origin in the lower left of the global desktop space.
In both cases, x increases as you move right, and y increases as you move up.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_HandleCursor_callback(
    inWindowID,    -- XPLMWindowID
    x,             -- int
    y,             -- int
    inRefcon       -- any Lua var/table
)
    -- your code here
    return nil  -- XPLMCursorStatus
end</code></pre>
</div>


**See associated types:**

- [XPLMWindowID](#xplmwindowid)
</div>

---

<div class="sym-block sym-callback" data-name="XPLMHandleMouseWheel_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMHandleMouseWheel_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span> <span class="sym-badge badge-version">XPLM200</span>

</div>

The SDK calls your mouse wheel callback when one of the mouse wheels is scrolled within your window.  Return true to consume the
mouse wheel movement or false to pass them on to a lower window.  (If your window appears opaque to the user, you should consume
mouse wheel scrolling even if it does nothing.)  The number of "clicks" indicates how far the wheel was turned since the last callback.
The wheel is 0 for the vertical axis or 1 for the horizontal axis (for OS/mouse combinations that support this).

The units for x and y values match the units used in your window. Thus, for "modern" windows
(those created via XPLMCreateWindowEx() and compiled against the XPLM300 library), the units are boxels,
while legacy windows will get pixels. Legacy windows have their origin in the lower left of the main
X-Plane window, while modern windows have their origin in the lower left of the global desktop space.
In both cases, x increases as you move right, and y increases as you move up.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_HandleMouseWheel_callback(
    inWindowID,    -- XPLMWindowID
    x,             -- int
    y,             -- int
    wheel,         -- int
    clicks,        -- int
    inRefcon       -- any Lua var/table
)
    -- your code here
    return true  -- boolean
end</code></pre>
</div>


**See associated types:**

- [XPLMWindowID](#xplmwindowid)
</div>

---

<div class="sym-block sym-callback" data-name="XPLMBrowserLoadFinished_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMBrowserLoadFinished_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span> <span class="sym-badge badge-version">XPLM440</span>

</div>

Called for a browser-content-type window when its main frame finishes loading a
page. NOT a success guarantee --a rendered HTTP error page (e.g. a 404) also
finishes here. A navigation that fails before the page renders fires
XPLMBrowserLoadError_f instead. Set this via browserLoadFinishedFunc in
XPLMCreateWindow_t.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_BrowserLoadFinished_callback(
    inWindow,    -- XPLMWindowID
    inURL,       -- string
    inRefcon     -- any Lua var/table
)
    -- your code here
end</code></pre>
</div>


**See associated types:**

- [XPLMWindowID](#xplmwindowid)
</div>

---

<div class="sym-block sym-callback" data-name="XPLMBrowserLoadError_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMBrowserLoadError_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span> <span class="sym-badge badge-version">XPLM440</span>

</div>

Called for a browser-content-type window when a navigation fails at the network
level (bad URL, host unreachable, TLS failure, file not found). inError describes
the failure. May be followed by XPLMBrowserLoadFinished_f for a substitute error
page, so treat this as the authoritative signal that the navigation to inURL
failed. Set this via browserLoadErrorFunc in XPLMCreateWindow_t.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_BrowserLoadError_callback(
    inWindow,    -- XPLMWindowID
    inURL,       -- string
    inError,     -- string
    inRefcon     -- any Lua var/table
)
    -- your code here
end</code></pre>
</div>


**See associated types:**

- [XPLMWindowID](#xplmwindowid)
</div>

---

<div class="sym-block sym-enum" data-name="XPLMWindowLayer" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMWindowLayer { .symbol-title }

<span class="sym-badge badge-enum">enum</span> <span class="sym-badge badge-version">XPLM300</span>

</div>

XPLMWindowLayer describes where in the ordering of windows X-Plane should place a particular window.
Windows in higher layers cover windows in lower layers. So, a given window might be at the top of its particular layer,
but it might still be obscured by a window in a higher layer. (This happens frequently when floating windows, like
X-Plane's map, are covered by a modal alert.)

Your window's layer can only be specified when you create the window (in the XPLMCreateWindow_t you pass to XPLMCreateWindowEx()).
For this reason, layering only applies to windows created with new X-Plane 11 GUI features.
(Windows created using the older XPLMCreateWindow(), or windows compiled against a pre-XPLM300 version of the SDK will
simply be placed in the flight overlay window layer.)

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplm_WindowLayerFlightOverlay | 0 | The lowest layer, used for HUD-like displays while flying. |
| xplm_WindowLayerFloatingWindows | 1 | Windows that "float" over the sim, like the X-Plane 11 map does. If you are not sure which layer to create your window in, choose floating. |
| xplm_WindowLayerModal | 2 | An interruptive modal that covers the sim with a transparent black overlay to draw the user's focus to the alert |
| xplm_WindowLayerGrowlNotifications | 3 | "Growl"-style notifications that are visible in a corner of the screen, even over modals |

</div>

</div>

---

<div class="sym-block sym-enum" data-name="XPLMWindowDecoration" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMWindowDecoration { .symbol-title }

<span class="sym-badge badge-enum">enum</span> <span class="sym-badge badge-version">XPLM301</span>

</div>

XPLMWindowDecoration describes how "modern" windows will be displayed. This impacts both how X-Plane draws your window as well as certain mouse handlers.

Your window's decoration can only be specified when you create the window (in the XPLMCreateWindow_t you pass to XPLMCreateWindowEx()).

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplm_WindowDecorationNone | 0 | X-Plane will draw no decoration for your window, and apply no automatic click handlers. The window will not stop click from passing through its bounds. This is suitable for "windows" which request, say, the full screen bounds, then only draw in a small portion of the available area. |
| xplm_WindowDecorationRoundRectangle | 1 | The default decoration for "native" windows, like the map. Provides a solid background, as well as click handlers for resizing and dragging the window. |
| xplm_WindowDecorationSelfDecorated | 2 | X-Plane will draw no decoration for your window, nor will it provide resize handlers for your window edges, but it will stop clicks from passing through your windows bounds. |
| xplm_WindowDecorationSelfDecoratedResizable | 3 | Like self-decorated, but with resizing; X-Plane will draw no decoration for your window, but it will stop clicks from passing through your windows bounds, and provide automatic mouse handlers for resizing. |

</div>

</div>

---

<div class="sym-block sym-struct" data-name="XPLMCreateWindow_t" data-type="struct" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCreateWindow_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span> <span class="sym-badge badge-version">XPLM200</span>

</div>

The XPMCreateWindow_t structure defines all of the parameters used to create a modern window using XPLMCreateWindowEx().  The structure
will be expanded in future SDK APIs to include more features.  Always set the structSize member to the size of your struct in
bytes!

All windows created by this function in the XPLM300 version of the API are created with the new X-Plane 11 GUI features.
This means your plugin will get to "know" about the existence of X-Plane windows other than the main window.
All drawing and mouse callbacks for your window will occur in "boxels," giving your windows automatic support
for high-DPI scaling in X-Plane. In addition, your windows can opt-in to decoration with the X-Plane 11
window styling, and you can use the XPLMSetWindowPositioningMode() API to make your window "popped out"
into a first-class operating system window.

Note that this requires dealing with your window's bounds in "global desktop" positioning units, rather than the traditional panel coordinate system.
In global desktop coordinates, the main X-Plane window may not have its origin at coordinate (0, 0), and your own window may have negative coordinates.
Assuming you don't implicitly assume (0, 0) as your origin, the only API change you should need is to start using XPLMGetMouseLocationGlobal()
rather than XPLMGetMouseLocation(), and XPLMGetScreenBoundsGlobal() instead of XPLMGetScreenSize().

If you ask to be decorated as a floating window, you'll get the blue window control bar and blue backing that you see in X-Plane 11's normal
"floating" windows (like the map).

<div class="lua-code" markdown="1">
<pre><code class="language-lua">local My_CreateWindow_t = {
    structSize                = 0,       -- int
    left                      = 0,       -- int
    top                       = 0,       -- int
    right                     = 0,       -- int
    bottom                    = 0,       -- int
    visible                   = false,   -- boolean
    drawWindowFunc            = nil,     -- see XPLMDrawWindow_f
    handleMouseClickFunc      = nil,     -- see XPLMHandleMouseClick_f
    handleKeyFunc             = nil,     -- see XPLMHandleKey_f
    handleCursorFunc          = nil,     -- see XPLMHandleCursor_f
    handleMouseWheelFunc      = nil,     -- see XPLMHandleMouseWheel_f
    refcon                    = nil,     -- any Lua var/table
    decorateAsFloatingWindow  = nil,     -- XPLMWindowDecoration
    layer                     = nil,     -- XPLMWindowLayer
    handleRightClickFunc      = nil,     -- see XPLMHandleMouseClick_f
    windowContentType         = nil,     -- XPLMWindowContentType
    browserLoadFinishedFunc   = nil,     -- see XPLMBrowserLoadFinished_f
    browserLoadErrorFunc      = nil,     -- see XPLMBrowserLoadError_f
}</code></pre>
</div>


**See available callback(s):**

- [XPLMBrowserLoadError_f](#xplmbrowserloaderror_f)
- [XPLMBrowserLoadFinished_f](#xplmbrowserloadfinished_f)
- [XPLMDrawWindow_f](#xplmdrawwindow_f)
- [XPLMHandleCursor_f](#xplmhandlecursor_f)
- [XPLMHandleKey_f](#xplmhandlekey_f)
- [XPLMHandleMouseClick_f](#xplmhandlemouseclick_f)
- [XPLMHandleMouseWheel_f](#xplmhandlemousewheel_f)
</div>

---

<div class="sym-block sym-function" data-name="XPLMCreateWindowEx" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCreateWindowEx { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM200</span>

</div>

This routine creates a new "modern" window. You pass in an XPLMCreateWindow_t structure with all
of the fields set in.  You must set the structSize of the structure to the size of the
actual structure you used.  Also, you must provide functions for every callback---you may
not leave them null!  (If you do not support the cursor or mouse wheel, use functions that
return the default values.)

NOTE: For an imgui-drawn window, Lua scripts should use XLuaCreateImguiWindow()
instead; it opens and closes the imgui frame for you and wires the input handlers.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns XPLMWindowID -> assign to local/var
local my_windowID = XPLMCreateWindowEx(
    inParams     -- see XPLMCreateWindow_t
)</code></pre>
</div>


**See associated types:**

- [XPLMCreateWindow_t](#xplmcreatewindow_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMDestroyWindow" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMDestroyWindow { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine destroys a window.  The window's callbacks are not called after this call.
Keyboard focus is removed from the window before destroying it.

NOTE: A window created with XLuaCreateImguiWindow() must be destroyed with
XLuaDestroyImguiWindow(), not this function, so its captured Lua callbacks are released.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMDestroyWindow(
    inWindowID     -- XPLMWindowID
)</code></pre>
</div>


**See associated types:**

- [XPLMWindowID](#xplmwindowid)
</div>

---

<div class="sym-block sym-function sym-lua-only" data-name="XLuaCreateImguiWindow" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XLuaCreateImguiWindow { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM440</span>

</div>

Lua only. Creates a modern panel-graphics window pre-wired for imgui drawing
and input, and returns its XPLMWindowID (or nil on failure).

Pass a single config table. Recognised fields (all optional):
  left, top, right, bottom    Window geometry in boxels (defaults 100/500/600/100).
  visible                     Boolean; whether the window starts visible (default true).
  decorateAsFloatingWindow    An XPLMWindowDecoration value (default xplm_WindowDecorationRoundRectangle).
  layer                       An XPLMWindowLayer value (default xplm_WindowLayerFloatingWindows).
  drawWindowFunc              function(windowID, width, height) -- called each frame inside an
                              imgui frame that is opened and closed for you; the body is pure
                              imgui widget calls (no NewFrame/Render boilerplate).

The imgui input handlers (mouse, keyboard, cursor, wheel) are installed
automatically; any input callbacks in the table are ignored by design.
Destroy the window with XLuaDestroyImguiWindow().

<div class="lua-code" markdown="1">
<!-- hand-written binding; see the XLua docs -->
</div>

</div>

---

<div class="sym-block sym-function sym-lua-only" data-name="XLuaDestroyImguiWindow" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XLuaDestroyImguiWindow { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM440</span>

</div>

Lua only. Destroys a window created with XLuaCreateImguiWindow() and releases
its captured Lua callbacks. Do not use on windows created any other way.

<div class="lua-code" markdown="1">
<!-- hand-written binding; see the XLua docs -->
</div>


**See associated types:**

- [XPLMWindowID](#xplmwindowid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMWindowSetURL" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMWindowSetURL { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM440</span>

</div>

Loads a URL into a browser-content-type window. Safe to call before the
underlying webview has finished initialising; the load is queued and
applied as soon as the browser is ready, so plugins may call this
immediately after `XPLMCreateWindowEx`. Subsequent calls replace the
pending or current page.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMWindowSetURL(
    inWindowID,    -- XPLMWindowID
    inURL          -- string
)</code></pre>
</div>


**See associated types:**

- [XPLMWindowID](#xplmwindowid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMWindowRefresh" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMWindowRefresh { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM440</span>

</div>

Reloads the current URL in a browser-content-type window. Pass true for
`inIgnoreCache` to bypass the HTTP cache (the equivalent of a
shift-reload).

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMWindowRefresh(
    inWindowID,       -- XPLMWindowID
    inIgnoreCache     -- boolean
)</code></pre>
</div>


**See associated types:**

- [XPLMWindowID](#xplmwindowid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMWindowInjectScript" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMWindowInjectScript { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM440</span>

</div>

Executes a JavaScript snippet in the browser window's main frame. The
script is run once; it has access to the same `xplane.*` namespace
exposed to the page itself (so it can call functions registered via
`XPLMWindowAddBrowserFunction`). If injected before the page has
finished loading, the script may run against an empty document.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMWindowInjectScript(
    inWindowID,    -- XPLMWindowID
    inScript       -- string
)</code></pre>
</div>


**See associated types:**

- [XPLMWindowID](#xplmwindowid)
</div>

---

<div class="sym-block sym-callback" data-name="XPLMBrowserCallback_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMBrowserCallback_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span> <span class="sym-badge badge-version">XPLM440</span>

</div>

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_BrowserCallback_callback(
    inWindowID,    -- XPLMWindowID
    inJSON,        -- string
    inRefcon       -- any Lua var/table
)
    -- your code here
    return nil  -- string
end</code></pre>
</div>


**See associated types:**

- [XPLMWindowID](#xplmwindowid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMWindowAddBrowserFunction" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMWindowAddBrowserFunction { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM440</span>

</div>

Registers a callback that the page running in this browser window can
invoke as `xplane.<inName>(arg)`. The JS call returns a Promise that
resolves to the value your `XPLMBrowserCallback_f` returns (parsed as
JSON -- see that callback's desc for the contract).

Multiple registrations against the same name on the same window
overwrite each other. Each window has its own independent `xplane.*`
namespace; functions registered on window A are not callable from
window B.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMWindowAddBrowserFunction(
    inWindowID,    -- XPLMWindowID
    inName,        -- string
    inFunction,    -- see XPLMBrowserCallback_f
    inRefcon       -- any Lua var/table
)</code></pre>
</div>


**See associated types:**

- [XPLMBrowserCallback_f](#xplmbrowsercallback_f)
- [XPLMWindowID](#xplmwindowid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMGetScreenSize" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetScreenSize { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns the size of the main X-Plane OpenGL window in pixels.
This number can be used to get a rough idea of the amount
of detail the user will be able to see when drawing in 3-d.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns a table of out values
local outs = XPLMGetScreenSize(
)
-- outs = { outWidth, outHeight }</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetScreenBoundsGlobal" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetScreenBoundsGlobal { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM300</span>

</div>

This routine returns the bounds of the "global" X-Plane desktop, in boxels.
Unlike the non-global version XPLMGetScreenSize(), this is multi-monitor aware.
There are three primary consequences of multimonitor awareness.

First, if the user is running X-Plane in full-screen on two or more monitors (typically configured using
one full-screen window per monitor), the global desktop will be sized to include all X-Plane windows.

Second, the origin of the screen coordinates is not guaranteed to be (0, 0). Suppose the user has two displays
side-by-side, both running at 1080p. Suppose further that they've configured their OS to make the left display
their "primary" monitor, and that X-Plane is running in full-screen on their right monitor only. In this case,
the global desktop bounds would be the rectangle from (1920, 0) to (3840, 1080). If the user later asked X-Plane
to draw on their primary monitor as well, the bounds would change to (0, 0) to (3840, 1080).

Finally, if the usable area of the virtual desktop is not a perfect rectangle (for instance,
because the monitors have different resolutions or because one monitor is configured in the operating system
to be above and to the right of the other), the global desktop will include any wasted space. Thus, if you
have two 1080p monitors, and monitor 2 is configured to have its bottom left touch monitor 1's upper right,
your global desktop area would be the rectangle from (0, 0) to (3840, 2160).

Note that popped-out windows (windows drawn in their own operating system windows, rather than "floating" within X-Plane)
are not included in these bounds.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns a table of out values
local outs = XPLMGetScreenBoundsGlobal(
)
-- outs = { outLeft, outTop, outRight, outBottom }</code></pre>
</div>

</div>

---

<div class="sym-block sym-callback" data-name="XPLMReceiveMonitorBoundsGlobal_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMReceiveMonitorBoundsGlobal_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span> <span class="sym-badge badge-version">XPLM300</span>

</div>

This function is informed of the global bounds (in boxels) of a particular monitor within the X-Plane global desktop space.
Note that X-Plane must be running in full screen on a monitor in order for that monitor to be passed to you in this callback.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_ReceiveMonitorBoundsGlobal_callback(
    inMonitorIndex,    -- int
    inLeftBx,          -- int
    inTopBx,           -- int
    inRightBx,         -- int
    inBottomBx,        -- int
    inRefcon           -- any Lua var/table
)
    -- your code here
end</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetAllMonitorBoundsGlobal" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetAllMonitorBoundsGlobal { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM300</span>

</div>

This routine immediately and synchronously calls you back with the bounds (in boxels) of each full-screen X-Plane window
within the X-Plane global desktop space, one callback per window.
Note that if a monitor is *not* covered by an X-Plane window, you cannot get its bounds this way. Likewise,
monitors with only an X-Plane window (not in full-screen mode) will not be included.

If X-Plane is running in full-screen and your monitors are of the same size and configured contiguously in the OS,
then the combined global bounds of all full-screen monitors
will match the total global desktop bounds, as returned by XPLMGetScreenBoundsGlobal(). (Of course,
if X-Plane is running in windowed mode, this will not be the case. Likewise, if you have differently sized monitors,
the global desktop space will include wasted space.)

Note that this function's monitor indices match those provided by XPLMGetAllMonitorBoundsOS(), but the coordinates are different
(since the X-Plane global desktop may not match the operating system's global desktop, and one X-Plane boxel may be larger than
one pixel due to 150% or 200% scaling).

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMGetAllMonitorBoundsGlobal(
    inMonitorBoundsCallback,    -- see XPLMReceiveMonitorBoundsGlobal_f
    inRefcon                    -- any Lua var/table
)</code></pre>
</div>


**See associated types:**

- [XPLMReceiveMonitorBoundsGlobal_f](#xplmreceivemonitorboundsglobal_f)
</div>

---

<div class="sym-block sym-callback" data-name="XPLMReceiveMonitorBoundsOS_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMReceiveMonitorBoundsOS_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span> <span class="sym-badge badge-version">XPLM300</span>

</div>

This function is informed of the global bounds (in pixels) of a particular monitor within the operating system's global desktop space.
Note that a monitor index being passed to you here does not indicate that X-Plane is running in full screen on this monitor,
or even that any X-Plane windows exist on this monitor.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_ReceiveMonitorBoundsOS_callback(
    inMonitorIndex,    -- int
    inLeftPx,          -- int
    inTopPx,           -- int
    inRightPx,         -- int
    inBottomPx,        -- int
    inRefcon           -- any Lua var/table
)
    -- your code here
end</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetAllMonitorBoundsOS" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetAllMonitorBoundsOS { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM300</span>

</div>

This routine immediately and synchronously calls you back with the bounds (in pixels) of each monitor within the operating system's
global desktop space, one callback per monitor. Note that unlike XPLMGetAllMonitorBoundsGlobal(), this may include monitors that have no X-Plane window on them.

Note that this function's monitor indices match those provided by XPLMGetAllMonitorBoundsGlobal(), but the coordinates are different
(since the X-Plane global desktop may not match the operating system's global desktop, and one X-Plane boxel may be larger than one pixel).

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMGetAllMonitorBoundsOS(
    inMonitorBoundsCallback,    -- see XPLMReceiveMonitorBoundsOS_f
    inRefcon                    -- any Lua var/table
)</code></pre>
</div>


**See associated types:**

- [XPLMReceiveMonitorBoundsOS_f](#xplmreceivemonitorboundsos_f)
</div>

---

<div class="sym-block sym-function" data-name="XPLMGetMouseLocationGlobal" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetMouseLocationGlobal { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM300</span>

</div>

Returns the current mouse location in global desktop boxels. Unlike
XPLMGetMouseLocation(), the bottom left of the main X-Plane window is not guaranteed to be
(0, 0)---instead, the origin is the lower left of the entire global desktop space.
In addition, this routine gives the real mouse location when the mouse goes
to X-Plane windows other than the primary display. Thus, it can be used with both
pop-out windows and secondary monitors.

This is the mouse location function to use with modern windows (i.e., those created by XPLMCreateWindowEx()).

Pass NULL to not receive info about either parameter.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns a table of out values
local outs = XPLMGetMouseLocationGlobal(
)
-- outs = { outX, outY }</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetModifierKeys" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetModifierKeys { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM440</span>

</div>

Returns the modifier keys that are being held down *right now*, as a bitfield of XPLMKeyFlags.
Unlike the modifier flags delivered with a key event, this reflects the live keyboard state at the
moment of the call, so it can be used to make mouse clicks modifier-sensitive (e.g. shift-click) or
to react to a modifier changing during drawing (e.g. show alignment guides while shift is held).

Only the modifier bits are ever set: xplm_ShiftFlag, xplm_OptionAltFlag, xplm_ControlFlag and
xplm_CapsLockFlag.  The xplm_DownFlag and xplm_UpFlag bits (which describe a key event's phase) are
never returned. As elsewhere in the SDK, the Command key on macOS is folded into xplm_ControlFlag
rather than reported separately.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns XPLMKeyFlags -> assign to local/var
local my_keyFlags = XPLMGetModifierKeys(
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetWindowGeometry" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetWindowGeometry { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns the position and size of a window. The units and coordinate system vary depending
on the type of window you have.

If this is a legacy window (one compiled against a pre-XPLM300 version of the SDK,
or an XPLM300 window that was not created using XPLMCreateWindowEx()), the units are pixels relative
to the main X-Plane display.

If, on the other hand, this is a new X-Plane 11-style window (compiled against the XPLM300 SDK and
created using XPLMCreateWindowEx()), the units are global desktop boxels.

Pass NULL to not receive any paramter.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns a table of out values
local outs = XPLMGetWindowGeometry(
    inWindowID     -- XPLMWindowID
)
-- outs = { outLeft, outTop, outRight, outBottom }</code></pre>
</div>


**See associated types:**

- [XPLMWindowID](#xplmwindowid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSetWindowGeometry" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetWindowGeometry { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine allows you to set the position and size of a window.

The units and coordinate system match those of XPLMGetWindowGeometry(). That is, modern windows use
global desktop boxel coordinates, while legacy windows use pixels relative to the main X-Plane display.

Note that this only applies to "floating" windows (that is, windows that are drawn within the X-Plane simulation windows,
rather than being "popped out" into their own first-class operating system windows). To set the position
of windows whose positioning mode is xplm_WindowPopOut, you'll need to instead use XPLMSetWindowGeometryOS().

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSetWindowGeometry(
    inWindowID,    -- XPLMWindowID
    inLeft,        -- int
    inTop,         -- int
    inRight,       -- int
    inBottom       -- int
)</code></pre>
</div>


**See associated types:**

- [XPLMWindowID](#xplmwindowid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMGetWindowGeometryOS" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetWindowGeometryOS { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM300</span>

</div>

This routine returns the position and size of a "popped out" window (i.e., a window whose positioning
mode is xplm_WindowPopOut), in operating system pixels.  Pass NULL to not receive any parameter.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns a table of out values
local outs = XPLMGetWindowGeometryOS(
    inWindowID     -- XPLMWindowID
)
-- outs = { outLeft, outTop, outRight, outBottom }</code></pre>
</div>


**See associated types:**

- [XPLMWindowID](#xplmwindowid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSetWindowGeometryOS" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetWindowGeometryOS { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM300</span>

</div>

This routine allows you to set the position and size, in operating system pixel coordinates, of a popped out window
(that is, a window whose positioning mode is xplm_WindowPopOut, which exists outside the X-Plane simulation window,
in its own first-class operating system window).

Note that you are responsible for ensuring both that your window is popped out (using XPLMWindowIsPoppedOut()) and
that a monitor really exists at the OS coordinates you provide (using XPLMGetAllMonitorBoundsOS()).

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSetWindowGeometryOS(
    inWindowID,    -- XPLMWindowID
    inLeft,        -- int
    inTop,         -- int
    inRight,       -- int
    inBottom       -- int
)</code></pre>
</div>


**See associated types:**

- [XPLMWindowID](#xplmwindowid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMGetWindowGeometryVR" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetWindowGeometryVR { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM301</span>

</div>

Returns the width and height, in boxels, of a window in VR.
Note that you are responsible for ensuring your window is in VR (using XPLMWindowIsInVR()).

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns a table of out values
local outs = XPLMGetWindowGeometryVR(
    inWindowID     -- XPLMWindowID
)
-- outs = { outWidthBoxels, outHeightBoxels }</code></pre>
</div>


**See associated types:**

- [XPLMWindowID](#xplmwindowid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSetWindowGeometryVR" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetWindowGeometryVR { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM301</span>

</div>

This routine allows you to set the size, in boxels, of a window in VR
(that is, a window whose positioning mode is xplm_WindowVR).

Note that you are responsible for ensuring your window is in VR (using XPLMWindowIsInVR()).

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSetWindowGeometryVR(
    inWindowID,      -- XPLMWindowID
    widthBoxels,     -- int
    heightBoxels     -- int
)</code></pre>
</div>


**See associated types:**

- [XPLMWindowID](#xplmwindowid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMGetWindowIsVisible" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetWindowIsVisible { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Returns true (1) if the specified window is visible.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns boolean -> assign to local/var
local my_result = XPLMGetWindowIsVisible(
    inWindowID     -- XPLMWindowID
)</code></pre>
</div>


**See associated types:**

- [XPLMWindowID](#xplmwindowid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSetWindowIsVisible" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetWindowIsVisible { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine shows or hides a window.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSetWindowIsVisible(
    inWindowID,     -- XPLMWindowID
    inIsVisible     -- boolean
)</code></pre>
</div>


**See associated types:**

- [XPLMWindowID](#xplmwindowid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMWindowIsPoppedOut" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMWindowIsPoppedOut { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM300</span>

</div>

True if this window has been popped out (making it a first-class window in the operating system), which
in turn is true if and only if you have set the window's positioning mode to xplm_WindowPopOut.

Only applies to modern windows. (Windows created using the deprecated XPLMCreateWindow(),
or windows compiled against a pre-XPLM300 version of the SDK cannot be popped out.)

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns boolean -> assign to local/var
local my_result = XPLMWindowIsPoppedOut(
    inWindowID     -- XPLMWindowID
)</code></pre>
</div>


**See associated types:**

- [XPLMWindowID](#xplmwindowid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMWindowIsInVR" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMWindowIsInVR { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM301</span>

</div>

True if this window has been moved to the virtual reality (VR) headset, which
in turn is true if and only if you have set the window's positioning mode to xplm_WindowVR.

Only applies to modern windows. (Windows created using the deprecated XPLMCreateWindow(),
or windows compiled against a pre-XPLM301 version of the SDK cannot be moved to VR.)

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns boolean -> assign to local/var
local my_result = XPLMWindowIsInVR(
    inWindowID     -- XPLMWindowID
)</code></pre>
</div>


**See associated types:**

- [XPLMWindowID](#xplmwindowid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSetWindowGravity" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetWindowGravity { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM300</span>

</div>

A window's "gravity" controls how the window shifts as the whole X-Plane window resizes.
A gravity of 1 means the window maintains its positioning relative to the right or top edges,
0 the left/bottom, and 0.5 keeps it centered.

Default gravity is (0, 1, 0, 1), meaning your window will maintain its position relative to the top left
and will not change size as its containing window grows.

If you wanted, say, a window that sticks to the top of the screen (with a constant height),
but which grows to take the full width of the window, you would pass (0, 1, 1, 1). Because your left
and right edges would maintain their positioning relative to their respective edges of the screen,
the whole width of your window would change with the X-Plane window.

Only applies to modern windows. (Windows created using the deprecated XPLMCreateWindow(),
or windows compiled against a pre-XPLM300 version of the SDK will simply get the default gravity.)

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSetWindowGravity(
    inWindowID,         -- XPLMWindowID
    inLeftGravity,      -- float
    inTopGravity,       -- float
    inRightGravity,     -- float
    inBottomGravity     -- float
)</code></pre>
</div>


**See associated types:**

- [XPLMWindowID](#xplmwindowid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSetWindowResizingLimits" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetWindowResizingLimits { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM300</span>

</div>

Sets the minimum and maximum size of the client rectangle of the given window. (That is, it does not include
any window styling that you might have asked X-Plane to apply on your behalf.)
All resizing operations are constrained to these sizes.

Only applies to modern windows. (Windows created using the deprecated XPLMCreateWindow(),
or windows compiled against a pre-XPLM300 version of the SDK will have no minimum or maximum size.)

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSetWindowResizingLimits(
    inWindowID,           -- XPLMWindowID
    inMinWidthBoxels,     -- int
    inMinHeightBoxels,    -- int
    inMaxWidthBoxels,     -- int
    inMaxHeightBoxels     -- int
)</code></pre>
</div>


**See associated types:**

- [XPLMWindowID](#xplmwindowid)
</div>

---

<div class="sym-block sym-enum" data-name="XPLMWindowPositioningMode" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMWindowPositioningMode { .symbol-title }

<span class="sym-badge badge-enum">enum</span> <span class="sym-badge badge-version">XPLM300</span>

</div>

XPLMWindowPositionMode describes how X-Plane will position your window on the user's screen. X-Plane will maintain
this positioning mode even as the user resizes their window or adds/removes full-screen monitors.

Positioning mode can only be set for "modern" windows (that is, windows created using XPLMCreateWindowEx()
and compiled against the XPLM300 SDK). Windows created using the deprecated XPLMCreateWindow(), or windows compiled against a
pre-XPLM300 version of the SDK will simply get the "free" positioning mode.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplm_WindowPositionFree | 0 | The default positioning mode. Set the window geometry and its future position will be determined by its window gravity, resizing limits, and user interactions. |
| xplm_WindowCenterOnMonitor | 1 | Keep the window centered on the monitor you specify |
| xplm_WindowFullScreenOnMonitor | 2 | Keep the window full screen on the monitor you specify |
| xplm_WindowFullScreenOnAllMonitors | 3 | Like gui_window_full_screen_on_monitor, but stretches over *all* monitors and popout windows. This is an obscure one... unless you have a very good reason to need it, you probably don't! |
| xplm_WindowPopOut | 4 | A first-class window in the operating system, completely separate from the X-Plane window(s) |
| xplm_WindowVR | 5 | A floating window visible on the VR headset |

</div>

**Used by:**

- [XPLMSetWindowPositioningMode](#xplmsetwindowpositioningmode)

</div>

---

<div class="sym-block sym-function" data-name="XPLMSetWindowPositioningMode" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetWindowPositioningMode { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM300</span>

</div>

Sets the policy for how X-Plane will position your window.

Some positioning modes apply to a particular monitor. For those modes, you can pass a negative monitor index
to position the window on the main X-Plane monitor (the screen with the X-Plane menu bar at the top). Or,
if you have a specific monitor you want to position your window on, you can pass a real monitor index as received
from, e.g., XPLMGetAllMonitorBoundsOS().

Only applies to modern windows. (Windows created using the deprecated XPLMCreateWindow(),
or windows compiled against a pre-XPLM300 version of the SDK will always use xplm_WindowPositionFree.)

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSetWindowPositioningMode(
    inWindowID,           -- XPLMWindowID
    inPositioningMode,    -- XPLMWindowPositioningMode
    inMonitorIndex        -- int
)</code></pre>
</div>


**See associated types:**

- [XPLMWindowID](#xplmwindowid)
- [XPLMWindowPositioningMode](#xplmwindowpositioningmode)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSetWindowTitle" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetWindowTitle { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM300</span>

</div>

Sets the name for a window. This only applies to windows that opted-in to styling
as an X-Plane 11 floating window (i.e., with styling mode xplm_WindowDecorationRoundRectangle)
when they were created using XPLMCreateWindowEx().

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSetWindowTitle(
    inWindowID,       -- XPLMWindowID
    inWindowTitle     -- string
)</code></pre>
</div>


**See associated types:**

- [XPLMWindowID](#xplmwindowid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMGetWindowRefCon" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetWindowRefCon { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Returns a window's reference constant, the unique value you can use for your own purposes.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMGetWindowRefCon(
    inWindowID     -- XPLMWindowID
)</code></pre>
</div>


**See associated types:**

- [XPLMWindowID](#xplmwindowid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSetWindowRefCon" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetWindowRefCon { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Sets a window's reference constant.  Use this to pass data to yourself in the callbacks.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSetWindowRefCon(
    inWindowID,    -- XPLMWindowID
    inRefcon       -- any Lua var/table
)</code></pre>
</div>


**See associated types:**

- [XPLMWindowID](#xplmwindowid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMTakeKeyboardFocus" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMTakeKeyboardFocus { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine gives a specific window keyboard focus.  Keystrokes will be sent to
that window.  Pass a window ID of 0 to remove keyboard focus from any plugin-created windows
and instead pass keyboard strokes directly to X-Plane.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMTakeKeyboardFocus(
    inWindow     -- XPLMWindowID
)</code></pre>
</div>


**See associated types:**

- [XPLMWindowID](#xplmwindowid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMHasKeyboardFocus" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMHasKeyboardFocus { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Returns true (1) if the indicated window has keyboard focus.
Pass a window ID of 0 to see if no plugin window has focus, and all keystrokes
will go directly to X-Plane.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns boolean -> assign to local/var
local my_result = XPLMHasKeyboardFocus(
    inWindow     -- XPLMWindowID
)</code></pre>
</div>


**See associated types:**

- [XPLMWindowID](#xplmwindowid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMBringWindowToFront" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMBringWindowToFront { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine brings the window to the front of the Z-order for its layer.  Windows are brought to the
front automatically when they are created. Beyond that, you should make sure you are front before
handling mouse clicks.

Note that this only brings your window to the front of its layer (XPLMWindowLayer).
Thus, if you have a window in the floating window layer (xplm_WindowLayerFloatingWindows),
but there is a modal window (in layer xplm_WindowLayerModal) above you, you would still
not be the true frontmost window after calling this. (After all, the window layers are
strictly ordered, and no window in a lower layer can ever be above any window in a higher one.)

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMBringWindowToFront(
    inWindow     -- XPLMWindowID
)</code></pre>
</div>


**See associated types:**

- [XPLMWindowID](#xplmwindowid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMIsWindowInFront" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMIsWindowInFront { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns true if the window you passed in is the frontmost visible window in its layer (XPLMWindowLayer).

Thus, if you have a window at the front of the floating window layer (xplm_WindowLayerFloatingWindows),
this will return true even if there is a modal window (in layer xplm_WindowLayerModal) above you.
(Not to worry, though: in such a case, X-Plane will not pass clicks or keyboard input down to your
layer until the window above stops "eating" the input.)

Note that legacy windows are always placed in layer xplm_WindowLayerFlightOverlay, while modern-style windows
default to xplm_WindowLayerFloatingWindows. This means it's perfectly consistent to have two different
plugin-created windows (one legacy, one modern) *both* be in the front (of their different layers!) at the same time.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns boolean -> assign to local/var
local my_result = XPLMIsWindowInFront(
    inWindow     -- XPLMWindowID
)</code></pre>
</div>


**See associated types:**

- [XPLMWindowID](#xplmwindowid)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>