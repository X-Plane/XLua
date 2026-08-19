<h1>Panel Graphics Map Display</h1>

These routines let you draw the base map for a navigation display (ND) or
multi-function display (MFD) into your avionics panel. The base map provides
layers for terrain, topography, bodies of water, EGPWS terrain warnings,
airport taxi layouts, NEXRAD and cloud tops. These are drawn with a transverse
Mercator projection centered near the map's datum.

Create a map display with XPLMCreateMapDisplay and draw it with
XPLMMapDisplayDrawIn. Each map instance manages its own terrain tile
loading and GPU state, so you can have multiple independent views (e.g. pilot
and copilot PFDs with different layers visible).

To draw your own symbology on top - airports, a flight plan, traffic - use
XPLMMapDisplayProject to turn a latitude/longitude into a pixel position, and
XPLMMapDisplayUnproject to turn a click back into a latitude/longitude. Both
take the same XPLMMapDrawInfo_t you draw with, so they describe exactly the
projection that draw call produces.

The base map works on any aircraft, regardless of whether the stock cockpit
has an FMS or other avionics installed.

---

<div class="sym-block sym-enum" data-name="XPLMMapLayers" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMMapLayers { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

</div>

Bit flags that control which visual layers a map display renders. Combine
flags with bitwise OR to enable multiple layers. NOTE: Not all layers can
be combined. You can display terrain and water and taxiways at the same
time, but you cannot display weather radar and EGPWS at the same time.
Only one of NEXRAD or Cloud IR can be displayed. Airport details (taxiways)
are only visible at close-in zoom levels.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplm_Map_Nexrad | 1 | Radar composite reflectivity. |
| xplm_Map_IR | 2 | Infrared false-color cloud tops. |
| xplm_Map_Topo | 4 | Topography (elevation color scale, not taking aircraft altitude into account). |
| xplm_Map_Terrain | 8 | Terrain (terrain elevation relative to aircraft altitude). |
| xplm_Map_Water | 16 | Bodies of water. |
| xplm_Map_EGPWS | 32 | Terrain warnings (relative to aircraft altitude, trajectory and landing gear position). |
| xplm_Map_raw_elev | 64 | Raw 0-255 texture of terrain elevation for plugin use. |
| xplm_Map_safe_taxi | 128 | Airport runway and taxiway layouts. |

</div>

</div>

---

<div class="sym-block sym-enum" data-name="XPLMEGPWSStyle" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMEGPWSStyle { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

</div>

Flag that controls how the map's EGPWS display layer is rendered.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplm_EGPWS_Style_Blocky | 0 | Terrain is drawn as small dithered blocks (common in most airliner avionics). |
| xplm_EGPWS_Style_Smooth | 1 | Terrain countours are smooth and curved (common in modern avionics). |

</div>

</div>

---

<div class="sym-block sym-struct" data-name="XPLMMapCustomData_t" data-type="struct" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMMapCustomData_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span>

</div>

Per-frame description of what a map display should show: where it is centered, how it is
oriented, how far it reaches, and what the terrain layers should shade against.

centerX and centerY are in the same panel coordinates as the rectangle in XPLMMapDrawInfo_t, NOT
relative to that rectangle. This is the point the map is centered on and the point it rotates
about - the same sense as XPLMTransformRotate's center. For a map centered in its own rectangle
it is ((left+right)/2, (bottom+top)/2). It is also the same space XPLMMapDisplayProject reports
positions in, so you can put a symbol on the map without offsetting anything yourself.

The center need not be the rectangle's midpoint, and may sit on or outside its edge: pushing it
down toward the bottom edge puts more of the map ahead of the aircraft, which is how an EFIS
arc mode is laid out.

Two fields set the scale, and they are deliberately a matching pair: roseRadius is the
distance from the center of the map out to the compass rose in pixels, and mapRange is that
same distance in nautical miles. So setting mapRange to 40 puts the rose edge 40 nm from the
aircraft, exactly like the range knob on a real EFIS control panel - and a centered rose
therefore spans 80 nm across.

Set structSize to the size of your struct so that future SDK versions can add fields without
breaking existing plugins.

<div class="xplm-code" markdown="1">

```cpp
typedef struct {
     int                       structSize;
     float                     datLat;
     float                     datLon;
     int                       centerX;
     int                       centerY;
     int                       roseRadius;
     float                     mapRange;
     int                       orientation;
     float                     terrainWarn;
     float                     terrainCaution;
     float                     acfAlt;
     int                       gearDown;
     float                     trueRotation;
     float                     nearestRwyElev;
     float                     egpwsBrightness;
     XPLMEGPWSStyle            egpwsStyle;
} XPLMMapCustomData_t;
```

</div>

</div>

---

<div class="sym-block sym-struct" data-name="XPLMCreateMap_t" data-type="struct" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCreateMap_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span>

</div>

Parameters for creating a base map display. Set structSize to the size of your
struct so that future SDK versions can add fields without breaking existing
plugins.

<div class="xplm-code" markdown="1">

```cpp
typedef struct {
     int                       structSize;
     int                       pilotIndex;
} XPLMCreateMap_t;
```

</div>

</div>

---

<div class="sym-block sym-typedef" data-name="XPLMMapDisplayRef" data-type="typedef" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMMapDisplayRef { .symbol-title }

<span class="sym-badge badge-typedef">typedef</span>

</div>

An opaque handle to a map display instance. Create one with
XPLMCreateMapDisplay and destroy it with XPLMDestroyMapDisplay.

<div class="xplm-code" markdown="1">

```cpp
typedef void * XPLMMapDisplayRef;
```

</div>


**Used by:**

- [XPLMDestroyMapDisplay](#xplmdestroymapdisplay)
- [XPLMMapDisplayDrawIn](#xplmmapdisplaydrawin)
- [XPLMMapDisplayGetNorthHeading](#xplmmapdisplaygetnorthheading)
- [XPLMMapDisplayGetTerrainAltitudes](#xplmmapdisplaygetterrainaltitudes)
- [XPLMMapDisplayProject](#xplmmapdisplayproject)
- [XPLMMapDisplayScaleMeter](#xplmmapdisplayscalemeter)
- [XPLMMapDisplayUnproject](#xplmmapdisplayunproject)
</div>

---

<div class="sym-block sym-struct" data-name="XPLMMapDrawInfo_t" data-type="struct" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMMapDrawInfo_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span>

</div>

Which layers a map shows and where on the panel it goes.

Pass the same XPLMMapDrawInfo_t and the same XPLMMapCustomData_t to XPLMMapDisplayDrawIn and to
the projection routines, and the projection you query is provably the projection you drew - so
your symbology cannot end up a frame or a zoom step out of step with the terrain under it.

Set structSize to the size of your struct so that future SDK versions can add fields without
breaking existing plugins.

<div class="xplm-code" markdown="1">

```cpp
typedef struct {
     int                       structSize;
     XPLMMapLayers             layers;
     int                       left;
     int                       top;
     int                       right;
     int                       bottom;
} XPLMMapDrawInfo_t;
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMCreateMapDisplay" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCreateMapDisplay { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function creates a new map display instance. The display begins loading
terrain tiles for the current aircraft position immediately. You can draw it
as soon as tiles are available; before that, the draw call is a no-op.

The returned handle must be destroyed with XPLMDestroyMapDisplay when no
longer needed. Handles are automatically destroyed when the owning plugin is
unloaded.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API XPLMMapDisplayRef XPLMCreateMapDisplay(
                         XPLMCreateMap_t *    params
                    );
```

</div>


**See associated types:**

- [XPLMCreateMap_t](#xplmcreatemap_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMDestroyMapDisplay" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMDestroyMapDisplay { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function destroys a map display and frees all associated resources.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMDestroyMapDisplay(
                         XPLMMapDisplayRef    map
                    );
```

</div>


**See associated types:**

- [XPLMMapDisplayRef](#xplmmapdisplayref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMMapDisplayDrawIn" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMMapDisplayDrawIn { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function renders the map display directly into the active panel surface
within the rectangle given by info. Map sets up its own projection to fit that
rectangle, so no transform stack manipulation is needed.

info->layers controls which visual layers are rendered. Note that some layers
are mutually exclusive, such as NEXRAD and EGPWS or NEXRAD and IR. The airport
details layer is only visible at very close zoom levels.

This function must be called from within an avionics drawing callback. If
terrain tiles have not finished loading yet, this function does nothing.

dataOverrides may be NULL, in which case the map follows the sim's own navigation
display: centered on the user aircraft in the middle of the rectangle, rose radius
half the shorter side of it, range taken from the EFIS range knob, and track-up or
north-up according to the sim's map mode. The pilotIndex you created the map with
selects which side's range and altitude are used.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMMapDisplayDrawIn(
                         XPLMMapDisplayRef    map,
                         XPLMMapDrawInfo_t *  info,
                         XPLMMapCustomData_t * dataOverrides    /* Can be NULL */
                    );
```

</div>


**See associated types:**

- [XPLMMapCustomData_t](#xplmmapcustomdata_t)
- [XPLMMapDisplayRef](#xplmmapdisplayref)
- [XPLMMapDrawInfo_t](#xplmmapdrawinfo_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMMapDisplayProject" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMMapDisplayProject { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Turns a latitude/longitude into a position in panel coordinates, for the map
that info describes. This is the inverse of XPLMMapDisplayUnproject.

Pass the same info you draw that map with and you get the projection that draw
call produces, whether you call this before or after XPLMMapDisplayDrawIn. So
the usual pattern - project your symbols, draw the map, then draw the symbols
on top - lines up exactly, with no need to cache anything between frames.

Unlike XPLMMapDisplayDrawIn, this does not have to be called from a drawing
callback; it is equally valid from a click handler or a flight loop.

Returns 1 on success. Returns 0, leaving outX and outY untouched, if the map's
terrain tiles have not loaded yet or if the point has no position on this map.

Note that the returned coordinates are in the same space as info's rectangle,
and like that rectangle they do not account for the panel graphics transform
stack. That is deliberate, and it is what you want: you take these coordinates
and hand them to a drawing call - XPLMTextureAtlasDrawAt to put a VOR symbol on
the map, say - and that drawing call applies the transform. Applying it here as
well would apply it twice.

Passing NULL for dataOverrides projects the sim's own navigation display view, the
same one XPLMMapDisplayDrawIn draws with NULL.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API int XPLMMapDisplayProject(
                         XPLMMapDisplayRef    map,
                         XPLMMapDrawInfo_t *  info,
                         XPLMMapCustomData_t * dataOverrides,    /* Can be NULL */
                         double               latitude,
                         double               longitude,
                         float *              outX,
                         float *              outY
                    );
```

</div>


**See associated types:**

- [XPLMMapCustomData_t](#xplmmapcustomdata_t)
- [XPLMMapDisplayRef](#xplmmapdisplayref)
- [XPLMMapDrawInfo_t](#xplmmapdrawinfo_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMMapDisplayUnproject" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMMapDisplayUnproject { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Turns a position back into a latitude/longitude, for the map that info
describes. This is the inverse of XPLMMapDisplayProject, and like it, x and y
are in the same space as info's rectangle rather than in transformed
coordinates.

Use this to turn a touch or click on your map into a place in the world - for
picking a waypoint, or reading out the position under the cursor. This needs no
adjustment on your part in either of its two uses. For a touch, the coordinates
your XPLMTouchEvent_f receives are already in the space you declared the zone
in, so as long as you put the zone down under the same transform as the map,
they are the space this function wants. For culling, you already hold your own
drawing coordinates, which are likewise untransformed. In both cases, running
the transform stack over the input - in either direction - would be the bug.

Unlike XPLMMapDisplayDrawIn, this does not have to be called from a drawing
callback; it is equally valid from a click handler or a flight loop, where there
is no transform stack at all.

Returns 1 on success. Returns 0, leaving outLatitude and outLongitude
untouched, if the map's terrain tiles have not loaded yet or if the point does
not correspond to anywhere on the earth.

Passing NULL for dataOverrides projects the sim's own navigation display view, the
same one XPLMMapDisplayDrawIn draws with NULL.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API int XPLMMapDisplayUnproject(
                         XPLMMapDisplayRef    map,
                         XPLMMapDrawInfo_t *  info,
                         XPLMMapCustomData_t * dataOverrides,    /* Can be NULL */
                         float                x,
                         float                y,
                         double *             outLatitude,
                         double *             outLongitude
                    );
```

</div>


**See associated types:**

- [XPLMMapCustomData_t](#xplmmapcustomdata_t)
- [XPLMMapDisplayRef](#xplmmapdisplayref)
- [XPLMMapDrawInfo_t](#xplmmapdrawinfo_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMMapDisplayScaleMeter" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMMapDisplayScaleMeter { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Returns how many pixels correspond to one meter at a given point on the map
that info describes. Use it to size symbols and range rings so they stay
correct as the range changes.

Returns 0 if the map's terrain tiles have not loaded yet.

Passing NULL for dataOverrides projects the sim's own navigation display view, the
same one XPLMMapDisplayDrawIn draws with NULL.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API float XPLMMapDisplayScaleMeter(
                         XPLMMapDisplayRef    map,
                         XPLMMapDrawInfo_t *  info,
                         XPLMMapCustomData_t * dataOverrides,    /* Can be NULL */
                         float                x,
                         float                y
                    );
```

</div>


**See associated types:**

- [XPLMMapCustomData_t](#xplmmapcustomdata_t)
- [XPLMMapDisplayRef](#xplmmapdisplayref)
- [XPLMMapDrawInfo_t](#xplmmapdrawinfo_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMMapDisplayGetNorthHeading" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMMapDisplayGetNorthHeading { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Returns the heading, in degrees clockwise from straight up on the display, at
which true north lies at a given point on the map that info describes. ADD it
to a true heading to get the angle to draw that heading at.

This accounts both for the map's own rotation - a heading-up map is turned to
put the aircraft's nose at the top - and for the projection's convergence,
which tilts north away from vertical as you move away from the map's center.

Returns 0 if the map's terrain tiles have not loaded yet.

Passing NULL for dataOverrides projects the sim's own navigation display view, the
same one XPLMMapDisplayDrawIn draws with NULL.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API float XPLMMapDisplayGetNorthHeading(
                         XPLMMapDisplayRef    map,
                         XPLMMapDrawInfo_t *  info,
                         XPLMMapCustomData_t * dataOverrides,    /* Can be NULL */
                         float                x,
                         float                y
                    );
```

</div>


**See associated types:**

- [XPLMMapCustomData_t](#xplmmapcustomdata_t)
- [XPLMMapDisplayRef](#xplmmapdisplayref)
- [XPLMMapDrawInfo_t](#xplmmapdrawinfo_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMMapDisplayGetTerrainAltitudes" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMMapDisplayGetTerrainAltitudes { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function returns the lowest and highest altitude shown on the map's
EGPWS terrain display.

Note that those altitudes are only available if the map has been drawn
with the xplm_Map_EGPWS layer. If altitudes are not available, the function
returns false, and the altitude pointers are not modified.

This function must be called from within an avionics drawing callback.

- map: the map display handle.
- min: a pointer to the minimum altitude.
- max: a pointer to the maximum altitude.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API int XPLMMapDisplayGetTerrainAltitudes(
                         XPLMMapDisplayRef    map,
                         float*               min,    /* Can be NULL */
                         float*               max    /* Can be NULL */
                    );
```

</div>


**See associated types:**

- [XPLMMapDisplayRef](#xplmmapdisplayref)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>