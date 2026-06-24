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
--- This function draws a filled convex polygon with a caller-specified outline
--- width. The interior is filled and an outline is drawn at the given width.
---
--- - lineWidth: the outline width in pixels.
---
---@field XPLMPolygonWithWidth fun(color: integer, lineWidth: number, vertices: XPLMVertex_t[], count: integer)

---@class _G
--- This function draws a filled convex polygon with per-vertex colors. Colors
--- are interpolated across the polygon interior.
---
---@field XPLMPolygonc fun(vertices: XPLMVertexColor_t[], count: integer)

---@class _G
--- This function draws a filled convex polygon with per-vertex colors and a
--- caller-specified outline width.
---
--- - lineWidth: the outline width in pixels.
---
---@field XPLMPolygoncWithWidth fun(lineWidth: number, vertices: XPLMVertexColor_t[], count: integer)

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
--- This function draws a quad strip with a caller-specified outline width.
--- Vertex interpretation is the same as XPLMQuadstrip.
---
--- - lineWidth: the outline width in pixels.
---
---@field XPLMQuadstripWithWidth fun(color: integer, lineWidth: number, vertices: XPLMVertex_t[], count: integer)

---@class _G
--- This function draws a quad strip with per-vertex colors. Vertex
--- interpretation is the same as XPLMQuadstrip; colors are interpolated across
--- each quad.
---
---@field XPLMQuadstripc fun(vertices: XPLMVertexColor_t[], count: integer)

---@class _G
--- This function draws a quad strip with per-vertex colors and a
--- caller-specified outline width.
---
--- - lineWidth: the outline width in pixels.
---
---@field XPLMQuadstripcWithWidth fun(lineWidth: number, vertices: XPLMVertexColor_t[], count: integer)

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
---@field XPLMFontAddFace fun(font: XPLMFontHandle, ttf_path: string)

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
--- This function returns the number of characters from the end of a string
--- that fit within the specified width at the given font size. Characters are
--- measured right to left. This is useful for right-aligning a truncated
--- string.
---
--- Returns a character count.
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
--- - angle: the rotation angle in degrees, positive counterclockwise.
---
---@field XPLMFontDrawStringRotated fun(font: XPLMFontHandle, color: integer, fontSize: number, x: number, y: number, string: string, angle: number, justification: XPLMJustification_t)

--- An opaque handle to a texture atlas. Create one with XPLMCreateTextureAtlas and destroy it with XPLMDestroyTextureAtlas.
---@class XPLMTextureAtlasRef : userdata
---@field private __XPLMTextureAtlasRef_marker any

--- A vertex for textured mesh drawing. Combines a position in panel coordinates with normalized texture coordinates within the image.
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
--- This function returns the UV coordinates of an image within the atlas
--- texture. This is useful for custom mesh rendering with
--- XPLMTextureAtlasDrawMesh.
---
--- - outUV: a pointer to an array of 4 floats that receives [s1, t1, s2, t2],
---   where (s1, t1) is the bottom-left corner and (s2, t2) is the top-right
---   corner in atlas texture space.
---
---@field XPLMTextureAtlasGetImageUVMap fun(inTextureAtlas: XPLMTextureAtlasRef, inImageIndex: integer): { outUV: number[] }

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
--- - top, left, bottom, right: the scissor bounds in panel coordinates.
---
---@field XPLMScissorSet fun(top: integer, left: integer, bottom: integer, right: integer)

---@class _G
--- This function insets (shrinks) the current scissor rectangle by the
--- specified amounts on each side. The result is the intersection of the
--- current scissor rectangle and the new inset rectangle, so the drawable area
--- can only get smaller. This is useful for nested clipping.
---
--- - top: inset from the top edge, in pixels.
--- - left: inset from the left edge, in pixels.
--- - bottom: inset from the bottom edge, in pixels.
--- - right: inset from the right edge, in pixels.
---
---@field XPLMScissorShrink fun(top: integer, left: integer, bottom: integer, right: integer)

---@class _G
--- This function begins stencil mask setup. While in setup mode, drawing
--- commands write to the stencil buffer instead of to the screen. Draw the
--- shapes that define your mask region, then call XPLMEndSetupStencilMask to
--- finish.
---
--- - bits: the stencil bit pattern to write into the stencil buffer where
---   geometry is drawn.
--- - mask: a bitmask selecting which stencil bits are written.
---
---@field XPLMBeginSetupStencilMask fun(bits: integer, mask: integer)

---@class _G
--- This function ends stencil mask setup. After this call, drawing commands
--- once again render to the screen. Call XPLMUseStencilMask to activate the
--- mask for subsequent drawing, or XPLMClearStencilMask to discard it.
---
---@field XPLMEndSetupStencilMask fun()

---@class _G
--- This function activates stencil testing. Subsequent drawing is clipped to
--- the region defined during stencil setup: only pixels where the stencil
--- buffer matches the specified bit pattern are drawn.
---
--- - bits: the reference bit pattern to test against.
--- - mask: a bitmask selecting which stencil bits participate in the test.
---
---@field XPLMUseStencilMask fun(bits: integer, mask: integer)

---@class _G
--- This function clears the stencil buffer and disables stencil testing.
--- Subsequent drawing is no longer clipped by the stencil mask.
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
---@field features XPLMSVTFeatures
---@field pilotIndex integer

--- An opaque handle to an SVT display instance. Create one with XPLMCreateSVTDisplay and destroy it with XPLMDestroySVTDisplay.
---@class XPLMSVTDisplayRef : userdata
---@field private __XPLMSVTDisplayRef_marker any

---@class _G
--- This function creates a new SVT display instance. The display begins loading
--- terrain tiles for the current aircraft position immediately. You can draw it
--- as soon as tiles are available; before that, the draw call is a no-op.
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

---@class XPLMMapCustomData_t
---@field datLat number
---@field datLon number
---@field ctrX integer
---@field ctrY integer
---@field roseDiameter integer
---@field mapRange number
---@field orientation integer
---@field terrainWarn number
---@field terrainCaution number
---@field acfAlt number
---@field gearDown integer
---@field trueRotation number

--- Parameters for creating a base map display. Set structSize to the size of your struct so that future SDK versions can add fields without breaking existing plugins.
---@class XPLMCreateMap_t
---@field structSize integer
---@field pilotIndex integer

--- An opaque handle to a map display instance. Create one with XPLMCreateMapDisplay and destroy it with XPLMDestroyMapDisplay.
---@class XPLMMapDisplayRef : userdata
---@field private __XPLMMapDisplayRef_marker any

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
--- within the specified rectangular region. Map sets up its own stereographic
--- projection to fit the rectangle, so no transform stack manipulation is
--- needed.
---
--- The layers parameter controls which visual layers are rendered for this
--- draw call. Pass a bitwise OR of XPLMMapLayers flags. Note that some layers
--- are mutually exclusive, such as NEXRAD and EGPWS or NEXRAD and IR.
--- The airport details layer is only visible at very close zoom levels.
---
--- This function must be called from within an avionics drawing callback. If
--- terrain tiles have not finished loading yet, this function does nothing.
---
--- - map: the map display handle.
--- - layers: bitwise OR of XPLMMapLayers flags to enable for this draw call.
--- - left, top, right, bottom: the bounding rectangle in panel coordinates.
---
---@field XPLMMapDisplayDrawIn fun(map: XPLMMapDisplayRef, layers: XPLMMapLayers, left: integer, top: integer, right: integer, bottom: integer, dataOverrides: XPLMMapCustomData_t)

