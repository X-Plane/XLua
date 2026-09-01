<h1>Widget Definitions</h1>

A widget is a call-back driven screen entity like a push-button, window, text entry
field, etc.

Use the widget API to create widgets of various classes. You can nest them into
trees of widgets to create complex user interfaces.

---

<div class="sym-block sym-typedef" data-name="XPWidgetID" data-type="typedef" markdown="1">

<div class="sym-title-row" markdown="1">

## XPWidgetID { .symbol-title }

<span class="sym-badge badge-typedef">typedef</span>

</div>

A Widget ID is an opaque unique non-zero handle identifying your widget. Use 0 to specify
"no widget". This type is defined as wide enough to hold a pointer. You receive a widget
ID when you create a new widget and then use that widget ID to further refer to the widget.

<div class="xplm-code" markdown="1">

```cpp
typedef void * XPWidgetID;
```

</div>


**Used by:**

- [XPWidgetFunc_t](widget_callback_function.md#xpwidgetfunc_t)
</div>

---

<div class="sym-block sym-enum" data-name="XPWidgetPropertyID" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## XPWidgetPropertyID { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

</div>

Properties are values attached to instances of your widgets. A property is
identified by a 32-bit ID and its value is the width of a pointer.

Each widget instance may have a property or not have it. When you set a property
on a widget for the first time, the property is added to the widget; it then
stays there for the life of the widget.

Some property IDs are predefined by the widget package; you can make up your
own property IDs as well.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xpProperty_Refcon | 0 | A window's refcon is an opaque value used by client code to find other data based on it. |
| xpProperty_Dragging | 1 | These properties are used by the utilities to implement dragging. |
| xpProperty_DragXOff | 2 |  |
| xpProperty_DragYOff | 3 |  |
| xpProperty_Hilited | 4 | Is the widget highlighted?  (For widgets that support this kind of thing.) |
| xpProperty_Object | 5 | Is there a C++ object attached to this widget? |
| xpProperty_Clip | 6 | If this property is 1, the widget package will use OpenGL to restrict drawing to the Widget's exposed rectangle. |
| xpProperty_Enabled | 7 | Is this widget enabled (for those that have a disabled state too)? |
| xpProperty_UserStart | 10000 | NOTE: Property IDs 1 - 999 are reserved for the widgets library.  NOTE: Property IDs 1000 - 9999 are allocated to the standard widget classes provided with the library.  Properties 1000 - 1099 are for widget class 0, 1100 - 1199 for widget class 1, etc. |

</div>

</div>

---

<div class="sym-block sym-struct" data-name="XPMouseState_t" data-type="struct" markdown="1">

<div class="sym-title-row" markdown="1">

## XPMouseState_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span>

</div>

When the mouse is clicked or dragged, a pointer to this structure is passed to your widget function.

<div class="xplm-code" markdown="1">

```cpp
typedef struct {
     int                       x;
     int                       y;
     int                       button;
     int                       delta;
} XPMouseState_t;
```

</div>

<div class="field-table" markdown="1">

| Field | Type | Description |
|:--|:--|:--|
| x | int |  |
| y | int |  |
| button | int | Mouse button number, left = 0 (right button not yet supported. |
| delta | int | Scroll wheel delta (button in this case would be the wheel axis number). |

</div>

</div>

---

<div class="sym-block sym-struct" data-name="XPKeyState_t" data-type="struct" markdown="1">

<div class="sym-title-row" markdown="1">

## XPKeyState_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span>

</div>

When a key is pressed, a pointer to this struct is passed to your widget function.

<div class="xplm-code" markdown="1">

```cpp
typedef struct {
     char                      key;
     XPLMKeyFlags              flags;
     char                      vkey;
} XPKeyState_t;
```

</div>

<div class="field-table" markdown="1">

| Field | Type | Description |
|:--|:--|:--|
| key | char | The ASCII key that was pressed.  WARNING: this may be 0 for some non-ASCII key sequences. |
| flags | XPLMKeyFlags | The flags.  Make sure to check this if you only want key-downs! |
| vkey | char | The virtual key code for the key |

</div>

</div>

---

<div class="sym-block sym-struct" data-name="XPWidgetGeometryChange_t" data-type="struct" markdown="1">

<div class="sym-title-row" markdown="1">

## XPWidgetGeometryChange_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span>

</div>

This structure contains the deltas for your widget's geometry when it changes.

<div class="xplm-code" markdown="1">

```cpp
typedef struct {
     int                       dx;
     int                       dy;
     int                       dwidth;
     int                       dheight;
} XPWidgetGeometryChange_t;
```

</div>

<div class="field-table" markdown="1">

| Field | Type | Description |
|:--|:--|:--|
| dx | int |  |
| dy | int | +Y = the widget moved up |
| dwidth | int |  |
| dheight | int |  |

</div>

</div>

---

<div class="sym-block sym-enum" data-name="XPDispatchMode" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## XPDispatchMode { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

</div>

The dispatching modes describe how the widgets library sends out messages.  Currently there are three modes:

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xpMode_Direct | 0 | The message will only be sent to the target widget. |
| xpMode_UpChain | 1 | The message is sent to the target widget, then up the chain of parents until the message is handled or a parentless widget is reached. |
| xpMode_Recursive | 2 | The message is sent to the target widget and then all of its children recursively depth-first. |
| xpMode_DirectAllCallbacks | 3 | The message is sent just to the target, but goes to every callback, even if it is handled. |
| xpMode_Once | 4 | The message is only sent to the very first handler even if it is not accepted. (This is really only useful for some internal widget library functions.) |

</div>

</div>

---

<div class="sym-block sym-typedef" data-name="XPWidgetClass" data-type="typedef" markdown="1">

<div class="sym-title-row" markdown="1">

## XPWidgetClass { .symbol-title }

<span class="sym-badge badge-typedef">typedef</span>

</div>

Widget classes define predefined widget types. A widget class basically specifies
from a library the widget function to be used for the widget. Most widgets can
be made right from classes.

<div class="xplm-code" markdown="1">

```cpp
typedef int XPWidgetClass;
```

</div>

</div>

---

<div class="sym-block sym-define" data-name="xpWidgetClass_None" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## xpWidgetClass_None { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

An unspecified widget class.  Other widget classes are in XPStandardWidgets.h

<div class="xplm-code" markdown="1">

`#define xpWidgetClass_None 0`

</div>

</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>