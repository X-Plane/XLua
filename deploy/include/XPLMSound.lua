-- Use require('XPLMSound') to access these functions.

--[[
   Copyright 2005-2022 Laminar Research, Sandy Barbour and Ben Supnik All
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

#include "XPLMDefs.h"
#include "fmod.hpp"
#include "fmod_studio.hpp"
require("XPLMDefs")

