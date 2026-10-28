<h1>Widget Callback Function</h1>

---

<div class="sym-block sym-callback" data-name="XPWidgetFunc_t" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPWidgetFunc_t { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

This function defines your custom widget's behavior. It will be called by the widgets library to send
messages to your widget. The message and widget ID are passed in, as well as two pointer-width signed
parameters whose meaning varies with the message. Return true to indicate that you have processed
the message, false to indicate that you have not. For any message that is not understood, return 0.

<div class="xplm-code" markdown="1">

```cpp
typedef int (* XPWidgetFunc_t)(
                         XPWidgetMessage      inMessage,
                         XPWidgetID           inWidget,
                         intptr_t             inParam1,
                         intptr_t             inParam2
                    );
```

</div>


**See associated types:**

- [XPWidgetID](widget_definitions.md#xpwidgetid)
- [XPWidgetMessage](widget_messages.md#xpwidgetmessage)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>