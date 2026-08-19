<h1>Map Layer Creation And Destruction</h1>

Enables the creation of new map layers. Layers are created for a particular instance of the X-Plane map.
For instance, if you want your layer to appear in both the normal map interface and the Instructor Operator
Station (IOS), you would need two separate calls to XPLMCreateMapLayer(), with two different values for your
XPLMCreateMapLayer_t::layer_name.

Your layer's lifetime will be determined by the lifetime of the map it is created in. If the map is destroyed
(on the X-Plane side), your layer will be too, and you'll receive a callback to your XPLMMapWillBeDeletedCallback_f.

---

<div class="sym-block sym-enum" data-name="XPLMMapLayerType" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMMapLayerType { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

</div>

Indicates the type of map layer you are creating. Fill layers will always be drawn beneath markings layers.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplm_MapLayer_Fill | 0 | A layer that draws "fill" graphics, like weather patterns, terrain, etc. Fill layers frequently cover a large portion of the visible map area. |
| xplm_MapLayer_Markings | 1 | A layer that provides markings for particular map features, like NAVAIDs, airports, etc. Even dense markings layers cover a small portion of the total map area. |

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_MAP_USER_INTERFACE" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_MAP_USER_INTERFACE { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

Globally unique identifier for X-Plane's Map window, used as the mapToCreateLayerIn parameter in XPLMCreateMapLayer_t

<div class="xplm-code" markdown="1">

`#define XPLM_MAP_USER_INTERFACE "XPLM_MAP_USER_INTERFACE"`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_MAP_IOS" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_MAP_IOS { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

Globally unique identifier for X-Plane's Instructor Operator Station window, used as the mapToCreateLayerIn parameter in XPLMCreateMapLayer_t

<div class="xplm-code" markdown="1">

`#define XPLM_MAP_IOS "XPLM_MAP_IOS"`

</div>

</div>

---

<div class="sym-block sym-struct" data-name="XPLMCreateMapLayer_t" data-type="struct" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCreateMapLayer_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span>

</div>

This structure defines all of the parameters used to create a map layer using XPLMCreateMapLayer. The structure
will be expanded in future SDK APIs to include more features.  Always set the structSize member to the size of your struct in
bytes!

Each layer must be associated with exactly one map instance in X-Plane. That map, and that map alone,
will call your callbacks. Likewise, when that map is deleted, your layer will be as well.

<div class="xplm-code" markdown="1">

```cpp
typedef struct {
     int                       structSize;
     const char *              mapToCreateLayerIn;
     XPLMMapLayerType          layerType;
     XPLMMapWillBeDeletedCallback_f willBeDeletedCallback;
     XPLMMapPrepareCacheCallback_f prepCacheCallback;
     XPLMMapDrawingCallback_f  drawCallback;
     XPLMMapIconDrawingCallback_f iconCallback;
     XPLMMapLabelDrawingCallback_f labelCallback;
     int                       showUiToggle;
     const char *              layerName;
     void*                     refcon;
} XPLMCreateMapLayer_t;
```

</div>


**See available callback(s):**

- [XPLMMapDrawingCallback_f](drawing_callbacks.md#xplmmapdrawingcallback_f)
- [XPLMMapIconDrawingCallback_f](drawing_callbacks.md#xplmmapicondrawingcallback_f)
- [XPLMMapLabelDrawingCallback_f](drawing_callbacks.md#xplmmaplabeldrawingcallback_f)
- [XPLMMapPrepareCacheCallback_f](layer_management_callbacks.md#xplmmappreparecachecallback_f)
- [XPLMMapWillBeDeletedCallback_f](layer_management_callbacks.md#xplmmapwillbedeletedcallback_f)
</div>

---

<div class="sym-block sym-function" data-name="XPLMCreateMapLayer" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCreateMapLayer { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine creates a new map layer. You pass in an XPLMCreateMapLayer_t structure with all
of the fields defined.  You must set the structSize of the structure to the size of the
actual structure you used.

Returns NULL if the layer creation failed. This happens most frequently because the map you specified in your
XPLMCreateMapLayer_t::mapToCreateLayerIn field doesn't exist (that is, if XPLMMapExists() returns 0 for the specified map).
You can use XPLMRegisterMapCreationHook() to get a notification
each time a new map is opened in X-Plane, at which time you can create layers in it.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API XPLMMapLayerID XPLMCreateMapLayer(
                         XPLMCreateMapLayer_t * inParams
                    );
```

</div>


**See associated types:**

- [XPLMCreateMapLayer_t](#xplmcreatemaplayer_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMDestroyMapLayer" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMDestroyMapLayer { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Destroys a map layer you created (calling your XPLMMapWillBeDeletedCallback_f if applicable). Returns true if a deletion took place.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API int XPLMDestroyMapLayer(
                         XPLMMapLayerID       inLayer
                    );
```

</div>


**See associated types:**

- [XPLMMapLayerID](drawing_callbacks.md#xplmmaplayerid)
</div>

---

<div class="sym-block sym-callback" data-name="XPLMMapCreatedCallback_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMMapCreatedCallback_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

A callback to notify your plugin that a new map has been created in X-Plane. This is the best time to
add a custom map layer using XPLMCreateMapLayer().

No OpenGL drawing is permitted within this callback.

<div class="xplm-code" markdown="1">

```cpp
typedef void (* XPLMMapCreatedCallback_f)(
                         const char *         mapIdentifier,
                         void*                inRefcon
                    );
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMRegisterMapCreationHook" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMRegisterMapCreationHook { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Registers your callback to receive a notification each time a new map is constructed in X-Plane.
This callback is the best time to add your custom map layer using XPLMCreateMapLayer().

Note that you will not be notified about any maps that already exist---you can use XPLMMapExists() to
check for maps that were created previously.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMRegisterMapCreationHook(
                         XPLMMapCreatedCallback_f callback,    /* Can be NULL */
                         void*                inRefcon
                    );
```

</div>


**See associated types:**

- [XPLMMapCreatedCallback_f](#xplmmapcreatedcallback_f)
</div>

---

<div class="sym-block sym-function" data-name="XPLMMapExists" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMMapExists { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Returns true if the map with the specified identifier already exists in X-Plane. In that case, you can
safely call XPLMCreateMapLayer() specifying that your layer should be added to that map.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API int XPLMMapExists(
                         const char *         mapIdentifier
                    );
```

</div>

</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>