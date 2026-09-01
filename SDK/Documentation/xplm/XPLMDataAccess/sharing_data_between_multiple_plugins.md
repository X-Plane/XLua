<h1>Sharing Data Between Multiple Plugins</h1>

The data reference registration APIs from the previous section allow a plugin to publish data
in a one-owner manner; the plugin that publishes the data reference owns the real memory that
the dataref uses. This is satisfactory for most cases, but there are also cases where plugins
need to share actual data.

With a shared data reference, no one plugin owns the actual memory for the data reference;
the plugin SDK allocates that for you. When the first plugin asks to 'share' the data,
the memory is allocated. When the data is changed, every plugin that is sharing the data
is notified.

Shared data references differ from the 'owned' data references from the previous section
in a few ways:

* With shared data references, any plugin can create the data reference; with owned plugins
one plugin must create the data reference and others subscribe. (This can be a problem if
you don't know which set of plugins will be present).

* With shared data references, every plugin that is sharing the data is notified when the
data is changed. With owned data references, only the one owner is notified when the
data is changed.

* With shared data references, you cannot access the physical memory of the data reference;
you must use the XPLMGet... and XPLMSet... APIs. With an owned data reference, the one
owning data reference can manipulate the data reference's memory in any way it sees fit.

Shared data references solve two problems: if you need to have a data reference used by
several plugins but do not know which plugins will be installed, or if all plugins sharing
data need to be notified when that data is changed, use shared data references.

---

<div class="sym-block sym-callback" data-name="XPLMDataChanged_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMDataChanged_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

An XPLMDataChanged_f is a callback that the XPLM calls whenever any other plug-in modifies
shared data. A refcon you provide is passed back to help identify which data is being changed.
In response, you may want to call one of the XPLMGetDataxxx routines to find the new value
of the data.

<div class="xplm-code" markdown="1">

```cpp
typedef void (* XPLMDataChanged_f)(
                         void*                inRefcon
                    );
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMShareData" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMShareData { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine connects a plug-in to shared data, creating the shared data if necessary.
inDataName is a standard path for the dataref, and inDataType specifies the type.
This function will create the data if it does not exist. If the data already exists but
the type does not match, an error is returned, so it is important that plug-in authors
collaborate to establish public standards for shared data.

If a notificationFunc is passed in and is not NULL, that notification function will be
called whenever the data is modified. The notification refcon will be passed to it.
This allows your plug-in to know which shared data was changed if multiple shared data are
handled by one callback, or if the plug-in does not use global variables.

True is returned for successfully creating or finding the shared data; false if
the data already exists but is of the wrong type.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API int XPLMShareData(
                         const char *         inDataName,
                         XPLMDataTypeID       inDataType,
                         XPLMDataChanged_f    inNotificationFunc,    /* Can be NULL */
                         void*                inNotificationRefcon
                    );
```

</div>


**See associated types:**

- [XPLMDataChanged_f](#xplmdatachanged_f)
- [XPLMDataTypeID](reading_and_writing_data.md#xplmdatatypeid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMUnshareData" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMUnshareData { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine removes your notification function for shared data. Call it when done with
the data to stop receiving change notifications. Arguments must match XPLMShareData. In Lua,
this means that you cannot pass a closure to XPLMShareData as the callback function if you want to unregister it.
The actual memory will not necessarily be freed, since other plug-ins could be using it.
This will return true if data was unshared, false otherwise.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API int XPLMUnshareData(
                         const char *         inDataName,
                         XPLMDataTypeID       inDataType,
                         XPLMDataChanged_f    inNotificationFunc,    /* Can be NULL */
                         void*                inNotificationRefcon
                    );
```

</div>


**See associated types:**

- [XPLMDataChanged_f](#xplmdatachanged_f)
- [XPLMDataTypeID](reading_and_writing_data.md#xplmdatatypeid)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>