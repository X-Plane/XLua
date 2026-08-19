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

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns int -> assign to local/var
local my_result = XPUFixedLayout(
    inMessage,    -- XPWidgetMessage
    inWidget,     -- XPWidgetID
    inParam1,     -- see intptr_t
    inParam2      -- see intptr_t
)</code></pre>
</div>

</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>