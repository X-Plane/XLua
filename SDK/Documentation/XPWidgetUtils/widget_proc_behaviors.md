<h1>Widget Proc Behaviors</h1>

These widget behavior functions add other useful behaviors to widgets.
These functions cannot be attached to a widget; they must be called from
your widget function.

---

<div class="sym-block sym-function" data-name="XPUSelectIfNeeded" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPUSelectIfNeeded { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This causes the widget to bring its window to the foreground if it is not
already. inEatClick specifies whether clicks in the background should be
consumed by bringing the window to the foreground.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns int -> assign to local/var
local my_result = XPUSelectIfNeeded(
    inMessage,     -- XPWidgetMessage
    inWidget,      -- XPWidgetID
    inParam1,      -- see intptr_t
    inParam2,      -- see intptr_t
    inEatClick     -- int
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPUDefocusKeyboard" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPUDefocusKeyboard { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This causes the widget to send keyboard focus back to X-Plane.
This stops editing of any text fields, etc.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns int -> assign to local/var
local my_result = XPUDefocusKeyboard(
    inMessage,     -- XPWidgetMessage
    inWidget,      -- XPWidgetID
    inParam1,      -- see intptr_t
    inParam2,      -- see intptr_t
    inEatClick     -- boolean
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPUDragWidget" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPUDragWidget { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

XPUDragWidget drags the widget in response to mouse clicks. Pass in not
only the event, but the global coordinates of the drag region, which might
be a sub-region of your widget (for example, a title bar).

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns int -> assign to local/var
local my_result = XPUDragWidget(
    inMessage,    -- XPWidgetMessage
    inWidget,     -- XPWidgetID
    inParam1,     -- see intptr_t
    inParam2,     -- see intptr_t
    inLeft,       -- int
    inTop,        -- int
    inRight,      -- int
    inBottom      -- int
)</code></pre>
</div>

</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>