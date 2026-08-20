<h1>Publishing Your Plugin's Data</h1>

These functions allow you to create data references that other plug-ins and X-Plane
can access via the above data access APIs. Data references published by other plugins
operate the same as ones published by X-Plane in all manners except that your data reference
will not be available to other plugins if/when your plugin is disabled.

You share data by registering data provider callback functions. When a plug-in
requests your data, these callbacks are then called. You provide one callback
to return the value when a plugin 'reads' it and another to change the value when
a plugin 'writes' it.

Important: you must pick a prefix for your datarefs other than "sim/" - this prefix is
reserved for X-Plane. The X-Plane SDK website contains a registry where authors can
select a unique first word for dataref names, to prevent dataref collisions between
plugins.

---

<div class="sym-block sym-callback" data-name="XPLMGetDatai_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetDatai_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

Data provider function pointers.

These define the function pointers you provide to get or set data. Note that you
are passed a generic pointer for each one. This is the same pointer you pass in
your register routine; you can use it to locate plugin variables, etc.

The semantics of your callbacks are the same as the dataref accessors above - basically
routines like XPLMGetDatai are just pass-throughs from a caller to your plugin. Be
particularly mindful in implementing array dataref read-write accessors; you are responsible
for avoiding overruns, supporting offset read/writes, and handling a read with a NULL buffer.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_GetDatai_callback(
    inRefcon     -- any Lua var/table
)
    -- your code here
    return 0  -- int
end</code></pre>
</div>

</div>

---

<div class="sym-block sym-callback" data-name="XPLMSetDatai_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetDatai_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_SetDatai_callback(
    inRefcon,    -- any Lua var/table
    inValue      -- int
)
    -- your code here
end</code></pre>
</div>

</div>

---

<div class="sym-block sym-callback" data-name="XPLMGetDataf_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetDataf_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_GetDataf_callback(
    inRefcon     -- any Lua var/table
)
    -- your code here
    return nil  -- float
end</code></pre>
</div>

</div>

---

<div class="sym-block sym-callback" data-name="XPLMSetDataf_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetDataf_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_SetDataf_callback(
    inRefcon,    -- any Lua var/table
    inValue      -- float
)
    -- your code here
end</code></pre>
</div>

</div>

---

<div class="sym-block sym-callback" data-name="XPLMGetDatad_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetDatad_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_GetDatad_callback(
    inRefcon     -- any Lua var/table
)
    -- your code here
    return nil  -- float
end</code></pre>
</div>

</div>

---

<div class="sym-block sym-callback" data-name="XPLMSetDatad_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetDatad_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_SetDatad_callback(
    inRefcon,    -- any Lua var/table
    inValue      -- float
)
    -- your code here
end</code></pre>
</div>

</div>

---

<div class="sym-block sym-callback" data-name="XPLMGetDatavi_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetDatavi_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_GetDatavi_callback(
    inRefcon,     -- any Lua var/table
    outValues,    -- int
    inOffset,     -- ArrayOffset
    inMax         -- ArraySize
)
    -- your code here
    return 0  -- int
end</code></pre>
</div>

</div>

---

<div class="sym-block sym-callback" data-name="XPLMSetDatavi_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetDatavi_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_SetDatavi_callback(
    inRefcon,    -- any Lua var/table
    inValues,    -- int
    inOffset,    -- ArrayOffset
    inCount      -- ArraySize
)
    -- your code here
end</code></pre>
</div>

</div>

---

<div class="sym-block sym-callback" data-name="XPLMGetDatavf_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetDatavf_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_GetDatavf_callback(
    inRefcon,     -- any Lua var/table
    outValues,    -- float
    inOffset,     -- ArrayOffset
    inMax         -- ArraySize
)
    -- your code here
    return 0  -- int
end</code></pre>
</div>

</div>

---

<div class="sym-block sym-callback" data-name="XPLMSetDatavf_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetDatavf_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_SetDatavf_callback(
    inRefcon,    -- any Lua var/table
    inValues,    -- float
    inOffset,    -- ArrayOffset
    inCount      -- ArraySize
)
    -- your code here
end</code></pre>
</div>

</div>

---

<div class="sym-block sym-callback" data-name="XPLMGetDatab_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetDatab_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_GetDatab_callback(
    inRefcon,       -- any Lua var/table
    outValue,       -- byte
    inOffset,       -- ArrayOffset
    inMaxLength     -- ArraySize
)
    -- your code here
    return 0  -- int
end</code></pre>
</div>

</div>

---

<div class="sym-block sym-callback" data-name="XPLMSetDatab_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetDatab_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_SetDatab_callback(
    inRefcon,    -- any Lua var/table
    inValue,     -- byte
    inOffset,    -- ArrayOffset
    inLength     -- ArraySize
)
    -- your code here
end</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMRegisterDataAccessor" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMRegisterDataAccessor { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine creates a new item of data that can be read and written. Pass in
the data's full name for searching, the type(s) of the data for accessing, and whether
the data can be written to. For each data type you support, pass in a read accessor
function and a write accessor function if necessary. Pass NULL for data types you
do not support or write accessors if you are read-only.

You are returned a dataref for the new item of data created. You can use this
dataref to unregister your data later or read or write from it.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns XPLMDataRef -> assign to local/var
local my_dataRef = XPLMRegisterDataAccessor(
    inDataName,           -- string
    inDataType,           -- XPLMDataTypeID
    inIsWritable,         -- boolean
    inReadInt,            -- see XPLMGetDatai_f
    inWriteInt,           -- see XPLMSetDatai_f
    inReadFloat,          -- see XPLMGetDataf_f
    inWriteFloat,         -- see XPLMSetDataf_f
    inReadDouble,         -- see XPLMGetDatad_f
    inWriteDouble,        -- see XPLMSetDatad_f
    inReadIntArray,       -- see XPLMGetDatavi_f
    inWriteIntArray,      -- see XPLMSetDatavi_f
    inReadFloatArray,     -- see XPLMGetDatavf_f
    inWriteFloatArray,    -- see XPLMSetDatavf_f
    inReadData,           -- see XPLMGetDatab_f
    inWriteData,          -- see XPLMSetDatab_f
    inReadRefcon,         -- any Lua var/table
    inWriteRefcon         -- any Lua var/table
)</code></pre>
</div>


**See associated types:**

- [XPLMDataTypeID](reading_and_writing_data.md#xplmdatatypeid)
- [XPLMGetDatab_f](#xplmgetdatab_f)
- [XPLMGetDatad_f](#xplmgetdatad_f)
- [XPLMGetDataf_f](#xplmgetdataf_f)
- [XPLMGetDatai_f](#xplmgetdatai_f)
- [XPLMGetDatavf_f](#xplmgetdatavf_f)
- [XPLMGetDatavi_f](#xplmgetdatavi_f)
- [XPLMSetDatab_f](#xplmsetdatab_f)
- [XPLMSetDatad_f](#xplmsetdatad_f)
- [XPLMSetDataf_f](#xplmsetdataf_f)
- [XPLMSetDatai_f](#xplmsetdatai_f)
- [XPLMSetDatavf_f](#xplmsetdatavf_f)
- [XPLMSetDatavi_f](#xplmsetdatavi_f)
</div>

---

<div class="sym-block sym-function" data-name="XPLMUnregisterDataAccessor" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMUnregisterDataAccessor { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Use this routine to unregister any data accessors you may have registered.
You unregister a dataref by the XPLMDataRef you get back from registration.
Once you unregister a dataref, your function pointer will not be called anymore.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMUnregisterDataAccessor(
    inDataRef     -- XPLMDataRef
)</code></pre>
</div>


**See associated types:**

- [XPLMDataRef](reading_and_writing_data.md#xplmdataref)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>