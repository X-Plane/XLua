---@meta XPLMPlugin

-- The functions, typedefs, enums, and defines in this file are
-- installed into the Lua VM at startup by the host's add_xplm_to_interp()
-- call. Scripts do NOT need to require('XPLMPlugin') to access them; this file
-- exists solely as type metadata for lua-language-server / EmmyLua.

--[[
   Copyright 2005-2026 Laminar Research, Sandy Barbour and Ben Supnik All
   rights reserved.  See license.txt for usage. X-Plane SDK Version: 4.0.0
]]--

-----------------------------------------------------------------------------
-- XPLMPlugin
-----------------------------------------------------------------------------

--[[
   These APIs provide facilities to find and work with other plugins and
   manage other plugins.
]]--

require("XPLMDefs")
require("XPLMSound")

---@class _G
--- This routine returns the plugin ID of the calling plug-in.  Call this to
--- get your own ID.
---
---@field XPLMGetMyID fun(): XPLMPluginID

---@class _G
--- This routine returns the total number of plug-ins that are loaded, both disabled and enabled.
---
---@field XPLMCountPlugins fun(): integer

---@class _G
--- This routine returns the ID of a plug-in by index.  Index is 0 based from 0 to XPLMCountPlugins-1, inclusive.
--- Plugins may be returned in any arbitrary order.
---
---@field XPLMGetNthPlugin fun(inIndex: integer): XPLMPluginID

---@class _G
--- This routine returns the plug-in ID of the plug-in whose file exists at the passed in absolute file system
--- path.  XPLM_NO_PLUGIN_ID is returned if the path does not point to a currently loaded plug-in.
---
---@field XPLMFindPluginByPath fun(inPath: string): XPLMPluginID

---@class _G
--- This routine returns the plug-in ID of the plug-in whose signature matches what is passed in or XPLM_NO_PLUGIN_ID
--- if no running plug-in has this signature.  Signatures are the best way to identify another plug-in as they are
--- independent of the file system path of a plug-in or the human-readable plug-in name, and should be unique for all
--- plug-ins.  Use this routine to locate another plugin that your plugin interoperates with
---
---@field XPLMFindPluginBySignature fun(inSignature: string): XPLMPluginID

---@class _G
--- This routine returns information about a plug-in.  Each parameter should be a pointer to a buffer of at least
--- 256 characters, or NULL to not receive the information.
---
--- outName - the human-readable name of the plug-in.
--- outFilePath - the absolute file path to the file that contains this plug-in.
--- outSignature - a unique string that identifies this plug-in.
--- outDescription - a human-readable description of this plug-in.
---
---@field XPLMGetPluginInfo fun(inPlugin: XPLMPluginID): { outName: string[], outFilePath: string[], outSignature: string[], outDescription: string[] }

---@class _G
--- Returns whether the specified plug-in is enabled for running.
---
---@field XPLMIsPluginEnabled fun(inPluginID: XPLMPluginID): boolean

---@class _G
--- This routine enables a plug-in if it is not already enabled.
--- It returns true if the plugin was enabled or successfully enables itself,
--- false if it does not.  Plugins may fail to enable (for example, if resources
--- cannot be acquired) by returning false from their XPluginEnable callback.
---
---@field XPLMEnablePlugin fun(inPluginID: XPLMPluginID): boolean

---@class _G
--- This routine disables an enabled plug-in.
---
---@field XPLMDisablePlugin fun(inPluginID: XPLMPluginID)

---@class _G
--- This routine reloads all plug-ins.  Once this routine is called and
--- you return from the callback you were within (e.g. a menu select callback)
--- you will receive your XPluginDisable and XPluginStop callbacks and your
--- DLL will be unloaded, then the start process happens as if the sim was
--- starting up.
---
---@field XPLMReloadPlugins fun()

---@class _G
--- This routine reloads the plug-ins which calls it. If you pass true for 'forReplacement',
--- a dialog will be shown after the .xpl has been unloaded to allow you to replace it with a
--- newer one manually. In other respects it works identically to XPLMReloadPlugins().
---
---@field XPLMReloadThisPlugin fun(forReplacement: boolean)

--[[
    This message is sent to your plugin whenever the user's plane crashes. The
    parameter is ignored.
]]--
XPLM_MSG_PLANE_CRASHED = 101

--[[
    This message is sent to your plugin whenever a new plane is loaded.  The
    parameter contains the index number of the plane being loaded; 0 indicates
    the user's plane. The parameter is an integer bit-cast to a pointer.
]]--
XPLM_MSG_PLANE_LOADED = 102

--[[
    This messages is sent whenever the user's plane is positioned at a new
    airport. The parameter is ignored.
]]--
XPLM_MSG_AIRPORT_LOADED = 103

--[[
    This message is sent whenever new scenery is loaded.  Use datarefs to
    determine the new scenery files that were loaded. The parameter is ignored.
]]--
XPLM_MSG_SCENERY_LOADED = 104

--[[
    This message is sent whenever the user adjusts the number of X-Plane aircraft
    models.  You must use XPLMCountPlanes to find out how many planes are now
    available.  This message will only be sent in XP7 and higher because in XP6
    the number of aircraft is not user-adjustable. The parameter is ignored.
]]--
XPLM_MSG_AIRPLANE_COUNT_CHANGED = 105

--[[
    This message is sent to your plugin whenever a plane is unloaded.  The
    parameter contains the index number of the plane being unloaded; 0 indicates
    the user's plane.  The parameter is of type int, bit-cast to a pointer.
]]--
XPLM_MSG_PLANE_UNLOADED = 106

--[[
    This message is sent to your plugin right before X-Plane writes its
    preferences file.  You can use this for two purposes: to write your own
    preferences, and to modify any datarefs to influence preferences output.  For
    example, if your plugin temporarily modifies saved preferences, you can put
    them back to their default values here to avoid having the tweaks be
    persisted if your plugin is not loaded on the next invocation of X-Plane. The
    parameter is ignored.
]]--
XPLM_MSG_WILL_WRITE_PREFS = 107

--[[
    This message is sent to your plugin right after a livery is loaded for an
    airplane.  You can use this to check the new livery (via datarefs) and react
    accordingly.  The parameter contains the index number of the aircraft whose
    livery is changing. The parameter is an integer, bit-cast to a pointer.
]]--
XPLM_MSG_LIVERY_LOADED = 108

--[[
    Sent to your plugin right before X-Plane enters virtual reality mode (at
    which time any windows that are not positioned in VR mode will no longer be
    visible to the user). The parameter is unused and should be ignored.
]]--
XPLM_MSG_ENTERED_VR = 109

--[[
    Sent to your plugin right before X-Plane leaves virtual reality mode (at
    which time you may want to clean up windows that are positioned in VR mode).
    The parameter is unused and should be ignored.
]]--
XPLM_MSG_EXITING_VR = 110

--[[
    Sent to your plugin if another plugin wants to take over AI planes. If you
    are a synthetic traffic provider,  that probably means a plugin for an online
    network has connected and wants to supply aircraft flown by real humans and
    you should cease to provide synthetic traffic. If however you are providing
    online traffic from real humans,  you probably don't want to disconnect, in
    which case you just ignore this message. The sender is the plugin ID of the
    plugin asking for control of the planes now. You can use it to find out who
    is requesting and whether you should yield to them. Synthetic traffic
    providers should always yield to online networks. The parameter is unused and
    should be ignored. Do not send this message directly; always use the
    XPLMAcquirePlanes() call.
]]--
XPLM_MSG_RELEASE_PLANES = 111

--[[
    Sent to your plugin after FMOD sound banks are loaded. The parameter is the
    XPLMBankID enum in XPLMSound.h, 0 for the master bank and 1 for the radio
    bank. The bank ID is bit-cast to a pointer.
]]--
XPLM_MSG_FMOD_BANK_LOADED = 112

--[[
    Sent to your plugin before FMOD sound banks are unloaded. Any associated
    resources should be cleaned up at this point. The parameter is the XPLMBankID
    enum in XPLMSound.h, 0 for the master bank and 1 for the radio bank. The bank
    ID is bit-cast to a pointer.
]]--
XPLM_MSG_FMOD_BANK_UNLOADING = 113

--[[
    Sent to your plugin per-frame (at-most) when/if datarefs are added. It will
    include the new data ref total count so that your plugin can keep a local
    cache of the total, see what's changed and know which ones to inquire about
    if it cares.
   
   This message is only sent to plugins that enable the
   XPLM_WANTS_DATAREF_NOTIFICATIONS feature. The parameteter is a pointer to an
   integer containing the new number of datarefs.
]]--
XPLM_MSG_DATAREFS_ADDED = 114

---@class _G
--- This function sends a message to another plug-in or X-Plane.  Pass XPLM_NO_PLUGIN_ID to broadcast
--- to all plug-ins.  Only enabled plug-ins with a message receive function receive the message.
---
---@field XPLMSendMessageToPlugin fun(inPlugin: XPLMPluginID, inMessage: integer, inParam: lightuserdata)

--- You pass an XPLMFeatureEnumerator_f to get a list of all features supported by a given version running version of X-Plane. This routine is called once for each feature.
---@alias XPLMFeatureEnumerator_f fun(inFeature: string, inRef: any)

---@class _G
--- This returns 1 if the given installation of X-Plane supports a feature, or 0 if it does not.
---
---@field XPLMHasFeature fun(inFeature: string): boolean

---@class _G
--- This returns 1 if a feature is currently enabled for your plugin, or 0 if it is not enabled.  It is
--- an error to call this routine with an unsupported feature.
---
---@field XPLMIsFeatureEnabled fun(inFeature: string): boolean

---@class _G
--- This routine enables or disables a feature for your plugin.  This will change the running behavior
--- of X-Plane and your plugin in some way, depending on the feature.
---
---@field XPLMEnableFeature fun(inFeature: string, inEnable: boolean)

---@class _G
--- This routine calls your enumerator callback once for each feature that this running version of X-Plane supports.
--- Use this routine to determine all of the features that X-Plane can support. Callbacks are synchronous.
---
---@field XPLMEnumerateFeatures fun(inEnumerator: XPLMFeatureEnumerator_f, inRef: any)

