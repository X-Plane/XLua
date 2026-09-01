<h1>X-Plane Misc</h1>

---

<div class="sym-block sym-function" data-name="XPLMReturnString" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMReturnString { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Copies `inString` into the host-managed return slot for the current
callback and returns a pointer that remains valid for the duration of
the host's use of the callback's result. This is the only sanctioned
way for an XPLM callback whose return type is `const char *` to hand a
string back to X-Plane: returning a stack buffer, a string literal, or
any other pointer is a contract violation and may corrupt the result.

The host pushes a return slot before invoking each `const char *`
callback and pops it afterwards, so callbacks must call
`XPLMReturnString` at most once per invocation and must not retain the
returned pointer past the callback's return.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API const char * XPLMReturnString(
                         const char *         inString
                    );
```

</div>

</div>

---

<div class="sym-block sym-enum" data-name="XPLMHostApplicationID" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMHostApplicationID { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

</div>

While the plug-in SDK is only accessible to plugins running inside X-Plane, the
original authors considered extending the API to other applications that shared basic infrastructure
with X-Plane. These enumerations are hold-overs from that original roadmap; all values other than
X-Plane are deprecated. Your plugin should never need this enumeration.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplm_Host_Unknown | 0 |  |
| xplm_Host_XPlane | 1 |  |
| xplm_Host_PlaneMaker | 2 |  |
| xplm_Host_WorldMaker | 3 |  |
| xplm_Host_Briefer | 4 |  |
| xplm_Host_PartMaker | 5 |  |
| xplm_Host_YoungsMod | 6 |  |
| xplm_Host_XAuto | 7 |  |
| xplm_Host_Xavion | 8 |  |
| xplm_Host_Control_Pad | 9 |  |
| xplm_Host_PFD_Map | 10 |  |
| xplm_Host_RADAR | 11 |  |

</div>

**Used by:**

- [XPLMGetVersions](#xplmgetversions)

</div>

---

<div class="sym-block sym-enum" data-name="XPLMLanguageCode" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMLanguageCode { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

</div>

These enums define what language the sim is running in. These enumerations do not imply that the sim can
or does run in all of these languages; they simply provide a known encoding in the event that a given
sim version is localized to a certain language.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplm_Language_Unknown | 0 |  |
| xplm_Language_English | 1 |  |
| xplm_Language_French | 2 |  |
| xplm_Language_German | 3 |  |
| xplm_Language_Italian | 4 |  |
| xplm_Language_Spanish | 5 |  |
| xplm_Language_Korean | 6 |  |
| xplm_Language_Russian | 7 |  |
| xplm_Language_Greek | 8 |  |
| xplm_Language_Japanese | 9 |  |
| xplm_Language_Chinese | 10 |  |
| xplm_Language_Ukrainian | 11 |  |

</div>

</div>

---

<div class="sym-block sym-callback" data-name="XPLMError_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMError_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span> <span class="sym-badge badge-version">XPLM200</span>

</div>

An XPLM error callback is a function that you provide to receive debugging information from the plugin
SDK. See XPLMSetErrorCallback for more information. NOTE: for the sake of debugging, your error callback
will be called even if your plugin is not enabled, allowing you to receive debug info in your XPluginStart
and XPluginStop callbacks. To avoid causing logic errors in the management code, do not call any other plugin
routines from your error callback - it is only meant for catching errors in the debugging.

<div class="xplm-code" markdown="1">

```cpp
typedef void (* XPLMError_f)(
                         const char *         inMessage
                    );
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMInitialized" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMInitialized { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-deprecated">XPLM_DEPRECATED</span>

</div>

Deprecated: This function returns true if X-Plane has properly initialized the plug-in system.
If this routine returns false, many XPLM functions will not work.

NOTE: because plugins are always called from within the XPLM, there is no need to check for
initialization; it will always return true.  This routine is deprecated - you do not need to check
it before continuing within your plugin.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API int XPLMInitialized(void);
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetVersions" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetVersions { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns the revision of both X-Plane and the XPLM DLL. All versions
are at least three-digit decimal numbers (e.g. 606 for version 6.06 of X-Plane); the current
revision of the XPLM is 400 (4.00). This routine also returns the host ID of the app
running us.

The most common use of this routine is to special-case around X-Plane version-specific
behavior.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMGetVersions(
                         int *                outXPlaneVersion,
                         int *                outXPLMVersion,
                         XPLMHostApplicationID * outHostID
                    );
```

</div>


**See associated types:**

- [XPLMHostApplicationID](#xplmhostapplicationid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMGetLanguage" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetLanguage { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns the langauge the sim is running in.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API XPLMLanguageCode XPLMGetLanguage(void);
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMFindSymbol" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMFindSymbol { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM200</span>

</div>

This routine will attempt to find the symbol passed in the inString parameter.
If the symbol is found a pointer the function is returned, othewise the function
will return NULL.

You can use XPLMFindSymbol to utilize newer SDK API features without requiring
newer versions of the SDK (and X-Plane) as your minimum X-Plane version as follows:

 * Define the XPLMnnn macro to the minimum required XPLM version you will ship with
   (e.g. XPLM210 for X-Plane 10 compatibility).

 * Use XPLMGetVersions and XPLMFindSymbol to detect that the host sim is new enough to use
   new functions and resolve function pointers.

 * Conditionally use the new functions if and only if XPLMFindSymbol only returns a non-
   NULL pointer.

Warning: you should always check the XPLM API version as well as the results of
XPLMFindSymbol to determine if funtionality is safe to use.

To use functionality via XPLMFindSymbol you will need to copy your own definitions of
the X-Plane API prototypes and cast the returned pointer to the correct type.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void * XPLMFindSymbol(
                         const char *         inString
                    );
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMSetErrorCallback" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetErrorCallback { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM200</span>

</div>

XPLMSetErrorCallback installs an error-reporting callback for your plugin. Normally the plugin
system performs minimum diagnostics to maximize performance. When you install an error callback,
you will receive calls due to certain plugin errors, such as passing bad parameters or incorrect
data.

Important: the error callback reports *programming* errors, e.g. bad API parameters. Every
error that is returned by the error callback represents a mistake in your plugin that you should fix.
A few APIs also use it to explain why a call that can legitimately fail did fail - for example,
XPLMFontAddFace reports the reason it could not load a font file - but the error callback is not a
general channel for run-time conditions your plugin is expected to handle.

The intention is for you to install the error callback during debug sections and put a break-point
inside your callback. This will cause you to break into the debugger from within the SDK at the
point in your plugin where you made an illegal call.

Installing an error callback may activate error checking code that would not normally run, and this
may adversely affect performance, so do not leave error callbacks installed in shipping plugins.
Since the only useful response to an error is to change code, error callbacks are not useful
"in the field".

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMSetErrorCallback(
                         XPLMError_f          inCallback
                    );
```

</div>


**See associated types:**

- [XPLMError_f](#xplmerror_f)
</div>

---

<div class="sym-block sym-function" data-name="XPLMDebugString" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMDebugString { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine outputs a C-style string to the Log.txt file. The file is immediately flushed so you will
not lose data. (This does cause a performance penalty.)

Please do *not* leave routine diagnostic logging enabled in your shipping plugin. The X-Plane Log file is
shared by X-Plane and every plugin in the system, and plugins that (when functioning normally) print
verbose log output make it difficult for developers to find error conditions from other parts of the system.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMDebugString(
                         const char *         inString
                    );
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMSpeakString" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSpeakString { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function displays the string in a translucent overlay over the current
display and also speaks the string if text-to-speech is enabled. The string
is spoken asynchronously, this function returns immediately. This function may
not speak or print depending on user preferences.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMSpeakString(
                         const char *         inString
                    );
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetVirtualKeyDescription" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetVirtualKeyDescription { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Given a virtual key code (as defined in XPLMDefs.h) this routine returns
a human-readable string describing the character. This routine is provided
for showing users what keyboard mappings they have set up. The string
may read 'unknown' or be a blank or NULL string if the virtual key is unknown.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API const char * XPLMGetVirtualKeyDescription(
                         char                 inVirtualKey
                    );
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMReloadScenery" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMReloadScenery { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

XPLMReloadScenery reloads the current set of scenery. You can use this
function in two typical ways: simply call it to reload the scenery, picking
up any new installed scenery, .env files, etc. from disk. Or, change
the lat/ref and lon/ref datarefs and then call this function to shift
the scenery environment.  This routine is equivalent to picking "reload scenery"
from the developer menu.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMReloadScenery(void);
```

</div>

</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>