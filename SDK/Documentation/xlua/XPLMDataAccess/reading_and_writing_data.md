<h1>Reading And Writing Data</h1>

These routines allow you to access data from within X-Plane and sometimes modify it.

---

<div class="sym-block sym-typedef" data-name="XPLMDataRef" data-type="typedef" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMDataRef { .symbol-title }

<span class="sym-badge badge-typedef">typedef</span>

</div>

A dataref is an opaque handle to data provided by the simulator or
another plugin. It uniquely identifies one variable (or array of variables)
over the lifetime of your plugin. You never hard code these values; you
always get them from XPLMFindDataRef.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">local my_dataRef = nil  -- XPLMDataRef</code></pre>
</div>


**Used by:**

- [XPLMCanWriteDataRef](#xplmcanwritedataref)
- [XPLMGetDataRefInfo](#xplmgetdatarefinfo)
- [XPLMGetDataRefTypes](#xplmgetdatareftypes)
- [XPLMGetDatab](data_accessors.md#xplmgetdatab)
- [XPLMGetDatad](data_accessors.md#xplmgetdatad)
- [XPLMGetDataf](data_accessors.md#xplmgetdataf)
- [XPLMGetDatai](data_accessors.md#xplmgetdatai)
- [XPLMGetDatavf](data_accessors.md#xplmgetdatavf)
- [XPLMGetDatavi](data_accessors.md#xplmgetdatavi)
- [XPLMIsDataRefGood](#xplmisdatarefgood)
- [XPLMSetDatab](data_accessors.md#xplmsetdatab)
- [XPLMSetDatad](data_accessors.md#xplmsetdatad)
- [XPLMSetDataf](data_accessors.md#xplmsetdataf)
- [XPLMSetDatai](data_accessors.md#xplmsetdatai)
- [XPLMSetDatavf](data_accessors.md#xplmsetdatavf)
- [XPLMSetDatavi](data_accessors.md#xplmsetdatavi)
- [XPLMUnregisterDataAccessor](publishing_your_plugins_data.md#xplmunregisterdataaccessor)
</div>

---

<div class="sym-block sym-enum" data-name="XPLMDataTypeID" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMDataTypeID { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

</div>

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

**Used by:**

- [XPLMRegisterDataAccessor](publishing_your_plugins_data.md#xplmregisterdataaccessor)

</div>

---

<div class="sym-block sym-struct" data-name="XPLMDataRefInfo_t" data-type="struct" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMDataRefInfo_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span> <span class="sym-badge badge-version">XPLM400</span>

</div>

The XPLMDataRefInfo_t structure contains all of the information about a single data ref.
The structure can be expanded in future SDK APIs to include more features. Always set the structSize member to the size of
your struct in bytes!

<div class="lua-code" markdown="1">
<pre><code class="language-lua">local My_DataRefInfo_t = {
    structSize  = 0,       -- int
    name        = "",      -- string
    type        = nil,     -- XPLMDataTypeID
    writable    = false,   -- boolean
    owner       = nil,     -- XPLMPluginID
}</code></pre>
</div>

<div class="field-table" markdown="1">

| Field | Type | Description |
|:--|:--|:--|
| structSize | int | Used to inform XPLMGetDatarefInfo() of the SDK version you compiled against; should always be set to sizeof(XPLMDataRefInfo_t) |
| name | string | The full name/path of the data ref |
| type | XPLMDataTypeID |  |
| writable | boolean | TRUE if the data ref permits writing to it. FALSE if it's read-only. |
| owner | XPLMPluginID | The handle to the plugin that registered this dataref. |

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMCountDataRefs" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCountDataRefs { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM400</span>

</div>

Returns the total number of datarefs that have been registered in X-Plane.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns int -> assign to local/var
local my_result = XPLMCountDataRefs(
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetDataRefsByIndex" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetDataRefsByIndex { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM400</span>

</div>

Given an offset and count, this function will return an array of XPLMDataRefs in that range.
The offset/count idiom is useful for things like pagination.

- offset: an integer index offset.
- count: an integer count of the number of datarefs to return, starting from the offset index.
- outDataRefs: a pre-allocated array (sized to count) to receive the XPLMDataRefs.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns a table of out values
local outs = XPLMGetDataRefsByIndex(
    offset,    -- ArrayOffset
    count      -- ArraySize
)
-- outs = { outDataRefs }</code></pre>
</div>


**See associated types:**

- [XPLMDataRef](#xplmdataref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMGetDataRefInfo" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetDataRefInfo { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM400</span>

</div>

Give a data ref, this routine returns a populated struct containing the available information about the dataref.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns a table of out values
local outs = XPLMGetDataRefInfo(
    inDataRef     -- XPLMDataRef
)
-- outs = { outInfo }</code></pre>
</div>


**See associated types:**

- [XPLMDataRefInfo_t](#xplmdatarefinfo_t)
- [XPLMDataRef](#xplmdataref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMFindDataRef" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMFindDataRef { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Given a C-style string that names the dataref, this routine looks up
the actual opaque XPLMDataRef that you use to read and write the data.
The string names for datarefs are published on the X-Plane SDK web site.

This function returns NULL if the dataref cannot be found.

NOTE: this function is relatively expensive; save the XPLMDataRef this
function returns for future use. Do not look up your dataref by string
every time you need to read or write it.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns XPLMDataRef -> assign to local/var
local my_dataRef = XPLMFindDataRef(
    inDataRefName     -- string
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMCanWriteDataRef" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCanWriteDataRef { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Given a dataref, this routine returns true if you can successfully set
the data, false otherwise. Some datarefs are read-only.

NOTE: even if a dataref is marked writable, it may not act writable.  This can happen for
datarefs that X-Plane writes to on every frame of simulation.  In some cases, the dataref
is writable but you have to set a separate "override" dataref to 1 to stop X-Plane from
writing it.

- inDataRef: either a valid handle to a dataref, or NULL.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns boolean -> assign to local/var
local my_result = XPLMCanWriteDataRef(
    inDataRef     -- XPLMDataRef
)</code></pre>
</div>


**See associated types:**

- [XPLMDataRef](#xplmdataref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMIsDataRefGood" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMIsDataRefGood { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function returns true if the passed in handle is a valid dataref that is not orphaned.

Note: there is normally no need to call this function; datarefs returned by XPLMFindDataRef
remain valid (but possibly orphaned) unless there is a complete plugin reload (in which case
your plugin is reloaded anyway). Orphaned datarefs can be safely read and return 0. Therefore
you never need to call XPLMIsDataRefGood to 'check' the safety of a dataref. (XPLMIsDataRefGood
performs some slow checking of the handle validity, so it has a performance cost.)

- inDataRef: either a valid handle to a dataref, or NULL.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns boolean -> assign to local/var
local my_result = XPLMIsDataRefGood(
    inDataRef     -- XPLMDataRef
)</code></pre>
</div>


**See associated types:**

- [XPLMDataRef](#xplmdataref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMGetDataRefTypes" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetDataRefTypes { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns the types of the dataref for accessor use. If a dataref
is available in multiple data types, the bit-wise OR of these types will be returned.

- inDataRef: either a valid handle to a dataref, or NULL.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns XPLMDataTypeID -> assign to local/var
local my_dataTypeID = XPLMGetDataRefTypes(
    inDataRef     -- XPLMDataRef
)</code></pre>
</div>


**See associated types:**

- [XPLMDataRef](#xplmdataref)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>