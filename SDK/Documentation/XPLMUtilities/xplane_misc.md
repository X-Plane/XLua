<h1>X-Plane Misc</h1>

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

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns a table of out values
local outs = XPLMGetVersions(
)
-- outs = { outXPlaneVersion, outXPLMVersion, outHostID }</code></pre>
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

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns XPLMLanguageCode -> assign to local/var
local my_languageCode = XPLMGetLanguage(
)</code></pre>
</div>

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

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMDebugString(
    inString     -- string
)</code></pre>
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

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSpeakString(
    inString     -- string
)</code></pre>
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

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns string -> assign to local/var
local my_result = XPLMGetVirtualKeyDescription(
    inVirtualKey     -- char
)</code></pre>
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

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMReloadScenery(
)</code></pre>
</div>

</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>