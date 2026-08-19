<h1>Data Accessors</h1>

These routines read and write the data references. For each supported data type there is a
reader and a writer.

If the dataref is orphaned, the plugin that provides it is disabled or there is a type mismatch,
the functions that read data will return 0 as a default value or not modify the passed in memory.
The plugins that write data will not write under these circumstances or if the dataref is read-only.

NOTE: to keep the overhead of reading datarefs low, these routines do not do full validation of a
dataref; passing a junk value for a dataref can result in crashing the sim. The get/set APIs do
check for NULL.

For array-style datarefs, you specify the number of items to read/write and the offset into the
array; the actual number of items read or written is returned. This may be less the number requested to prevent an
array-out-of-bounds error.

---

<div class="sym-block sym-function" data-name="XPLMGetDatai" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetDatai { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Read an integer dataref and return its value.
The return value is the dataref value or 0 if the dataref is NULL or the plugin is disabled.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns int -> assign to local/var
local my_result = XPLMGetDatai(
    inDataRef     -- XPLMDataRef
)</code></pre>
</div>


**See associated types:**

- [XPLMDataRef](reading_and_writing_data.md#xplmdataref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSetDatai" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetDatai { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Write a new value to an integer dataref.
This routine is a no-op if the plugin publishing the dataref is disabled, the dataref is NULL, or the dataref is not writable.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSetDatai(
    inDataRef,    -- XPLMDataRef
    inValue       -- int
)</code></pre>
</div>


**See associated types:**

- [XPLMDataRef](reading_and_writing_data.md#xplmdataref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMGetDataf" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetDataf { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Read a single precision floating point dataref and return its value.
The return value is the dataref value or 0.0 if the dataref is NULL or the plugin is disabled.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns float -> assign to local/var
local my_result = XPLMGetDataf(
    inDataRef     -- XPLMDataRef
)</code></pre>
</div>


**See associated types:**

- [XPLMDataRef](reading_and_writing_data.md#xplmdataref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSetDataf" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetDataf { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Write a new value to a single precision floating point dataref.
This routine is a no-op if the plugin publishing the dataref is disabled, the dataref is NULL, or the
dataref is not writable.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSetDataf(
    inDataRef,    -- XPLMDataRef
    inValue       -- float
)</code></pre>
</div>


**See associated types:**

- [XPLMDataRef](reading_and_writing_data.md#xplmdataref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMGetDatad" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetDatad { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Read a double precision floating point dataref and return its value.
The return value is the dataref value or 0.0 if the dataref is NULL or the plugin is disabled.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns float -> assign to local/var
local my_result = XPLMGetDatad(
    inDataRef     -- XPLMDataRef
)</code></pre>
</div>


**See associated types:**

- [XPLMDataRef](reading_and_writing_data.md#xplmdataref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSetDatad" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetDatad { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Write a new value to a double precision floating point dataref.
This routine is a no-op if the plugin publishing the dataref is disabled, the dataref is NULL, or the
dataref is not writable.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSetDatad(
    inDataRef,    -- XPLMDataRef
    inValue       -- float
)</code></pre>
</div>


**See associated types:**

- [XPLMDataRef](reading_and_writing_data.md#xplmdataref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMGetDatavi" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetDatavi { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Read a part of an integer array dataref. If you pass NULL for outValues, the routine will return the
size of the array, ignoring inOffset and inMax.

If outValues is not NULL, then up to inMax values are copied from the dataref into outValues, starting
at inOffset in the dataref. If inMax + inOffset is larger than the size of the dataref, less than inMax
values will be copied. The number of values copied is returned.

Note: the semantics of array datarefs are entirely implemented by the plugin (or X-Plane) that provides
the dataref, not the SDK itself; the above description is how these datarefs are intended to work, but a
rogue plugin may have different behavior.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns int, plus a table of out values
local my_result, outs = XPLMGetDatavi(
    inDataRef,    -- XPLMDataRef
    inOffset,     -- ArrayOffset
    inMax         -- ArraySize
)
-- outs = { outValues }</code></pre>
</div>


**See associated types:**

- [XPLMDataRef](reading_and_writing_data.md#xplmdataref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSetDatavi" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetDatavi { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Write part or all of an integer array dataref. The values passed by inValues are written into the
dataref starting at inOffset. Up to inCount values are written; however if the values would write past
the end of the dataref array, then fewer values are written.

Note: the semantics of array datarefs are entirely implemented by the plugin (or X-Plane) that provides
the dataref, not the SDK itself; the above description is how these datarefs are intended to work, but a
rogue plugin may have different behavior.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSetDatavi(
    inDataRef,    -- XPLMDataRef
    inValues,     -- int
    inoffset,     -- ArrayOffset
    inCount       -- ArraySize
)</code></pre>
</div>


**See associated types:**

- [XPLMDataRef](reading_and_writing_data.md#xplmdataref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMGetDatavf" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetDatavf { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Read a part of a single precision floating point array dataref. If you pass NULL for outValues, the
routine will return the size of the array, ignoring inOffset and inMax.

If outValues is not NULL, then up to inMax values are copied from the dataref into outValues, starting
at inOffset in the dataref.
If inMax + inOffset is larger than the size of the dataref, less than inMax values will be copied. The
number of values copied is returned.

Note: the semantics of array datarefs are entirely implemented by the plugin (or X-Plane) that provides
the dataref, not the SDK
itself; the above description is how these datarefs are intended to work, but a rogue plugin may have
different behavior.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns int, plus a table of out values
local my_result, outs = XPLMGetDatavf(
    inDataRef,    -- XPLMDataRef
    inOffset,     -- ArrayOffset
    inMax         -- ArraySize
)
-- outs = { outValues }</code></pre>
</div>


**See associated types:**

- [XPLMDataRef](reading_and_writing_data.md#xplmdataref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSetDatavf" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetDatavf { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Write part or all of a single precision floating point array dataref. The values passed by inValues are
written into the dataref starting at
inOffset. Up to inCount values are written; however if the values would write past the end of the
dataref array, then fewer values are written.

Note: the semantics of array datarefs are entirely implemented by the plugin (or X-Plane) that provides
the dataref, not the SDK
itself; the above description is how these datarefs are intended to work, but a rogue plugin may have
different behavior.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSetDatavf(
    inDataRef,    -- XPLMDataRef
    inValues,     -- float
    inoffset,     -- ArrayOffset
    inCount       -- ArraySize
)</code></pre>
</div>


**See associated types:**

- [XPLMDataRef](reading_and_writing_data.md#xplmdataref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMGetDatab" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetDatab { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Read a part of a byte array dataref. If you pass NULL for outValues, the routine will return the size of
the array, ignoring inOffset and inMax.

If outValues is not NULL, then up to inMax values are copied from the dataref into outValues, starting
at inOffset in the dataref.
If inMax + inOffset is larger than the size of the dataref, less than inMax values will be copied. The
number of values copied is returned.

Note: the semantics of array datarefs are entirely implemented by the plugin (or X-Plane) that provides
the dataref, not the SDK
itself; the above description is how these datarefs are intended to work, but a rogue plugin may have
different behavior.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns int, plus a table of out values
local my_result, outs = XPLMGetDatab(
    inDataRef,     -- XPLMDataRef
    inOffset,      -- ArrayOffset
    inMaxBytes     -- ArraySize
)
-- outs = { outValue }</code></pre>
</div>


**See associated types:**

- [XPLMDataRef](reading_and_writing_data.md#xplmdataref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSetDatab" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetDatab { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Write part or all of a byte array dataref. The values passed by inValues are written into the dataref
starting at
inOffset. Up to inCount values are written; however if the values would write "off the end" of the
dataref array, then fewer values are written.

Note: the semantics of array datarefs are entirely implemented by the plugin (or X-Plane) that provides
the dataref, not the SDK
itself; the above description is how these datarefs are intended to work, but a rogue plugin may have
different behavior.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSetDatab(
    inDataRef,    -- XPLMDataRef
    inValue,      -- byte
    inOffset,     -- ArrayOffset
    inLength      -- ArraySize
)</code></pre>
</div>


**See associated types:**

- [XPLMDataRef](reading_and_writing_data.md#xplmdataref)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>