<h1>XPLM Processing API</h1>
---

This API allows you to get regular callbacks during the flight loop, the part of
X-Plane where the plane's position calculates the physics of flight, etc. Use
these APIs to accomplish periodic tasks like logging data and performing I/O.

You can receive a callback either just before or just after the per-frame physics
calculations happen - you can use post-flightmodel callbacks to "patch" the flight model
after it has run.

If the user has set the number of flight model iterations per frame greater than
one your plugin will _not_ see this; these integrations run on the sub-section of
the flight model where iterations improve responsiveness (e.g. physical integration,
not simple systems tracking) and are thus opaque to plugins.

Flight loop scheduling, when scheduled by time, is scheduled by a "first callback
after the deadline" schedule, e.g. your callbacks will always be slightly late to
ensure that we don't run faster than your deadline.

WARNING: Do NOT use the post-flightmodel callback for initialization, resource
creation, etc. The only recommended use of post-FM callbacks is to "patch" the
computed values of the flightmodel using dataref read-writes, and to compute custom
system values by reading the flightmodel. APIs that create resources or initialize
the sim may issue warnings, crash rhe sim, or have unexpected results.

WARNING: Do NOT use these callbacks to draw! You cannot draw during flight
loop callbacks. Use the drawing callbacks (see XPLMDisplay for more info)
for graphics or the XPLMInstance functions for aircraft or models.
(One exception: you can use a post-flight loop callback to update
your own off-screen FBOs.)



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>