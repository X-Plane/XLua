---@meta XPLMPanelGraphics

-- The functions, typedefs, enums, and defines in this file are
-- installed into the Lua VM at startup by the host's add_xplm_to_interp()
-- call. Scripts do NOT need to require('XPLMPanelGraphics') to access them; this file
-- exists solely as type metadata for lua-language-server / EmmyLua.

--[[
   Copyright 2005-2026 Laminar Research, Sandy Barbour and Ben Supnik All
   rights reserved.  See license.txt for usage. X-Plane SDK Version: 4.0.0
]]--

-----------------------------------------------------------------------------
-- XPLMPanelGraphics
-----------------------------------------------------------------------------

--[[
   The XPLMPanelGraphics API provides a 2-D drawing toolkit for avionics
   screens and instrument panels. You use these routines from within an
   avionics drawing callback (registered via XPLMRegisterAvionicsCallbacksEx
   or XPLMCreateAvionicsEx) to draw lines, polygons, text, and images onto the
   panel surface.
   
   All drawing is expressed in panel coordinates: X increases to the right and
   Y increases upward. Drawing commands are buffered and rendered by X-Plane
   at the end of your callback; you do not manage OpenGL state directly.
   
   Drawing State
   ---
   
   Panel graphics functions modify a shared drawing state that includes a
   transformation matrix, a scissor (clip) rectangle, and a stencil mask. Each
   of these has a push/pop stack so you can save and restore state around
   localized drawing operations.
   
   Drawing Order
   ---
   
   Primitives are drawn in the order you submit them. Later drawing calls
   paint over earlier ones. Use the retained-drawing API to record a sequence
   of draw calls once and replay it efficiently on subsequent frames.
]]--

require("XPLMDefs")
require("XPLMUtilities")
require("XPLMDisplay")

--- A 2-D vertex with an x and y position in panel coordinates.
---@class XPLMVertex_t
---@field x number
---@field y number

--- A 2-D vertex with an x and y position in panel coordinates and a per-vertex color. Use this struct with the "c" drawing variants to assign a different color to each vertex; colors are interpolated across the primitive.
---@class XPLMVertexColor_t
---@field x number
---@field y number
---@field color integer

---@class _G
--- This function packs four floating-point color components into a single uint32_t
--- suitable for use with all panel graphics drawing routines. Each component is in
--- the range 0.0 to 1.0 and is clamped before packing. The returned value is in
--- ABGR byte order (alpha in the high byte, red in the low byte).
---
---@field XPLMMakeColor fun(red: number, green: number, blue: number, alpha: number): integer

---@class _G
--- This function draws disconnected line segments. Every pair of vertices defines
--- one segment: the first segment runs from vertices[0] to vertices[1], the second
--- from vertices[2] to vertices[3], and so on.
---
--- - count: the number of vertices. Should be even; an odd trailing vertex is
---   ignored.
---
---@field XPLMLines fun(color: integer, vertices: XPLMVertex_t[], count: integer)

---@class _G
--- This function draws disconnected line segments with a caller-specified line
--- width. Vertex interpretation is the same as XPLMLines.
---
--- - lineWidth: the line width in pixels.
---
---@field XPLMLinesWithWidth fun(color: integer, lineWidth: number, vertices: XPLMVertex_t[], count: integer)

---@class _G
--- This function draws disconnected line segments with per-vertex colors.
--- Vertex interpretation is the same as XPLMLines; colors are interpolated along
--- each segment.
---
---@field XPLMLinesc fun(vertices: XPLMVertexColor_t[], count: integer)

---@class _G
--- This function draws disconnected line segments with per-vertex colors and a
--- caller-specified line width.
---
--- - lineWidth: the line width in pixels.
---
---@field XPLMLinescWithWidth fun(lineWidth: number, vertices: XPLMVertexColor_t[], count: integer)

---@class _G
--- This function draws disconnected dashed line segments. Vertex interpretation
--- is the same as XPLMLines. The dash pattern alternates between drawn and
--- undrawn segments of equal length.
---
--- - dashLength: the length of each dash and gap, in pixels.
--- - lineWidth: the line width in pixels.
---
---@field XPLMLinesStipple fun(color: integer, pts: XPLMVertex_t[], count: integer, dashLength: number, lineWidth: number)

---@class _G
--- This function draws a connected line strip. Vertices are connected in order:
--- a segment from vertices[0] to vertices[1], then from vertices[1] to
--- vertices[2], and so on. The last vertex is not connected back to the first.
---
---@field XPLMLineStrip fun(color: integer, pts: XPLMVertex_t[], count: integer)

---@class _G
--- This function draws a connected line strip with a caller-specified line width.
--- Vertex interpretation is the same as XPLMLineStrip.
---
--- - lineWidth: the line width in pixels.
---
---@field XPLMLineStripWithWidth fun(color: integer, lineWidth: number, pts: XPLMVertex_t[], count: integer)

---@class _G
--- This function draws a connected line strip with per-vertex colors. Vertex
--- interpretation is the same as XPLMLineStrip; colors are interpolated along
--- each segment.
---
---@field XPLMLineStripc fun(pts: XPLMVertexColor_t[], count: integer)

---@class _G
--- This function draws a connected line strip with per-vertex colors and a
--- caller-specified line width.
---
--- - lineWidth: the line width in pixels.
---
---@field XPLMLineStripcWithWidth fun(lineWidth: number, pts: XPLMVertexColor_t[], count: integer)

---@class _G
--- This function draws a connected dashed line strip. Vertex interpretation is
--- the same as XPLMLineStrip. The dash pattern alternates between drawn and
--- undrawn segments of equal length.
---
--- - dashLength: the length of each dash and gap, in pixels.
--- - lineWidth: the line width in pixels.
---
---@field XPLMLineStripStipple fun(color: integer, pts: XPLMVertex_t[], count: integer, dashLength: number, lineWidth: number)

---@class _G
--- This function draws a closed line loop. Vertices are connected in order, and
--- the last vertex is automatically connected back to the first, forming a closed
--- shape. The interior is not filled.
---
---@field XPLMLineLoop fun(color: integer, pts: XPLMVertex_t[], count: integer)

---@class _G
--- This function draws a closed line loop with a caller-specified line width.
--- Vertex interpretation is the same as XPLMLineLoop.
---
--- - lineWidth: the line width in pixels.
---
---@field XPLMLineLoopWithWidth fun(color: integer, lineWidth: number, pts: XPLMVertex_t[], count: integer)

---@class _G
--- This function draws a closed line loop with per-vertex colors. Vertex
--- interpretation is the same as XPLMLineLoop; colors are interpolated along
--- each segment.
---
---@field XPLMLineLoopc fun(pts: XPLMVertexColor_t[], count: integer)

---@class _G
--- This function draws a closed line loop with per-vertex colors and a
--- caller-specified line width.
---
--- - lineWidth: the line width in pixels.
---
---@field XPLMLineLoopcWithWidth fun(lineWidth: number, pts: XPLMVertexColor_t[], count: integer)

---@class _G
--- This function draws a closed dashed line loop. Vertex interpretation is
--- the same as XPLMLineLoop. The dash pattern alternates between drawn and
--- undrawn segments of equal length.
---
--- - dashLength: the length of each dash and gap, in pixels.
--- - lineWidth: the line width in pixels.
---
---@field XPLMLineLoopStipple fun(color: integer, pts: XPLMVertex_t[], count: integer, dashLength: number, lineWidth: number)

---@class _G
--- This function draws a filled convex polygon. The vertices define the outline
--- of the polygon, and the interior is filled with the specified color.
---
--- - count: the number of vertices. You must provide at least 3 vertices.
---
---@field XPLMPolygon fun(color: integer, vertices: XPLMVertex_t[], count: integer)

---@class _G
--- This function draws a filled convex polygon with per-vertex colors. Colors
--- are interpolated across the polygon interior.
---
---@field XPLMPolygonc fun(vertices: XPLMVertexColor_t[], count: integer)

---@class _G
--- This function draws a series of connected filled quadrilaterals. Vertices
--- are taken in pairs: the first quad is formed by vertices[0], vertices[1],
--- vertices[2], vertices[3]; the next quad shares its leading edge with the
--- previous one, formed by vertices[2], vertices[3], vertices[4], vertices[5];
--- and so on.
---
--- - count: the number of vertices. Must be even and at least 4.
---
---@field XPLMQuadstrip fun(color: integer, vertices: XPLMVertex_t[], count: integer)

---@class _G
--- This function draws a quad strip with per-vertex colors. Vertex
--- interpretation is the same as XPLMQuadstrip; colors are interpolated across
--- each quad.
---
---@field XPLMQuadstripc fun(vertices: XPLMVertexColor_t[], count: integer)

--[[
This enumeration specifies the character set for a font created with
XPLMCreateFont. The character set determines which glyphs are rasterized
and available for drawing.
]]--

---@enum XPLMCharSet_t
local XPLMCharSet_t = {
    -- Digits 0-9 and common numeric punctuation only.
    xplm_CharSetDigits                       = 0,
    -- The printable ASCII character range (codes 32-126).
    xplm_CharSetASCII                        = 1,
    -- Full Unicode support; glyphs are rasterized on demand.
    xplm_CharSetUnicode                      = 2,
}
---@class _G
---@field XPLMCharSet_t XPLMCharSet_t

--[[
This enumeration specifies horizontal text justification for the font
drawing routines. The x and y position you pass to a drawing function is
the baseline of the text at the anchor point determined by justification:
left-aligned text anchors at the left edge, centered text at the midpoint,
and right-aligned text at the right edge.
]]--

---@enum XPLMJustification_t
local XPLMJustification_t = {
    -- Left-justified; x is the left edge of the string.
    xplm_JustLeft                            = 0,
    -- Center-justified; x is the horizontal center of the string.
    xplm_JustCenter                          = 1,
    -- Right-justified; x is the right edge of the string.
    xplm_JustRight                           = 2,
}
---@class _G
---@field XPLMJustification_t XPLMJustification_t

--- XPLMFontMetrics_t receives font measurement data from XPLMFontGetMetrics. The structure may be expanded in future SDKs - always set structSize to the size of your structure in bytes.
---@class XPLMFontMetrics_t
---@field structSize integer
---@field lineHeight number
---@field lineAscent number
---@field lineDescent number

--- An opaque handle to a font created by XPLMCreateFont. Pass this handle to the font measurement and drawing routines. Destroy the handle with XPLMDestroyFont when you are done with it.
---@class XPLMFontHandle : userdata
---@field private __XPLMFontHandle_marker any

---@class _G
--- This function creates a new font handle. The character set determines which
--- glyphs are available for rendering. After creating the font, add one or more
--- TrueType faces with XPLMFontAddFace before drawing.
---
--- Returns an opaque font handle.
---
---@field XPLMCreateFont fun(charset: XPLMCharSet_t): XPLMFontHandle

---@class _G
--- This function destroys a font handle and frees all associated resources.
---
---@field XPLMDestroyFont fun(font: XPLMFontHandle)

---@class _G
--- This function adds a TrueType font face to an existing font handle. You may
--- add multiple faces to a single font to provide fallback glyphs; if a glyph
--- is not found in the first face, subsequent faces are searched in the order
--- they were added.
---
--- - ttf_path: a file system path to a .ttf or .otf font file.
---
--- Returns 1 if the face was loaded and added, or 0 if it could not be. When
--- this returns 0 the font is left exactly as it was, so you can try another
--- path, and a message explaining what went wrong is sent to your error
--- callback (see XPLMSetErrorCallback) and written to Log.txt.
---
--- Drawing with a font that has no faces draws nothing; it is not an error.
---
---@field XPLMFontAddFace fun(font: XPLMFontHandle, ttf_path: string): boolean

---@class _G
--- This function returns line metrics for a font at a given size. The metrics
--- describe the vertical dimensions of a line of text and are useful for
--- computing text layout.
---
--- - fontSize: the font size in pixels.
--- - outMetrics: receives the computed metrics. You must set outMetrics->structSize
---   before calling.
---
---@field XPLMFontGetMetrics fun(font: XPLMFontHandle, fontSize: number): { outMetrics: XPLMFontMetrics_t }

---@class _G
--- This function returns the width in pixels that a string would occupy if
--- drawn at the given font size. The string is not drawn.
---
--- Returns the horizontal advance width, in pixels.
---
---@field XPLMFontMeasureString fun(font: XPLMFontHandle, fontSize: number, string: string): number

---@class _G
--- This function calculates how many lines a string would occupy if word-wrapped
--- to the specified width at the given font size.
---
--- Returns the number of lines.
---
---@field XPLMFontGetLineCount fun(font: XPLMFontHandle, fontSize: number, string: string, width: number): integer

---@class _G
--- This function returns the number of characters from the beginning of a
--- string that fit within the specified width at the given font size. Characters
--- are measured left to right.
---
--- Returns a character count.
---
---@field XPLMFontFitForward fun(font: XPLMFontHandle, fontSize: number, string: string, width: number): integer

---@class _G
--- This function returns the number of characters in the input string that must be
--- skipped to fit the reset of the string into the specified space. This is useful for
--- right-aligning a truncated string.
---
--- Returns a character count - the number of characters that must be removed to fit.
---
---@field XPLMFontFitReverse fun(font: XPLMFontHandle, fontSize: number, string: string, width: number): integer

---@class _G
--- This function draws a null-terminated string at the specified position with
--- the given font, size, color, and justification. The x and y coordinates
--- specify the baseline position at the justification anchor point.
---
--- - fontSize: the font size in pixels.
--- - x, y: the anchor position of the baseline, in panel coordinates.
---
---@field XPLMFontDrawString fun(font: XPLMFontHandle, color: integer, fontSize: number, x: number, y: number, string: string, justification: XPLMJustification_t)

---@class _G
--- This function draws a null-terminated string using fixed character spacing
--- instead of the font's natural proportional spacing. Each character occupies
--- exactly fixedSpacing pixels horizontally, regardless of the glyph's actual
--- width. This is useful for numeric readouts where digits must not shift as
--- values change.
---
--- - fontSize: the font size in pixels.
--- - x, y: the anchor position of the baseline, in panel coordinates.
--- - fixedSpacing: the horizontal advance per character, in pixels.
---
---@field XPLMFontDrawStringFixedSpacing fun(font: XPLMFontHandle, color: integer, fontSize: number, x: number, y: number, string: string, fixedSpacing: integer, justification: XPLMJustification_t)

---@class _G
--- This function draws a null-terminated string with automatic word wrapping.
--- Text is broken at word boundaries to fit within the specified wrap width.
--- Lines are stacked downward from the initial y position, spaced by the font's
--- line height.
---
--- - fontSize: the font size in pixels.
--- - x, y: the anchor position of the first line's baseline, in panel coordinates.
--- - wrapWidth: the maximum line width in pixels before wrapping.
---
---@field XPLMFontDrawStringWordWrapped fun(font: XPLMFontHandle, color: integer, fontSize: number, x: number, y: number, string: string, wrapWidth: integer, justification: XPLMJustification_t)

---@class _G
--- This function draws a null-terminated string rotated by the specified angle
--- around the anchor point. The anchor point is determined by x, y, and the
--- justification, just as in XPLMFontDrawString.
---
--- - fontSize: the font size in pixels.
--- - x, y: the anchor position of the baseline, in panel coordinates.
--- - angle: the rotation angle in degrees, positive clockwise.
---
---@field XPLMFontDrawStringRotated fun(font: XPLMFontHandle, color: integer, fontSize: number, x: number, y: number, string: string, angle: number, justification: XPLMJustification_t)

--- An opaque handle to a texture atlas. Create one with XPLMCreateTextureAtlas and destroy it with XPLMDestroyTextureAtlas.
---@class XPLMTextureAtlasRef : userdata
---@field private __XPLMTextureAtlasRef_marker any

--- A vertex for textured mesh drawing. Combines a position in panel coordinates with normalized texture coordinates within the image. Texture coordinates are always relative to the image you are drawing, never to the atlas sheet it happens to be packed into. This is true for both XPLMTextureAtlasDrawMesh and XPLMTextureSourceDrawMesh, so the same vertex array means the same thing to either one.
---@class XPLMTextureVertex_t
---@field x number
---@field y number
---@field s number
---@field t number

---@class _G
--- This function creates a new, empty texture atlas. After creating the atlas,
--- add images with the XPLMTextureAtlasAddImage or XPLMTextureAtlasAddImageFile
--- family of functions, then call XPLMTextureAtlasBake before drawing.
---
--- Returns an opaque atlas handle.
---
---@field XPLMCreateTextureAtlas fun(): XPLMTextureAtlasRef

---@class _G
--- This function destroys a texture atlas and frees all associated GPU and CPU
--- resources.
---
---@field XPLMDestroyTextureAtlas fun(inTextureAtlas: XPLMTextureAtlasRef)

---@class _G
--- This function loads a PNG image file and adds it to the atlas as a single
--- image. Call this before XPLMTextureAtlasBake.
---
--- - inImageFilePath: the file system path to a PNG file.
---
--- Returns the zero-based image index assigned to this image.
---
---@field XPLMTextureAtlasAddImageFile fun(inTextureAtlas: XPLMTextureAtlasRef, inImageFilePath: string): integer

---@class _G
--- This function loads a PNG image file and subdivides it into a grid of cells,
--- adding each cell to the atlas as a separate image. This is useful for sprite
--- sheets and image strip assets. Call this before XPLMTextureAtlasBake.
---
--- - inImageFilePath: the file system path to a PNG file.
--- - inCellsX: the number of columns to divide the image into.
--- - inCellsY: the number of rows to divide the image into.
---
--- Returns the zero-based image index of the first cell (top-left). Subsequent
--- cells are numbered in row-major order: index + y * inCellsX + x.
---
---@field XPLMTextureAtlasAddImageFileSet fun(inTextureAtlas: XPLMTextureAtlasRef, inImageFilePath: string, inCellsX: integer, inCellsY: integer): integer

---@class _G
--- This function adds a single image from raw pixel data to the atlas. The
--- pixel data must be RGBA format, 4 bytes per pixel, with rows ordered from
--- top to bottom. Call this before XPLMTextureAtlasBake.
---
--- - inImage: pointer to the raw RGBA pixel data.
--- - inWidth: the image width in pixels.
--- - inHeight: the image height in pixels.
---
--- Returns the zero-based image index assigned to this image.
---
---@field XPLMTextureAtlasAddImage fun(inTextureAtlas: XPLMTextureAtlasRef, inImage: userdata, inWidth: integer, inHeight: integer): integer

---@class _G
--- This function packs all previously added images into a GPU texture. You must
--- call this after adding all images and before any draw calls. Once baked, you
--- cannot add more images to the atlas.
---
---@field XPLMTextureAtlasBake fun(inTextureAtlas: XPLMTextureAtlasRef)

---@class _G
--- This function returns the width in pixels of a single image (or cell) in the
--- atlas.
---
--- Returns the image width in pixels.
---
---@field XPLMTextureAtlasGetImageWidth fun(inTextureAtlas: XPLMTextureAtlasRef, inImageIndex: integer): integer

---@class _G
--- This function returns the height in pixels of a single image (or cell) in
--- the atlas.
---
--- Returns the image height in pixels.
---
---@field XPLMTextureAtlasGetImageHeight fun(inTextureAtlas: XPLMTextureAtlasRef, inImageIndex: integer): integer

---@class _G
--- This function draws an atlas image at its native resolution. The image is
--- positioned with its top-left corner at (inX, inY) and extends rightward and
--- downward by its native pixel dimensions.
---
--- - inTintColor: a color that is multiplied with the texture. Use
---   XPLMMakeColor(1, 1, 1, 1) for no tinting.
--- - inX: the left edge of the image, in panel coordinates.
--- - inY: the top edge of the image, in panel coordinates.
---
---@field XPLMTextureAtlasDrawAt fun(inTextureAtlas: XPLMTextureAtlasRef, inImageIndex: integer, inTintColor: integer, inX: number, inY: number)

---@class _G
--- This function draws an atlas image scaled to fill a rectangular region. The
--- image is stretched or compressed to exactly match the specified bounds.
---
--- - inTintColor: a color that is multiplied with the texture.
--- - inLeft, inTop, inRight, inBottom: the bounding rectangle in panel
---   coordinates.
---
---@field XPLMTextureAtlasDrawIn fun(inTextureAtlas: XPLMTextureAtlasRef, inImageIndex: integer, inTintColor: integer, inLeft: number, inTop: number, inRight: number, inBottom: number)

---@class _G
--- This function draws an atlas image using 9-slice scaling into a rectangular
--- region. The image is divided into a 3x3 grid (each slice being one third of
--- the original width and height). The four corner slices are drawn at their
--- native size, the four edge slices are stretched along one axis, and the
--- center slice is stretched in both directions. This preserves corners and
--- borders when scaling UI elements like buttons or panels.
---
--- - inTintColor: a color that is multiplied with the texture.
--- - inLeft, inTop, inRight, inBottom: the bounding rectangle in panel
---   coordinates.
---
---@field XPLMTextureAtlasDrawStretched fun(inTextureAtlas: XPLMTextureAtlasRef, inImageIndex: integer, inTintColor: integer, inLeft: number, inTop: number, inRight: number, inBottom: number)

---@class _G
--- This function draws an atlas image with arbitrary scaling, rotation, and
--- positioning. The image is placed so that the atlas-space pivot point
--- (inXAtlas, inYAtlas) aligns with the panel-space position (inXPanel,
--- inYPanel), then scaled and rotated around that point.
---
--- - inTintColor: a color that is multiplied with the texture.
--- - inXPanel, inYPanel: the destination point in panel coordinates.
--- - inXAtlas, inYAtlas: the pivot point within the image, in pixels from
---   the image's bottom-left corner.
--- - inXScale, inYScale: horizontal and vertical scale factors. 1.0 draws at
---   native resolution.
--- - inRotateCW: clockwise rotation in degrees around the pivot point.
---
---@field XPLMTextureAtlasDrawScaled fun(inTextureAtlas: XPLMTextureAtlasRef, inImageIndex: integer, inTintColor: integer, inXPanel: number, inYPanel: number, inXAtlas: number, inYAtlas: number, inXScale: number, inYScale: number, inRotateCW: number)

---@class _G
--- This function draws an atlas image onto an arbitrary triangle-strip mesh.
--- Each vertex specifies both a panel-space position and a normalized texture
--- coordinate within the image (0.0 to 1.0). This gives you full control over
--- how the image is mapped onto geometry.
---
--- Texture coordinates are relative to the image, not to the atlas sheet; the
--- mapping onto wherever the image was packed is applied for you, exactly as it
--- is for the other atlas drawing routines. One consequence is that the same
--- vertex array can be drawn with any inImageIndex - you do not have to rebuild
--- the mesh to switch images.
---
--- Coordinates outside 0.0 to 1.0 are not clamped, and will sample whatever
--- neighboring image shares the atlas sheet. Keep them in range.
---
--- - inTintColor: a color that is multiplied with the texture.
--- - vertices: an array of XPLMTextureVertex_t vertices defining the triangle
---   strip.
--- - count: the number of vertices. Must be at least 3.
---
---@field XPLMTextureAtlasDrawMesh fun(inTextureAtlas: XPLMTextureAtlasRef, inImageIndex: integer, inTintColor: integer, vertices: XPLMTextureVertex_t[], count: integer)

--[[
An XPLMTextureSource identifies a stock simulator texture that can be drawn
with the texture source drawing functions.
]]--

---@enum XPLMTextureSource
local XPLMTextureSource = {
    -- The pilot-side weather radar display.
    xplm_Texture_WeatherRadar1               = 0,
    -- The copilot-side weather radar display.
    xplm_Texture_WeatherRadar2               = 1,
}
---@class _G
---@field XPLMTextureSource XPLMTextureSource

---@class _G
--- This function draws a texture source scaled to fill a rectangular region. The
--- texture is stretched or compressed to exactly match the specified bounds.
---
--- - tex: the texture source to draw.
--- - tint: a color that is multiplied with the texture. Use
---   XPLMMakeColor(1, 1, 1, 1) for no tinting.
--- - left, top, right, bottom: the bounding rectangle in panel coordinates.
---
---@field XPLMTextureSourceDrawIn fun(tex: XPLMTextureSource, tint: integer, left: integer, top: integer, right: integer, bottom: integer)

---@class _G
--- This function draws a texture source onto an arbitrary triangle-strip mesh.
--- Each vertex specifies both a panel-space position and a normalized texture
--- coordinate (0.0 to 1.0) within the source texture. This gives you full
--- control over how the texture is mapped onto geometry.
---
--- - tex: the texture source to draw.
--- - tint: a color that is multiplied with the texture.
--- - mesh: an array of XPLMTextureVertex_t vertices defining the triangle strip.
--- - count: the number of vertices. Must be at least 3.
---
---@field XPLMTextureSourceDrawMesh fun(tex: XPLMTextureSource, tint: integer, mesh: XPLMTextureVertex_t[], count: integer)

---@class _G
--- This function saves the current transformation matrix onto the transform
--- stack. Call XPLMTransformPop to restore it. Calls must be balanced.
---
---@field XPLMTransformPush fun()

---@class _G
--- This function restores the transformation matrix from the top of the
--- transform stack, undoing all translate, rotate, and scale operations since
--- the matching XPLMTransformPush.
---
---@field XPLMTransformPop fun()

---@class _G
--- This function translates (offsets) all subsequent drawing by the specified
--- amounts. The translation is applied on top of the current transformation
--- matrix.
---
--- - dx: horizontal offset in pixels, positive to the right.
--- - dy: vertical offset in pixels, positive upward.
---
---@field XPLMTransformTranslate fun(dx: number, dy: number)

---@class _G
--- This function rotates all subsequent drawing around a center point. The
--- rotation is applied on top of the current transformation matrix.
---
--- - centerX, centerY: the center of rotation in panel coordinates.
--- - angle: the rotation angle in degrees, positive counterclockwise.
---
---@field XPLMTransformRotate fun(centerX: number, centerY: number, angle: number)

---@class _G
--- This function scales all subsequent drawing relative to the origin of the
--- current coordinate system. The scale is applied on top of the current
--- transformation matrix.
---
--- - scaleX: horizontal scale factor. 1.0 is no change, 2.0 doubles width.
--- - scaleY: vertical scale factor. 1.0 is no change, 2.0 doubles height.
---
---@field XPLMTransformScale fun(scaleX: number, scaleY: number)

---@class _G
--- This function saves the current scissor rectangle onto the scissor stack.
--- Call XPLMScissorPop to restore it. Calls must be balanced.
---
---@field XPLMScissorPush fun()

---@class _G
--- This function restores the scissor rectangle from the top of the scissor
--- stack, undoing any set or shrink operations since the matching
--- XPLMScissorPush.
---
---@field XPLMScissorPop fun()

---@class _G
--- This function sets an absolute scissor rectangle. Only pixels within this
--- rectangle are drawn; everything outside is clipped.
---
--- - left, top, right, bottom: the scissor bounds in panel coordinates.
---
---@field XPLMScissorSet fun(left: integer, top: integer, right: integer, bottom: integer)

---@class _G
--- This function sets the scissors box to the intersection of the existing
--- scissors box. The result is always a same or smaller drawable area.
--- This is useful for nested clipping.
---
--- - left: inset from the left edge, in pixels.
--- - top: inset from the top edge, in pixels.
--- - right: inset from the right edge, in pixels.
--- - bottom: inset from the bottom edge, in pixels.
---
---@field XPLMScissorIntersect fun(left: integer, top: integer, right: integer, bottom: integer)

---@class _G
--- This function begins stencil mask setup. While in setup mode, drawing
--- commands write to the stencil buffer instead of to the screen. Draw the
--- shapes that define your mask region, then call XPLMEndSetupStencilMask to
--- finish.
---
--- The stencil buffer is eight bits wide, so you can record up to eight
--- independent masks and pick among them later with XPLMUseStencilMask - one bit
--- per mask - without having to re-draw them.
---
--- - bits: the stencil bit pattern to write into the stencil buffer where
---   geometry is drawn.
--- - mask: a bitmask selecting which stencil bits are written.
---
--- Both parameters must be in the range 0 to 255, and every bit set in bits must
--- also be set in mask - a bit outside the mask can never be written. Stencil
--- testing must be off (see XPLMUseStencilMask) when you call this.
---
---@field XPLMBeginSetupStencilMask fun(bits: integer, mask: integer)

---@class _G
--- This function ends stencil mask setup. After this call, drawing commands
--- once again render to the screen, and stencil testing is off. Call
--- XPLMUseStencilMask to start drawing through the mask you just recorded.
---
--- The mask stays in the stencil buffer until you overwrite it or call
--- XPLMClearStencilMask, so you may record several masks up front and then
--- switch among them.
---
---@field XPLMEndSetupStencilMask fun()

---@class _G
--- This function selects which stencil mask clips your drawing. Subsequent
--- drawing is clipped to the region you recorded with XPLMBeginSetupStencilMask:
--- only pixels where the stencil buffer matches the specified bit pattern are
--- drawn.
---
--- - bits: the reference bit pattern to test against.
--- - mask: a bitmask selecting which stencil bits participate in the test.
---
--- Both parameters must be in the range 0 to 255, and every bit set in bits must
--- also be set in mask - a bit outside the mask can never match.
---
--- You may call this as often as you like within one drawing callback to switch
--- between masks you have recorded; each call replaces the previous test. Pass
--- (0, 0) to stop stencil testing entirely. You do not have to do that at the
--- end of your callback - X-Plane turns stencil testing off for you, and for a
--- window it also clears any mask you recorded, so nothing you draw leaks into
--- another window.
---
--- This function may not be called between XPLMBeginSetupStencilMask and
--- XPLMEndSetupStencilMask.
---
---@field XPLMUseStencilMask fun(bits: integer, mask: integer)

---@class _G
--- This function erases the entire stencil buffer, discarding every mask you
--- have recorded. It does not change whether stencil testing is on - use
--- XPLMUseStencilMask(0, 0) for that.
---
--- Because this throws away all eight masks at once, you rarely need it: to stop
--- drawing through a mask, call XPLMUseStencilMask(0, 0), and to replace one,
--- just record over it. It is safe to call at any time as a way of asking for a
--- known starting state, even if you have recorded nothing.
---
--- Stencil testing must be off, and you may not call this between
--- XPLMBeginSetupStencilMask and XPLMEndSetupStencilMask.
---
---@field XPLMClearStencilMask fun()

--[[
This enumeration specifies how a touch zone responds to user interaction.
]]--

---@enum XPLMTouchZone
local XPLMTouchZone = {
    -- The zone is registered but takes no action when touched.
    xplm_TouchZone_Nothing                   = 0,
    -- The zone fires an XPLMCommandRef when touched (begin on mouse-down, end on
    -- mouse-up).
    xplm_TouchZone_Command                   = 1,
    -- The zone delivers touch events to the callback registered via
    -- XPLMAvionicsSetTouchEventHandler, identified by the zone's identifier
    -- field.
    xplm_TouchZone_Identifier                = 2,
}
---@class _G
---@field XPLMTouchZone XPLMTouchZone

--- Your touch event callback is invoked when the user interacts with a touch zone whose type is xplm_TouchZone_Identifier. You receive the zone's identifier, the mouse status, the current position, the delta from the initial click point, and the mouse button involved.
---@alias XPLMTouchEvent_f fun(identifier: integer, status: XPLMMouseStatus, x: integer, y: integer, dx: integer, dy: integer, button: integer, ref: any)

--- XPLMTouchZoneSpec_t describes a single interactive touch zone on the panel. Pass a pointer to this struct to XPLMAccumulateTouchZone during your drawing callback. The structure may be expanded in future SDKs - always set structSize to the size of your structure in bytes.
---@class XPLMTouchZoneSpec_t
---@field structSize integer
---@field type XPLMTouchZone
---@field command XPLMCommandRef
---@field identifier integer
---@field left integer
---@field top integer
---@field right integer
---@field bottom integer

---@class _G
--- This function registers a touch zone for the current frame. Call this during
--- your avionics drawing callback each frame for every interactive region on
--- your panel. Zones registered later take priority over earlier ones when they
--- overlap.
---
--- Returns true if the zone is currently being clicked or held by the user,
--- false otherwise. You can use this to provide visual feedback (for example,
--- drawing a button in its pressed state).
---
---@field XPLMAccumulateTouchZone fun(inSpec: XPLMTouchZoneSpec_t): boolean

---@class _G
--- This function registers a callback to receive touch events for zones of type
--- xplm_TouchZone_Identifier on a specific avionics device. When the user
--- interacts with an identifier-type zone, your callback is invoked with the
--- zone's identifier and the mouse event details.
---
--- - avionic: the avionics device handle (from XPLMRegisterAvionicsCallbacksEx
---   or XPLMCreateAvionicsEx).
--- - handler: your XPLMTouchEvent_f callback.
--- - ref: a reference pointer passed through to your callback.
---
---@field XPLMAvionicsSetTouchEventHandler fun(avionic: XPLMAvionicsID, handler: XPLMTouchEvent_f, ref: any)

---@class _G
---@field XPLMWindowSetTouchEventHandler fun(window: XPLMWindowID, handler: XPLMTouchEvent_f, ref: any)

--- An opaque handle to a recorded sequence of drawing commands. Create one by bracketing draw calls between XPLMBeginRetainedDrawing and XPLMEndRetainedDrawing. Destroy it with XPLMDestroyRetainedDrawing when it is no longer needed.
---@class XPLMRetainedDrawing_t : userdata
---@field private __XPLMRetainedDrawing_t_marker any

---@class _G
--- This function begins recording drawing commands. All panel graphics calls
--- made after this function and before XPLMEndRetainedDrawing are captured into
--- a retained drawing instead of being rendered immediately.
---
--- NOTE: Do not nest retained drawing sessions.
---
---@field XPLMBeginRetainedDrawing fun()

---@class _G
--- This function ends recording and returns a handle to the captured drawing
--- commands. Subsequent panel graphics calls are once again rendered immediately.
---
--- Returns an opaque handle to the retained drawing.
---
---@field XPLMEndRetainedDrawing fun(): XPLMRetainedDrawing_t

---@class _G
--- This function replays a previously recorded sequence of drawing commands.
--- You can call this multiple times per frame and across multiple frames to
--- efficiently re-draw the same content.
---
---@field XPLMDrawRetained fun(drawing: XPLMRetainedDrawing_t)

---@class _G
--- This function destroys a retained drawing and frees its resources.
---
---@field XPLMDestroyRetainedDrawing fun(drawing: XPLMRetainedDrawing_t)

--[[
Bit flags that control which visual layers an SVT display renders. Combine
flags with bitwise OR to enable multiple layers.
]]--

---@enum XPLMSVTFeatures
local XPLMSVTFeatures = {
    -- 3-D terrain mesh with elevation coloring.
    xplm_SVT_Terrain                         = 1,
    -- Runway outlines, centerline stripes, and numbers.
    xplm_SVT_Runways                         = 2,
    -- Obstacle markers (towers, masts, etc.).
    xplm_SVT_Obstacles                       = 4,
    -- Flight path guidance hoops along the active route.
    xplm_SVT_FlightPath                      = 8,
    -- TCAS traffic symbols.
    xplm_SVT_Traffic                         = 16,
    -- Airport identification signs near airports.
    xplm_SVT_AirportSigns                    = 32,
    -- ILS approach guidance hoops.
    xplm_SVT_ILSHoops                        = 64,
    -- Horizon line and heading reference.
    xplm_SVT_HorizonHeading                  = 128,
    -- All visual layers enabled.
    xplm_SVT_All                             = 255,
}
---@class _G
---@field XPLMSVTFeatures XPLMSVTFeatures

--- Parameters for creating an SVT display. Set structSize to the size of your struct so that future SDK versions can add fields without breaking existing plugins.
---@class XPLMCreateSVT_t
---@field structSize integer
---@field pilotIndex integer
---@field pixelsPerDegree number

--- An opaque handle to an SVT display instance. Create one with XPLMCreateSVTDisplay and destroy it with XPLMDestroySVTDisplay.
---@class XPLMSVTDisplayRef : userdata
---@field private __XPLMSVTDisplayRef_marker any

---@class _G
--- This function creates a new SVT display instance. The display begins loading
--- terrain tiles for the current aircraft position immediately. You can draw it
--- as soon as tiles are available; before that, the draw call is a no-op.
---
--- The pixelsPerDegree scale and the rectangle you pass to XPLMSVTDisplayDrawIn
--- together determine the field of view: the rectangle is simply the scale applied
--- to the view's angular extent. So drawing into a bigger rectangle at the same
--- scale shows _more_ of the world at the same magnification rather than zooming
--- in, and to zoom you change the scale, not the rectangle. Pick the same scale
--- your pitch ladder uses and the 3-d horizon will line up with your artificial
--- horizon.
---
--- Which visual layers are rendered is a property of the draw call, not of the
--- display - see XPLMSVTDisplayDrawIn.
---
--- The returned handle must be destroyed with XPLMDestroySVTDisplay when no
--- longer needed. Handles are automatically destroyed when the owning plugin is
--- unloaded.
---
---@field XPLMCreateSVTDisplay fun(params: XPLMCreateSVT_t): XPLMSVTDisplayRef

---@class _G
--- This function destroys an SVT display and frees all associated resources.
---
---@field XPLMDestroySVTDisplay fun(svt: XPLMSVTDisplayRef)

---@class XPLMSVTCustomData_t
---@field pitchDeg number
---@field rollDeg number
---@field headingMagDeg number
---@field magVarDeg number
---@field indicatedAltFt number
---@field baroSettingInHg number
---@field hsiSource integer
---@field hdefDots number
---@field vdefDots number

---@class _G
--- This function renders the SVT display directly into the active panel surface
--- within the specified rectangular region. SVT sets up its own 3-D perspective
--- projection to fit the rectangle, so no transform stack manipulation is
--- needed.
---
--- The features parameter controls which visual layers are rendered for this
--- draw call. Pass a bitwise OR of XPLMSVTFeatures flags.
---
--- This function must be called from within an avionics drawing callback. If
--- terrain tiles have not finished loading yet, this function does nothing.
---
--- - svt: the SVT display handle.
--- - features: bitwise OR of XPLMSVTFeatures flags to enable for this draw call.
--- - left, top, right, bottom: the bounding rectangle in panel coordinates.
--- - dataOverrides. Pass nullptr for default sim state.
---
---@field XPLMSVTDisplayDrawIn fun(svt: XPLMSVTDisplayRef, features: XPLMSVTFeatures, left: integer, top: integer, right: integer, bottom: integer, dataOverrides: XPLMSVTCustomData_t)

--[[
Bit flags that control which visual layers a map display renders. Combine
flags with bitwise OR to enable multiple layers. NOTE: Not all layers can
be combined. You can display terrain and water and taxiways at the same 
time, but you cannot display weather radar and EGPWS at the same time. 
Only one of NEXRAD or Cloud IR can be displayed. Airport details (taxiways)
are only visible at close-in zoom levels.
]]--

---@enum XPLMMapLayers
local XPLMMapLayers = {
    -- Radar composite reflectivity.
    xplm_Map_Nexrad                          = 1,
    -- Infrared false-color cloud tops.
    xplm_Map_IR                              = 2,
    -- Topography (elevation color scale, not taking aircraft altitude into
    -- account).
    xplm_Map_Topo                            = 4,
    -- Terrain (terrain elevation relative to aircraft altitude).
    xplm_Map_Terrain                         = 8,
    -- Bodies of water.
    xplm_Map_Water                           = 16,
    -- Terrain warnings (relative to aircraft altitude, trajectory and landing
    -- gear position).
    xplm_Map_EGPWS                           = 32,
    -- Raw 0-255 texture of terrain elevation for plugin use.
    xplm_Map_raw_elev                        = 64,
    -- Airport runway and taxiway layouts.
    xplm_Map_safe_taxi                       = 128,
}
---@class _G
---@field XPLMMapLayers XPLMMapLayers

--[[
Flag that controls how the map's EGPWS display layer is rendered.
]]--

---@enum XPLMEGPWSStyle
local XPLMEGPWSStyle = {
    -- Terrain is drawn as small dithered blocks (common in most airliner
    -- avionics).
    xplm_EGPWS_Style_Blocky                  = 0,
    -- Terrain countours are smooth and curved (common in modern avionics).
    xplm_EGPWS_Style_Smooth                  = 1,
}
---@class _G
---@field XPLMEGPWSStyle XPLMEGPWSStyle

--- Per-frame description of what a map display should show: where it is centered, how it is oriented, how far it reaches, and what the terrain layers should shade against. centerX and centerY are in the same panel coordinates as the rectangle in XPLMMapDrawInfo_t, NOT relative to that rectangle. This is the point the map is centered on and the point it rotates about - the same sense as XPLMTransformRotate's center. For a map centered in its own rectangle it is ((left+right)/2, (bottom+top)/2). It is also the same space XPLMMapDisplayProject reports positions in, so you can put a symbol on the map without offsetting anything yourself. The center need not be the rectangle's midpoint, and may sit on or outside its edge: pushing it down toward the bottom edge puts more of the map ahead of the aircraft, which is how an EFIS arc mode is laid out. Two fields set the scale, and they are deliberately a matching pair: roseRadius is the distance from the center of the map out to the compass rose in pixels, and mapRange is that same distance in nautical miles. So setting mapRange to 40 puts the rose edge 40 nm from the aircraft, exactly like the range knob on a real EFIS control panel - and a centered rose therefore spans 80 nm across. Set structSize to the size of your struct so that future SDK versions can add fields without breaking existing plugins.
---@class XPLMMapCustomData_t
---@field structSize integer
---@field datLat number
---@field datLon number
---@field centerX integer
---@field centerY integer
---@field roseRadius integer
---@field mapRange number
---@field orientation integer
---@field terrainWarn number
---@field terrainCaution number
---@field acfAlt number
---@field gearDown integer
---@field trueRotation number
---@field nearestRwyElev number
---@field egpwsBrightness number
---@field egpwsStyle XPLMEGPWSStyle

--- Parameters for creating a base map display. Set structSize to the size of your struct so that future SDK versions can add fields without breaking existing plugins.
---@class XPLMCreateMap_t
---@field structSize integer
---@field pilotIndex integer

--- An opaque handle to a map display instance. Create one with XPLMCreateMapDisplay and destroy it with XPLMDestroyMapDisplay.
---@class XPLMMapDisplayRef : userdata
---@field private __XPLMMapDisplayRef_marker any

--- Which layers a map shows and where on the panel it goes. Pass the same XPLMMapDrawInfo_t and the same XPLMMapCustomData_t to XPLMMapDisplayDrawIn and to the projection routines, and the projection you query is provably the projection you drew - so your symbology cannot end up a frame or a zoom step out of step with the terrain under it. Set structSize to the size of your struct so that future SDK versions can add fields without breaking existing plugins.
---@class XPLMMapDrawInfo_t
---@field structSize integer
---@field layers XPLMMapLayers
---@field left integer
---@field top integer
---@field right integer
---@field bottom integer

---@class _G
--- This function creates a new map display instance. The display begins loading
--- terrain tiles for the current aircraft position immediately. You can draw it
--- as soon as tiles are available; before that, the draw call is a no-op.
---
--- The returned handle must be destroyed with XPLMDestroyMapDisplay when no
--- longer needed. Handles are automatically destroyed when the owning plugin is
--- unloaded.
---
---@field XPLMCreateMapDisplay fun(params: XPLMCreateMap_t): XPLMMapDisplayRef

---@class _G
--- This function destroys a map display and frees all associated resources.
---
---@field XPLMDestroyMapDisplay fun(map: XPLMMapDisplayRef)

---@class _G
--- This function renders the map display directly into the active panel surface
--- within the rectangle given by info. Map sets up its own projection to fit that
--- rectangle, so no transform stack manipulation is needed.
---
--- info->layers controls which visual layers are rendered. Note that some layers
--- are mutually exclusive, such as NEXRAD and EGPWS or NEXRAD and IR. The airport
--- details layer is only visible at very close zoom levels.
---
--- This function must be called from within an avionics drawing callback. If
--- terrain tiles have not finished loading yet, this function does nothing.
---
--- dataOverrides may be NULL, in which case the map follows the sim's own navigation
--- display: centered on the user aircraft in the middle of the rectangle, rose radius
--- half the shorter side of it, range taken from the EFIS range knob, and track-up or
--- north-up according to the sim's map mode. The pilotIndex you created the map with
--- selects which side's range and altitude are used.
---
---@field XPLMMapDisplayDrawIn fun(map: XPLMMapDisplayRef, info: XPLMMapDrawInfo_t, dataOverrides: XPLMMapCustomData_t)

---@class _G
--- Turns a latitude/longitude into a position in panel coordinates, for the map
--- that info describes. This is the inverse of XPLMMapDisplayUnproject.
---
--- Pass the same info you draw that map with and you get the projection that draw
--- call produces, whether you call this before or after XPLMMapDisplayDrawIn. So
--- the usual pattern - project your symbols, draw the map, then draw the symbols
--- on top - lines up exactly, with no need to cache anything between frames.
---
--- Unlike XPLMMapDisplayDrawIn, this does not have to be called from a drawing
--- callback; it is equally valid from a click handler or a flight loop.
---
--- Returns 1 on success. Returns 0, leaving outX and outY untouched, if the map's
--- terrain tiles have not loaded yet or if the point has no position on this map.
---
--- Note that the returned coordinates are in the same space as info's rectangle,
--- and like that rectangle they do not account for the panel graphics transform
--- stack.
---
--- Passing NULL for dataOverrides projects the sim's own navigation display view, the
--- same one XPLMMapDisplayDrawIn draws with NULL.
---
---@field XPLMMapDisplayProject fun(map: XPLMMapDisplayRef, info: XPLMMapDrawInfo_t, dataOverrides: XPLMMapCustomData_t, latitude: number, longitude: number): integer, { outX: userdata, outY: userdata }

---@class _G
--- Turns a position in panel coordinates back into a latitude/longitude, for the
--- map that info describes. This is the inverse of XPLMMapDisplayProject.
---
--- Use this to turn a touch or click on your map into a place in the world - for
--- picking a waypoint, or reading out the position under the cursor.
---
--- Unlike XPLMMapDisplayDrawIn, this does not have to be called from a drawing
--- callback; it is equally valid from a click handler or a flight loop.
---
--- Returns 1 on success. Returns 0, leaving outLatitude and outLongitude
--- untouched, if the map's terrain tiles have not loaded yet or if the point does
--- not correspond to anywhere on the earth.
---
--- Passing NULL for dataOverrides projects the sim's own navigation display view, the
--- same one XPLMMapDisplayDrawIn draws with NULL.
---
---@field XPLMMapDisplayUnproject fun(map: XPLMMapDisplayRef, info: XPLMMapDrawInfo_t, dataOverrides: XPLMMapCustomData_t, x: number, y: number): integer, { outLatitude: userdata, outLongitude: userdata }

---@class _G
--- Returns how many pixels correspond to one meter at a given point on the map
--- that info describes. Use it to size symbols and range rings so they stay
--- correct as the range changes.
---
--- Returns 0 if the map's terrain tiles have not loaded yet.
---
--- Passing NULL for dataOverrides projects the sim's own navigation display view, the
--- same one XPLMMapDisplayDrawIn draws with NULL.
---
---@field XPLMMapDisplayScaleMeter fun(map: XPLMMapDisplayRef, info: XPLMMapDrawInfo_t, dataOverrides: XPLMMapCustomData_t, x: number, y: number): number

---@class _G
--- Returns the heading, in degrees clockwise from straight up on the display, at
--- which true north lies at a given point on the map that info describes. ADD it
--- to a true heading to get the angle to draw that heading at.
---
--- This accounts both for the map's own rotation - a heading-up map is turned to
--- put the aircraft's nose at the top - and for the projection's convergence,
--- which tilts north away from vertical as you move away from the map's center.
---
--- Returns 0 if the map's terrain tiles have not loaded yet.
---
--- Passing NULL for dataOverrides projects the sim's own navigation display view, the
--- same one XPLMMapDisplayDrawIn draws with NULL.
---
---@field XPLMMapDisplayGetNorthHeading fun(map: XPLMMapDisplayRef, info: XPLMMapDrawInfo_t, dataOverrides: XPLMMapCustomData_t, x: number, y: number): number

---@class _G
--- This function returns the lowest and highest altitude shown on the map's
--- EGPWS terrain display.
---
--- Note that those altitudes are only available if the map has been drawn
--- with the xplm_Map_EGPWS layer. If altitudes are not available, the function
--- returns false, and the altitude pointers are not modified.
---
--- This function must be called from within an avionics drawing callback.
---
--- - map: the map display handle.
--- - min: a pointer to the minimum altitude.
--- - max: a pointer to the maximum altitude.
---
---@field XPLMMapDisplayGetTerrainAltitudes fun(map: XPLMMapDisplayRef): integer, { min: userdata, max: userdata }

