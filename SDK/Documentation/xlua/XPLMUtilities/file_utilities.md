<h1>File Utilities</h1>

The XPLMUtilities file APIs provide some basic file and path functions for use with X-Plane.

Directory Separators
--------------------

The XPLM has two modes it can work in:

 * X-Plane native paths: all paths are UTF8 strings, using the unix forward slash (/) as the
   directory separating character.  In native path mode, you use the same path format for
   all three operating systems.

 * Legacy OS paths: the directroy separator is \ for Windows, : for OS X, and / for Linux;
   OS paths are encoded in MacRoman for OS X using legacy HFS conventions, use the application
   code page for multi-byte encoding on Unix using DOS path conventions, and use UTF-8 for
   Linux.

While legacy OS paths are the default, we strongly encourage you to opt in to native paths
using the XPLMEnableFeature API.

 * All OS X plugins should enable native paths all of the time; if you do not do this, you will
   have to convert all paths back from HFS to Unix (and deal with MacRoman) - code written using
   native paths and the C file APIs "just works" on OS X.

 * For Linux plugins, there is no difference between the two encodings.

 * Windows plugins will need to convert the UTF8 file paths to UTF16 for use with the "wide"
   APIs. While it might seem tempting to stick with legacy OS paths (and just use the "ANSI"
   Windows APIs), X-Plane is fully unicode-capable, and will often be installed in paths where
   the user's directories have no ACP encoding.

Full and Relative Paths
-----------------------

Some of these APIs use full paths, but others use paths relative to the user's X-Plane installation.
This is documented on a per-API basis.

---

<div class="sym-block sym-enum" data-name="XPLMDataFileType" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMDataFileType { .symbol-title }

<span class="sym-badge badge-enum">enum</span> <span class="sym-badge badge-version">XPLM200</span>

</div>

These enums define types of data files you can load or unload using the SDK.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplm_DataFile_Situation | 1 | A situation (.sit) file, which starts off a flight in a given configuration. |
| xplm_DataFile_ReplayMovie | 2 | A situation movie (.smo) file, which replays a past flight. |

</div>

**Used by:**

- [XPLMLoadDataFile](#xplmloaddatafile)
- [XPLMSaveDataFile](#xplmsavedatafile)

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetSystemPath" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetSystemPath { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function returns the full path to the X-System folder. Note that this is a
directory path, so it ends in a trailing : or / .

The buffer you pass should be at least 512 characters long.  The path is returned using the
current native or OS path conventions.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns a table of out values
local outs = XPLMGetSystemPath(
)
-- outs = { outSystemPath }</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetPrefsPath" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetPrefsPath { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns a full path to a file that is within X-Plane's preferences
directory. (You should remove the file name back to the last directory separator
to get the preferences directory using XPLMExtractFileAndPath).

The buffer you pass should be at least 512 characters long.  The path is returned using the
current native or OS path conventions.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns a table of out values
local outs = XPLMGetPrefsPath(
)
-- outs = { outPrefsPath }</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetDirectorySeparator" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetDirectorySeparator { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns a string with one char and a null terminator that is the directory
separator for the current platform. This allows you to write code that concatenates
directory paths without having to #ifdef for platform. The character returned will reflect
the current file path mode.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns string -> assign to local/var
local my_result = XPLMGetDirectorySeparator(
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMLoadDataFile" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMLoadDataFile { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM200</span>

</div>

Loads a data file of a given type. Paths must be relative to the X-System folder.
To clear the replay, pass a NULL file name (this is only valid with replay movies, not sit files).

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns boolean -> assign to local/var
local my_result = XPLMLoadDataFile(
    inFileType,    -- XPLMDataFileType
    inFilePath     -- string
)</code></pre>
</div>


**See associated types:**

- [XPLMDataFileType](#xplmdatafiletype)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSaveDataFile" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSaveDataFile { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM200</span>

</div>

Saves the current situation or replay; paths are relative to the X-System folder.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns boolean -> assign to local/var
local my_result = XPLMSaveDataFile(
    inFileType,    -- XPLMDataFileType
    inFilePath     -- string
)</code></pre>
</div>


**See associated types:**

- [XPLMDataFileType](#xplmdatafiletype)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>