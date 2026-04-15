-- Use require('XPLMUtilities') to access these functions.

--[[
   Copyright 2005-2026 Laminar Research, Sandy Barbour and Ben Supnik All
   rights reserved.  See license.txt for usage. X-Plane SDK Version: 4.0.0
]]--

-----------------------------------------------------------------------------
-- XPLMUtilities
-----------------------------------------------------------------------------


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
--[[
    Returns   : Table {
          ["outSystemPath"]                 (array[512] of string)
    }

    Parameters:
      None.
]]--

--[[
   XLuaGetPrefsPath
   
   This routine returns a full path to a file that is within X-Plane's
   preferences directory. (You should remove the file name back to the last
   directory separator to get the preferences directory using
   XPLMExtractFileAndPath).
   
   The buffer you pass should be at least 512 characters long.  The path is
   returned using the current native or OS path conventions.
]]--
--[[
    Returns   : Table {
          ["outPrefsPath"]                  (array[512] of string)
    }

    Parameters:
      None.
]]--

--[[
   XLuaGetDirectorySeparator
   
   This routine returns a string with one char and a null terminator that is
   the directory separator for the current platform. This allows you to write
   code that concatenates directory paths without having to #ifdef for
   platform. The character returned will reflect the current file path mode.
]]--
--[[
    Returns   : string

    Parameters:
      None.
]]--

--[[
   XLuaLoadDataFile
   
   Loads a data file of a given type. Paths must be relative to the X-System
   folder. To clear the replay, pass a NULL file name (this is only valid with
   replay movies, not sit files).
]]--
--[[
    Returns   : boolean

    Parameters:
     inFileType                             (XPLMDataFileType)
     inFilePath                             (string)

]]--

--[[
   XLuaSaveDataFile
   
   Saves the current situation or replay; paths are relative to the X-System
   folder.
]]--
--[[
    Returns   : boolean

    Parameters:
     inFileType                             (XPLMDataFileType)
     inFilePath                             (string)

]]--

--[[
While the plug-in SDK is only accessible to plugins running inside X-Plane, the
original authors considered extending the API to other applications that shared basic infrastructure
with X-Plane. These enumerations are hold-overs from that original roadmap; all values other than
X-Plane are deprecated. Your plugin should never need this enumeration.
]]--

XPLMHostApplicationID = {
    xplm_Host_Unknown                        = 0,
    xplm_Host_XPlane                         = 1,
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
   XLuaGetVersions
   
   This routine returns the revision of both X-Plane and the XPLM DLL. All
   versions are at least three-digit decimal numbers (e.g. 606 for version
   6.06 of X-Plane); the current revision of the XPLM is 400 (4.00). This
   routine also returns the host ID of the app running us.
   
   The most common use of this routine is to special-case around X-Plane
   version-specific behavior.
]]--
--[[
    Returns   : Table {
          ["outXPlaneVersion"]              (integer),
          ["outXPLMVersion"]                (integer),
          ["outHostID"]                     (integer)
    }

    Parameters:
      None.
]]--

--[[
   XLuaGetLanguage
   
   This routine returns the langauge the sim is running in.
]]--
--[[
    Returns   : integer

    Parameters:
      None.
]]--

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
--[[
    Returns   : Nothing.

    Parameters:
     inString                               (string)

]]--

--[[
   XLuaSpeakString
   
   This function displays the string in a translucent overlay over the current
   display and also speaks the string if text-to-speech is enabled. The string
   is spoken asynchronously, this function returns immediately. This function
   may not speak or print depending on user preferences.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inString                               (string)

]]--

--[[
   XLuaGetVirtualKeyDescription
   
   Given a virtual key code (as defined in XPLMDefs.h) this routine returns a
   human-readable string describing the character. This routine is provided
   for showing users what keyboard mappings they have set up. The string may
   read 'unknown' or be a blank or NULL string if the virtual key is unknown.
]]--
--[[
    Returns   : string

    Parameters:
     inVirtualKey                           (string)

]]--

--[[
   XLuaReloadScenery
   
   XPLMReloadScenery reloads the current set of scenery. You can use this
   function in two typical ways: simply call it to reload the scenery, picking
   up any new installed scenery, .env files, etc. from disk. Or, change the
   lat/ref and lon/ref datarefs and then call this function to shift the
   scenery environment.  This routine is equivalent to picking "reload
   scenery" from the developer menu.
]]--
--[[
    Returns   : Nothing.

    Parameters:
      None.
]]--

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
--[[
    Returns   : userdata<XPLMCommandRef>

    Parameters:
     inName                                 (string)

]]--

--[[
   XLuaCommandBegin
   
   XPLMCommandBegin starts the execution of a command, specified by its
   command reference. The command is "held down" until XPLMCommandEnd is
   called.  You must balance each XPLMCommandBegin call with an XPLMCommandEnd
   call.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inCommand                              (XPLMCommandRef)

]]--

--[[
   XLuaCommandEnd
   
   XPLMCommandEnd ends the execution of a given command that was started with
   XPLMCommandBegin.  You must not issue XPLMCommandEnd for a command you did
   not begin.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inCommand                              (XPLMCommandRef)

]]--

--[[
   XLuaCommandOnce
   
   This executes a given command momentarily, that is, the command begins and
   ends immediately. This is the equivalent of calling XPLMCommandBegin() and
   XPLMCommandEnd() back to back.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inCommand                              (XPLMCommandRef)

]]--

--[[
   XLuaCreateCommand
   
   XPLMCreateCommand creates a new command for a given string. If the command
   already exists, the existing command reference is returned. The description
   may appear in user interface contexts, such as the joystick configuration
   screen.
]]--
--[[
    Returns   : userdata<XPLMCommandRef>

    Parameters:
     inName                                 (string)
     inDescription                          (string)

]]--

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
--[[
    Returns   : Nothing.

    Parameters:
     inComand                               (XPLMCommandRef)
     inHandler                              (XPLMCommandCallback_f)
     inBefore                               (boolean)
     inRefcon                               (Any reference value)

]]--

--[[
   XLuaUnregisterCommandHandler
   
   XPLMUnregisterCommandHandler removes a command callback registered with
   XPLMRegisterCommandHandler.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inComand                               (XPLMCommandRef)
     inHandler                              (XPLMCommandCallback_f)
     inBefore                               (boolean)
     inRefcon                               (Any reference value)

]]--

