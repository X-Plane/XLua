<h1>Layer Management Callbacks</h1>

These are various "bookkeeping" callbacks that your map layer can receive (if you provide the callback in your
XPLMCreateMapLayer_t). They allow you to manage the lifecycle of your layer, as well as cache any
computationally-intensive preparation you might need for drawing.

---

<div class="sym-block sym-callback" data-name="XPLMMapPrepareCacheCallback_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMMapPrepareCacheCallback_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

A callback used to allow you to cache whatever information your layer needs to draw in the current map area.

This is called each time the map's total bounds change. This is typically triggered by new DSFs being loaded,
such that X-Plane discards old, now-distant DSFs and pulls in new ones. At that point, the available bounds
of the map also change to match the new DSF area.

By caching just the information you need to draw in this area, your future draw calls can be made faster,
since you'll be able to simply "splat" your precomputed information each frame.

We guarantee that the map projection will not change between successive prepare cache calls, nor will any
draw call give you bounds outside these total map bounds. So, if you cache the projected map coordinates
of all the items you might want to draw in the total map area, you can be guaranteed that no draw call
will be asked to do any new work.

- inTotalMapBoundsLeftTopRightBottom: a 4-element array defining the map's new total bounds
  (in map units; to convert to latitude/longitude, use the map projection APIs). This is the
  maximal area you will ever be asked to draw (at least until you receive the next prepare
  cache call).
- projection: the map projection in use; guaranteed to match the projection passed to all map
  drawing calls until the next prepare cache call.
- inRefcon: a reference to arbitrary data from when you registered this layer.

<div class="xplm-code" markdown="1">

```cpp
typedef void (* XPLMMapPrepareCacheCallback_f)(
                         XPLMMapLayerID       inLayer,
                         const float          inTotalMapBoundsLeftTopRightBottom[4],
                         XPLMMapProjectionID  projection,
                         void*                inRefcon
                    );
```

</div>


**See associated types:**

- [XPLMMapLayerID](drawing_callbacks.md#xplmmaplayerid)
- [XPLMMapProjectionID](drawing_callbacks.md#xplmmapprojectionid)
</div>

---

<div class="sym-block sym-callback" data-name="XPLMMapWillBeDeletedCallback_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMMapWillBeDeletedCallback_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

Called just before your map layer gets deleted. Because SDK-created map layers have the same lifetime
as the X-Plane map that contains them, if the map gets unloaded from memory, your layer will too.

This callback fires exactly once, just before deletion, after which none of the layer's callbacks are used.

- inRefcon: a reference to arbitrary data from when you registered this layer.

<div class="xplm-code" markdown="1">

```cpp
typedef void (* XPLMMapWillBeDeletedCallback_f)(
                         XPLMMapLayerID       inLayer,
                         void*                inRefcon
                    );
```

</div>


**See associated types:**

- [XPLMMapLayerID](drawing_callbacks.md#xplmmaplayerid)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>