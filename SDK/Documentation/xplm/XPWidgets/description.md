<h1>XP Widgets API</h1>
---

## THEORY OF OPERATION AND NOTES

Widgets are persistent view 'objects' for X-Plane. A widget is an object referenced by its opaque handle (widget
ID)
and the APIs in this file. You cannot access the widget's guts directly. Every Widget has the following
intrinsic
data:

- A bounding box defined in global screen coordinates with 0,0 in the bottom left and +y = up, +x = right.
- A visible box, which is the intersection of the bounding box with the widget's parents visible box.
- Zero or one parent widgets. (Always zero if the widget is a root widget.
- Zero or more child widgets.
- Whether the widget is a root. Root widgets are the top level plugin windows.
- Whether the widget is visible.
- A text string descriptor, whose meaning varies from widget to widget.
- An arbitrary set of 32 bit integral properties defined by 32-bit integral keys. This is how specific widgets store specific data.
- A list of widget callback procedures that implements the widgets behaviors.

The Widgets library sends messages to widgets to request specific behaviors or notify the widget of things.

Widgets may have more than one callback function, in which case messages are sent to the most recently added
callback
function until the message is handled. Messages may also be sent to parents or children; see the XPWidgetDefs.h
header file for the different widget message dispatching functions. By adding a callback function to a window
you can 'subclass' its behavior.

A set of standard widgets are provided that serve common UI purposes. You can also customize or implement
entirely custom widgets.

Widgets are different than other view hierarchies (most notably Win32, which they bear a striking resemblance
to) in the following ways:

- Not all behavior can be patched. State that is managed by the XPWidgets DLL and not by individual widgets
cannot be customized.
- All coordinates are in global screen coordinates. Coordinates are not relative to an enclosing widget, nor are
they relative to a display window.
- Widget messages are always dispatched synchronously, and there is no concept of scheduling an update or a
dirty region. Messages originate from X-Plane as the sim cycle goes by. Since X-Plane is constantly redrawing, so are
widgets; there is no need to mark a part of a widget as 'needing redrawing' because redrawing happens frequently
whether the widget needs it or not.
- Any widget may be a 'root' widget, causing it to be drawn; there is no relationship between widget class and
rootness. Root widgets are implemented as XPLMDisplay windows.



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>