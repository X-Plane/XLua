<h1>Creating Custom Widgets</h1>

---

<div class="sym-block sym-function" data-name="XPAddWidgetCallback" data-type="function" markdown="1">

## XPAddWidgetCallback { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function adds a new widget callback to a widget. This widget callback supercedes
any existing ones and will receive messages first; if it does not handle messages they
will go on to be handled by pre-existing widgets.

The widget function will remain on the widget for the life of the widget. The
creation message will be sent to the new callback immediately with the widget ID, and
the destruction message will be sent before the other widget function receives a
destruction message.

This provides a way to 'subclass' an existing widget. By providing a second hook that
only handles certain widget messages, you can customize or extend widget behavior.

```cpp
XPLM_API void       XPAddWidgetCallback(
                         XPWidgetID           inWidget,
                         XPWidgetFunc_t       inNewCallback
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPGetWidgetClassFunc" data-type="function" markdown="1">

## XPGetWidgetClassFunc { .symbol-title }

<span class="sym-badge badge-fn">function</span>

Given a widget class, this function returns the callbacks that power that widget class.

```cpp
XPLM_API XPWidgetFunc_tXPGetWidgetClassFunc(
                         XPWidgetClass        inWidgetClass
                    );
```

</div>

---



<!-- whitespace for navigation purposes -->
<div style="height:100vh;"></div>