<h1>Accessing Widget Data</h1>

---

<div class="sym-block sym-function" data-name="XPSetWidgetDescriptor" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPSetWidgetDescriptor { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Every widget has a descriptor, which is a text string. What the text string
is used for varies from widget to widget; for example, a push button's text
is its descriptor, a caption shows its descriptor, and a text field's descriptor
is the text being edited. In other words, the usage for the text varies from
widget to widget, but this API provides a universal and convenient way to get at
it. While not all UI widgets need their descriptor, many do.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPSetWidgetDescriptor(
    inWidget,        -- XPWidgetID
    inDescriptor     -- string
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPGetWidgetDescriptor" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPGetWidgetDescriptor { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns the widget's descriptor. Pass in the length of the buffer
you are going to receive the descriptor in. The descriptor will be null terminated
for you. This routine returns the length of the actual descriptor; if you pass
NULL for outDescriptor, you can get the descriptor's length without getting its text.
If the length of the descriptor exceeds your buffer length, the buffer will not be
null terminated (this routine has 'strncpy' semantics).

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns int, plus a table of out values
local my_result, outs = XPGetWidgetDescriptor(
    inWidget,           -- XPWidgetID
    inMaxDescLength     -- int
)
-- outs = { outDescriptor }</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPGetWidgetUnderlyingWindow" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPGetWidgetUnderlyingWindow { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Returns the window (from the XPLMDisplay API) that backs your widget window.
If you have opted in to modern windows, via a call to
XPLMEnableFeature("XPLM_USE_NATIVE_WIDGET_WINDOWS", 1), you can use the
returned window ID for display APIs like XPLMSetWindowPositioningMode(),
allowing you to pop the widget window out into a real OS window, or
move it into VR.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns XPLMWindowID -> assign to local/var
local my_windowID = XPGetWidgetUnderlyingWindow(
    inWidget     -- XPWidgetID
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPSetWidgetProperty" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPSetWidgetProperty { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function sets a widget's property. Properties are arbitrary values associated by a widget by ID.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPSetWidgetProperty(
    inWidget,      -- XPWidgetID
    inProperty,    -- XPWidgetPropertyID
    inValue        -- see intptr_t
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPGetWidgetProperty" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPGetWidgetProperty { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns the value of a widget's property, or 0 if the property is not
defined. If you need to know whether the property is defined, pass a pointer to an
int for inExists; the existence of that property will be returned in the int. Pass
NULL for inExists if you do not need this information.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns see intptr_t, plus a table of out values
local my_result, outs = XPGetWidgetProperty(
    inWidget,      -- XPWidgetID
    inProperty     -- XPWidgetPropertyID
)
-- outs = { inExists }</code></pre>
</div>

</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>