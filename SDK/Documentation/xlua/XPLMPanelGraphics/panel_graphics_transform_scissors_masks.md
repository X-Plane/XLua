<h1>Panel_graphics Transform/Scissors/Masks</h1>

These routines modify the drawing state for subsequent panel graphics calls.
The transformation matrix controls the position, rotation, and scale of all
drawing. The scissor rectangle clips drawing to a rectangular region. The
stencil mask clips drawing to an arbitrary shape.

The transform and the scissor rectangle each have a push/pop stack. Always
push before modifying either one and pop to restore the previous state when
you are done. For the transform this is required, not merely good manners:
XPLMTransformTranslate, XPLMTransformRotate and XPLMTransformScale must be
called inside a XPLMTransformPush/XPLMTransformPop pair; calling one outside a
pair is an error. X-Plane does not push a transform scope around your drawing
callback, so a transform with no enclosing push has no defined end.

Scissor rectangles ride the transform stack, exactly like the drawing they
clip: the rectangle you pass is in panel coordinates and is put through the
transform in force when you set it. Once set, it stays where you set it - a
later transform does not move it, and popping the scissor stack restores
whatever rectangle was in force before the matching push.

Rotation is the one transform a rectangle cannot survive, because an
axis-aligned rectangle cannot describe a rotated one. Calling any of these
while a rotation is in effect is an error, reported to Log.txt and through your
error callback:

- XPLMScissorSet and XPLMScissorIntersect
- XPLMAccumulateTouchZone
- XPLMDrawCalls, whose draw calls carry their own scissor rectangles
- XPLMSVTDisplayDrawIn and XPLMMapDisplayDrawIn, which clip themselves
- XPLMDrawRetained, if the retained drawing contains any of the above

Translate and scale are fine for all of them, and are applied for you.

The stencil has no stack. Instead the stencil buffer holds up to eight
independent one-bit masks, and you select which of them clips your drawing by
calling XPLMUseStencilMask as often as you like. X-Plane restores the stencil
state for you at the end of your drawing callback.

---

<div class="sym-block sym-function" data-name="XPLMTransformPush" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMTransformPush { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function saves the current transformation matrix onto the transform
stack. Call XPLMTransformPop to restore it. Calls must be balanced.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMTransformPush(
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMTransformPop" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMTransformPop { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function restores the transformation matrix from the top of the
transform stack, undoing all translate, rotate, and scale operations since
the matching XPLMTransformPush.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMTransformPop(
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMTransformTranslate" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMTransformTranslate { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function translates (offsets) all subsequent drawing by the specified
amounts. The translation is applied on top of the current transformation
matrix.

Must be called inside a XPLMTransformPush/XPLMTransformPop pair.

- dx: horizontal offset in pixels, positive to the right.
- dy: vertical offset in pixels, positive upward.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMTransformTranslate(
    dx,    -- float
    dy     -- float
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMTransformRotate" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMTransformRotate { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function rotates all subsequent drawing around a center point. The
rotation is applied on top of the current transformation matrix.

Must be called inside a XPLMTransformPush/XPLMTransformPop pair.

While a rotation is in effect, you may not use any routine that works with an
axis-aligned rectangle - scissors, touch zones, XPLMDrawCalls, and the SVT and
map draw-ins. See the section description above for the full list. This is
decided by whether you called this function, not by the angle you passed: a
rotation of zero degrees still counts. Keep rotations in as tight a push/pop
scope as you can, so those routines are available again after the pop.

- centerX, centerY: the center of rotation in panel coordinates.
- angle: the rotation angle in degrees, positive counterclockwise.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMTransformRotate(
    centerX,    -- float
    centerY,    -- float
    angle       -- float
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMTransformScale" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMTransformScale { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function scales all subsequent drawing relative to the origin of the
current coordinate system. The scale is applied on top of the current
transformation matrix.

Must be called inside a XPLMTransformPush/XPLMTransformPop pair.

Neither factor may be zero: a zero scale collapses the coordinate system onto
a line, so a position expressed in it can no longer be recovered. Negative
factors are fine and mirror your drawing.

- scaleX: horizontal scale factor. 1.0 is no change, 2.0 doubles width.
- scaleY: vertical scale factor. 1.0 is no change, 2.0 doubles height.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMTransformScale(
    scaleX,    -- float
    scaleY     -- float
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMScissorPush" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMScissorPush { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function saves the current scissor rectangle onto the scissor stack.
Call XPLMScissorPop to restore it. Calls must be balanced.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMScissorPush(
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMScissorPop" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMScissorPop { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function restores the scissor rectangle from the top of the scissor
stack, undoing any set or shrink operations since the matching
XPLMScissorPush.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMScissorPop(
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMScissorSet" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMScissorSet { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function sets an absolute scissor rectangle. Only pixels within this
rectangle are drawn; everything outside is clipped.

- left, top, right, bottom: the scissor bounds in panel coordinates.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMScissorSet(
    left,      -- int
    top,       -- int
    right,     -- int
    bottom     -- int
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMScissorIntersect" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMScissorIntersect { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function sets the scissor rectangle to the intersection of the current
scissor rectangle and the rectangle you pass in. The result is always the
same or a smaller drawable area. This is useful for nested clipping.

- left, top, right, bottom: the scissor bounds in panel coordinates, the
  same coordinate space used by XPLMScissorSet.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMScissorIntersect(
    left,      -- int
    top,       -- int
    right,     -- int
    bottom     -- int
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMBeginSetupStencilMask" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMBeginSetupStencilMask { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function begins stencil mask setup. While in setup mode, drawing
commands write to the stencil buffer instead of to the screen. Draw the
shapes that define your mask region, then call XPLMEndSetupStencilMask to
finish.

The stencil buffer is eight bits wide, so you can record up to eight
independent masks and pick among them later with XPLMUseStencilMask - one bit
per mask - without having to re-draw them.

- bits: the stencil bit pattern to write into the stencil buffer where
  geometry is drawn.
- mask: a bitmask selecting which stencil bits are written.

Both parameters must be in the range 0 to 255, and every bit set in bits must
also be set in mask - a bit outside the mask can never be written. Stencil
testing must be off (see XPLMUseStencilMask) when you call this.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMBeginSetupStencilMask(
    bits,    -- int
    mask     -- int
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMEndSetupStencilMask" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMEndSetupStencilMask { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function ends stencil mask setup. After this call, drawing commands
once again render to the screen, and stencil testing is off. Call
XPLMUseStencilMask to start drawing through the mask you just recorded.

The mask stays in the stencil buffer until you overwrite it or call
XPLMClearStencilMask, so you may record several masks up front and then
switch among them.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMEndSetupStencilMask(
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMUseStencilMask" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMUseStencilMask { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function selects which stencil mask clips your drawing. Subsequent
drawing is clipped to the region you recorded with XPLMBeginSetupStencilMask:
only pixels where the stencil buffer matches the specified bit pattern are
drawn.

- bits: the reference bit pattern to test against.
- mask: a bitmask selecting which stencil bits participate in the test.

Both parameters must be in the range 0 to 255, and every bit set in bits must
also be set in mask - a bit outside the mask can never match.

You may call this as often as you like within one drawing callback to switch
between masks you have recorded; each call replaces the previous test. Pass
(0, 0) to stop stencil testing entirely. You do not have to do that at the
end of your callback - X-Plane turns stencil testing off for you, and for a
window it also clears any mask you recorded, so nothing you draw leaks into
another window.

This function may not be called between XPLMBeginSetupStencilMask and
XPLMEndSetupStencilMask.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMUseStencilMask(
    bits,    -- int
    mask     -- int
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMClearStencilMask" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMClearStencilMask { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function erases the entire stencil buffer, discarding every mask you
have recorded. It does not change whether stencil testing is on - use
XPLMUseStencilMask(0, 0) for that.

Because this throws away all eight masks at once, you rarely need it: to stop
drawing through a mask, call XPLMUseStencilMask(0, 0), and to replace one,
just record over it. It is safe to call at any time as a way of asking for a
known starting state, even if you have recorded nothing.

Stencil testing must be off, and you may not call this between
XPLMBeginSetupStencilMask and XPLMEndSetupStencilMask.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMClearStencilMask(
)</code></pre>
</div>

</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>