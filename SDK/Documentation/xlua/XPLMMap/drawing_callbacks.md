<h1>Drawing Callbacks</h1>

When you create a new map layer (using XPLMCreateMapLayer), you can provide any or all of these callbacks.
They allow you to insert your own OpenGL drawing, text labels, and icons into
the X-Plane map at the appropriate places, allowing your layer to behave as similarly
to X-Plane's built-in layers as possible.

---

<div class="sym-block sym-typedef" data-name="XPLMMapLayerID" data-type="typedef" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMMapLayerID { .symbol-title }

<span class="sym-badge badge-typedef">typedef</span>

</div>

This is an opaque handle for a plugin-created map layer. Pass it to the map drawing APIs from an appropriate callback
to draw in the layer you created.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">local my_mapLayerID = nil  -- XPLMMapLayerID</code></pre>
</div>


**Used by:**

- [XPLMDestroyMapLayer](map_layer_creation_and_destruction.md#xplmdestroymaplayer)
- [XPLMDrawMapIconFromSheet](map_drawing.md#xplmdrawmapiconfromsheet)
- [XPLMDrawMapLabel](map_drawing.md#xplmdrawmaplabel)
- [XPLMMapDrawingCallback_f](#xplmmapdrawingcallback_f)
- [XPLMMapIconDrawingCallback_f](#xplmmapicondrawingcallback_f)
- [XPLMMapLabelDrawingCallback_f](#xplmmaplabeldrawingcallback_f)
- [XPLMMapPrepareCacheCallback_f](layer_management_callbacks.md#xplmmappreparecachecallback_f)
- [XPLMMapWillBeDeletedCallback_f](layer_management_callbacks.md#xplmmapwillbedeletedcallback_f)
</div>

---

<div class="sym-block sym-typedef" data-name="XPLMMapProjectionID" data-type="typedef" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMMapProjectionID { .symbol-title }

<span class="sym-badge badge-typedef">typedef</span>

</div>

This is an opaque handle for a map projection. Pass it to the projection APIs to translate between
map coordinates and latitude/longitudes.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">local my_mapProjectionID = nil  -- XPLMMapProjectionID</code></pre>
</div>


**Used by:**

- [XPLMMapDrawingCallback_f](#xplmmapdrawingcallback_f)
- [XPLMMapGetNorthHeading](map_projections.md#xplmmapgetnorthheading)
- [XPLMMapIconDrawingCallback_f](#xplmmapicondrawingcallback_f)
- [XPLMMapLabelDrawingCallback_f](#xplmmaplabeldrawingcallback_f)
- [XPLMMapPrepareCacheCallback_f](layer_management_callbacks.md#xplmmappreparecachecallback_f)
- [XPLMMapProject](map_projections.md#xplmmapproject)
- [XPLMMapScaleMeter](map_projections.md#xplmmapscalemeter)
- [XPLMMapUnproject](map_projections.md#xplmmapunproject)
</div>

---

<div class="sym-block sym-enum" data-name="XPLMMapStyle" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMMapStyle { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

</div>

Indicates the visual style being drawn by the map. In X-Plane, the user can choose between a number of
map types, and different map types may have use a different visual representation for the same elements
(for instance, the visual style of the terrain layer changes drastically between the VFR and IFR layers),
or certain layers may be disabled entirely in some map types (e.g., localizers are only visible in the
IFR low-enroute style).

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplm_MapStyle_VFR_Sectional | 0 |  |
| xplm_MapStyle_IFR_LowEnroute | 1 |  |
| xplm_MapStyle_IFR_HighEnroute | 2 |  |

</div>

**Used by:**

- [XPLMMapDrawingCallback_f](#xplmmapdrawingcallback_f)
- [XPLMMapIconDrawingCallback_f](#xplmmapicondrawingcallback_f)
- [XPLMMapLabelDrawingCallback_f](#xplmmaplabeldrawingcallback_f)

</div>

---

<div class="sym-block sym-callback" data-name="XPLMMapDrawingCallback_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMMapDrawingCallback_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

This is the OpenGL map drawing callback for plugin-created map layers.
You can perform arbitrary OpenGL drawing from this callback, with
one exception: changes to the Z-buffer are not permitted, and will result in map drawing errors.

All drawing done from within this callback appears beneath all built-in X-Plane icons and labels, but above
the built-in "fill" layers (layers providing major details, like terrain and water).
Note, however, that the relative ordering between the drawing callbacks of different plugins is not guaranteed.

- inMapBoundsLeftTopRightBottom: a 4-element array defining the currently visible map bounds
  (in map units; to convert to latitude/longitude, use the map projection APIs).
- zoomRatio: any ratio (negative or positive), where 0 indicates the whole map is visible. A
  negative zoom means the user zoomed out beyond the full map bounds. When the map is fully
  zoomed in, the zoom ratio may exceed 30.
- mapUnitsPerUserInterfaceUnit: if your layer is drawing in the standard X-Plane map window,
  this is map units per boxel; if you're drawing within the sim itself, this is the map units
  per "virtual device pixel," whose size in real screen pixels is of course fluid since the
  user can move the camera relative to the in-sim map.
- mapStyle: the user-selected map style being drawn currently.
- projection: the map projection in use (this is guaranteed to match the projection last
  passed to your XPLMMapPrepareCacheCallback_f, if applicable).
- inRefcon: a reference to arbitrary data from when you registered this layer.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_MapDrawingCallback_callback(
    inLayer,                          -- XPLMMapLayerID
    inMapBoundsLeftTopRightBottom,    -- float
    zoomRatio,                        -- float
    mapUnitsPerUserInterfaceUnit,     -- float
    mapStyle,                         -- XPLMMapStyle
    projection,                       -- XPLMMapProjectionID
    inRefcon                          -- any Lua var/table
)
    -- your code here
end</code></pre>
</div>


**See associated types:**

- [XPLMMapLayerID](#xplmmaplayerid)
- [XPLMMapProjectionID](#xplmmapprojectionid)
- [XPLMMapStyle](#xplmmapstyle)
</div>

---

<div class="sym-block sym-callback" data-name="XPLMMapIconDrawingCallback_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMMapIconDrawingCallback_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

This is the icon drawing callback that enables plugin-created map layers to draw icons using X-Plane's
built-in icon drawing functionality.
You can request an arbitrary number of PNG icons to be drawn via XPLMDrawMapIconFromSheet() from within this callback,
but you may not perform any OpenGL drawing here.

Icons enqueued by this function will appear above all OpenGL drawing (performed by your optional XPLMMapDrawingCallback_f), and
above all built-in X-Plane map icons of the same layer type ("fill" or "markings," as determined by the
XPLMMapLayerType in your XPLMCreateMapLayer_t). Note, however, that the relative ordering between
the drawing callbacks of different plugins is not guaranteed.

- inMapBoundsLeftTopRightBottom: a 4-element array defining the currently visible map bounds
  (in map units; to convert to latitude/longitude, use the map projection APIs).
- zoomRatio: any ratio (negative or positive), where 0 indicates the whole map is visible. A
  negative zoom means the user zoomed out beyond the full map bounds. When the map is fully
  zoomed in, the zoom ratio may exceed 30.
- mapUnitsPerUserInterfaceUnit: if your layer is drawing in the standard X-Plane map window,
  this is map units per boxel; if you're drawing within the sim itself, this is the map units
  per "virtual device pixel," whose size in real screen pixels is of course fluid since the
  user can move the camera relative to the in-sim map.
- mapStyle: the user-selected map style being drawn currently.
- projection: the map projection in use (this is guaranteed to match the projection last
  passed to your XPLMMapPrepareCacheCallback_f, if applicable).
- inRefcon: a reference to arbitrary data from when you registered this layer.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_MapIconDrawingCallback_callback(
    inLayer,                          -- XPLMMapLayerID
    inMapBoundsLeftTopRightBottom,    -- float
    zoomRatio,                        -- float
    mapUnitsPerUserInterfaceUnit,     -- float
    mapStyle,                         -- XPLMMapStyle
    projection,                       -- XPLMMapProjectionID
    inRefcon                          -- any Lua var/table
)
    -- your code here
end</code></pre>
</div>


**See associated types:**

- [XPLMMapLayerID](#xplmmaplayerid)
- [XPLMMapProjectionID](#xplmmapprojectionid)
- [XPLMMapStyle](#xplmmapstyle)
</div>

---

<div class="sym-block sym-callback" data-name="XPLMMapLabelDrawingCallback_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMMapLabelDrawingCallback_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

This is the label drawing callback that enables plugin-created map layers to draw text labels
using X-Plane's built-in labeling functionality.
You can request an arbitrary number of text labels to be drawn via XPLMDrawMapLabel() from within this callback,
but you may not perform any OpenGL drawing here.

Labels enqueued by this function will appear above all OpenGL drawing (performed by your optional XPLMMapDrawingCallback_f), and
above all built-in map icons and labels of the same layer type ("fill" or "markings," as determined by the
XPLMMapLayerType in your XPLMCreateMapLayer_t). Note, however, that the relative ordering between
the drawing callbacks of different plugins is not guaranteed.

- inMapBoundsLeftTopRightBottom: a 4-element array defining the currently visible map bounds
  (in map units; to convert to latitude/longitude, use the map projection APIs).
- zoomRatio: any ratio (negative or positive), where 0 indicates the whole map is visible. A
  negative zoom means the user zoomed out beyond the full map bounds. When the map is fully
  zoomed in, the zoom ratio may exceed 30.
- mapUnitsPerUserInterfaceUnit: if your layer is drawing in the standard X-Plane map window,
  this is map units per boxel; if you're drawing within the sim itself, this is the map units
  per "virtual device pixel," whose size in real screen pixels is of course fluid since the
  user can move the camera relative to the in-sim map.
- mapStyle: the user-selected map style being drawn currently.
- projection: the map projection in use (this is guaranteed to match the projection last
  passed to your XPLMMapPrepareCacheCallback_f, if applicable).
- inRefcon: a reference to arbitrary data from when you registered this layer.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_MapLabelDrawingCallback_callback(
    inLayer,                          -- XPLMMapLayerID
    inMapBoundsLeftTopRightBottom,    -- float
    zoomRatio,                        -- float
    mapUnitsPerUserInterfaceUnit,     -- float
    mapStyle,                         -- XPLMMapStyle
    projection,                       -- XPLMMapProjectionID
    inRefcon                          -- any Lua var/table
)
    -- your code here
end</code></pre>
</div>


**See associated types:**

- [XPLMMapLayerID](#xplmmaplayerid)
- [XPLMMapProjectionID](#xplmmapprojectionid)
- [XPLMMapStyle](#xplmmapstyle)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>