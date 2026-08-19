<h1>Map Projections</h1>

As of X-Plane 11, the map draws using true cartographic projections, and different maps may use different projections.
Thus, to draw at a particular latitude and longitude, you must first transform your real-world coordinates into
map coordinates.

The map projection is also responsible for giving you the current scale of the map. That is, the projection
can tell you how many map units correspond to 1 meter at a given point.

Finally, the map projection can give you the current rotation of the map. Since X-Plane 11 maps can rotate to
match the heading of the aircraft, the map's rotation can potentially change every frame.

---

<div class="sym-block sym-function" data-name="XPLMMapProject" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMMapProject { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Projects a latitude/longitude into map coordinates.
This is the inverse of XPLMMapUnproject().

Only valid from within a map layer callback (one of XPLMMapPrepareCacheCallback_f, XPLMMapDrawingCallback_f,
XPLMMapIconDrawingCallback_f, or XPLMMapLabelDrawingCallback_f.)

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMMapProject(
                         XPLMMapProjectionID  projection,
                         double               latitude,
                         double               longitude,
                         float *              outX,
                         float *              outY
                    );
```

</div>


**See associated types:**

- [XPLMMapProjectionID](drawing_callbacks.md#xplmmapprojectionid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMMapUnproject" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMMapUnproject { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Transforms map coordinates back into a latitude and longitude.
This is the inverse of XPLMMapProject().

Only valid from within a map layer callback (one of XPLMMapPrepareCacheCallback_f, XPLMMapDrawingCallback_f,
XPLMMapIconDrawingCallback_f, or XPLMMapLabelDrawingCallback_f.)

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMMapUnproject(
                         XPLMMapProjectionID  projection,
                         float                mapX,
                         float                mapY,
                         double *             outLatitude,
                         double *             outLongitude
                    );
```

</div>


**See associated types:**

- [XPLMMapProjectionID](drawing_callbacks.md#xplmmapprojectionid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMMapScaleMeter" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMMapScaleMeter { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Returns the number of map units that correspond to a distance of one meter at a given set of map coordinates.

Only valid from within a map layer callback (one of XPLMMapPrepareCacheCallback_f, XPLMMapDrawingCallback_f,
XPLMMapIconDrawingCallback_f, or XPLMMapLabelDrawingCallback_f.)

<div class="xplm-code" markdown="1">

```cpp
XPLM_API float XPLMMapScaleMeter(
                         XPLMMapProjectionID  projection,
                         float                mapX,
                         float                mapY
                    );
```

</div>


**See associated types:**

- [XPLMMapProjectionID](drawing_callbacks.md#xplmmapprojectionid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMMapGetNorthHeading" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMMapGetNorthHeading { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Returns the heading (in degrees clockwise) from the positive Y axis in the cartesian mapping coordinate system to
true north at the point passed in.  You can use it as a clockwise rotational offset to align icons and other 2-d
drawing with true north on the map, compensating for rotations in the map due to projection.

Only valid from within a map layer callback (one of XPLMMapPrepareCacheCallback_f, XPLMMapDrawingCallback_f,
XPLMMapIconDrawingCallback_f, or XPLMMapLabelDrawingCallback_f.)

<div class="xplm-code" markdown="1">

```cpp
XPLM_API float XPLMMapGetNorthHeading(
                         XPLMMapProjectionID  projection,
                         float                mapX,
                         float                mapY
                    );
```

</div>


**See associated types:**

- [XPLMMapProjectionID](drawing_callbacks.md#xplmmapprojectionid)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>