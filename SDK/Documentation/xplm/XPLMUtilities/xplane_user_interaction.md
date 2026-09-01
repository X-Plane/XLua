<h1>X-Plane User Interaction</h1>

WARNING: The legacy user interaction API is deprecated; while it was the only way to run
commands in X-Plane 6,7 and 8, it is obsolete, and was replaced by the command system API
in X-Plane 9. You should not use this API; replace any of the calls below with XPLMCommand
invocations based on persistent command strings. The documentation that follows is for historic
reference only.

The legacy user interaction APIs let you simulate commands the user can do with a joystick,
keyboard etc. Note that it is generally safer for future compatibility to use one of these
commands than to manipulate the underlying sim data.

---

<div class="sym-block sym-bulkenum" data-name="XPLMCommandKeyID" data-type="bulkenum" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCommandKeyID { .symbol-title }

<span class="sym-badge badge-bulkenum">enum constants</span>

</div>

These enums represent all the keystrokes available within X-Plane. They can be
sent to X-Plane directly. For example, you can reverse thrust using these
enumerations.

<div class="xplm-code" markdown="1">

```cpp
xplm_key_pause,
                xplm_key_revthrust,
                xplm_key_jettison,
                xplm_key_brakesreg,
                xplm_key_brakesmax,
                xplm_key_gear,
                xplm_key_timedn,
                xplm_key_timeup,
                xplm_key_fadec,

                xplm_key_otto_dis,
                xplm_key_otto_atr,
                xplm_key_otto_asi,
                xplm_key_otto_hdg,
                xplm_key_otto_gps,
                xplm_key_otto_lev,
                xplm_key_otto_hnav,
                xplm_key_otto_alt,
                xplm_key_otto_vvi,
                xplm_key_otto_vnav,
                xplm_key_otto_nav1,
                xplm_key_otto_nav2,

                xplm_key_targ_dn,
                xplm_key_targ_up,

                xplm_key_hdgdn,
                xplm_key_hdgup,
                xplm_key_barodn,
                xplm_key_baroup,
                xplm_key_obs1dn,
                xplm_key_obs1up,
                xplm_key_obs2dn,
                xplm_key_obs2up,
                xplm_key_com1_1,
                xplm_key_com1_2,
                xplm_key_com1_3,
                xplm_key_com1_4,
                xplm_key_nav1_1,
                xplm_key_nav1_2,
                xplm_key_nav1_3,
                xplm_key_nav1_4,
                xplm_key_com2_1,
                xplm_key_com2_2,
                xplm_key_com2_3,
                xplm_key_com2_4,
                xplm_key_nav2_1,
                xplm_key_nav2_2,
                xplm_key_nav2_3,
                xplm_key_nav2_4,
                xplm_key_adf_1,
                xplm_key_adf_2,
                xplm_key_adf_3,
                xplm_key_adf_4,
                xplm_key_adf_5,
                xplm_key_adf_6,
                xplm_key_transpon_1,
                xplm_key_transpon_2,
                xplm_key_transpon_3,
                xplm_key_transpon_4,
                xplm_key_transpon_5,
                xplm_key_transpon_6,
                xplm_key_transpon_7,
                xplm_key_transpon_8,
                xplm_key_flapsup,
                xplm_key_flapsdn,
                xplm_key_cheatoff,
                xplm_key_cheaton,
                xplm_key_sbrkoff,
                xplm_key_sbrkon,
                xplm_key_ailtrimL,
                xplm_key_ailtrimR,
                xplm_key_rudtrimL,
                xplm_key_rudtrimR,
                xplm_key_elvtrimD,
                xplm_key_elvtrimU,
                xplm_key_forward,
                xplm_key_down,
                xplm_key_left,
                xplm_key_right,
                xplm_key_back,
                xplm_key_tower,
                xplm_key_runway,
                xplm_key_chase,
                xplm_key_free1,
                xplm_key_free2,
                xplm_key_spot,
                xplm_key_fullscrn1,
                xplm_key_fullscrn2,
                xplm_key_tanspan,
                xplm_key_smoke,
                xplm_key_map,
                xplm_key_zoomin,
                xplm_key_zoomout,
                xplm_key_cycledump,
                xplm_key_replay,
                xplm_key_tranID,
                xplm_key_max
```

</div>

</div>

---

<div class="sym-block sym-bulkenum" data-name="XPLMCommandButtonID" data-type="bulkenum" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCommandButtonID { .symbol-title }

<span class="sym-badge badge-bulkenum">enum constants</span>

</div>

These are enumerations for all of the things you can do with a joystick button
in X-Plane. They currently match the buttons menu in the equipment setup dialog,
but these enums will be stable even if they change in X-Plane.

<div class="xplm-code" markdown="1">

```cpp
xplm_joy_nothing ,
                xplm_joy_start_all,
                xplm_joy_start_0 ,
                xplm_joy_start_1 ,
                xplm_joy_start_2 ,
                xplm_joy_start_3 ,
                xplm_joy_start_4 ,
                xplm_joy_start_5 ,
                xplm_joy_start_6 ,
                xplm_joy_start_7 ,
                xplm_joy_throt_up ,
                xplm_joy_throt_dn ,
                xplm_joy_prop_up ,
                xplm_joy_prop_dn ,
                xplm_joy_mixt_up ,
                xplm_joy_mixt_dn ,
                xplm_joy_carb_tog ,
                xplm_joy_carb_on ,
                xplm_joy_carb_off ,
                xplm_joy_trev ,
                xplm_joy_trm_up ,
                xplm_joy_trm_dn ,
                xplm_joy_rot_trm_up,
                xplm_joy_rot_trm_dn,
                xplm_joy_rud_lft ,
                xplm_joy_rud_cntr ,
                xplm_joy_rud_rgt ,
                xplm_joy_ail_lft ,
                xplm_joy_ail_cntr ,
                xplm_joy_ail_rgt ,
                xplm_joy_B_rud_lft,
                xplm_joy_B_rud_rgt,
                xplm_joy_look_up ,
                xplm_joy_look_dn ,
                xplm_joy_look_lft ,
                xplm_joy_look_rgt ,
                xplm_joy_glance_l ,
                xplm_joy_glance_r ,
                xplm_joy_v_fnh ,
                xplm_joy_v_fwh ,
                xplm_joy_v_tra ,
                xplm_joy_v_twr ,
                xplm_joy_v_run ,
                xplm_joy_v_cha ,
                xplm_joy_v_fr1 ,
                xplm_joy_v_fr2 ,
                xplm_joy_v_spo ,
                xplm_joy_flapsup ,
                xplm_joy_flapsdn ,
                xplm_joy_vctswpfwd,
                xplm_joy_vctswpaft,
                xplm_joy_gear_tog ,
                xplm_joy_gear_up ,
                xplm_joy_gear_down,
                xplm_joy_lft_brake,
                xplm_joy_rgt_brake,
                xplm_joy_brakesREG,
                xplm_joy_brakesMAX,
                xplm_joy_speedbrake,

                xplm_joy_ott_dis ,
                xplm_joy_ott_atr ,
                xplm_joy_ott_asi ,
                xplm_joy_ott_hdg ,
                xplm_joy_ott_alt ,
                xplm_joy_ott_vvi ,

                xplm_joy_tim_start,
                xplm_joy_tim_reset,
                xplm_joy_ecam_up ,
                xplm_joy_ecam_dn ,
                xplm_joy_fadec ,
                xplm_joy_yaw_damp ,
                xplm_joy_art_stab ,
                xplm_joy_chute ,
                xplm_joy_JATO ,
                xplm_joy_arrest ,
                xplm_joy_jettison ,
                xplm_joy_fuel_dump,
                xplm_joy_puffsmoke,
                xplm_joy_prerotate,
                xplm_joy_UL_prerot,
                xplm_joy_UL_collec,
                xplm_joy_TOGA ,
                xplm_joy_shutdown ,
                xplm_joy_con_atc ,
                xplm_joy_fail_now ,
                xplm_joy_pause ,
                xplm_joy_rock_up ,
                xplm_joy_rock_dn ,
                xplm_joy_rock_lft ,
                xplm_joy_rock_rgt ,
                xplm_joy_rock_for ,
                xplm_joy_rock_aft ,
                xplm_joy_idle_hilo,
                xplm_joy_lanlights,
                xplm_joy_max
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMSimulateKeyPress" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSimulateKeyPress { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function simulates a key being pressed for X-Plane. The keystroke goes
directly to X-Plane; it is never sent to any plug-ins. However, since this
is a raw key stroke it may be mapped by the keys file or enter text into a field.

Deprecated: use XPLMCommandOnce

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMSimulateKeyPress(
                         int                  inKeyType,
                         int                  inKey
                    );
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMCommandKeyStroke" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCommandKeyStroke { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-deprecated">XPLM_DEPRECATED</span>

</div>

This routine simulates a command-key stroke. However, the keys are done by
function, not by actual letter, so this function works even if the user has
remapped their keyboard. Examples of things you might do with this include
pausing the simulator.

Deprecated: use XPLMCommandOnce

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMCommandKeyStroke(
                         XPLMCommandKeyID     inKey
                    );
```

</div>


**See associated types:**

- [XPLMCommandKeyID](#xplmcommandkeyid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMCommandButtonPress" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCommandButtonPress { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-deprecated">XPLM_DEPRECATED</span>

</div>

This function simulates any of the actions that might be taken by pressing
a joystick button. However, this lets you call the command directly rather
than having to know which button is mapped where. Important: you must release
each button you press. The APIs are separate so that you can 'hold down' a
button for a fixed amount of time.

Deprecated: use XPLMCommandBegin.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMCommandButtonPress(
                         XPLMCommandButtonID  inButton
                    );
```

</div>


**See associated types:**

- [XPLMCommandButtonID](#xplmcommandbuttonid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMCommandButtonRelease" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCommandButtonRelease { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-deprecated">XPLM_DEPRECATED</span>

</div>

This function simulates any of the actions that might be taken by pressing
a joystick button. See XPLMCommandButtonPress.

Deprecated: use XPLMCommandEnd.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMCommandButtonRelease(
                         XPLMCommandButtonID  inButton
                    );
```

</div>


**See associated types:**

- [XPLMCommandButtonID](#xplmcommandbuttonid)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>