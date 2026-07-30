<h1>Global Definitions</h1>

These definitions are used in all parts of the SDK.

---

<div class="sym-block sym-typedef" data-name="XPLMPluginID" data-type="typedef" markdown="1">

## XPLMPluginID { .symbol-title }

<span class="sym-badge badge-typedef">typedef</span>

Each plug-in is identified by a unique integer ID.  This ID can be used to disable
or enable a plug-in, or discover what plug-in is 'running' at the time.  A plug-in
ID is unique within the currently running instance of X-Plane unless plug-ins are
reloaded.  Plug-ins may receive a different unique ID each time they are loaded.
This includes the unloading and reloading of plugins that are part of the user's
aircraft.

For persistent identification of plug-ins, use XPLMFindPluginBySignature in
XPLMUtiltiies.h .

-1 indicates no plug-in.

```cpp
typedef int XPLMPluginID;
```

</div>

---

<div class="sym-block sym-enum" data-name="XPLMKeyFlags" data-type="enum" markdown="1">

## XPLMKeyFlags { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

These bitfields define modifier keys in a platform independent way.
When a key is pressed, a series of messages are sent to your plugin.  The down
flag is set in the first of these messages, and the up flag in the last.  While
the key is held down, messages are sent with neither flag set to indicate that the key
is being held down as a repeated character.

The control flag is mapped to the control flag on Macintosh and PC.  Generally
X-Plane uses the control key and not the command key on Macintosh, providing
a consistent interface across platforms that does not necessarily match the Macintosh
user interface guidelines.  There is not yet a way for plugins to access the Macintosh
control keys without using #ifdefed code.

The down and up flags describe the phase of a key *event* and are only meaningful when
these flags arrive with a keystroke.  When you poll the live modifier state with
XPLMGetModifierKeys(), only the modifier bits (shift, option/alt, command/control, caps lock)
are ever set --- the down/up flags are never returned by that call.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplm_ShiftFlag | 1 | The shift key is down |
| xplm_OptionAltFlag | 2 | The option or alt key is down |
| xplm_ControlFlag | 4 | The control key is down |
| xplm_DownFlag | 8 | The key is being pressed down |
| xplm_UpFlag | 16 | The key is being released |
| xplm_CapsLockFlag | 32 | The caps lock key is engaged.  Only reported by XPLMGetModifierKeys(); never set on a key event. |

</div>

</div>

---

<div class="sym-block sym-enum" data-name="XPLMCursorStatus" data-type="enum" markdown="1">

## XPLMCursorStatus { .symbol-title }

<span class="sym-badge badge-enum">enum</span> <span class="sym-badge badge-version">XPLM200</span>

XPLMCursorStatus describes how you would like X-Plane to manage the cursor.  See XPLMHandleCursor_f for more info.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplm_CursorDefault | 0 | X-Plane manages the cursor normally, plugin does not affect the cusrsor. |
| xplm_CursorHidden | 1 | X-Plane hides the cursor. |
| xplm_CursorArrow | 2 | X-Plane shows the cursor as the default arrow. |
| xplm_CursorCustom | 3 | X-Plane shows the cursor but lets you select an OS cursor. |
| xplm_CursorRotateSmall | 4 | X-Plane shows a small bi-directional knob-rotating cursor. |
| xplm_CursorRotateSmallLeft | 5 | X-Plane shows a small counter-clockwise knob-rotating cursor. |
| xplm_CursorRotateSmallRight | 6 | X-Plane shows a small clockwise knob-rotating cursor. |
| xplm_CursorRotateMedium | 7 | X-Plane shows a medium bi-directional knob-rotating cursor. |
| xplm_CursorRotateMediumLeft | 8 | X-Plane shows a medium counter-clockwise knob-rotating cursor. |
| xplm_CursorRotateMediumRight | 9 | X-Plane shows a medium clockwise knob-rotating cursor. |
| xplm_CursorRotateLarge | 10 | X-Plane shows a large bi-directional knob-rotating cursor. |
| xplm_CursorRotateLargeLeft | 11 | X-Plane shows a large counter-clockwise knob-rotating cursor. |
| xplm_CursorRotateLargeRight | 12 | X-Plane shows a large clockwise knob-rotating cursor. |
| xplm_CursorUpDown | 13 | X-Plane shows an up-and-down arrows cursor. |
| xplm_CursorDown | 14 | X-Plane shows a down arrow cursor. |
| xplm_CursorUp | 15 | X-Plane shows an up arrow cursor. |
| xplm_CursorLeftRight | 16 | X-Plane shows a left-right arrow cursor. |
| xplm_CursorLeft | 17 | X-Plane shows a left arrow cursor. |
| xplm_CursorRight | 18 | X-Plane shows a right arrow cursor. |
| xplm_CursorButton | 19 | X-Plane shows a button-pushing cursor. |
| xplm_CursorHandle | 20 | X-Plane shows a handle-grabbing cursor. |
| xplm_CursorFourArrows | 21 | X-Plane shows a four-arrows cursor. |
| xplm_CursorSplitterH | 22 | X-Plane shows a cursor to drag a horizontal splitter bar. |
| xplm_CursorSplitterV | 23 | X-Plane shows a cursor to drag a vertical splitter bar. |
| xplm_CursorText | 24 | X-Plane shows an I-Beam cursor for text editing. |

</div>

</div>

---

<div class="sym-block sym-enum" data-name="XPLMMouseStatus" data-type="enum" markdown="1">

## XPLMMouseStatus { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

When the mouse is clicked, your mouse click routine is called repeatedly.  It is first called with the
mouse down message.  It is then called zero or more times with the mouse-drag message, and finally it
is called once with the mouse up message.  All of these messages will be directed to the same window;
you are guaranteed to not receive a drag or mouse-up event without first receiving the corresponding mouse-down.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplm_MouseDown | 1 |  |
| xplm_MouseDrag | 2 |  |
| xplm_MouseUp | 3 |  |

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_NO_PLUGIN_ID" data-type="define" markdown="1">

## XPLM_NO_PLUGIN_ID { .symbol-title }

<span class="sym-badge badge-define">define</span>

No plugin.

`#define XPLM_NO_PLUGIN_ID (-1)`

</div>

---

<div class="sym-block sym-define" data-name="XPLM_PLUGIN_XPLANE" data-type="define" markdown="1">

## XPLM_PLUGIN_XPLANE { .symbol-title }

<span class="sym-badge badge-define">define</span>

X-Plane itself

`#define XPLM_PLUGIN_XPLANE (0)`

</div>

---

<div class="sym-block sym-define" data-name="kXPLM_Version" data-type="define" markdown="1">

## kXPLM_Version { .symbol-title }

<span class="sym-badge badge-define">define</span>

The current XPLM revision is 4.6.0 (460).

`#define kXPLM_Version (460)`

</div>

---

<div class="sym-block sym-struct" data-name="XPLMFixedString150_t" data-type="struct" markdown="1">

## XPLMFixedString150_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span>

A container for a fixed-size string buffer of 150 characters.

```cpp
typedef struct {
     char[150]                 buffer;
} XPLMFixedString150_t;
```

</div>

---



<!-- whitespace for navigation purposes -->
<div style="height:100vh;"></div>