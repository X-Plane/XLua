<h1>Interplugin Messaging</h1>

Plugin messages are defined as 32-bit integers.  Messages below 0x00FFFFFF are
reserved for X-Plane and the plugin SDK.

Messages come with a pointer parameter; the meaning of this pointer depends on
the message itself. In some messages, the pointer parameter  contains an actual typed
pointer to data that can be inspected in the plugin; in these cases the documentation will
state that the parameter "points to" information.

in other cases, the value of the pointer is actually an integral number stuffed into the
pointer's storage. In these second cases, the pointer parameter needs to be cast,
not dereferenced. In these caess, the documentation will state that the parameter "contains"
a value, which will always be an integral type.

Some messages don't use the pointer parameter - in this case your plugin should ignore it.

Messages have two conceptual uses: notifications and commands.  Commands are
sent from one plugin to another to induce behavior; notifications are sent
from one plugin to all others for informational purposes.  It is important that
commands and notifications not have the same values because this could
cause a notification sent by one plugin to accidentally induce a command in
another.

By convention, plugin-defined notifications should have the high bit set
(e.g. be greater or equal to unsigned 0x8000000) while commands should have
this bit be cleared.

The following messages are sent to your plugin by X-Plane.

---

<div class="sym-block sym-event" data-name="XPLM_MSG_PLANE_CRASHED" data-type="event" markdown="1">

## XPLM_MSG_PLANE_CRASHED { .symbol-title }

<span class="sym-badge badge-event">event</span>

This message is sent to your plugin whenever the user's plane crashes. The parameter
is ignored.

`#define XPLM_MSG_PLANE_CRASHED 101`

</div>

---

<div class="sym-block sym-event" data-name="XPLM_MSG_PLANE_LOADED" data-type="event" markdown="1">

## XPLM_MSG_PLANE_LOADED { .symbol-title }

<span class="sym-badge badge-event">event</span>

This message is sent to your plugin whenever a new plane is loaded.  The parameter
contains the index number of the plane being loaded; 0 indicates the user's plane.
The parameter is an integer bit-cast to a pointer.

`#define XPLM_MSG_PLANE_LOADED 102`

</div>

---

<div class="sym-block sym-event" data-name="XPLM_MSG_AIRPORT_LOADED" data-type="event" markdown="1">

## XPLM_MSG_AIRPORT_LOADED { .symbol-title }

<span class="sym-badge badge-event">event</span>

This messages is sent whenever the user's plane is positioned at a new airport. The
parameter is ignored.

`#define XPLM_MSG_AIRPORT_LOADED 103`

</div>

---

<div class="sym-block sym-event" data-name="XPLM_MSG_SCENERY_LOADED" data-type="event" markdown="1">

## XPLM_MSG_SCENERY_LOADED { .symbol-title }

<span class="sym-badge badge-event">event</span>

This message is sent whenever new scenery is loaded.  Use datarefs to determine the new scenery files that were loaded.
The parameter is ignored.

`#define XPLM_MSG_SCENERY_LOADED 104`

</div>

---

<div class="sym-block sym-event" data-name="XPLM_MSG_AIRPLANE_COUNT_CHANGED" data-type="event" markdown="1">

## XPLM_MSG_AIRPLANE_COUNT_CHANGED { .symbol-title }

<span class="sym-badge badge-event">event</span>

This message is sent whenever the user adjusts the number of X-Plane aircraft models.  You must use XPLMCountPlanes to
find out how many planes are now available.  This message will only be sent in XP7 and higher because in XP6 the number
of aircraft is not user-adjustable. The parameter is ignored.

`#define XPLM_MSG_AIRPLANE_COUNT_CHANGED 105`

</div>

---

<div class="sym-block sym-event" data-name="XPLM_MSG_PLANE_UNLOADED" data-type="event" markdown="1">

## XPLM_MSG_PLANE_UNLOADED { .symbol-title }

<span class="sym-badge badge-event">event</span> <span class="sym-badge badge-version">XPLM200</span>

This message is sent to your plugin whenever a plane is unloaded.  The parameter
contains the index number of the plane being unloaded; 0 indicates the user's plane.  The parameter is of type int,
bit-cast to a pointer.

`#define XPLM_MSG_PLANE_UNLOADED 106`

</div>

---

<div class="sym-block sym-event" data-name="XPLM_MSG_WILL_WRITE_PREFS" data-type="event" markdown="1">

## XPLM_MSG_WILL_WRITE_PREFS { .symbol-title }

<span class="sym-badge badge-event">event</span> <span class="sym-badge badge-version">XPLM210</span>

This message is sent to your plugin right before X-Plane writes its preferences file.  You can use this for
two purposes: to write your own preferences, and to modify any datarefs to influence preferences output.  For example,
if your plugin temporarily modifies saved preferences, you can put them back to their default values here to avoid
having the tweaks be persisted if your plugin is not loaded on the next invocation of X-Plane. The parameter is ignored.

`#define XPLM_MSG_WILL_WRITE_PREFS 107`

</div>

---

<div class="sym-block sym-event" data-name="XPLM_MSG_LIVERY_LOADED" data-type="event" markdown="1">

## XPLM_MSG_LIVERY_LOADED { .symbol-title }

<span class="sym-badge badge-event">event</span> <span class="sym-badge badge-version">XPLM210</span>

This message is sent to your plugin right after a livery is loaded for an airplane.  You can use this to
check the new livery (via datarefs) and react accordingly.  The parameter contains the index number of the
aircraft whose livery is changing. The parameter is an integer, bit-cast to a pointer.

`#define XPLM_MSG_LIVERY_LOADED 108`

</div>

---

<div class="sym-block sym-event" data-name="XPLM_MSG_ENTERED_VR" data-type="event" markdown="1">

## XPLM_MSG_ENTERED_VR { .symbol-title }

<span class="sym-badge badge-event">event</span> <span class="sym-badge badge-version">XPLM301</span>

Sent to your plugin right before X-Plane enters virtual reality mode (at which time any windows that
are not positioned in VR mode will no longer be visible to the user). The parameter is unused and should be ignored.

`#define XPLM_MSG_ENTERED_VR 109`

</div>

---

<div class="sym-block sym-event" data-name="XPLM_MSG_EXITING_VR" data-type="event" markdown="1">

## XPLM_MSG_EXITING_VR { .symbol-title }

<span class="sym-badge badge-event">event</span> <span class="sym-badge badge-version">XPLM301</span>

Sent to your plugin right before X-Plane leaves virtual reality mode (at which time you may want to clean
up windows that are positioned in VR mode). The parameter is unused and should be ignored.

`#define XPLM_MSG_EXITING_VR 110`

</div>

---

<div class="sym-block sym-event" data-name="XPLM_MSG_RELEASE_PLANES" data-type="event" markdown="1">

## XPLM_MSG_RELEASE_PLANES { .symbol-title }

<span class="sym-badge badge-event">event</span> <span class="sym-badge badge-version">XPLM303</span>

Sent to your plugin if another plugin wants to take over AI planes. If you are a synthetic traffic provider,
that probably means a plugin for an online network has connected and wants to supply aircraft flown by real humans and
you should cease to provide synthetic traffic. If however you are providing online traffic from real humans,
you probably don't want to disconnect, in which case you just ignore this message. The sender is the plugin ID of
the plugin asking for control of the planes now. You can use it to find out who is requesting and whether you should yield to them.
Synthetic traffic providers should always yield to online networks. The parameter is unused and should be ignored.
Do not send this message directly; always use the XPLMAcquirePlanes() call.

`#define XPLM_MSG_RELEASE_PLANES 111`

</div>

---

<div class="sym-block sym-event" data-name="XPLM_MSG_FMOD_BANK_LOADED" data-type="event" markdown="1">

## XPLM_MSG_FMOD_BANK_LOADED { .symbol-title }

<span class="sym-badge badge-event">event</span> <span class="sym-badge badge-version">XPLM400</span>

Sent to your plugin after FMOD sound banks are loaded. The parameter is the XPLMBankID enum in XPLMSound.h,
0 for the master bank and 1 for the radio bank. The bank ID is bit-cast to a pointer.

`#define XPLM_MSG_FMOD_BANK_LOADED 112`

</div>

---

<div class="sym-block sym-event" data-name="XPLM_MSG_FMOD_BANK_UNLOADING" data-type="event" markdown="1">

## XPLM_MSG_FMOD_BANK_UNLOADING { .symbol-title }

<span class="sym-badge badge-event">event</span> <span class="sym-badge badge-version">XPLM400</span>

Sent to your plugin before FMOD sound banks are unloaded. Any associated resources should
be cleaned up at this point. The parameter is the XPLMBankID enum in XPLMSound.h,
0 for the master bank and 1 for the radio bank. The bank ID is bit-cast to a pointer.

`#define XPLM_MSG_FMOD_BANK_UNLOADING 113`

</div>

---

<div class="sym-block sym-event" data-name="XPLM_MSG_DATAREFS_ADDED" data-type="event" markdown="1">

## XPLM_MSG_DATAREFS_ADDED { .symbol-title }

<span class="sym-badge badge-event">event</span> <span class="sym-badge badge-version">XPLM400</span>

Sent to your plugin per-frame (at-most) when/if datarefs are added. It will include the new data ref total count
so that your plugin can keep a local cache of the total, see what's changed and know which ones to inquire about
if it cares.

This message is only sent to plugins that enable the XPLM_WANTS_DATAREF_NOTIFICATIONS feature. The parameteter
is a pointer to an integer containing the new number of datarefs.

`#define XPLM_MSG_DATAREFS_ADDED 114`

</div>

---

<div class="sym-block sym-function" data-name="XPLMSendMessageToPlugin" data-type="function" markdown="1">

## XPLMSendMessageToPlugin { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function sends a message to another plug-in or X-Plane.  Pass XPLM_NO_PLUGIN_ID to broadcast
to all plug-ins.  Only enabled plug-ins with a message receive function receive the message.

```cpp
XPLM_API void       XPLMSendMessageToPlugin(
                         XPLMPluginID         inPlugin,
                         int                  inMessage,
                         void *               inParam
                    );
```

</div>

---



<!-- whitespace for navigation purposes -->
<div style="height:100vh;"></div>