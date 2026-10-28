<h1>Fmod Access</h1>

---

<div class="sym-block sym-enum" data-name="XPLMAudioBus" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMAudioBus { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

</div>

This enumeration states the type of audio you wish to play - that is, the part of the
simulated environment that the audio belongs in.
If you use FMOD directly, note that COM1, COM2, Pilot and GND exist in a different FMOD bank so
you may see these channels being unloaded/reloaded independently of the others. They may also be using
a different FMOD::System if the user has selected a dedicated headset output device.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplm_AudioRadioCom1 | 0 | Incoming speech on COM1 |
| xplm_AudioRadioCom2 | 1 | Incoming speech on COM2 |
| xplm_AudioRadioPilot | 2 | Pilot's own speech |
| xplm_AudioRadioCopilot | 3 | Copilot's own speech |
| xplm_AudioExteriorAircraft | 4 |  |
| xplm_AudioExteriorEnvironment | 5 |  |
| xplm_AudioExteriorUnprocessed | 6 |  |
| xplm_AudioInterior | 7 |  |
| xplm_AudioUI | 8 |  |
| xplm_AudioGround | 9 | Dedicated ground vehicle cable |
| xplm_Master | 10 | Master bus. Not normally to be used directly. |

</div>

**Used by:**

- [XPLMGetFMODChannelGroup](#xplmgetfmodchannelgroup)
- [XPLMPlayPCMOnBus](#xplmplaypcmonbus)

</div>

---

<div class="sym-block sym-enum" data-name="XPLMBankID" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMBankID { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

</div>

These values are returned as the parameter of the "XPLM_MSG_FMOD_BANK_LOADED" and "XPLM_MSG_FMOD_BANK_UNLOADING"
messages.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplm_MasterBank | 0 | Master bank. Handles all aircraft and environmental audio. |
| xplm_RadioBank | 1 | Radio bank. Handles COM1/COM2/GND/Pilot/Copilot. |

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetFMODStudio" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetFMODStudio { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Get a handle to the FMOD Studio, allowing you to load/process whatever else you need. This also
gives access to the underlying system via FMOD::Studio::System::getCoreSystem() / FMOD_Studio_System_GetCoreSystem() .
When a separate output device is being used for the radio, this will always return the FMOD::Studio that is running
the environment output, as before. If you want to specifically target the headset output device, you can obtain that
FMOD::Studio by getting one of the radio-specific output channelgroups and using the getSystem() call on that.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API FMOD_STUDIO_SYSTEM* XPLMGetFMODStudio(void);
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetFMODChannelGroup" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetFMODChannelGroup { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Get a reference to a particular channel group - that is, an output channel. See the table above
for values.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API FMOD_CHANNELGROUP* XPLMGetFMODChannelGroup(
                         XPLMAudioBus         audioType
                    );
```

</div>


**See associated types:**

- [XPLMAudioBus](#xplmaudiobus)
</div>

---

<div class="sym-block sym-enum" data-name="FMOD_RESULT" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## FMOD_RESULT { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

</div>

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| FMOD_OK | 0 |  |

</div>

**Used by:**

- [XPLMPCMComplete_f](#xplmpcmcomplete_f)

</div>

---

<div class="sym-block sym-enum" data-name="FMOD_SOUND_FORMAT" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## FMOD_SOUND_FORMAT { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

</div>

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| FMOD_SOUND_FORMAT_PCM16 | 2 |  |

</div>

**Used by:**

- [XPLMPlayPCMOnBus](#xplmplaypcmonbus)

</div>

---

<div class="sym-block sym-typedef" data-name="FMOD_CHANNEL" data-type="typedef" markdown="1">

<div class="sym-title-row" markdown="1">

## FMOD_CHANNEL { .symbol-title }

<span class="sym-badge badge-typedef">typedef</span>

</div>

<div class="xplm-code" markdown="1">

```cpp
typedef void FMOD_CHANNEL;
```

</div>


**Used by:**

- [XPLMSetAudioCone](#xplmsetaudiocone)
- [XPLMSetAudioFadeDistance](#xplmsetaudiofadedistance)
- [XPLMSetAudioPitch](#xplmsetaudiopitch)
- [XPLMSetAudioPosition](#xplmsetaudioposition)
- [XPLMSetAudioVolume](#xplmsetaudiovolume)
- [XPLMStopAudio](#xplmstopaudio)
</div>

---

<div class="sym-block sym-struct" data-name="FMOD_VECTOR" data-type="struct" markdown="1">

<div class="sym-title-row" markdown="1">

## FMOD_VECTOR { .symbol-title }

<span class="sym-badge badge-struct">struct</span>

</div>

<div class="xplm-code" markdown="1">

```cpp
typedef struct {
     float                     x;
     float                     y;
     float                     z;
} FMOD_VECTOR;
```

</div>

</div>

---

<div class="sym-block sym-callback" data-name="XPLMPCMComplete_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMPCMComplete_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

If you use XPLMPlayPCMOnBus() you may use this optional callback to find out when the FMOD::Channel is
complete, if you need to deallocate memory for example. It will not be called more than once per completion.

<div class="xplm-code" markdown="1">

```cpp
typedef void (* XPLMPCMComplete_f)(
                         void*                inRefcon,
                         FMOD_RESULT          status
                    );
```

</div>


**See associated types:**

- [FMOD_RESULT](#fmod_result)
</div>

---

<div class="sym-block sym-function" data-name="XPLMPlayPCMOnBus" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMPlayPCMOnBus { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Play an in-memory audio buffer on a given audio bus. The resulting FMOD channel is returned.
PAY ATTENTION TO THE CALLBACK - when the sample completes or is stopped by X-Plane, the channel
will go away. It's up to you to listen for the callback and invalidate any copy of the channel pointer
you have lying around. The callback is optional because if you have no intention of interacting
with the sound after it's launched, then you don't need to keep the channel pointer at all.
The sound is not started instantly. Instead, it will be started the next time X-Plane refreshes the sound system,
typically at the start of the next frame. This allows you to set the initial position for the sound, if required.
The callback will be called on the main thread, and will be called only once per sound.
If the call fails and you provide a callback function, you will get a callback with an FMOD status code.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API FMOD_CHANNEL* XPLMPlayPCMOnBus(
                         void*                audioBuffer,
                         int                  bufferSize,
                         FMOD_SOUND_FORMAT    soundFormat,
                         int                  freqHz,
                         int                  numChannels,
                         int                  loop,
                         XPLMAudioBus         audioType,
                         XPLMPCMComplete_f    inCallback,    /* Can be NULL */
                         void*                inRefcon
                    );
```

</div>


**See associated types:**

- [FMOD_SOUND_FORMAT](#fmod_sound_format)
- [XPLMAudioBus](#xplmaudiobus)
- [XPLMPCMComplete_f](#xplmpcmcomplete_f)
</div>

---

<div class="sym-block sym-function" data-name="XPLMStopAudio" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMStopAudio { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Stop playing an active FMOD channel. If you defined a completion callback, this will be called. After this,
the FMOD::Channel* will no longer be valid and must not be used in any future calls.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API FMOD_RESULT XPLMStopAudio(
                         FMOD_CHANNEL*        fmod_channel
                    );
```

</div>


**See associated types:**

- [FMOD_CHANNEL](#fmod_channel)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSetAudioPosition" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetAudioPosition { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Move the given audio channel (i.e. a single sound) to a specific location in local co-ordinates. This will set the
sound to 3D if it is not already.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API FMOD_RESULT XPLMSetAudioPosition(
                         FMOD_CHANNEL*        fmod_channel,
                         FMOD_VECTOR*         position,
                         FMOD_VECTOR*         velocity
                    );
```

</div>


**See associated types:**

- [FMOD_CHANNEL](#fmod_channel)
- [FMOD_VECTOR](#fmod_vector)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSetAudioFadeDistance" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetAudioFadeDistance { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Set the minimum and maximum fade distances for a given sound. This is highly unlikely to be 0 - please
see https://documentation.help/FMOD-Studio-API/FMOD_Sound_Set3DMinMaxDistance.html for full details.
This will set the sound to 3D if it is not already. You can set a 3D sound back to 2D by passing
negative values for both min amd max.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API FMOD_RESULT XPLMSetAudioFadeDistance(
                         FMOD_CHANNEL*        fmod_channel,
                         float                min_fade_distance,
                         float                max_fade_distance
                    );
```

</div>


**See associated types:**

- [FMOD_CHANNEL](#fmod_channel)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSetAudioVolume" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetAudioVolume { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Set the current volume of an active FMOD channel. This should be used to handle changes in the audio source volume,
not for fading with distance. Values from 0 to 1 are normal, above 1 can be used to artificially amplify a sound.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API FMOD_RESULT XPLMSetAudioVolume(
                         FMOD_CHANNEL*        fmod_channel,
                         float                source_volume
                    );
```

</div>


**See associated types:**

- [FMOD_CHANNEL](#fmod_channel)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSetAudioPitch" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetAudioPitch { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Change the current pitch of an active FMOD channel.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API FMOD_RESULT XPLMSetAudioPitch(
                         FMOD_CHANNEL*        fmod_channel,
                         float                audio_pitch_hz
                    );
```

</div>


**See associated types:**

- [FMOD_CHANNEL](#fmod_channel)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSetAudioCone" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetAudioCone { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Set a directional cone for an active FMOD channel. The orientation vector is in local coordinates.
This will set the sound to 3D if it is not already.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API FMOD_RESULT XPLMSetAudioCone(
                         FMOD_CHANNEL*        fmod_channel,
                         float                inside_angle,
                         float                outside_angle,
                         float                outside_volume,
                         FMOD_VECTOR*         orientation
                    );
```

</div>


**See associated types:**

- [FMOD_CHANNEL](#fmod_channel)
- [FMOD_VECTOR](#fmod_vector)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>