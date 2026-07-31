<h1>XPLM Planes API</h1>
---

The XPLMPlanes APIs allow you to control the various aircraft in X-Plane,
both the user's and the sim's.

You cannot initialize a flight from any XPLM callback. Only initialize a flight in response to:
 * Command handlers
 * Menu handlers
 * UI handlers (keyboard, mouse) from XPLMDisplay/widgets
 * The pre-flightmodel processing callback

In particular, do not initialize a flight from:
 * The post-flightmodel processing callback
 * Dataref get/set handlers
 * Any drawing callbacks

*Note*: Some older APIs for accessing aircraft require full paths and not paths relative to
the X-Plane folder for historical reasons. You will need to prefix all relative paths with the
X-Plane path as accessed via XPLMGetSystemPath.



<!-- whitespace for navigation purposes -->
<div style="height:100vh;"></div>