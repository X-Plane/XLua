<h1>Store File Access</h1>

---

<div class="sym-block sym-function" data-name="XPLMIsStoreManagedPlugin" data-type="function" markdown="1">

## XPLMIsStoreManagedPlugin { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM460</span>

Returns non-zero if the calling plugin is a store-managed plugin.

```cpp
XPLM_API int        XPLMIsStoreManagedPlugin(void);
```

</div>

---

<div class="sym-block sym-enum" data-name="XPLMDecryptResult" data-type="enum" markdown="1">

## XPLMDecryptResult { .symbol-title }

<span class="sym-badge badge-enum">enum</span> <span class="sym-badge badge-version">XPLM460</span>

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

<div class="sym-block sym-function" data-name="XPLMStoreDecryptFile" data-type="function" markdown="1">

## XPLMStoreDecryptFile { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM460</span>

Decrypts a store-managed file belonging to the same product as the calling plugin.
Path must be relative to the X-System folder.
Returns xplmDecrypt_Ok on success, another XPLMDecryptResult value on failure.
On success outBuf is set to a pointer to the resulting buffer.
Pass outBuf to XPLMStoreFileFree() when done.

```cpp
XPLM_API int        XPLMStoreDecryptFile(
                         const char *         inFilePath,
                         void **              outBuf,    /* Can be NULL */
                         int *                outBufSize    /* Can be NULL */
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMStoreLoadFile" data-type="function" markdown="1">

## XPLMStoreLoadFile { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM460</span>

Loads a store-managed file belonging to the same product as the calling plugin.
Path must be relative to the X-System folder.
Returns 1 on success, 0 or a negative errno-style value on failure. On success
outBuf is set to a pointer to the resulting buffer (left NULL for an empty file).
Pass outBuf to XPLMStoreFileFree() when done.

```cpp
XPLM_API int        XPLMStoreLoadFile(
                         const char *         inFilePath,
                         void **              outBuf,    /* Can be NULL */
                         int *                outBufSize    /* Can be NULL */
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMStoreFileFree" data-type="function" markdown="1">

## XPLMStoreFileFree { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM460</span>

Frees the buffer allocated by XPLMStoreDecryptFile() or XPLMStoreLoadFile().

```cpp
XPLM_API void       XPLMStoreFileFree(
                         void *               inBuf    /* Can be NULL */
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMStoreIsEncrypted" data-type="function" markdown="1">

## XPLMStoreIsEncrypted { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM460</span>

Checks whether a store-managed file belonging to the same product as the calling
plugin is encrypted. Path must be relative to the X-System folder.
Returns 1 if the file is encrypted, 0 if it is not encrypted, and -1 on error
(the calling plugin is not store-managed, the file is not a known store-managed
file, or it does not belong to the same product as the calling plugin).

```cpp
XPLM_API int        XPLMStoreIsEncrypted(
                         const char *         inFilePath
                    );
```

</div>

---



<!-- whitespace for navigation purposes -->
<div style="height:100vh;"></div>