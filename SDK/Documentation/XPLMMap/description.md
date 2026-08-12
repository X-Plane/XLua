<h1>XPLM Map API</h1>
---

This API allows you to create new layers within X-Plane maps. Your layers can draw arbitrary OpenGL, but they
conveniently also have access to X-Plane's built-in icon and label drawing functions.

As of X-Plane 11, map drawing happens in three stages:

1. backgrounds and "fill",
2. icons, and
3. labels.

Thus, all background drawing gets layered beneath all icons, which likewise get layered beneath all labels.
Within each stage, the map obeys a consistent layer ordering, such that "fill" layers (layers that cover a
large amount of map area, like the terrain and clouds) appear beneath "markings" layers (like airport icons).
This ensures that layers with fine details don't get obscured by layers with larger details.

The XPLM map API reflects both aspects of this draw layering: you can register a layer as providing either
markings or fill, and X-Plane will draw your fill layers beneath your markings layers (regardless of registration
order). Likewise, you are guaranteed that your layer's icons (added from within an icon callback) will go above
your layer's OpenGL drawing, and your labels will go above your icons.

The XPLM guarantees that all plugin-created fill layers go on top of all native X-Plane fill layers, and all plugin-created markings
layers go on top of all X-Plane markings layers (with the exception of the aircraft icons). It also guarantees
that the draw order of your own plugin's layers will be consistent. But, for layers created by different plugins,
the only guarantee is that we will draw all of one plugin's layers of each type (fill, then markings),
then all of the others'; we don't guarantee which plugin's fill and markings layers go on top of the other's.

As of X-Plane 11, maps use true cartographic projections for their drawing, and different maps may use
different projections. For that reason, all drawing calls include an opaque handle for the projection you
should use to do the drawing. Any time you would draw at a particular latitude/longitude, you'll need to ask
the projection to translate that position into "map coordinates." (Note that the projection is guaranteed not
to change between calls to your prepare-cache hook, so if you cache your map coordinates ahead of time, there's
no need to re-project them when you actually draw.)

In addition to mapping normal latitude/longitude locations into map coordinates, the projection APIs also
let you know the current heading for north. (Since X-Plane 11 maps can rotate to match the heading of the
user's aircraft, it's not safe to assume that north is at zero degrees rotation.)



<!-- whitespace for navigation purposes -->
<div style="height:100vh;"></div>