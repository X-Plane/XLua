<h1>XPLM Panel Graphics API</h1>
---

The XPLMPanelGraphics API provides a 2-D drawing toolkit for avionics screens and
instrument panels. You use these routines from within an avionics drawing callback
(registered via XPLMRegisterAvionicsCallbacksEx or XPLMCreateAvionicsEx) to draw
lines, polygons, text, and images onto the panel surface.

All drawing is expressed in panel coordinates: X increases to the right and Y increases
upward. Drawing commands are buffered and rendered by X-Plane at the end of your
callback; you do not manage OpenGL state directly.

Drawing State
---

Panel graphics functions modify a shared drawing state that includes a transformation
matrix, a scissor (clip) rectangle, and a stencil mask. Each of these has a
push/pop stack so you can save and restore state around localized drawing
operations.

Drawing Order
---

Primitives are drawn in the order you submit them. Later drawing calls paint over
earlier ones. Use the retained-drawing API to record a sequence of draw calls once
and replay it efficiently on subsequent frames.



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>