<h1>Widget Positioning And Visibility</h1>

---

<div class="sym-block sym-function" data-name="XPPlaceWidgetWithin" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPPlaceWidgetWithin { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function changes which container a widget resides in. You may NOT use this
function on a root widget! inSubWidget is the widget that will be moved. Pass
a widget ID in inContainer to make inSubWidget be a child of inContainer. It
will become the last/closest widget in the container. Pass 0 to remove the widget
from any container. Any call to this other than passing the widget ID of the old
parent of the affected widget will cause the widget to be removed from its old parent.
Placing a widget within its own parent simply makes it the last widget.

NOTE: this routine does not reposition the sub widget in global coordinates. If the
container has layout management code, it will reposition the subwidget for you,
otherwise you must do it with SetWidgetGeometry.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPPlaceWidgetWithin(
    inSubWidget,    -- XPWidgetID
    inContainer     -- XPWidgetID
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPCountChildWidgets" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPCountChildWidgets { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns the number of widgets another widget contains.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns int -> assign to local/var
local my_result = XPCountChildWidgets(
    inWidget     -- XPWidgetID
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPGetNthChildWidget" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPGetNthChildWidget { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns the widget ID of a child widget by index. Indexes are 0
based, from 0 to the number of widgets in the parentone minus one, inclusive. If
the index is invalid, 0 is returned.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns XPWidgetID -> assign to local/var
local my_widgetID = XPGetNthChildWidget(
    inWidget,    -- XPWidgetID
    inIndex      -- int
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPGetParentWidget" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPGetParentWidget { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Returns the parent of a widget, or 0 if the widget has no parent. Root widgets never have parents and therefore always return 0.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns XPWidgetID -> assign to local/var
local my_widgetID = XPGetParentWidget(
    inWidget     -- XPWidgetID
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPShowWidget" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPShowWidget { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine makes a widget visible if it is not already. Note that if a widget
is not in a rooted widget hierarchy or one of its parents is not visible, it will
still not be visible to the user.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPShowWidget(
    inWidget     -- XPWidgetID
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPHideWidget" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPHideWidget { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Makes a widget invisible. See XPShowWidget for considerations of when a widget might
not be visible despite its own visibility state.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPHideWidget(
    inWidget     -- XPWidgetID
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPIsWidgetVisible" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPIsWidgetVisible { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This returns 1 if a widget is visible, 0 if it is not. Note that this routine takes
into consideration whether a parent is invisible. Use this routine to tell if the user can see
the widget.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns boolean -> assign to local/var
local my_result = XPIsWidgetVisible(
    inWidget     -- XPWidgetID
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPFindRootWidget" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPFindRootWidget { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Returns the Widget ID of the root widget that contains the passed
in widget or NULL if the passed in widget is not in a rooted hierarchy.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns XPWidgetID -> assign to local/var
local my_widgetID = XPFindRootWidget(
    inWidget     -- XPWidgetID
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPBringRootWidgetToFront" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPBringRootWidgetToFront { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine makes the specified widget be in the frontmost widget hierarchy.
If this widget is a root widget, its widget hierarchy comes to front, otherwise
the widget's root is brought to the front. If this widget is not in an active
widget hiearchy (e.g. there is no root widget at the top of the tree), this routine
does nothing.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPBringRootWidgetToFront(
    inWidget     -- XPWidgetID
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPIsWidgetInFront" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPIsWidgetInFront { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns true if this widget's hierarchy is the frontmost hierarchy.
It returns false if the widget's hierarchy is not in front, or if the widget is not
in a rooted hierarchy.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns boolean -> assign to local/var
local my_result = XPIsWidgetInFront(
    inWidget     -- XPWidgetID
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPGetWidgetGeometry" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPGetWidgetGeometry { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns the bounding box of a widget in global coordinates.
Pass NULL for any parameter you are not interested in.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns a table of out values
local outs = XPGetWidgetGeometry(
    inWidget     -- XPWidgetID
)
-- outs = { outLeft, outTop, outRight, outBottom }</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPSetWidgetGeometry" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPSetWidgetGeometry { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function changes the bounding box of a widget.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPSetWidgetGeometry(
    inWidget,    -- XPWidgetID
    inLeft,      -- int
    inTop,       -- int
    inRight,     -- int
    inBottom     -- int
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPGetWidgetForLocation" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPGetWidgetForLocation { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Given a widget and a location, this routine returns the widget ID of the
child of that widget that owns that location. If inRecursive is true
then this will return a child of a child of a widget as it tries to find the
deepest widget at that location. If inVisibleOnly is true, then only visible
widgets are considered, otherwise all widgets are considered. The widget ID
passed for inContainer will be returned if the location is in that widget
but not in a child widget. 0 is returned if the location is not in the container.

NOTE: if a widget's geometry extends outside its parents geometry, it will not
be returned by this call for mouse locations outside the parent geometry. The
parent geometry limits the child's eligibility for mouse location.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns XPWidgetID -> assign to local/var
local my_widgetID = XPGetWidgetForLocation(
    inContainer,      -- XPWidgetID
    inXOffset,        -- int
    inYOffset,        -- int
    inRecursive,      -- int
    inVisibleOnly     -- boolean
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPGetWidgetExposedGeometry" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPGetWidgetExposedGeometry { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns the bounds of the area of a widget that is completely
within its parent widgets. Since a widget's bounding box can be outside
its parent, part of its area will not be eligible for mouse clicks and
should not draw. Use XPGetWidgetGeometry to find out what area defines
your widget's shape, but use this routine to find out what area to actually
draw into. Note that the widget library does not use OpenGL clipping to
keep frame rates up, although you could use it internally.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns a table of out values
local outs = XPGetWidgetExposedGeometry(
    inWidgetID     -- XPWidgetID
)
-- outs = { outLeft, outTop, outRight, outBottom }</code></pre>
</div>

</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>