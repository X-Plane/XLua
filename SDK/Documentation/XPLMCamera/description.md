<h1>XPLM Camera API</h1>
---

The XPLMCamera APIs allow plug-ins to control the camera angle in X-Plane. This
has a number of applications, including but not limited to:

- Creating new views (including dynamic/user-controllable views) for the user.
- Creating applications that use X-Plane as a renderer of scenery, aircrafts, or both.

The camera is controlled via six parameters: a location in OpenGL coordinates
and pitch, roll and yaw, similar to an airplane's position. OpenGL coordinate info
is described in detail in the XPLMGraphics documentation; generally you should use
the XPLMGraphics routines to convert from world to local coordinates. The camera's
orientation starts facing level with the ground directly up the negative-Z axis
(approximately north) with the horizon horizontal. It is then rotated clockwise
for yaw, pitched up for positive pitch, and rolled clockwise around the vector it
is looking along for roll.

You control the camera either either until the user selects a new view or
permanently (the latter being similar to how UDP camera control works). You control
the camera by registering a callback per frame from which you calculate the new
camera positions. This guarantees smooth camera motion.

Use the XPLMDataAccess APIs to get information like the position of the aircraft, etc.
for complex camera positioning.

Note: if your goal is to move the virtual pilot in the cockpit, this API is not needed;
simply update the datarefs for the pilot's head position.

For custom exterior cameras, set the camera's mode to an external view first to
get correct sound and 2-d panel behavior.



<!-- whitespace for navigation purposes -->
<div style="height:100vh;"></div>