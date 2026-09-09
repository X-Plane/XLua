---@meta XPLMSound

-- The functions, typedefs, enums, and defines in this file are
-- installed into the Lua VM at startup by the host's add_xplm_to_interp()
-- call. Scripts do NOT need to require('XPLMSound') to access them; this file
-- exists solely as type metadata for lua-language-server / EmmyLua.

--[[
   Copyright 2005-2026 Laminar Research, Sandy Barbour and Ben Supnik All
   rights reserved.  See license.txt for usage. X-Plane SDK Version: 4.0.0
]]--

-----------------------------------------------------------------------------
-- XPLMSound
-----------------------------------------------------------------------------

--[[
   This provides a minimal interface into the FMOD audio system. On the
   simplest level, you can request that X-Plane plays an in-memory audio
   buffer. This will work without linking to FMOD yourself. If you want to do
   anything more, such as modifying the sound, or loading banks and triggering
   your own events, you can get a pointer to the FMOD Studio instance.
]]--

require("XPLMDefs")

