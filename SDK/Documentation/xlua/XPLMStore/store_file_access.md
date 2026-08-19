<h1>Store File Access</h1>

---

<div class="sym-block sym-function" data-name="XPLMIsStoreManagedPlugin" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMIsStoreManagedPlugin { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM460</span>

</div>

Returns non-zero if the calling plugin is a store-managed plugin.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns boolean -> assign to local/var
local my_result = XPLMIsStoreManagedPlugin(
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-enum" data-name="XPLMDecryptResult" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMDecryptResult { .symbol-title }

<span class="sym-badge badge-enum">enum</span> <span class="sym-badge badge-version">XPLM460</span>

</div>

These enums define the result of a decryption operation.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplmDecrypt_Ok | 1 | Decryption succeeded |
| xplmDecrypt_NotAllowed | -1 | Decryption failed, the calling plugin is not allowed to decrypt requested file |
| xplmDecrypt_FileError | -2 | Decryption failed due to a file error. |

</div>

</div>

---

<div class="sym-block sym-function sym-lua-only" data-name="XLuaStoreLoadFile" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XLuaStoreLoadFile { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM460</span>

</div>

Lua only. Loads a store-managed file belonging to the same product as the calling
plugin and returns its contents as a string. Path must be relative to the X-System
folder. On failure returns nil and an error code.

<div class="lua-code" markdown="1">
<!-- hand-written binding; see the XLua docs -->
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMStoreIsEncrypted" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMStoreIsEncrypted { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM460</span>

</div>

Checks whether a store-managed file belonging to the same product as the calling
plugin is encrypted. Path must be relative to the X-System folder.
Returns 1 if the file is encrypted, 0 if it is not encrypted, and -1 on error
(the calling plugin is not store-managed, the file is not a known store-managed
file, or it does not belong to the same product as the calling plugin).

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns int -> assign to local/var
local my_result = XPLMStoreIsEncrypted(
    inFilePath     -- string
)</code></pre>
</div>

</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>