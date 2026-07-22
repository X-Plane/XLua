<h1>Library Access</h1>

The library access routines allow you to locate scenery objects via the X-Plane library system. Right now
library access is only provided for objects, allowing plugin-drawn objects to be extended using the library system.

---

<div class="sym-block sym-callback" data-name="XPLMLibraryEnumerator_f" data-type="callback" markdown="1">

## XPLMLibraryEnumerator_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

An XPLMLibraryEnumerator_f is a callback you provide that is called once for each library element that
is located. The returned paths will be relative to the X-System folder.

```cpp
typedef void (* XPLMLibraryEnumerator_f)(
                         const char *         inFilePath,
                         void *               inRef
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMLookupObjects" data-type="function" markdown="1">

## XPLMLookupObjects { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This routine looks up a virtual path in the library system and returns all matching elements. You
provide a callback - one virtual path may match many objects in the library. XPLMLookupObjects returns
the number of objects found.

The latitude and longitude parameters specify the location the object will be used. The library system
allows for scenery packages to only provide objects to certain local locations. Only objects that are
allowed at the latitude/longitude you provide will be returned.

The enumerator is fully synchronous: it is called once per matching object, and all calls complete before
XPLMLookupObjects returns.

```cpp
XPLM_API int        XPLMLookupObjects(
                         const char *         inPath,
                         float                inLatitude,
                         float                inLongitude,
                         XPLMLibraryEnumerator_f enumerator,
                         void *               ref
                    );
```

</div>

---



<!-- whitespace for navigation purposes -->
<div style="height:100vh;"></div>