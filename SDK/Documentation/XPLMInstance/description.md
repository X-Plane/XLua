<h1>XPLM Instance API</h1>
---

This API provides instanced drawing of X-Plane objects (.obj files). In contrast to old drawing APIs,
which required you to draw your own objects per-frame, the instancing API allows you to simply register
an OBJ for drawing, then move or manipulate it later (as needed).

This provides one tremendous benefit: it keeps all dataref operations for your object in one place.
Because datarefs access may be done from the main thread only, allowing dataref access anywhere is a serious performance
bottleneck for the simulator - the whole simulator has to pause and wait for each dataref access.
This performance penalty will only grow worse as X-Plane moves toward an ever more heavily
multithreaded engine.

The instancing API allows X-Plane to isolate all dataref manipulations for all plugin object drawing
to one place, potentially providing huge performance gains.

Here's how it works:

When an instance is created, it provides a list of all datarefs you want to manipulate for the OBJ
in the future. This list of datarefs replaces the ad-hoc collections of dataref objects previously used
by art assets. Then, per-frame, you can manipulate the instance by passing in a "block" of packed floats
representing the current values of the datarefs for your instance. (Note that the ordering of this set of
packed floats must exactly match the ordering of the datarefs when you created your instance.)



<!-- whitespace for navigation purposes -->
<div style="height:100vh;"></div>