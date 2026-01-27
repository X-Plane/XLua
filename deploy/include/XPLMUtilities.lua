-- Use require('XPLMUtilities') to access these functions.

--[[
   Copyright 2005-2022 Laminar Research, Sandy Barbour and Ben Supnik All
   rights reserved.  See license.txt for usage. X-Plane SDK Version: 4.0.0
]]--

-----------------------------------------------------------------------------
-- XPLMUtilities
-----------------------------------------------------------------------------


#include "XPLMDefs.h"
require("XPLMDefs")

--[[
These enums define types of data files you can load or unload using the SDK.
]]--

XPLMDataFileType = {
    -- A situation (.sit) file, which starts off a flight in a given
    -- configuration.
    xplm_DataFile_Situation                  = 1,
    -- A situation movie (.smo) file, which replays a past flight.
    xplm_DataFile_ReplayMovie                = 2,
}

--[[
   XLuaGetSystemPath
   
   This function returns the full path to the X-System folder. Note that this
   is a directory path, so it ends in a trailing : or / .
   
   The buffer you pass should be at least 512 characters long.  The path is
   returned using the current native or OS path conventions.
]]--
-- Returns   :  Table { ["outSystemPath"] }
-- Parameters:
--   None.

--[[
   XLuaGetPrefsPath
   
   This routine returns a full path to a file that is within X-Plane's
   preferences directory. (You should remove the file name back to the last
   directory separator to get the preferences directory using
   XPLMExtractFileAndPath).
   
   The buffer you pass should be at least 512 characters long.  The path is
   returned using the current native or OS path conventions.
]]--
-- Returns   :  Table { ["outPrefsPath"] }
-- Parameters:
--   None.

--[[
   XLuaGetDirectorySeparator
   
   This routine returns a string with one char and a null terminator that is
   the directory separator for the current platform. This allows you to write
   code that concatenates directory paths without having to #ifdef for
   platform. The character returned will reflect the current file path mode.
]]--
-- Returns   : string
-- Parameters:
--   None.

--[[
   XLuaLoadDataFile
   
   Loads a data file of a given type. Paths must be relative to the X-System
   folder. To clear the replay, pass a NULL file name (this is only valid with
   replay movies, not sit files).
]]--
-- Returns   : boolean
-- Parameters:
--   inFileType (integer)
--   inFilePath (string)

--[[
   XLuaSaveDataFile
   
   Saves the current situation or replay; paths are relative to the X-System
   folder.
]]--
-- Returns   : boolean
-- Parameters:
--   inFileType (integer)
--   inFilePath (string)

--[[
While the plug-in SDK is only accessible to plugins running inside X-Plane, the
original authors considered extending the API to other applications that shared basic infrastructure
with X-Plane. These enumerations are hold-overs from that original roadmap; all values other than
X-Plane are deprecated. Your plugin should never need this enumeration.
]]--

XPLMHostApplicationID = {
    xplm_Host_Unknown                        = 0,
    xplm_Host_XPlane                         = 1,
    xplm_Host_PlaneMaker                     = 2,
    xplm_Host_WorldMaker                     = 3,
    xplm_Host_Briefer                        = 4,
    xplm_Host_PartMaker                      = 5,
    xplm_Host_YoungsMod                      = 6,
    xplm_Host_XAuto                          = 7,
    xplm_Host_Xavion                         = 8,
    xplm_Host_Control_Pad                    = 9,
    xplm_Host_PFD_Map                        = 10,
    xplm_Host_RADAR                          = 11,
}

--[[
These enums define what language the sim is running in. These enumerations do not imply that the sim can
or does run in all of these languages; they simply provide a known encoding in the event that a given
sim version is localized to a certain language.
]]--

XPLMLanguageCode = {
    xplm_Language_Unknown                    = 0,
    xplm_Language_English                    = 1,
    xplm_Language_French                     = 2,
    xplm_Language_German                     = 3,
    xplm_Language_Italian                    = 4,
    xplm_Language_Spanish                    = 5,
    xplm_Language_Korean                     = 6,
    xplm_Language_Russian                    = 7,
    xplm_Language_Greek                      = 8,
    xplm_Language_Japanese                   = 9,
    xplm_Language_Chinese                    = 10,
    xplm_Language_Ukrainian                  = 11,
}

--[[
   XLuaInitialized    <<< DEPRECATED. DO NOT USE IN NEW CODE. >>>
   
   Deprecated: This function returns true if X-Plane has properly initialized
   the plug-in system. If this routine returns false, many XPLM functions will
   not work.
   
   NOTE: because plugins are always called from within the XPLM, there is no
   need to check for initialization; it will always return true.  This routine
   is deprecated - you do not need to check it before continuing within your
   plugin.
]]--
-- Returns   : boolean
-- Parameters:
--   None.

--[[
   XLuaGetVersions
   
   This routine returns the revision of both X-Plane and the XPLM DLL. All
   versions are at least three-digit decimal numbers (e.g. 606 for version
   6.06 of X-Plane); the current revision of the XPLM is 400 (4.00). This
   routine also returns the host ID of the app running us.
   
   The most common use of this routine is to special-case around X-Plane
   version-specific behavior.
]]--
-- Returns   :  Table { ["outXPlaneVersion"], ["outXPLMVersion"], ["outHostID"] }
-- Parameters:
--   None.

--[[
   XLuaGetLanguage
   
   This routine returns the langauge the sim is running in.
]]--
-- Returns   : integer
-- Parameters:
--   None.

--[[
   XLuaDebugString
   
   This routine outputs a C-style string to the Log.txt file. The file is
   immediately flushed so you will not lose data. (This does cause a
   performance penalty.)
   
   Please do *not* leave routine diagnostic logging enabled in your shipping
   plugin. The X-Plane Log file is shared by X-Plane and every plugin in the
   system, and plugins that (when functioning normally) print verbose log
   output make it difficult for developers to find error conditions from other
   parts of the system.
]]--
-- Returns   : Nothing.
-- Parameters:
--   inString (string)

--[[
   XLuaSpeakString
   
   This function displays the string in a translucent overlay over the current
   display and also speaks the string if text-to-speech is enabled. The string
   is spoken asynchronously, this function returns immediately. This function
   may not speak or print depending on user preferences.
]]--
-- Returns   : Nothing.
-- Parameters:
--   inString (string)

--[[
   XLuaGetVirtualKeyDescription
   
   Given a virtual key code (as defined in XPLMDefs.h) this routine returns a
   human-readable string describing the character. This routine is provided
   for showing users what keyboard mappings they have set up. The string may
   read 'unknown' or be a blank or NULL string if the virtual key is unknown.
]]--
-- Returns   : string
-- Parameters:
--   inVirtualKey (string)

--[[
   XLuaReloadScenery
   
   XPLMReloadScenery reloads the current set of scenery. You can use this
   function in two typical ways: simply call it to reload the scenery, picking
   up any new installed scenery, .env files, etc. from disk. Or, change the
   lat/ref and lon/ref datarefs and then call this function to shift the
   scenery environment.  This routine is equivalent to picking "reload
   scenery" from the developer menu.
]]--
-- Returns   : Nothing.
-- Parameters:
--   None.

--[[
The phases of a command.
]]--

XPLMCommandPhase = {
    -- The command is being started.
    xplm_CommandBegin                        = 0,
    -- The command is continuing to execute.
    xplm_CommandContinue                     = 1,
    -- The command has ended.
    xplm_CommandEnd                          = 2,
}

--[[
   XLuaFindCommand
   
   XPLMFindCommand looks up a command by name, and returns its command
   reference or NULL if the command does not exist.
]]--
-- Returns   : userdata<XPLMCommandRef>
-- Parameters:
--   inName (string)

--[[
   XLuaCommandBegin
   
   XPLMCommandBegin starts the execution of a command, specified by its
   command reference. The command is "held down" until XPLMCommandEnd is
   called.  You must balance each XPLMCommandBegin call with an XPLMCommandEnd
   call.
]]--
-- Returns   : Nothing.
-- Parameters:
--   inCommand (XPLMCommandRef)

--[[
   XLuaCommandEnd
   
   XPLMCommandEnd ends the execution of a given command that was started with
   XPLMCommandBegin.  You must not issue XPLMCommandEnd for a command you did
   not begin.
]]--
-- Returns   : Nothing.
-- Parameters:
--   inCommand (XPLMCommandRef)

--[[
   XLuaCommandOnce
   
   This executes a given command momentarily, that is, the command begins and
   ends immediately. This is the equivalent of calling XPLMCommandBegin() and
   XPLMCommandEnd() back to back.
]]--
-- Returns   : Nothing.
-- Parameters:
--   inCommand (XPLMCommandRef)

--[[
   XLuaCreateCommand
   
   XPLMCreateCommand creates a new command for a given string. If the command
   already exists, the existing command reference is returned. The description
   may appear in user interface contexts, such as the joystick configuration
   screen.
]]--
-- Returns   : userdata<XPLMCommandRef>
-- Parameters:
--   inName (string)
--   inDescription (string)

--[[
   XLuaRegisterCommandHandler
   
   XPLMRegisterCommandHandler registers a callback to be called when a command
   is executed. You provide a callback with a reference pointer.
   
   If inBefore is true, your command handler callback will be executed before
   X-Plane executes the command, and returning 0 from your callback will
   disable X-Plane's processing of the command. If inBefore is false, your
   callback will run after X-Plane. (You can register a single callback both
   before and after a command.)
]]--
-- Returns   : Nothing.
-- Parameters:
--   inComand (XPLMCommandRef)
--   inHandler (XPLMCommandCallback_f)
--   inBefore (boolean)
--   inRefcon (Any reference value)

--[[
   XLuaUnregisterCommandHandler
   
   XPLMUnregisterCommandHandler removes a command callback registered with
   XPLMRegisterCommandHandler.
]]--
-- Returns   : Nothing.
-- Parameters:
--   inComand (XPLMCommandRef)
--   inHandler (XPLMCommandCallback_f)
--   inBefore (boolean)
--   inRefcon (Any reference value)

--[[
   XPLMCommandKeyID
   
   These enums represent all the keystrokes available within X-Plane. They can
   be sent to X-Plane directly. For example, you can reverse thrust using
   these enumerations.
]]--
XPLMCommandKeyID = {
          xplm_key_pause=0,
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
}

--[[
   XPLMCommandButtonID
   
   These are enumerations for all of the things you can do with a joystick
   button in X-Plane. They currently match the buttons menu in the equipment
   setup dialog, but these enums will be stable even if they change in
   X-Plane.
]]--
XPLMCommandButtonID = {
          xplm_joy_nothing=0,
          xplm_joy_start_all,
          xplm_joy_start_0,
          xplm_joy_start_1,
          xplm_joy_start_2,
          xplm_joy_start_3,
          xplm_joy_start_4,
          xplm_joy_start_5,
          xplm_joy_start_6,
          xplm_joy_start_7,
          xplm_joy_throt_up,
          xplm_joy_throt_dn,
          xplm_joy_prop_up,
          xplm_joy_prop_dn,
          xplm_joy_mixt_up,
          xplm_joy_mixt_dn,
          xplm_joy_carb_tog,
          xplm_joy_carb_on,
          xplm_joy_carb_off,
          xplm_joy_trev,
          xplm_joy_trm_up,
          xplm_joy_trm_dn,
          xplm_joy_rot_trm_up,
          xplm_joy_rot_trm_dn,
          xplm_joy_rud_lft,
          xplm_joy_rud_cntr,
          xplm_joy_rud_rgt,
          xplm_joy_ail_lft,
          xplm_joy_ail_cntr,
          xplm_joy_ail_rgt,
          xplm_joy_B_rud_lft,
          xplm_joy_B_rud_rgt,
          xplm_joy_look_up,
          xplm_joy_look_dn,
          xplm_joy_look_lft,
          xplm_joy_look_rgt,
          xplm_joy_glance_l,
          xplm_joy_glance_r,
          xplm_joy_v_fnh,
          xplm_joy_v_fwh,
          xplm_joy_v_tra,
          xplm_joy_v_twr,
          xplm_joy_v_run,
          xplm_joy_v_cha,
          xplm_joy_v_fr1,
          xplm_joy_v_fr2,
          xplm_joy_v_spo,
          xplm_joy_flapsup,
          xplm_joy_flapsdn,
          xplm_joy_vctswpfwd,
          xplm_joy_vctswpaft,
          xplm_joy_gear_tog,
          xplm_joy_gear_up,
          xplm_joy_gear_down,
          xplm_joy_lft_brake,
          xplm_joy_rgt_brake,
          xplm_joy_brakesREG,
          xplm_joy_brakesMAX,
          xplm_joy_speedbrake,
          xplm_joy_ott_dis,
          xplm_joy_ott_atr,
          xplm_joy_ott_asi,
          xplm_joy_ott_hdg,
          xplm_joy_ott_alt,
          xplm_joy_ott_vvi,
          xplm_joy_tim_start,
          xplm_joy_tim_reset,
          xplm_joy_ecam_up,
          xplm_joy_ecam_dn,
          xplm_joy_fadec,
          xplm_joy_yaw_damp,
          xplm_joy_art_stab,
          xplm_joy_chute,
          xplm_joy_JATO,
          xplm_joy_arrest,
          xplm_joy_jettison,
          xplm_joy_fuel_dump,
          xplm_joy_puffsmoke,
          xplm_joy_prerotate,
          xplm_joy_UL_prerot,
          xplm_joy_UL_collec,
          xplm_joy_TOGA,
          xplm_joy_shutdown,
          xplm_joy_con_atc,
          xplm_joy_fail_now,
          xplm_joy_pause,
          xplm_joy_rock_up,
          xplm_joy_rock_dn,
          xplm_joy_rock_lft,
          xplm_joy_rock_rgt,
          xplm_joy_rock_for,
          xplm_joy_rock_aft,
          xplm_joy_idle_hilo,
          xplm_joy_lanlights,
          xplm_joy_max
}

--[[
   XLuaSimulateKeyPress
   
   This function simulates a key being pressed for X-Plane. The keystroke goes
   directly to X-Plane; it is never sent to any plug-ins. However, since this
   is a raw key stroke it may be mapped by the keys file or enter text into a
   field.
   
   Deprecated: use XPLMCommandOnce
]]--
-- Returns   : Nothing.
-- Parameters:
--   inKeyType (integer)
--   inKey (integer)

--[[
   XLuaCommandKeyStroke    <<< DEPRECATED. DO NOT USE IN NEW CODE. >>>
   
   This routine simulates a command-key stroke. However, the keys are done by
   function, not by actual letter, so this function works even if the user has
   remapped their keyboard. Examples of things you might do with this include
   pausing the simulator.
   
   Deprecated: use XPLMCommandOnce
]]--
-- Returns   : Nothing.
-- Parameters:
--   inKey (integer)

--[[
   XLuaCommandButtonPress    <<< DEPRECATED. DO NOT USE IN NEW CODE. >>>
   
   This function simulates any of the actions that might be taken by pressing
   a joystick button. However, this lets you call the command directly rather
   than having to know which button is mapped where. Important: you must
   release each button you press. The APIs are separate so that you can 'hold
   down' a button for a fixed amount of time.
   
   Deprecated: use XPLMCommandBegin.
]]--
-- Returns   : Nothing.
-- Parameters:
--   inButton (integer)

--[[
   XLuaCommandButtonRelease    <<< DEPRECATED. DO NOT USE IN NEW CODE. >>>
   
   This function simulates any of the actions that might be taken by pressing
   a joystick button. See XPLMCommandButtonPress.
   
   Deprecated: use XPLMCommandEnd.
]]--
-- Returns   : Nothing.
-- Parameters:
--   inButton (integer)

