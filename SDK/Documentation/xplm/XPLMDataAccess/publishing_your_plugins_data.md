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

<div class="xplm-code" markdown="1">

```cpp
typedef int (* XPLMGetDatai_f)(
                         void*                inRefcon
                    );
```

</div>

</div>

---

<div class="sym-block sym-callback" data-name="XPLMSetDatai_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetDatai_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

<div class="xplm-code" markdown="1">

```cpp
typedef void (* XPLMSetDatai_f)(
                         void*                inRefcon,
                         int                  inValue
                    );
```

</div>

</div>

---

<div class="sym-block sym-callback" data-name="XPLMGetDataf_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetDataf_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

<div class="xplm-code" markdown="1">

```cpp
typedef float (* XPLMGetDataf_f)(
                         void*                inRefcon
                    );
```

</div>

</div>

---

<div class="sym-block sym-callback" data-name="XPLMSetDataf_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetDataf_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

<div class="xplm-code" markdown="1">

```cpp
typedef void (* XPLMSetDataf_f)(
                         void*                inRefcon,
                         float                inValue
                    );
```

</div>

</div>

---

<div class="sym-block sym-callback" data-name="XPLMGetDatad_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetDatad_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

<div class="xplm-code" markdown="1">

```cpp
typedef double (* XPLMGetDatad_f)(
                         void*                inRefcon
                    );
```

</div>

</div>

---

<div class="sym-block sym-callback" data-name="XPLMSetDatad_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetDatad_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

<div class="xplm-code" markdown="1">

```cpp
typedef void (* XPLMSetDatad_f)(
                         void*                inRefcon,
                         double               inValue
                    );
```

</div>

</div>

---

<div class="sym-block sym-callback" data-name="XPLMGetDatavi_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetDatavi_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

<div class="xplm-code" markdown="1">

```cpp
typedef int (* XPLMGetDatavi_f)(
                         void*                inRefcon,
                         int                  outValues[],    /* Can be NULL */
                         int                  inOffset,
                         int                  inMax
                    );
```

</div>

</div>

---

<div class="sym-block sym-callback" data-name="XPLMSetDatavi_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetDatavi_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

<div class="xplm-code" markdown="1">

```cpp
typedef void (* XPLMSetDatavi_f)(
                         void*                inRefcon,
                         int                  inValues[],
                         int                  inOffset,
                         int                  inCount
                    );
```

</div>

</div>

---

<div class="sym-block sym-callback" data-name="XPLMGetDatavf_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetDatavf_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

<div class="xplm-code" markdown="1">

```cpp
typedef int (* XPLMGetDatavf_f)(
                         void*                inRefcon,
                         float                outValues[],    /* Can be NULL */
                         int                  inOffset,
                         int                  inMax
                    );
```

</div>

</div>

---

<div class="sym-block sym-callback" data-name="XPLMSetDatavf_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetDatavf_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

<div class="xplm-code" markdown="1">

```cpp
typedef void (* XPLMSetDatavf_f)(
                         void*                inRefcon,
                         float                inValues[],
                         int                  inOffset,
                         int                  inCount
                    );
```

</div>

</div>

---

<div class="sym-block sym-callback" data-name="XPLMGetDatab_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetDatab_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

<div class="xplm-code" markdown="1">

```cpp
typedef int (* XPLMGetDatab_f)(
                         void*                inRefcon,
                         void*                outValue,    /* Can be NULL */
                         int                  inOffset,
                         int                  inMaxLength
                    );
```

</div>

</div>

---

<div class="sym-block sym-callback" data-name="XPLMSetDatab_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetDatab_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

<div class="xplm-code" markdown="1">

```cpp
typedef void (* XPLMSetDatab_f)(
                         void*                inRefcon,
                         void*                inValue,
                         int                  inOffset,
                         int                  inLength
                    );
```

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

<div class="xplm-code" markdown="1">

```cpp
XPLM_API XPLMDataRef XPLMRegisterDataAccessor(
                         const char *         inDataName,
                         XPLMDataTypeID       inDataType,
                         int                  inIsWritable,
                         XPLMGetDatai_f       inReadInt,    /* Can be NULL */
                         XPLMSetDatai_f       inWriteInt,    /* Can be NULL */
                         XPLMGetDataf_f       inReadFloat,    /* Can be NULL */
                         XPLMSetDataf_f       inWriteFloat,    /* Can be NULL */
                         XPLMGetDatad_f       inReadDouble,    /* Can be NULL */
                         XPLMSetDatad_f       inWriteDouble,    /* Can be NULL */
                         XPLMGetDatavi_f      inReadIntArray,    /* Can be NULL */
                         XPLMSetDatavi_f      inWriteIntArray,    /* Can be NULL */
                         XPLMGetDatavf_f      inReadFloatArray,    /* Can be NULL */
                         XPLMSetDatavf_f      inWriteFloatArray,    /* Can be NULL */
                         XPLMGetDatab_f       inReadData,    /* Can be NULL */
                         XPLMSetDatab_f       inWriteData,    /* Can be NULL */
                         void*                inReadRefcon,
                         void*                inWriteRefcon
                    );
```

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

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMUnregisterDataAccessor(
                         XPLMDataRef          inDataRef
                    );
```

</div>


**See associated types:**

- [XPLMDataRef](reading_and_writing_data.md#xplmdataref)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>