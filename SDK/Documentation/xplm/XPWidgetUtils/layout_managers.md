<h1>Layout Managers</h1>

The layout managers are widget behavior functions for handling where widgets move.
Layout managers can be called from a widget function or attached to a widget later.

---

<div class="sym-block sym-function" data-name="XPUFixedLayout" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPUFixedLayout { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function causes the widget to maintain its children in fixed position
relative to itself as it is resized. Use this on the top level 'window' widget
for your window.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API int XPUFixedLayout(
                         XPWidgetMessage      inMessage,
                         XPWidgetID           inWidget,
                         intptr_t             inParam1,
                         intptr_t             inParam2
                    );
```

</div>

</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>