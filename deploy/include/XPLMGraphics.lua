-- Use require('XPLMGraphics') to access these functions.

--[[
   Copyright 2005-2022 Laminar Research, Sandy Barbour and Ben Supnik All
   rights reserved.  See license.txt for usage. X-Plane SDK Version: 4.0.0
]]--

-----------------------------------------------------------------------------
-- XPLMGraphics
-----------------------------------------------------------------------------

--[[
   A few notes on coordinate systems:
   
   X-Plane uses three kinds of coordinates.  Global coordinates are specified
   as latitude, longitude and elevation.  This coordinate system never changes
   but is not very precise.
   
   OpenGL (or 'local') coordinates are cartesian and move with the aircraft. 
   They offer more precision and are used for 3-d OpenGL drawing.  The X axis
   is aligned east-west with positive X meaning east.  The Y axis is aligned
   straight up and down at the point 0,0,0 (but since the Earth is round it is
   not truly straight up and down at other points).  The Z axis is aligned
   north-south at 0, 0, 0 with positive Z pointing south (but since the Earth
   is round it isn't exactly north-south as you move east or west of 0, 0, 0).
   One unit is one meter and the point 0,0,0 is on the surface of the Earth at
   sea level for some latitude and longitude picked by the sim such that the
   user's aircraft is reasonably nearby.
   
   2-d Panel coordinates are 2d, with the X axis horizontal and the Y axis
     vertical. The point 0,0 is the bottom left and 1024,768 is the upper
     right of the screen. This is true no matter what resolution the user's
     monitor is in; when running in higher resolution, graphics will be
     scaled.
   
   Use X-Plane's routines to convert between global and local coordinates.  Do
   not attempt to do this conversion yourself; the precise 'roundness' of
   X-Plane's physics model may not match your own, and (to make things
   weirder) the user can potentially customize the physics of the current
   planet.
]]--

#include "XPLMDefs.h"
require("XPLMDefs")

--[[
   XLuaWorldToLocal
   
                   This routine translates coordinates from latitude,
                   longitude, and altitude to local scene coordinates.
                   Latitude and longitude are in decimal degrees, and altitude
                   is in meters MSL (mean sea level).  The XYZ coordinates are
                   in meters in the local OpenGL coordinate system.
]]--
-- Returns   :  Table { ["outX"], ["outY"], ["outZ"] }
-- Parameters:
--   inLatitude (number)
--   inLongitude (number)
--   inAltitude (number)

--[[
   XLuaLocalToWorld
   
                   This routine translates a local coordinate triplet back
                   into latitude, longitude, and altitude.  Latitude and
                   longitude are in decimal degrees, and altitude is in meters
                   MSL (mean sea level).  The XYZ coordinates are in meters in
                   the local OpenGL coordinate system.
   
                   NOTE: world coordinates are less precise than local
                   coordinates; you should try to avoid round tripping from
                   local to world and back.
]]--
-- Returns   :  Table { ["outLatitude"], ["outLongitude"], ["outAltitude"] }
-- Parameters:
--   inX (number)
--   inY (number)
--   inZ (number)

--[[
X-Plane features some fixed-character fonts.  Each font may have its own metrics.

WARNING: Some of these fonts are no longer supported or may have changed geometries.
For maximum copmatibility, see the comments below.

Note: X-Plane 7 supports proportional-spaced fonts.  Since no measuring routine
is available yet, the SDK will normally draw using a fixed-width font.  You can
use a dataref to enable proportional font drawing on XP7 if you want to.
]]--

XPLMFontID = {
    -- Mono-spaced font for user interface.  Available in all versions of the SDK.
    xplmFont_Basic                           = 0,
    -- Deprecated, do not use.
    xplmFont_Menus                           = 1,
    -- Deprecated, do not use.
    xplmFont_Metal                           = 2,
    -- Deprecated, do not use.
    xplmFont_Led                             = 3,
    -- Deprecated, do not use.
    xplmFont_LedWide                         = 4,
    -- Deprecated, do not use.
    xplmFont_PanelHUD                        = 5,
    -- Deprecated, do not use.
    xplmFont_PanelEFIS                       = 6,
    -- Deprecated, do not use.
    xplmFont_PanelGPS                        = 7,
    -- Deprecated, do not use.
    xplmFont_RadiosGA                        = 8,
    -- Deprecated, do not use.
    xplmFont_RadiosBC                        = 9,
    -- Deprecated, do not use.
    xplmFont_RadiosHM                        = 10,
    -- Deprecated, do not use.
    xplmFont_RadiosGANarrow                  = 11,
    -- Deprecated, do not use.
    xplmFont_RadiosBCNarrow                  = 12,
    -- Deprecated, do not use.
    xplmFont_RadiosHMNarrow                  = 13,
    -- Deprecated, do not use.
    xplmFont_Timer                           = 14,
    -- Deprecated, do not use.
    xplmFont_FullRound                       = 15,
    -- Deprecated, do not use.
    xplmFont_SmallRound                      = 16,
    -- Deprecated, do not use.
    xplmFont_Menus_Localized                 = 17,
    -- Proportional UI font.
    xplmFont_Proportional                    = 18,
}

--[[
   XLuaDrawString
   
   This routine draws a NULL terminated string in a given font.  Pass in the
   lower left pixel that the character is to be drawn onto.  Also pass the
   character and font ID. This function returns the x offset plus the width of
   all drawn characters. The color to draw in is specified as a pointer to an
   array of three floating point colors, representing RGB intensities from 0.0
   to 1.0.
]]--
-- Returns   : Nothing.
-- Parameters:
--   inColorRGB (array<number|float>[3])
--   inXOffset (integer)
--   inYOffset (integer)
--   inChar (string)
--   inWordWrapWidth (integer)
--   inFontID (integer)

--[[
   XLuaDrawNumber
   
   This routine draws a number similar to the digit editing fields in
   PlaneMaker and data output display in X-Plane.  Pass in a color, a
   position, a floating point value, and formatting info.  Specify how many
   integer and how many decimal digits to show and whether to show a sign, as
   well as a character set. This routine returns the xOffset plus width of the
   string drawn.
]]--
-- Returns   : Nothing.
-- Parameters:
--   inColorRGB (array<number|float>[3])
--   inXOffset (integer)
--   inYOffset (integer)
--   inValue (number)
--   inDigits (integer)
--   inDecimals (integer)
--   inShowSign (boolean)
--   inFontID (integer)

--[[
   XLuaGetFontDimensions
   
   This routine returns the width and height of a character in a given font.
   It also tells you if the font only supports numeric digits.  Pass NULL if
   you don't need a given field.  Note that for a proportional font the width
   will be an arbitrary, hopefully average width.
]]--
-- Returns   :  Table { ["outCharWidth"], ["outCharHeight"], ["outDigitsOnly"] }
-- Parameters:
--   inFontID (integer)

--[[
   XLuaMeasureString
   
   This routine returns the width in pixels of a string using a given font. 
   The string is passed as a pointer plus length (and does not need to be null
   terminated); this is used to allow for measuring substrings. The return
   value is floating point; it is possible that future font drawing may allow
   for fractional pixels.
]]--
-- Returns   : number
-- Parameters:
--   inFontID (integer)
--   inChar (string)
--   inNumChars (integer)

