<h1>Panel Graphics Map Display</h1>

These routines let you draw the base map for a navigation display (ND) or
multi-function display (MFD) into your avionics panel. The base map provides
layers for terrain, topography, bodies of water, EGPWS terrain warnings,
airport taxi layouts, NEXRAD and cloud tops. These are drawn with a
stereographic projectionwhere the pole is the current user aircraft position.

Create a map display with XPLMCreateMapDisplay and draw it with
XPLMMapDisplayDrawIn. Each map instance manages its own terrain tile
loading and GPU state, so you can have multiple independent views (e.g. pilot
and copilot PFDs with different layers visible).

The base map works on any aircraft, regardless of whether the stock cockpit
has an FMS or other avionics installed.

---

<div class="sym-block sym-enum" data-name="XPLMMapLayers" data-type="enum" markdown="1">

## XPLMMapLayers { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

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

## XPLMEGPWSStyle { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

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

## XPLMMapCustomData_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span>

```cpp
typedef struct {
     float                     datLat;
     float                     datLon;
     int                       ctrX;
     int                       ctrY;
     int                       roseDiameter;
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

---

<div class="sym-block sym-struct" data-name="XPLMCreateMap_t" data-type="struct" markdown="1">

## XPLMCreateMap_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span>

Parameters for creating a base map display. Set structSize to the size of your
struct so that future SDK versions can add fields without breaking existing
plugins.

```cpp
typedef struct {
     int                       structSize;
     int                       pilotIndex;
} XPLMCreateMap_t;
```

</div>

---

<div class="sym-block sym-typedef" data-name="XPLMMapDisplayRef" data-type="typedef" markdown="1">

## XPLMMapDisplayRef { .symbol-title }

<span class="sym-badge badge-typedef">typedef</span>

An opaque handle to a map display instance. Create one with
XPLMCreateMapDisplay and destroy it with XPLMDestroyMapDisplay.

```cpp
typedef void * XPLMMapDisplayRef;
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMCreateMapDisplay" data-type="function" markdown="1">

## XPLMCreateMapDisplay { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function creates a new map display instance. The display begins loading
terrain tiles for the current aircraft position immediately. You can draw it
as soon as tiles are available; before that, the draw call is a no-op.

The returned handle must be destroyed with XPLMDestroyMapDisplay when no
longer needed. Handles are automatically destroyed when the owning plugin is
unloaded.

```cpp
XPLM_API XPLMMapDisplayRefXPLMCreateMapDisplay(
                         XPLMCreateMap_t *    params
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMDestroyMapDisplay" data-type="function" markdown="1">

## XPLMDestroyMapDisplay { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function destroys a map display and frees all associated resources.

```cpp
XPLM_API void       XPLMDestroyMapDisplay(
                         XPLMMapDisplayRef    map
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMMapDisplayDrawIn" data-type="function" markdown="1">

## XPLMMapDisplayDrawIn { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function renders the map display directly into the active panel surface
within the specified rectangular region. Map sets up its own stereographic
projection to fit the rectangle, so no transform stack manipulation is
needed.

The layers parameter controls which visual layers are rendered for this
draw call. Pass a bitwise OR of XPLMMapLayers flags. Note that some layers
are mutually exclusive, such as NEXRAD and EGPWS or NEXRAD and IR.
The airport details layer is only visible at very close zoom levels.

This function must be called from within an avionics drawing callback. If
terrain tiles have not finished loading yet, this function does nothing.

- map: the map display handle.
- layers: bitwise OR of XPLMMapLayers flags to enable for this draw call.
- left, top, right, bottom: the bounding rectangle in panel coordinates.

```cpp
XPLM_API void       XPLMMapDisplayDrawIn(
                         XPLMMapDisplayRef    map,
                         XPLMMapLayers        layers,
                         int                  left,
                         int                  top,
                         int                  right,
                         int                  bottom,
                         XPLMMapCustomData_t* dataOverrides    /* Can be NULL */
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMMapDisplayGetTerrainAltitudes" data-type="function" markdown="1">

## XPLMMapDisplayGetTerrainAltitudes { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function returns the lowest and highest altitude shown on the map's
EGPWS terrain display.

Note that those altitudes are only available if the map has been drawn
with the xplm_Map_EGPWS layer. If altitudes are not available, the function
returns false, and the altitude pointers are not modified.

This function must be called from within an avionics drawing callback.

- map: the map display handle.
- min: a pointer to the minimum altitude.
- max: a pointer to the maximum altitude.

```cpp
XPLM_API int        XPLMMapDisplayGetTerrainAltitudes(
                         XPLMMapDisplayRef    map,
                         float*               min,    /* Can be NULL */
                         float*               max    /* Can be NULL */
                    );
```

</div>

---



<!-- whitespace for navigation purposes -->
<div style="height:100vh;"></div>