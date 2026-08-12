<h1>Widget Creation And Management</h1>

---

<div class="sym-block sym-function" data-name="XPCreateWidget" data-type="function" markdown="1">

## XPCreateWidget { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function creates a new widget and returns the new widget's ID to you. If the
widget creation fails for some reason, it returns NULL. Widget creation will fail
either if you pass a bad class ID or if there is not adequate memory.

Input Parameters:

- Top, left, bottom, and right in global screen coordinates defining the widget's
location on the screen.
- inVisible is 1 if the widget should be drawn, 0 to start the widget as hidden.
- inDescriptor is a null terminated string that will become the widget's descriptor.
- inIsRoot is 1 if this is going to be a root widget, 0 if it will not be.
- inContainer is the ID of this widget's container. It must be 0 for a root widget.
For a non-root widget, pass the widget ID of the widget to place this widget within.
If this widget is not going to start inside another widget, pass 0; this new widget
will be created but will not be drawn until it is placed inside another widget.
- inClass is the class of the widget to draw. Use one of the predefined class-IDs
to create a standard widget.

A note on widget embedding: a widget is only called (and will be drawn, etc.) if
it is placed within a widget that will be called. Root widgets are always called.
So it is possible to have whole chains of widgets that are simply not called.
You can preconstruct widget trees and then place them into root widgets later to
activate them if you wish.

```cpp
XPLM_API XPWidgetID XPCreateWidget(
                         int                  inLeft,
                         int                  inTop,
                         int                  inRight,
                         int                  inBottom,
                         int                  inVisible,
                         const char *         inDescriptor,
                         int                  inIsRoot,
                         XPWidgetID           inContainer,
                         XPWidgetClass        inClass
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPCreateCustomWidget" data-type="function" markdown="1">

## XPCreateCustomWidget { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function is the same as XPCreateWidget except that instead of passing a class ID,
you pass your widget callback function pointer defining the widget. Use this
function to define a custom widget. All parameters are the same as XPCreateWidget,
except that the widget class has been replaced with the widget function.

```cpp
XPLM_API XPWidgetID XPCreateCustomWidget(
                         int                  inLeft,
                         int                  inTop,
                         int                  inRight,
                         int                  inBottom,
                         int                  inVisible,
                         const char *         inDescriptor,
                         int                  inIsRoot,
                         XPWidgetID           inContainer,
                         XPWidgetFunc_t       inCallback
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPDestroyWidget" data-type="function" markdown="1">

## XPDestroyWidget { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This class destroys a widget. Pass in the ID of the widget to kill. If you
pass 1 for inDestroyChilren, the widget's children will be destroyed first, then
this widget will be destroyed. (Furthermore, the widget's children will be destroyed
with the inDestroyChildren flag set to 1, so the destruction will recurse down the
widget tree.) If you pass 0 for this flag, direct child widgets will simply end up
with their parent set to 0.

```cpp
XPLM_API void       XPDestroyWidget(
                         XPWidgetID           inWidget,
                         int                  inDestroyChildren
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPSendMessageToWidget" data-type="function" markdown="1">

## XPSendMessageToWidget { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This sends any message to a widget. You should probably not go around simulating the
predefined messages that the widgets library defines for you. You may however define
custom messages for your widgets and send them with this method.

This method supports several dispatching patterns; see XPDispatchMode for more info.
The function returns true if the message was handled, false if it was not.

For each widget that receives the message (see the dispatching modes), each widget
function from the most recently installed to the oldest one receives the message in
order until it is handled.

```cpp
XPLM_API int        XPSendMessageToWidget(
                         XPWidgetID           inWidget,
                         XPWidgetMessage      inMessage,
                         XPDispatchMode       inMode,
                         intptr_t             inParam1,
                         intptr_t             inParam2
                    );
```

</div>

---



<!-- whitespace for navigation purposes -->
<div style="height:100vh;"></div>