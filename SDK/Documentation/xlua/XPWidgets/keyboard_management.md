<h1>Keyboard Management</h1>

---

<div class="sym-block sym-function" data-name="XPSetKeyboardFocus" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPSetKeyboardFocus { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Controls which widget will receive keystrokes. Pass the widget ID
of the widget to get the keys. Note that if the widget does not care about keystrokes,
they will go to the parent widget, and if no widget cares about them, they go to
X-Plane.

If you set the keyboard focus to widget ID 0, X-Plane gets keyboard focus.

This routine returns the widget ID that ended up with keyboard focus, or 0 for X-Plane.

Keyboard focus is not changed if the new widget will not accept it. For setting to
X-Plane, keyboard focus is always accepted.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns XPWidgetID -> assign to local/var
local my_widgetID = XPSetKeyboardFocus(
    inWidget     -- XPWidgetID
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLoseKeyboardFocus" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLoseKeyboardFocus { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This causes the specified widget to lose focus; focus is passed to its parent, or
the next parent that will accept it. This routine does nothing if this widget
does not have focus.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLoseKeyboardFocus(
    inWidget     -- XPWidgetID
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPGetWidgetWithFocus" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPGetWidgetWithFocus { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns the widget that has keyboard focus, or 0 if X-Plane has keyboard
focus or some other plugin window that does not have widgets has focus.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns XPWidgetID -> assign to local/var
local my_widgetID = XPGetWidgetWithFocus(
)</code></pre>
</div>

</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>