<h1>Key Sniffers</h1>

Low-level keyboard handlers. Allows for intercepting keystrokes outside the normal rules of the user interface.

---

<div class="sym-block sym-callback" data-name="XPLMKeySniffer_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMKeySniffer_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

This is the prototype for a low level key-sniffing function.  Window-based UI
_should not use this_!  The windowing system provides high-level mediated keyboard
access, via the callbacks you attach to your XPLMCreateWindow_t.
By comparison, the key sniffer provides low level keyboard access.

Key sniffers are provided to allow libraries to provide non-windowed user
interaction.  For example, the MUI library uses a key sniffer to do pop-up text
entry.

Return true to pass the key on to the next sniffer, the window manager, X-Plane, or whomever
is down stream.  Return false to consume the key.

Warning: this API declares virtual keys as a signed character; however the VKEY #define
macros in XPLMDefs.h define the vkeys using unsigned values (that is 0x80
instead of -0x80).  So you may need to cast the incoming vkey to an unsigned char
to get correct comparisons in C.

<div class="xplm-code" markdown="1">

```cpp
typedef int (* XPLMKeySniffer_f)(
                         char                 inChar,
                         XPLMKeyFlags         inFlags,
                         char                 inVirtualKey,
                         void*                inRefcon
                    );
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMRegisterKeySniffer" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMRegisterKeySniffer { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine registers a key sniffing callback.  You specify whether you want to
sniff before the window system, or only sniff keys the window system does not
consume.  You should ALMOST ALWAYS sniff non-control keys after the window system.  When the window
system consumes a key, it is because the user has "focused" a window.  Consuming
the key or taking action based on the key will produce very weird results.  Returns
true if successful.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API int XPLMRegisterKeySniffer(
                         XPLMKeySniffer_f     inCallback,
                         int                  inBeforeWindows,
                         void*                inRefcon
                    );
```

</div>


**See associated types:**

- [XPLMKeySniffer_f](#xplmkeysniffer_f)
</div>

---

<div class="sym-block sym-function" data-name="XPLMUnregisterKeySniffer" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMUnregisterKeySniffer { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine unregisters a key sniffer.  You must unregister a key sniffer for every
time you register one with the exact same signature.  Returns true if successful.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API int XPLMUnregisterKeySniffer(
                         XPLMKeySniffer_f     inCallback,
                         int                  inBeforeWindows,
                         void*                inRefcon
                    );
```

</div>


**See associated types:**

- [XPLMKeySniffer_f](#xplmkeysniffer_f)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>