<h1>Reading And Writing Data</h1>

These routines allow you to access data from within X-Plane and sometimes modify it.

---

<div class="sym-block sym-typedef" data-name="XPLMDataRef" data-type="typedef" markdown="1">

## XPLMDataRef { .symbol-title }

<span class="sym-badge badge-typedef">typedef</span>

A dataref is an opaque handle to data provided by the simulator or
another plugin. It uniquely identifies one variable (or array of variables)
over the lifetime of your plugin. You never hard code these values; you
always get them from XPLMFindDataRef.

```cpp
typedef void * XPLMDataRef;
```

</div>

---

<div class="sym-block sym-enum" data-name="XPLMDataTypeID" data-type="enum" markdown="1">

## XPLMDataTypeID { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

This is an enumeration that defines the type of the data behind a data reference.
This allows you to sanity check that the data type matches what you expect.
But for the most part, you will know the type of data you are expecting from
the online documentation.

Data types each take a bit field; it is legal to have a single dataref be more
than one type of data.  Whe this happens, you can pick any matching get/set API.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplmType_Unknown | 0 | Data of a type the current XPLM doesn't do. |
| xplmType_Int | 1 | A single 4-byte integer, native endian. |
| xplmType_Float | 2 | A single 4-byte float, native endian. |
| xplmType_Double | 4 | A single 8-byte double, native endian. |
| xplmType_FloatArray | 8 | An array of 4-byte floats, native endian. |
| xplmType_IntArray | 16 | An array of 4-byte integers, native endian. |
| xplmType_Data | 32 | A variable block of data. |

</div>

</div>

---

<div class="sym-block sym-struct" data-name="XPLMDataRefInfo_t" data-type="struct" markdown="1">

## XPLMDataRefInfo_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span> <span class="sym-badge badge-version">XPLM400</span>

The XPLMDataRefInfo_t structure contains all of the information about a single data ref.
The structure can be expanded in future SDK APIs to include more features. Always set the structSize member to the size of
your struct in bytes!

```cpp
typedef struct {
     int                       structSize;
     const char *              name;
     XPLMDataTypeID            type;
     bool                      writable;
     XPLMPluginID              owner;
} XPLMDataRefInfo_t;
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMCountDataRefs" data-type="function" markdown="1">

## XPLMCountDataRefs { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM400</span>

Returns the total number of datarefs that have been registered in X-Plane.

```cpp
XPLM_API int        XPLMCountDataRefs(void);
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetDataRefsByIndex" data-type="function" markdown="1">

## XPLMGetDataRefsByIndex { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM400</span>

Given an offset and count, this function will return an array of XPLMDataRefs in that range.
The offset/count idiom is useful for things like pagination.

```cpp
XPLM_API void       XPLMGetDataRefsByIndex(
                         ArrayOffset          offset,
                         ArraySize            count,
                         XPLMDataRef *        outDataRefs
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetDataRefInfo" data-type="function" markdown="1">

## XPLMGetDataRefInfo { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM400</span>

Give a data ref, this routine returns a populated struct containing the available information about the dataref.

```cpp
XPLM_API void       XPLMGetDataRefInfo(
                         XPLMDataRef          inDataRef,
                         XPLMDataRefInfo_t *  outInfo    /* Can be NULL */
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMFindDataRef" data-type="function" markdown="1">

## XPLMFindDataRef { .symbol-title }

<span class="sym-badge badge-fn">function</span>

Given a C-style string that names the dataref, this routine looks up
the actual opaque XPLMDataRef that you use to read and write the data.
The string names for datarefs are published on the X-Plane SDK web site.

This function returns NULL if the dataref cannot be found.

NOTE: this function is relatively expensive; save the XPLMDataRef this
function returns for future use. Do not look up your dataref by string
every time you need to read or write it.

```cpp
XPLM_API XPLMDataRefXPLMFindDataRef(
                         const char *         inDataRefName
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMCanWriteDataRef" data-type="function" markdown="1">

## XPLMCanWriteDataRef { .symbol-title }

<span class="sym-badge badge-fn">function</span>

Given a dataref, this routine returns true if you can successfully set
the data, false otherwise. Some datarefs are read-only.

NOTE: even if a dataref is marked writable, it may not act writable.  This can happen for
datarefs that X-Plane writes to on every frame of simulation.  In some cases, the dataref
is writable but you have to set a separate "override" dataref to 1 to stop X-Plane from
writing it.

```cpp
XPLM_API int        XPLMCanWriteDataRef(
                         XPLMDataRef          inDataRef
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMIsDataRefGood" data-type="function" markdown="1">

## XPLMIsDataRefGood { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function returns true if the passed in handle is a valid dataref that is not orphaned.

Note: there is normally no need to call this function; datarefs returned by XPLMFindDataRef
remain valid (but possibly orphaned) unless there is a complete plugin reload (in which case
your plugin is reloaded anyway). Orphaned datarefs can be safely read and return 0. Therefore
you never need to call XPLMIsDataRefGood to 'check' the safety of a dataref. (XPLMIsDataRefGood
performs some slow checking of the handle validity, so it has a performance cost.)

```cpp
XPLM_API int        XPLMIsDataRefGood(
                         XPLMDataRef          inDataRef
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetDataRefTypes" data-type="function" markdown="1">

## XPLMGetDataRefTypes { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This routine returns the types of the dataref for accessor use. If a dataref
is available in multiple data types, the bit-wise OR of these types will be returned.

```cpp
XPLM_API XPLMDataTypeIDXPLMGetDataRefTypes(
                         XPLMDataRef          inDataRef
                    );
```

</div>

---



<!-- whitespace for navigation purposes -->
<div style="height:100vh;"></div>