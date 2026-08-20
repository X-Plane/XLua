<h1>XPLM Graphics API</h1>
---

A few notes on coordinate systems:

X-Plane uses three kinds of coordinates.  Global coordinates are specified
as latitude, longitude and elevation.  This coordinate system never changes but
is not very precise.

OpenGL (or 'local') coordinates are cartesian and move with the aircraft.  They offer
more precision and are used for 3-d OpenGL drawing.  The X axis is aligned east-west
with positive X meaning east.  The Y axis is aligned straight up and down at the point
0,0,0 (but since the Earth is round it is not truly straight up and down at other
points).  The Z axis is aligned north-south at 0, 0, 0 with positive Z pointing south
(but since the Earth is round it isn't exactly north-south as you move east or west
of 0, 0, 0).  One unit is one meter and the point 0,0,0 is on the surface of the
Earth at sea level for some latitude and longitude picked by the sim such that the
user's aircraft is reasonably nearby.

2-d Panel coordinates are 2d, with the X axis horizontal and the Y axis vertical.
The point 0,0 is the bottom left and 1024,768 is the upper right of the screen.
This is true no matter what resolution the user's monitor is in; when running in
higher resolution, graphics will be scaled.

Use X-Plane's routines to convert between global and local coordinates.  Do not
attempt to do this conversion yourself; the precise 'roundness' of X-Plane's
physics model may not match your own, and (to make things weirder) the user can
potentially customize the physics of the current planet.



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>