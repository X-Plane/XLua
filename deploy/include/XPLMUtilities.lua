---@meta XPLMUtilities

-- The functions, typedefs, enums, and defines in this file are
-- installed into the Lua VM at startup by the host's add_xplm_to_interp()
-- call. Scripts do NOT need to require('XPLMUtilities') to access them; this file
-- exists solely as type metadata for lua-language-server / EmmyLua.

--[[
   Copyright 2005-2026 Laminar Research, Sandy Barbour and Ben Supnik All
   rights reserved.  See license.txt for usage. X-Plane SDK Version: 4.0.0
]]--

-----------------------------------------------------------------------------
-- XPLMUtilities
-----------------------------------------------------------------------------


require("XPLMDefs")


-----------------------------------------------------------------------------
-- FILE UTILITIES
-----------------------------------------------------------------------------

--[[
   The XPLMUtilities file APIs provide some basic file and path functions for
   use with X-Plane.
   
   Directory Separators
   --------------------
   
   The XPLM has two modes it can work in:
   
    * X-Plane native paths: all paths are UTF8 strings, using the unix forward
      slash (/) as the directory separating character.  In native path mode,
      you use the same path format for all three operating systems.
   
    * Legacy OS paths: the directroy separator is \ for Windows, : for OS X,
      and / for Linux; OS paths are encoded in MacRoman for OS X using legacy
      HFS conventions, use the application code page for multi-byte encoding
      on Unix using DOS path conventions, and use UTF-8 for Linux.
   
   While legacy OS paths are the default, we strongly encourage you to opt in
   to native paths using the XPLMEnableFeature API.
   
    * All OS X plugins should enable native paths all of the time; if you do
      not do this, you will have to convert all paths back from HFS to Unix
      (and deal with MacRoman) - code written using native paths and the C
      file APIs "just works" on OS X.
   
    * For Linux plugins, there is no difference between the two encodings.
   
    * Windows plugins will need to convert the UTF8 file paths to UTF16 for
      use with the "wide" APIs. While it might seem tempting to stick with
      legacy OS paths (and just use the "ANSI" Windows APIs), X-Plane is fully
      unicode-capable, and will often be installed in paths where the user's
      directories have no ACP encoding.
   
   Full and Relative Paths
   -----------------------
   
   Some of these APIs use full paths, but others use paths relative to the
   user's X-Plane installation. This is documented on a per-API basis.
]]--

--[[
These enums define types of data files you can load or unload using the SDK.
]]--

---@enum XPLMDataFileType
local XPLMDataFileType = {
    -- A situation (.sit) file, which starts off a flight in a given
    -- configuration.
    xplm_DataFile_Situation                  = 1,
    -- A situation movie (.smo) file, which replays a past flight.
    xplm_DataFile_ReplayMovie                = 2,
}
---@class _G
---@field XPLMDataFileType XPLMDataFileType

---@class _G
--- This function returns the full path to the X-System folder. Note that this is a
--- directory path, so it ends in a trailing : or / .
---
--- The buffer you pass should be at least 512 characters long.  The path is returned using the
--- current native or OS path conventions.
---
---@field XPLMGetSystemPath fun(): { outSystemPath: string[] }

---@class _G
--- This routine returns a full path to a file that is within X-Plane's preferences
--- directory. (You should remove the file name back to the last directory separator
--- to get the preferences directory using XPLMExtractFileAndPath).
---
--- The buffer you pass should be at least 512 characters long.  The path is returned using the
--- current native or OS path conventions.
---
---@field XPLMGetPrefsPath fun(): { outPrefsPath: string[] }

---@class _G
--- This routine returns a string with one char and a null terminator that is the directory
--- separator for the current platform. This allows you to write code that concatenates
--- directory paths without having to #ifdef for platform. The character returned will reflect
--- the current file path mode.
---
---@field XPLMGetDirectorySeparator fun(): string

---@class _G
--- Loads a data file of a given type. Paths must be relative to the X-System folder.
--- To clear the replay, pass a NULL file name (this is only valid with replay movies, not sit files).
---
---@field XPLMLoadDataFile fun(inFileType: XPLMDataFileType, inFilePath: string): boolean

---@class _G
--- Saves the current situation or replay; paths are relative to the X-System folder.
---
---@field XPLMSaveDataFile fun(inFileType: XPLMDataFileType, inFilePath: string): boolean


-----------------------------------------------------------------------------
-- X-PLANE MISC
-----------------------------------------------------------------------------

--[[
While the plug-in SDK is only accessible to plugins running inside X-Plane, the
original authors considered extending the API to other applications that shared basic infrastructure
with X-Plane. These enumerations are hold-overs from that original roadmap; all values other than
X-Plane are deprecated. Your plugin should never need this enumeration.
]]--

---@enum XPLMHostApplicationID
local XPLMHostApplicationID = {
    xplm_Host_Unknown                        = 0,
    xplm_Host_XPlane                         = 1,
}
---@class _G
---@field XPLMHostApplicationID XPLMHostApplicationID

--[[
These enums define what language the sim is running in. These enumerations do not imply that the sim can
or does run in all of these languages; they simply provide a known encoding in the event that a given
sim version is localized to a certain language.
]]--

---@enum XPLMLanguageCode
local XPLMLanguageCode = {
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
---@class _G
---@field XPLMLanguageCode XPLMLanguageCode

--[[
Whether this copy of X-Plane is running under a Professional-use license (a HASP Pro USB key or a
valid Pro digital-download product key). Demo and Home installs both report xplm_ProLicense_NotLicensed.
]]--

---@enum XPLMProLicenseStatus
local XPLMProLicenseStatus = {
    -- X-Plane has not finished its license check yet. Wait for
    -- XPLM_MSG_PRO_LICENSE_CHANGED.
    xplm_ProLicense_Unknown                  = 0,
    -- No Pro license is active.
    xplm_ProLicense_NotLicensed              = 1,
    -- A Pro license is active.
    xplm_ProLicense_Licensed                 = 2,
}
---@class _G
---@field XPLMProLicenseStatus XPLMProLicenseStatus

---@class _G
--- This routine returns the revision of both X-Plane and the XPLM DLL. All versions
--- are at least three-digit decimal numbers (e.g. 606 for version 6.06 of X-Plane); the current
--- revision of the XPLM is 400 (4.00). This routine also returns the host ID of the app
--- running us.
---
--- The most common use of this routine is to special-case around X-Plane version-specific
--- behavior.
---
---@field XPLMGetVersions fun(): { outXPlaneVersion: userdata, outXPLMVersion: userdata, outHostID: XPLMHostApplicationID }

---@class _G
--- This routine returns the langauge the sim is running in.
---
---@field XPLMGetLanguage fun(): XPLMLanguageCode

---@class _G
--- Returns whether X-Plane is currently running under a Professional-use license.
---
--- X-Plane finishes its license check after global plugins have received XPluginStart and XPluginEnable,
--- so from those callbacks a global plugin sees xplm_ProLicense_Unknown. Listen for
--- XPLM_MSG_PRO_LICENSE_CHANGED: it is broadcast once the check completes and again whenever the status
--- changes during the session (for example, the user enters a product key or a key expires). Aircraft
--- plugins load after the check completes and see a settled value immediately. If you see a settled value
--- in XPluginStart, do not wait for the message; the initial transition was broadcast before your plugin
--- loaded.
---
--- Call this only from the main thread.
---
---@field XPLMGetProLicenseStatus fun(): XPLMProLicenseStatus

---@class _G
--- This routine outputs a C-style string to the Log.txt file. The file is immediately flushed so you will
--- not lose data. (This does cause a performance penalty.)
---
--- Please do *not* leave routine diagnostic logging enabled in your shipping plugin. The X-Plane Log file is
--- shared by X-Plane and every plugin in the system, and plugins that (when functioning normally) print
--- verbose log output make it difficult for developers to find error conditions from other parts of the system.
---
---@field XPLMDebugString fun(inString: string)

---@class _G
--- This function displays the string in a translucent overlay over the current
--- display and also speaks the string if text-to-speech is enabled. The string
--- is spoken asynchronously, this function returns immediately. This function may
--- not speak or print depending on user preferences.
---
---@field XPLMSpeakString fun(inString: string)

---@class _G
--- Given a virtual key code (as defined in XPLMDefs.h) this routine returns
--- a human-readable string describing the character. This routine is provided
--- for showing users what keyboard mappings they have set up. The string
--- may read 'unknown' or be a blank or NULL string if the virtual key is unknown.
---
---@field XPLMGetVirtualKeyDescription fun(inVirtualKey: string): string

---@class _G
--- XPLMReloadScenery reloads the current set of scenery. You can use this
--- function in two typical ways: simply call it to reload the scenery, picking
--- up any new installed scenery, .env files, etc. from disk. Or, change
--- the lat/ref and lon/ref datarefs and then call this function to shift
--- the scenery environment.  This routine is equivalent to picking "reload scenery"
--- from the developer menu.
---
---@field XPLMReloadScenery fun()


-----------------------------------------------------------------------------
-- X-PLANE COMMAND MANAGEMENT
-----------------------------------------------------------------------------

--[[
   The command management APIs let plugins interact with the command-system in
   X-Plane, the abstraction behind keyboard presses and joystick buttons. This
   API lets you create new commands and modify the behavior (or get
   notification) of existing ones.
   
   X-Plane Command Phases
   ----------------------
   
   X-Plane commands are not instantaneous; they operate over a duration.
   (Think of a joystick button press - you can press, hold down, and then
   release the joystick button; X-Plane commands model this entire process.)
   
   An X-Plane command consists of three phases: a beginning, continuous
   repetition, and an ending. The command may be repeated zero times in its
   duration, followed by one command ending. Command begin and end messges are
   balanced, but a command may be bound to more than one event source (e.g. a
   keyboard key and a joystick button), in which case you may receive a second
   begin during before any end).
   
   When you issue commands in the plugin system, you *must* balance every call
   to XPLMCommandBegin with a call to XPLMCommandEnd with the same command
   reference.
   
   Command Behavior Modification
   -----------------------------
   
   You can register a callback to handle a command either before or after
   X-Plane does; if you receive the command before X-Plane you have the option
   to either let X-Plane handle the command or hide the command from X-Plane.
   This lets plugins both augment commands and replace them.
   
   If you register for an existing command, be sure that you are *consistent*
   in letting X-Plane handle or not handle the command; you are responsible
   for passing a *balanced* number of begin and end messages to X-Plane. (E.g.
   it is not legal to pass all the begin messages to X-Plane but hide all the
   end messages).
]]--

--[[
The phases of a command.
]]--

---@enum XPLMCommandPhase
local XPLMCommandPhase = {
    -- The command is being started.
    xplm_CommandBegin                        = 0,
    -- The command is continuing to execute.
    xplm_CommandContinue                     = 1,
    -- The command has ended.
    xplm_CommandEnd                          = 2,
}
---@class _G
---@field XPLMCommandPhase XPLMCommandPhase

--- A command ref is an opaque identifier for an X-Plane command. Command references stay the same for the life of your plugin but not between executions of X-Plane. Command refs are used to execute commands, create commands, and create callbacks for particular commands. Note that a command is not "owned" by a particular plugin. Since many plugins may participate in a command's execution, the command does not go away if the plugin that created it is unloaded.
---@class XPLMCommandRef : userdata
---@field private __XPLMCommandRef_marker any

--- A command callback is a function in your plugin that is called when a command is pressed. Your callback receives the command reference for the particular command, the phase of the command that is executing, and a reference pointer that you specify when registering the callback. Your command handler should return true to let processing of the command continue to other plugins and X-Plane, or false to halt processing, potentially bypassing X-Plane code.
---@alias XPLMCommandCallback_f fun(inCommand: XPLMCommandRef, inPhase: XPLMCommandPhase, inRefcon: any): boolean

---@class _G
--- XPLMFindCommand looks up a command by name, and returns its command reference or NULL if the command
--- does not exist.
---
---@field XPLMFindCommand fun(inName: string): XPLMCommandRef

---@class _G
--- XPLMCommandBegin starts the execution of a command, specified by its command reference. The command is
--- "held down" until XPLMCommandEnd is called.  You must balance each XPLMCommandBegin call with an XPLMCommandEnd
--- call.
---
---@field XPLMCommandBegin fun(inCommand: XPLMCommandRef)

---@class _G
--- XPLMCommandEnd ends the execution of a given command that was started with XPLMCommandBegin.  You must not
--- issue XPLMCommandEnd for a command you did not begin.
---
---@field XPLMCommandEnd fun(inCommand: XPLMCommandRef)

---@class _G
--- This executes a given command momentarily, that is, the command begins and ends immediately. This is the
--- equivalent of calling XPLMCommandBegin() and XPLMCommandEnd() back to back.
---
---@field XPLMCommandOnce fun(inCommand: XPLMCommandRef)

---@class _G
--- XPLMCreateCommand creates a new command for a given string. If the command already exists, the
--- existing command reference is returned. The description may appear in user interface contexts, such
--- as the joystick configuration screen.
---
---@field XPLMCreateCommand fun(inName: string, inDescription: string): XPLMCommandRef

---@class _G
--- XPLMRegisterCommandHandler registers a callback to be called when a command is executed. You provide
--- a callback with a reference pointer.
---
--- If inBefore is true, your command handler callback will be executed before X-Plane executes the command,
--- and returning 0 from your callback will disable X-Plane's processing of the command. If inBefore is
--- false, your callback will run after X-Plane. (You can register a single callback both before and after
--- a command.)
---
---@field XPLMRegisterCommandHandler fun(inComand: XPLMCommandRef, inHandler: XPLMCommandCallback_f, inBefore: boolean, inRefcon: any)

---@class _G
--- XPLMUnregisterCommandHandler removes a command callback registered with XPLMRegisterCommandHandler.
---
---@field XPLMUnregisterCommandHandler fun(inComand: XPLMCommandRef, inHandler: XPLMCommandCallback_f, inBefore: boolean, inRefcon: any)

