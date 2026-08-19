<h1>Hot Keys</h1>

Keystrokes that can be managed by others. These are lower-level than window keyboard handlers
(i.e., callbacks you attach to your XPLMCreateWindow_t), but higher level than key sniffers.

---

<div class="sym-block sym-callback" data-name="XPLMHotKey_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMHotKey_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

Your hot key callback simply takes a pointer of your choosing.

<div class="xplm-code" markdown="1">

```cpp
typedef void (* XPLMHotKey_f)(
                         void*                inRefcon
                    );
```

</div>

</div>

---

<div class="sym-block sym-typedef" data-name="XPLMHotKeyID" data-type="typedef" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMHotKeyID { .symbol-title }

<span class="sym-badge badge-typedef">typedef</span>

</div>

An opaque ID used to identify a hot key.

<div class="xplm-code" markdown="1">

```cpp
typedef void * XPLMHotKeyID;
```

</div>


**Used by:**

- [XPLMGetHotKeyInfo](#xplmgethotkeyinfo)
- [XPLMSetHotKeyCombination](#xplmsethotkeycombination)
- [XPLMUnregisterHotKey](#xplmunregisterhotkey)
</div>

---

<div class="sym-block sym-function sym-deprecated-block" data-name="XPLMRegisterHotKey" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMRegisterHotKey { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-deprecated">deprecated XPLM300</span>

</div>

This routine registers a hot key.  You specify your preferred key
stroke virtual key/flag combination, a description of what your callback
does (so other plug-ins can describe the plug-in to the user for remapping)
and a callback function and opaque pointer to pass in).  A new hot key ID
is returned.  During execution, the actual key associated with your hot key
may change, but you are insulated from this.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API XPLMHotKeyID XPLMRegisterHotKey(
                         char                 inVirtualKey,
                         XPLMKeyFlags         inFlags,
                         const char *         inDescription,
                         XPLMHotKey_f         inCallback,
                         void*                inRefcon
                    );
```

</div>


**See associated types:**

- [XPLMHotKey_f](#xplmhotkey_f)
</div>

---

<div class="sym-block sym-function sym-deprecated-block" data-name="XPLMUnregisterHotKey" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMUnregisterHotKey { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-deprecated">deprecated XPLM300</span>

</div>

Unregisters a hot key.  You can only unregister your own hot keys.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMUnregisterHotKey(
                         XPLMHotKeyID         inHotKey
                    );
```

</div>


**See associated types:**

- [XPLMHotKeyID](#xplmhotkeyid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMCountHotKeys" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCountHotKeys { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Returns the number of current hot keys.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API int XPLMCountHotKeys(void);
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetNthHotKey" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetNthHotKey { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Returns a hot key by index, for iteration on all hot keys.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API XPLMHotKeyID XPLMGetNthHotKey(
                         int                  inIndex
                    );
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetHotKeyInfo" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetHotKeyInfo { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Returns information about the hot key.  Return NULL for any
parameter you don't want info about.  The description should
be at least 512 chars long.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMGetHotKeyInfo(
                         XPLMHotKeyID         inHotKey,
                         char                 outVirtualKey[1],    /* Can be NULL */
                         XPLMKeyFlags *       outFlags,    /* Can be NULL */
                         char                 outDescription[512],    /* Can be NULL */
                         XPLMPluginID *       outPlugin    /* Can be NULL */
                    );
```

</div>


**See associated types:**

- [XPLMHotKeyID](#xplmhotkeyid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSetHotKeyCombination" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetHotKeyCombination { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Remaps a hot key's keystrokes.  You may remap another plugin's keystrokes.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMSetHotKeyCombination(
                         XPLMHotKeyID         inHotKey,
                         char                 inVirtualKey,
                         XPLMKeyFlags         inFlags
                    );
```

</div>


**See associated types:**

- [XPLMHotKeyID](#xplmhotkeyid)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>