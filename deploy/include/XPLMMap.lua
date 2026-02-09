-- Use require('XPLMMap') to access these functions.

--[[
   Copyright 2005-2026 Laminar Research, Sandy Barbour and Ben Supnik All
   rights reserved.  See license.txt for usage. X-Plane SDK Version: 4.0.0
]]--

-----------------------------------------------------------------------------
-- XPLMMap
-----------------------------------------------------------------------------

--[[
   This API allows you to create new layers within X-Plane maps. Your layers
   can draw arbitrary OpenGL, but they conveniently also have access to
   X-Plane's built-in icon and label drawing functions.
   
   As of X-Plane 11, map drawing happens in three stages:
   
   1. backgrounds and "fill",
   2. icons, and
   3. labels.
   
   Thus, all background drawing gets layered beneath all icons, which likewise
   get layered beneath all labels. Within each stage, the map obeys a
   consistent layer ordering, such that "fill" layers (layers that cover a
   large amount of map area, like the terrain and clouds) appear beneath
   "markings" layers (like airport icons). This ensures that layers with fine
   details don't get obscured by layers with larger details.
   
   The XPLM map API reflects both aspects of this draw layering: you can
   register a layer as providing either markings or fill, and X-Plane will
   draw your fill layers beneath your markings layers (regardless of
   registration order). Likewise, you are guaranteed that your layer's icons
   (added from within an icon callback) will go above your layer's OpenGL
   drawing, and your labels will go above your icons.
   
   The XPLM guarantees that all plugin-created fill layers go on top of all
   native X-Plane fill layers, and all plugin-created markings layers go on
   top of all X-Plane markings layers (with the exception of the aircraft
   icons). It also guarantees that the draw order of your own plugin's layers
   will be consistent. But, for layers created by different plugins, the only
   guarantee is that we will draw all of one plugin's layers of each type
   (fill, then markings), then all of the others'; we don't guarantee which
   plugin's fill and markings layers go on top of the other's.
   
   As of X-Plane 11, maps use true cartographic projections for their drawing,
   and different maps may use different projections. For that reason, all
   drawing calls include an opaque handle for the projection you should use to
   do the drawing. Any time you would draw at a particular latitude/longitude,
   you'll need to ask the projection to translate that position into "map
   coordinates." (Note that the projection is guaranteed not to change between
   calls to your prepare-cache hook, so if you cache your map coordinates
   ahead of time, there's no need to re-project them when you actually draw.)
   
   In addition to mapping normal latitude/longitude locations into map
   coordinates, the projection APIs also let you know the current heading for
   north. (Since X-Plane 11 maps can rotate to match the heading of the user's
   aircraft, it's not safe to assume that north is at zero degrees rotation.)
]]--

require("XPLMDefs")

--[[
Indicates the visual style being drawn by the map. In X-Plane, the user can choose between a number of
map types, and different map types may have use a different visual representation for the same elements
(for instance, the visual style of the terrain layer changes drastically between the VFR and IFR layers),
or certain layers may be disabled entirely in some map types (e.g., localizers are only visible in the
IFR low-enroute style).
]]--

XPLMMapStyle = {
    xplm_MapStyle_VFR_Sectional              = 0,
    xplm_MapStyle_IFR_LowEnroute             = 1,
    xplm_MapStyle_IFR_HighEnroute            = 2,
}

--[[
Indicates the type of map layer you are creating. Fill layers will always be drawn beneath markings layers.]]--

XPLMMapLayerType = {
    -- A layer that draws "fill" graphics, like weather patterns, terrain, etc.
    -- Fill layers frequently cover a large portion of the visible map area.
    xplm_MapLayer_Fill                       = 0,
    -- A layer that provides markings for particular map features, like NAVAIDs,
    -- airports, etc. Even dense markings layers cover a small portion of the
    -- total map area.
    xplm_MapLayer_Markings                   = 1,
}

--[[
   XLuaCreateMapLayer
   
   This routine creates a new map layer. You pass in an XPLMCreateMapLayer_t
   structure with all of the fields defined.  You must set the structSize of
   the structure to the size of the actual structure you used.
   
   Returns NULL if the layer creation failed. This happens most frequently
   because the map you specified in your
   XPLMCreateMapLayer_t::mapToCreateLayerIn field doesn't exist (that is, if
   XPLMMapExists() returns 0 for the specified map). You can use
   XPLMRegisterMapCreationHook() to get a notification each time a new map is
   opened in X-Plane, at which time you can create layers in it.
]]--
--[[
    Returns   : userdata<XPLMMapLayerID>

    Parameters:
     inParams                               (XPLMCreateMapLayer_t)

]]--

--[[
   XLuaDestroyMapLayer
   
   Destroys a map layer you created (calling your
   XPLMMapWillBeDeletedCallback_f if applicable). Returns true if a deletion
   took place.
]]--
--[[
    Returns   : boolean

    Parameters:
     inLayer                                (XPLMMapLayerID)

]]--

--[[
   XLuaRegisterMapCreationHook
   
   Registers your callback to receive a notification each time a new map is
   constructed in X-Plane. This callback is the best time to add your custom
   map layer using XPLMCreateMapLayer().
   
   Note that you will not be notified about any maps that already exist---you
   can use XPLMMapExists() to check for maps that were created previously.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     callback                               (XPLMMapCreatedCallback_f)
     inRefcon                               (Any reference value)

]]--

--[[
   XLuaMapExists
   
   Returns true if the map with the specified identifier already exists in
   X-Plane. In that case, you can safely call XPLMCreateMapLayer() specifying
   that your layer should be added to that map.
]]--
--[[
    Returns   : boolean

    Parameters:
     mapIdentifier                          (string)

]]--

--[[
Indicates whether a map element should be match its rotation to the map itself, or to the user interface.
For instance, the map itself may be rotated such that "up" matches the user's aircraft, but you may want
to draw a text label such that it is always rotated zero degrees relative to the user's perspective.
In that case, you would have it draw with UI orientation.
]]--

XPLMMapOrientation = {
    -- Orient such that a 0 degree rotation matches the map's north
    xplm_MapOrientation_Map                  = 0,
    -- Orient such that a 0 degree rotation is "up" relative to the user interface
    xplm_MapOrientation_UI                   = 1,
}

--[[
   XLuaDrawMapIconFromSheet
   
   Enables plugin-created map layers to draw PNG icons using X-Plane's
   built-in icon drawing functionality. Only valid from within an
   XPLMIconDrawingCallback_t (but you can request an arbitrary number of icons
   to be drawn from within your callback).
   
   X-Plane will automatically manage the memory for your texture so that it
   only has to be loaded from disk once as long as you continue drawing it
   per-frame. (When you stop drawing it, the memory may purged in a "garbage
   collection" pass, require a load from disk in the future.)
   
   Instead of having X-Plane draw a full PNG, this method allows you to use UV
   coordinates to request a portion of the image to be drawn. This allows you
   to use a single texture load (of an icon sheet, for example) to draw many
   icons. Doing so is much more efficient than drawing a dozen different small
   PNGs.
   
   The UV coordinates used here treat the texture you load as being comprised
   of a number of identically sized "cells". You specify the width and height
   in cells (ds and dt, respectively), as well as the coordinates within the
   cell grid for the sub-image you'd like to draw.
   
   Note that you can use different ds and dt values in subsequent calls with
   the same texture sheet. This enables you to use icons of different sizes in
   the same sheet if you arrange them properly in the PNG.
   
   This function is only valid from within an XPLMIconDrawingCallback_t (but
   you can request an arbitrary number of icons to be drawn from within your
   callback).
]]--
--[[
    Returns   : Nothing.

    Parameters:
     layer                                  (XPLMMapLayerID)
     inPngPath                              (string)
     s                                      (integer)
     t                                      (integer)
     ds                                     (integer)
     dt                                     (integer)
     mapX                                   (number)
     mapY                                   (number)
     orientation                            (XPLMMapOrientation)
     rotationDegrees                        (number)
     mapWidth                               (number)

]]--

--[[
   XLuaDrawMapLabel
   
   Enables plugin-created map layers to draw text labels using X-Plane's
   built-in labeling functionality. Only valid from within an
   XPLMMapLabelDrawingCallback_f (but you can request an arbitrary number of
   text labels to be drawn from within your callback).
]]--
--[[
    Returns   : Nothing.

    Parameters:
     layer                                  (XPLMMapLayerID)
     inText                                 (string)
     mapX                                   (number)
     mapY                                   (number)
     orientation                            (XPLMMapOrientation)
     rotationDegrees                        (number)

]]--

--[[
   XLuaMapProject
   
   Projects a latitude/longitude into map coordinates. This is the inverse of
   XPLMMapUnproject().
   
   Only valid from within a map layer callback (one of
   XPLMMapPrepareCacheCallback_f, XPLMMapDrawingCallback_f,
   XPLMMapIconDrawingCallback_f, or XPLMMapLabelDrawingCallback_f.)
]]--
--[[
    Returns   : Table {
          ["outX"]                          (number),
          ["outY"]                          (number)
    }

    Parameters:
     projection                             (XPLMMapProjectionID)
     latitude                               (number)
     longitude                              (number)

]]--

--[[
   XLuaMapUnproject
   
   Transforms map coordinates back into a latitude and longitude. This is the
   inverse of XPLMMapProject().
   
   Only valid from within a map layer callback (one of
   XPLMMapPrepareCacheCallback_f, XPLMMapDrawingCallback_f,
   XPLMMapIconDrawingCallback_f, or XPLMMapLabelDrawingCallback_f.)
]]--
--[[
    Returns   : Table {
          ["outLatitude"]                   (number),
          ["outLongitude"]                  (number)
    }

    Parameters:
     projection                             (XPLMMapProjectionID)
     mapX                                   (number)
     mapY                                   (number)

]]--

--[[
   XLuaMapScaleMeter
   
   Returns the number of map units that correspond to a distance of one meter
   at a given set of map coordinates.
   
   Only valid from within a map layer callback (one of
   XPLMMapPrepareCacheCallback_f, XPLMMapDrawingCallback_f,
   XPLMMapIconDrawingCallback_f, or XPLMMapLabelDrawingCallback_f.)
]]--
--[[
    Returns   : number

    Parameters:
     projection                             (XPLMMapProjectionID)
     mapX                                   (number)
     mapY                                   (number)

]]--

--[[
   XLuaMapGetNorthHeading
   
   Returns the heading (in degrees clockwise) from the positive Y axis in the
   cartesian mapping coordinate system to true north at the point passed in. 
   You can use it as a clockwise rotational offset to align icons and other
   2-d drawing with true north on the map, compensating for rotations in the
   map due to projection.
   
   Only valid from within a map layer callback (one of
   XPLMMapPrepareCacheCallback_f, XPLMMapDrawingCallback_f,
   XPLMMapIconDrawingCallback_f, or XPLMMapLabelDrawingCallback_f.)
]]--
--[[
    Returns   : number

    Parameters:
     projection                             (XPLMMapProjectionID)
     mapX                                   (number)
     mapY                                   (number)

]]--

