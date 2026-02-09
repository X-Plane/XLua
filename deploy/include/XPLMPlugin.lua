-- Use require('XPLMPlugin') to access these functions.

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

--[[
   XLuaGetMyID
   
   This routine returns the plugin ID of the calling plug-in.  Call this to
   get your own ID.
]]--
--[[
    Returns   : userdata<XPLMPluginID>

    Parameters:
      None.
]]--

--[[
   XLuaCountPlugins
   
   This routine returns the total number of plug-ins that are loaded, both
   disabled and enabled.
]]--
--[[
    Returns   : integer

    Parameters:
      None.
]]--

--[[
   XLuaGetNthPlugin
   
   This routine returns the ID of a plug-in by index.  Index is 0 based from 0
   to XPLMCountPlugins-1, inclusive. Plugins may be returned in any arbitrary
   order.
]]--
--[[
    Returns   : userdata<XPLMPluginID>

    Parameters:
     inIndex                                (integer)

]]--

--[[
   XLuaFindPluginByPath
   
   This routine returns the plug-in ID of the plug-in whose file exists at the
   passed in absolute file system path.  XPLM_NO_PLUGIN_ID is returned if the
   path does not point to a currently loaded plug-in.
]]--
--[[
    Returns   : userdata<XPLMPluginID>

    Parameters:
     inPath                                 (string)

]]--

--[[
   XLuaFindPluginBySignature
   
   This routine returns the plug-in ID of the plug-in whose signature matches
   what is passed in or XPLM_NO_PLUGIN_ID if no running plug-in has this
   signature.  Signatures are the best way to identify another plug-in as they
   are independent of the file system path of a plug-in or the human-readable
   plug-in name, and should be unique for all plug-ins.  Use this routine to
   locate another plugin that your plugin interoperates with
]]--
--[[
    Returns   : userdata<XPLMPluginID>

    Parameters:
     inSignature                            (string)

]]--

--[[
   XLuaGetPluginInfo
   
   This routine returns information about a plug-in.  Each parameter should be
   a pointer to a buffer of at least
   256 characters, or NULL to not receive the information.
   
   outName - the human-readable name of the plug-in. outFilePath - the
   absolute file path to the file that contains this plug-in. outSignature - a
   unique string that identifies this plug-in. outDescription - a
   human-readable description of this plug-in.
]]--
--[[
    Returns   : Table {
          ["outName"]                       (array[256] of string),
          ["outFilePath"]                   (array[256] of string),
          ["outSignature"]                  (array[256] of string),
          ["outDescription"]                (array[256] of string)
    }

    Parameters:
     inPlugin                               (XPLMPluginID)

]]--

--[[
   XLuaIsPluginEnabled
   
   Returns whether the specified plug-in is enabled for running.
]]--
--[[
    Returns   : boolean

    Parameters:
     inPluginID                             (XPLMPluginID)

]]--

--[[
   XLuaEnablePlugin
   
   This routine enables a plug-in if it is not already enabled. It returns
   true if the plugin was enabled or successfully enables itself, false if it
   does not.  Plugins may fail to enable (for example, if resources cannot be
   acquired) by returning false from their XPluginEnable callback.
]]--
--[[
    Returns   : boolean

    Parameters:
     inPluginID                             (XPLMPluginID)

]]--

--[[
   XLuaDisablePlugin
   
   This routine disables an enabled plug-in.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inPluginID                             (XPLMPluginID)

]]--

--[[
   XLuaReloadPlugins
   
   This routine reloads all plug-ins.  Once this routine is called and you
   return from the callback you were within (e.g. a menu select callback) you
   will receive your XPluginDisable and XPluginStop callbacks and your DLL
   will be unloaded, then the start process happens as if the sim was starting
   up.
]]--
--[[
    Returns   : Nothing.

    Parameters:
      None.
]]--

--[[
   XLuaReloadThisPlugin
   
   This routine reloads the plug-ins which calls it. If you pass true for
   'forReplacement', a dialog will be shown after the .xpl has been unloaded
   to allow you to replace it with a newer one manually. In other respects it
   works identically to XPLMReloadPlugins().
]]--
--[[
    Returns   : Nothing.

    Parameters:
     forReplacement                         (boolean)

]]--

--[[
   XLuaSendMessageToPlugin
   
   This function sends a message to another plug-in or X-Plane.  Pass
   XPLM_NO_PLUGIN_ID to broadcast to all plug-ins.  Only enabled plug-ins with
   a message receive function receive the message.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inPlugin                               (XPLMPluginID)
     inMessage                              (integer)
     inParam                                (void*)

]]--

--[[
   XLuaHasFeature
   
   This returns 1 if the given installation of X-Plane supports a feature, or
   0 if it does not.
]]--
--[[
    Returns   : boolean

    Parameters:
     inFeature                              (string)

]]--

--[[
   XLuaIsFeatureEnabled
   
   This returns 1 if a feature is currently enabled for your plugin, or 0 if
   it is not enabled.  It is an error to call this routine with an unsupported
   feature.
]]--
--[[
    Returns   : boolean

    Parameters:
     inFeature                              (string)

]]--

--[[
   XLuaEnableFeature
   
   This routine enables or disables a feature for your plugin.  This will
   change the running behavior of X-Plane and your plugin in some way,
   depending on the feature.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inFeature                              (string)
     inEnable                               (boolean)

]]--

--[[
   XLuaEnumerateFeatures
   
   This routine calls your enumerator callback once for each feature that this
   running version of X-Plane supports. Use this routine to determine all of
   the features that X-Plane can support.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inEnumerator                           (XPLMFeatureEnumerator_f)
     inRef                                  (Any reference value)

]]--

