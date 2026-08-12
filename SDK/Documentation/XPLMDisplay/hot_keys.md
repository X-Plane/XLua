<h1>Hot Keys</h1>

Keystrokes that can be managed by others. These are lower-level than window keyboard handlers
(i.e., callbacks you attach to your XPLMCreateWindow_t), but higher level than key sniffers.

---

<div class="sym-block sym-callback" data-name="XPLMHotKey_f" data-type="callback" markdown="1">

## XPLMHotKey_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

Your hot key callback simply takes a pointer of your choosing.

```cpp
typedef void (* XPLMHotKey_f)(
                         void *               inRefcon
                    );
```

</div>

---

<div class="sym-block sym-typedef" data-name="XPLMHotKeyID" data-type="typedef" markdown="1">

## XPLMHotKeyID { .symbol-title }

<span class="sym-badge badge-typedef">typedef</span>

An opaque ID used to identify a hot key.

```cpp
typedef void * XPLMHotKeyID;
```

</div>

---

<div class="sym-block sym-function sym-deprecated-block" data-name="XPLMRegisterHotKey" data-type="function" markdown="1">

## XPLMRegisterHotKey { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-deprecated">deprecated XPLM300</span>

This routine registers a hot key.  You specify your preferred key
stroke virtual key/flag combination, a description of what your callback
does (so other plug-ins can describe the plug-in to the user for remapping)
and a callback function and opaque pointer to pass in).  A new hot key ID
is returned.  During execution, the actual key associated with your hot key
may change, but you are insulated from this.

```cpp
XPLM_API XPLMHotKeyIDXPLMRegisterHotKey(
                         char                 inVirtualKey,
                         XPLMKeyFlags         inFlags,
                         const char *         inDescription,
                         XPLMHotKey_f         inCallback,
                         void *               inRefcon
                    );
```

</div>

---

<div class="sym-block sym-function sym-deprecated-block" data-name="XPLMUnregisterHotKey" data-type="function" markdown="1">

## XPLMUnregisterHotKey { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-deprecated">deprecated XPLM300</span>

Unregisters a hot key.  You can only unregister your own hot keys.

```cpp
XPLM_API void       XPLMUnregisterHotKey(
                         XPLMHotKeyID         inHotKey
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMCountHotKeys" data-type="function" markdown="1">

## XPLMCountHotKeys { .symbol-title }

<span class="sym-badge badge-fn">function</span>

Returns the number of current hot keys.

```cpp
XPLM_API int        XPLMCountHotKeys(void);
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetNthHotKey" data-type="function" markdown="1">

## XPLMGetNthHotKey { .symbol-title }

<span class="sym-badge badge-fn">function</span>

Returns a hot key by index, for iteration on all hot keys.

```cpp
XPLM_API XPLMHotKeyIDXPLMGetNthHotKey(
                         int                  inIndex
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetHotKeyInfo" data-type="function" markdown="1">

## XPLMGetHotKeyInfo { .symbol-title }

<span class="sym-badge badge-fn">function</span>

Returns information about the hot key.  Return NULL for any
parameter you don't want info about.  The description should
be at least 512 chars long.

```cpp
XPLM_API void       XPLMGetHotKeyInfo(
                         XPLMHotKeyID         inHotKey,
                         char *               outVirtualKey,    /* Can be NULL */
                         XPLMKeyFlags *       outFlags,    /* Can be NULL */
                         char *               outDescription,    /* Can be NULL */
                         XPLMPluginID *       outPlugin    /* Can be NULL */
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMSetHotKeyCombination" data-type="function" markdown="1">

## XPLMSetHotKeyCombination { .symbol-title }

<span class="sym-badge badge-fn">function</span>

Remaps a hot key's keystrokes.  You may remap another plugin's keystrokes.

```cpp
XPLM_API void       XPLMSetHotKeyCombination(
                         XPLMHotKeyID         inHotKey,
                         char                 inVirtualKey,
                         XPLMKeyFlags         inFlags
                    );
```

</div>

---



<!-- whitespace for navigation purposes -->
<div style="height:100vh;"></div>