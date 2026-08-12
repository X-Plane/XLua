<h1>Object Drawing</h1>

The object drawing routines let you load and draw X-Plane OBJ files. Objects are loaded by file path and
managed via an opaque handle. X-Plane naturally reference counts objects, so it is important that you
balance every successful call to XPLMLoadObject with a call to XPLMUnloadObject!

---

<div class="sym-block sym-typedef" data-name="XPLMObjectRef" data-type="typedef" markdown="1">

## XPLMObjectRef { .symbol-title }

<span class="sym-badge badge-typedef">typedef</span> <span class="sym-badge badge-version">XPLM200</span>

An XPLMObjectRef is a opaque handle to an .obj file that has been loaded into memory.

```cpp
typedef void * XPLMObjectRef;
```

</div>

---

<div class="sym-block sym-struct" data-name="XPLMDrawInfo_t" data-type="struct" markdown="1">

## XPLMDrawInfo_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span> <span class="sym-badge badge-version">XPLM200</span>

The XPLMDrawInfo_t structure contains positioning info for one object that is to be drawn.
Be sure to set structSize to the size of the structure for future expansion.

```cpp
typedef struct {
     int                       structSize;
     float                     x;
     float                     y;
     float                     z;
     float                     pitch;
     float                     heading;
     float                     roll;
} XPLMDrawInfo_t;
```

</div>

---

<div class="sym-block sym-struct" data-name="XPLMDrawInfoDouble_t" data-type="struct" markdown="1">

## XPLMDrawInfoDouble_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span> <span class="sym-badge badge-version">XPLM420</span>

The XPLMDrawInfo_t structure contains positioning info for one object that is to be drawn.
Be sure to set structSize to the size of the structure for future expansion.

```cpp
typedef struct {
     int                       structSize;
     double                    x;
     double                    y;
     double                    z;
     double                    pitch;
     double                    heading;
     double                    roll;
} XPLMDrawInfoDouble_t;
```

</div>

---

<div class="sym-block sym-callback" data-name="XPLMObjectLoaded_f" data-type="callback" markdown="1">

## XPLMObjectLoaded_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span> <span class="sym-badge badge-version">XPLM210</span>

You provide this callback when loading an object asynchronously; it will be called once the object is
loaded. Your refcon is passed back. The object ref passed in is the newly loaded object (ready for use) or
NULL if an error occured. It will not be called more than once per object.

If your plugin is disabled, this callback will be delivered as soon as the plugin is re-enabled. If your
plugin is unloaded before this callback is ever called, the SDK will release the object handle for you.

```cpp
typedef void (* XPLMObjectLoaded_f)(
                         XPLMObjectRef        inObject,
                         void *               inRefcon
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMLoadObject" data-type="function" markdown="1">

## XPLMLoadObject { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM200</span>

This routine loads an OBJ file and returns a handle to it. If X-Plane has already loaded the object, the
handle to the existing object is returned. Do not assume you will get the same handle back twice, but do make
sure to call unload once for every load to avoid "leaking" objects. The object will be purged from memory when
no plugins and no scenery are using it.

The path for the object must be relative to the X-System base folder. If the path is in the root of the
X-System folder you may need to prepend ./ to it; loading objects in the root of the X-System folder is STRONGLY
discouraged - your plugin should not dump art resources in the root folder!

XPLMLoadObject will return NULL if the object cannot be loaded (either because it is not found or the
file is misformatted). This routine will load any object that can be used in the X-Plane scenery system.

It is important that the datarefs an object uses for animation already be registered before you load the
object. For this reason it may be necessary to defer object loading until the sim has fully started.

```cpp
XPLM_API XPLMObjectRefXPLMLoadObject(
                         const char *         inPath
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMLoadObjectAsync" data-type="function" markdown="1">

## XPLMLoadObjectAsync { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM210</span>

This routine loads an object asynchronously; control is returned to you immediately while X-Plane loads
the object. The sim will not stop flying while the object loads. For large objects, it may be several
seconds before the load finishes.

You provide a callback function that is called once the load has completed. Note that if the object
cannot be loaded, you will not find out until the callback function is called with a NULL object handle.

There is no way to cancel an asynchronous object load; you must wait for the load to complete and then
release the object if it is no longer desired.

```cpp
XPLM_API void       XPLMLoadObjectAsync(
                         const char *         inPath,
                         XPLMObjectLoaded_f   inCallback,
                         void *               inRefcon
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMDrawObjects" data-type="function" markdown="1">

## XPLMDrawObjects { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-deprecated">XPLM_DEPRECATED</span>

__Deprecation Warning__: use XPLMInstancing to draw 3-d objects by creating instances, rather than
these APIs from draw callbacks.

XPLMDrawObjects draws an object from an OBJ file one or more times. You pass in the object and an array
of XPLMDrawInfo_t structs, one for each place you would like the object to be drawn.

X-Plane will attempt to cull the objects based on LOD and visibility, and will pick the appropriate LOD.

Lighting is a boolean; pass true to show the night version of object with night-only lights lit up. Pass false
to show the daytime version of the object.

earth_relative controls the coordinate system. If this is true, the rotations you specify are applied to
the object after its coordinate system is transformed from local to earth-relative coordinates -- that is, an
object with no rotations will point toward true north and the Y axis will be up against gravity. If this is false, the
object is drawn with your rotations from local coordanates -- that is, an object with no rotations is drawn
pointing down the -Z axis and the Y axis of the object matches the local coordinate Y axis.

```cpp
XPLM_API void       XPLMDrawObjects(
                         XPLMObjectRef        inObject,
                         int                  inCount,
                         XPLMDrawInfo_t *     inLocations,
                         int                  lighting,
                         int                  earth_relative
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMUnloadObject" data-type="function" markdown="1">

## XPLMUnloadObject { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM200</span>

This routine marks an object as no longer being used by your plugin. Objects are reference counted: once
no plugins are using an object, it is purged from memory. Make sure to call XPLMUnloadObject once for each
successful call to XPLMLoadObject.

```cpp
XPLM_API void       XPLMUnloadObject(
                         XPLMObjectRef        inObject
                    );
```

</div>

---



<!-- whitespace for navigation purposes -->
<div style="height:100vh;"></div>