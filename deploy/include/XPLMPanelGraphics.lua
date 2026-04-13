-- Use require('XPLMPanelGraphics') to access these functions.

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

--[[
   XLuaMakeColor
   
   This function packs four floating-point color components into a single
   uint32_t suitable for use with all panel graphics drawing routines. Each
   component is in the range 0.0 to 1.0 and is clamped before packing. The
   returned value is in ABGR byte order (alpha in the high byte, red in the
   low byte).
]]--
--[[
    Returns   : integer

    Parameters:
     red                                    (number)
     green                                  (number)
     blue                                   (number)
     alpha                                  (number)

]]--

--[[
   XLuaLines
   
   This function draws disconnected line segments. Every pair of vertices
   defines one segment: the first segment runs from vertices[0] to
   vertices[1], the second from vertices[2] to vertices[3], and so on.
   
   - count: the number of vertices. Should be even; an odd trailing vertex is
     ignored.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     color                                  (integer)
     vertices                               (array<table<XPLMVertex_t>|XPLMVertex_t>[])
     count                                  (integer)

]]--

--[[
   XLuaLinesWithWidth
   
   This function draws disconnected line segments with a caller-specified line
   width. Vertex interpretation is the same as XPLMLines.
   
   - lineWidth: the line width in pixels.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     color                                  (integer)
     lineWidth                              (number)
     vertices                               (array<table<XPLMVertex_t>|XPLMVertex_t>[])
     count                                  (integer)

]]--

--[[
   XLuaLinesc
   
   This function draws disconnected line segments with per-vertex colors.
   Vertex interpretation is the same as XPLMLines; colors are interpolated
   along each segment.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     vertices                               (array<table<XPLMVertexColor_t>|XPLMVertexColor_t>[])
     count                                  (integer)

]]--

--[[
   XLuaLinescWithWidth
   
   This function draws disconnected line segments with per-vertex colors and a
   caller-specified line width.
   
   - lineWidth: the line width in pixels.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     lineWidth                              (number)
     vertices                               (array<table<XPLMVertexColor_t>|XPLMVertexColor_t>[])
     count                                  (integer)

]]--

--[[
   XLuaLinesStipple
   
   This function draws disconnected dashed line segments. Vertex
   interpretation is the same as XPLMLines. The dash pattern alternates
   between drawn and undrawn segments of equal length.
   
   - dashLength: the length of each dash and gap, in pixels.
   - lineWidth: the line width in pixels.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     color                                  (integer)
     pts                                    (array<table<XPLMVertex_t>|XPLMVertex_t>[])
     count                                  (integer)
     dashLength                             (number)
     lineWidth                              (number)

]]--

--[[
   XLuaLineStrip
   
   This function draws a connected line strip. Vertices are connected in
   order: a segment from vertices[0] to vertices[1], then from vertices[1] to
   vertices[2], and so on. The last vertex is not connected back to the first.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     color                                  (integer)
     pts                                    (array<table<XPLMVertex_t>|XPLMVertex_t>[])
     count                                  (integer)

]]--

--[[
   XLuaLineStripWithWidth
   
   This function draws a connected line strip with a caller-specified line
   width. Vertex interpretation is the same as XPLMLineStrip.
   
   - lineWidth: the line width in pixels.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     color                                  (integer)
     lineWidth                              (number)
     pts                                    (array<table<XPLMVertex_t>|XPLMVertex_t>[])
     count                                  (integer)

]]--

--[[
   XLuaLineStripc
   
   This function draws a connected line strip with per-vertex colors. Vertex
   interpretation is the same as XPLMLineStrip; colors are interpolated along
   each segment.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     pts                                    (array<table<XPLMVertexColor_t>|XPLMVertexColor_t>[])
     count                                  (integer)

]]--

--[[
   XLuaLineStripcWithWidth
   
   This function draws a connected line strip with per-vertex colors and a
   caller-specified line width.
   
   - lineWidth: the line width in pixels.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     lineWidth                              (number)
     pts                                    (array<table<XPLMVertexColor_t>|XPLMVertexColor_t>[])
     count                                  (integer)

]]--

--[[
   XLuaLineStripStipple
   
   This function draws a connected dashed line strip. Vertex interpretation is
   the same as XPLMLineStrip. The dash pattern alternates between drawn and
   undrawn segments of equal length.
   
   - dashLength: the length of each dash and gap, in pixels.
   - lineWidth: the line width in pixels.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     color                                  (integer)
     pts                                    (array<table<XPLMVertex_t>|XPLMVertex_t>[])
     count                                  (integer)
     dashLength                             (number)
     lineWidth                              (number)

]]--

--[[
   XLuaLineLoop
   
   This function draws a closed line loop. Vertices are connected in order,
   and the last vertex is automatically connected back to the first, forming a
   closed shape. The interior is not filled.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     color                                  (integer)
     pts                                    (array<table<XPLMVertex_t>|XPLMVertex_t>[])
     count                                  (integer)

]]--

--[[
   XLuaLineLoopWithWidth
   
   This function draws a closed line loop with a caller-specified line width.
   Vertex interpretation is the same as XPLMLineLoop.
   
   - lineWidth: the line width in pixels.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     color                                  (integer)
     lineWidth                              (number)
     pts                                    (array<table<XPLMVertex_t>|XPLMVertex_t>[])
     count                                  (integer)

]]--

--[[
   XLuaLineLoopc
   
   This function draws a closed line loop with per-vertex colors. Vertex
   interpretation is the same as XPLMLineLoop; colors are interpolated along
   each segment.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     pts                                    (array<table<XPLMVertexColor_t>|XPLMVertexColor_t>[])
     count                                  (integer)

]]--

--[[
   XLuaLineLoopcWithWidth
   
   This function draws a closed line loop with per-vertex colors and a
   caller-specified line width.
   
   - lineWidth: the line width in pixels.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     lineWidth                              (number)
     pts                                    (array<table<XPLMVertexColor_t>|XPLMVertexColor_t>[])
     count                                  (integer)

]]--

--[[
   XLuaLineLoopStipple
   
   This function draws a closed dashed line loop. Vertex interpretation is the
   same as XPLMLineLoop. The dash pattern alternates between drawn and undrawn
   segments of equal length.
   
   - dashLength: the length of each dash and gap, in pixels.
   - lineWidth: the line width in pixels.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     color                                  (integer)
     pts                                    (array<table<XPLMVertex_t>|XPLMVertex_t>[])
     count                                  (integer)
     dashLength                             (number)
     lineWidth                              (number)

]]--

--[[
   XLuaPolygon
   
   This function draws a filled convex polygon. The vertices define the
   outline of the polygon, and the interior is filled with the specified
   color.
   
   - count: the number of vertices. You must provide at least 3 vertices.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     color                                  (integer)
     vertices                               (array<table<XPLMVertex_t>|XPLMVertex_t>[])
     count                                  (integer)

]]--

--[[
   XLuaPolygonWithWidth
   
   This function draws a filled convex polygon with a caller-specified outline
   width. The interior is filled and an outline is drawn at the given width.
   
   - lineWidth: the outline width in pixels.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     color                                  (integer)
     lineWidth                              (number)
     vertices                               (array<table<XPLMVertex_t>|XPLMVertex_t>[])
     count                                  (integer)

]]--

--[[
   XLuaPolygonc
   
   This function draws a filled convex polygon with per-vertex colors. Colors
   are interpolated across the polygon interior.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     vertices                               (array<table<XPLMVertexColor_t>|XPLMVertexColor_t>[])
     count                                  (integer)

]]--

--[[
   XLuaPolygoncWithWidth
   
   This function draws a filled convex polygon with per-vertex colors and a
   caller-specified outline width.
   
   - lineWidth: the outline width in pixels.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     lineWidth                              (number)
     vertices                               (array<table<XPLMVertexColor_t>|XPLMVertexColor_t>[])
     count                                  (integer)

]]--

--[[
   XLuaQuadstrip
   
   This function draws a series of connected filled quadrilaterals. Vertices
   are taken in pairs: the first quad is formed by vertices[0], vertices[1],
   vertices[2], vertices[3]; the next quad shares its leading edge with the
   previous one, formed by vertices[2], vertices[3], vertices[4], vertices[5];
   and so on.
   
   - count: the number of vertices. Must be even and at least 4.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     color                                  (integer)
     vertices                               (array<table<XPLMVertex_t>|XPLMVertex_t>[])
     count                                  (integer)

]]--

--[[
   XLuaQuadstripWithWidth
   
   This function draws a quad strip with a caller-specified outline width.
   Vertex interpretation is the same as XPLMQuadstrip.
   
   - lineWidth: the outline width in pixels.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     color                                  (integer)
     lineWidth                              (number)
     vertices                               (array<table<XPLMVertex_t>|XPLMVertex_t>[])
     count                                  (integer)

]]--

--[[
   XLuaQuadstripc
   
   This function draws a quad strip with per-vertex colors. Vertex
   interpretation is the same as XPLMQuadstrip; colors are interpolated across
   each quad.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     vertices                               (array<table<XPLMVertexColor_t>|XPLMVertexColor_t>[])
     count                                  (integer)

]]--

--[[
   XLuaQuadstripcWithWidth
   
   This function draws a quad strip with per-vertex colors and a
   caller-specified outline width.
   
   - lineWidth: the outline width in pixels.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     lineWidth                              (number)
     vertices                               (array<table<XPLMVertexColor_t>|XPLMVertexColor_t>[])
     count                                  (integer)

]]--

--[[
This enumeration specifies the character set for a font created with
XPLMCreateFont. The character set determines which glyphs are rasterized
and available for drawing.
]]--

XPLMCharSet_t = {
    -- Digits 0-9 and common numeric punctuation only.
    xplm_CharSetDigits                       = 0,
    -- The printable ASCII character range (codes 32-126).
    xplm_CharSetASCII                        = 1,
    -- Full Unicode support; glyphs are rasterized on demand.
    xplm_CharSetUnicode                      = 2,
}

--[[
This enumeration specifies horizontal text justification for the font
drawing routines. The x and y position you pass to a drawing function is
the baseline of the text at the anchor point determined by justification:
left-aligned text anchors at the left edge, centered text at the midpoint,
and right-aligned text at the right edge.
]]--

XPLMJustification_t = {
    -- Left-justified; x is the left edge of the string.
    xplm_JustLeft                            = 0,
    -- Center-justified; x is the horizontal center of the string.
    xplm_JustCenter                          = 1,
    -- Right-justified; x is the right edge of the string.
    xplm_JustRight                           = 2,
}

--[[
   XLuaCreateFont
   
   This function creates a new font handle. The character set determines which
   glyphs are available for rendering. After creating the font, add one or
   more TrueType faces with XPLMFontAddFace before drawing.
   
   Returns an opaque font handle.
]]--
--[[
    Returns   : userdata<XPLMFontHandle>

    Parameters:
     charset                                (XPLMCharSet_t)

]]--

--[[
   XLuaDestroyFont
   
   This function destroys a font handle and frees all associated resources.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     font                                   (XPLMFontHandle)

]]--

--[[
   XLuaFontAddFace
   
   This function adds a TrueType font face to an existing font handle. You may
   add multiple faces to a single font to provide fallback glyphs; if a glyph
   is not found in the first face, subsequent faces are searched in the order
   they were added.
   
   - ttf_path: a file system path to a .ttf or .otf font file.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     font                                   (XPLMFontHandle)
     ttf_path                               (string)

]]--

--[[
   XLuaFontGetMetrics
   
   This function returns line metrics for a font at a given size. The metrics
   describe the vertical dimensions of a line of text and are useful for
   computing text layout.
   
   - fontSize: the font size in pixels.
   - outMetrics: receives the computed metrics. You must set
     outMetrics->structSize before calling.
]]--
--[[
    Returns   : Table {
          ["outMetrics"]                    (XPLMFontMetrics_t)
    }

    Parameters:
     font                                   (XPLMFontHandle)
     fontSize                               (number)

]]--

--[[
   XLuaFontMeasureString
   
   This function returns the width in pixels that a string would occupy if
   drawn at the given font size. The string is not drawn.
   
   Returns the horizontal advance width, in pixels.
]]--
--[[
    Returns   : number

    Parameters:
     font                                   (XPLMFontHandle)
     fontSize                               (number)
     string                                 (string)

]]--

--[[
   XLuaFontGetLineCount
   
   This function calculates how many lines a string would occupy if
   word-wrapped to the specified width at the given font size.
   
   Returns the number of lines.
]]--
--[[
    Returns   : integer

    Parameters:
     font                                   (XPLMFontHandle)
     fontSize                               (number)
     string                                 (string)
     width                                  (number)

]]--

--[[
   XLuaFontFitForward
   
   This function returns the number of characters from the beginning of a
   string that fit within the specified width at the given font size.
   Characters are measured left to right.
   
   Returns a character count.
]]--
--[[
    Returns   : integer

    Parameters:
     font                                   (XPLMFontHandle)
     fontSize                               (number)
     string                                 (string)
     width                                  (number)

]]--

--[[
   XLuaFontFitReverse
   
   This function returns the number of characters from the end of a string
   that fit within the specified width at the given font size. Characters are
   measured right to left. This is useful for right-aligning a truncated
   string.
   
   Returns a character count.
]]--
--[[
    Returns   : integer

    Parameters:
     font                                   (XPLMFontHandle)
     fontSize                               (number)
     string                                 (string)
     width                                  (number)

]]--

--[[
   XLuaFontDrawString
   
   This function draws a null-terminated string at the specified position with
   the given font, size, color, and justification. The x and y coordinates
   specify the baseline position at the justification anchor point.
   
   - fontSize: the font size in pixels.
   - x, y: the anchor position of the baseline, in panel coordinates.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     font                                   (XPLMFontHandle)
     color                                  (integer)
     fontSize                               (number)
     x                                      (number)
     y                                      (number)
     string                                 (string)
     justification                          (XPLMJustification_t)

]]--

--[[
   XLuaFontDrawStringFixedSpacing
   
   This function draws a null-terminated string using fixed character spacing
   instead of the font's natural proportional spacing. Each character occupies
   exactly fixedSpacing pixels horizontally, regardless of the glyph's actual
   width. This is useful for numeric readouts where digits must not shift as
   values change.
   
   - fontSize: the font size in pixels.
   - x, y: the anchor position of the baseline, in panel coordinates.
   - fixedSpacing: the horizontal advance per character, in pixels.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     font                                   (XPLMFontHandle)
     color                                  (integer)
     fontSize                               (number)
     x                                      (number)
     y                                      (number)
     string                                 (string)
     fixedSpacing                           (integer)
     justification                          (XPLMJustification_t)

]]--

--[[
   XLuaFontDrawStringWordWrapped
   
   This function draws a null-terminated string with automatic word wrapping.
   Text is broken at word boundaries to fit within the specified wrap width.
   Lines are stacked downward from the initial y position, spaced by the
   font's line height.
   
   - fontSize: the font size in pixels.
   - x, y: the anchor position of the first line's baseline, in panel
     coordinates.
   - wrapWidth: the maximum line width in pixels before wrapping.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     font                                   (XPLMFontHandle)
     color                                  (integer)
     fontSize                               (number)
     x                                      (number)
     y                                      (number)
     string                                 (string)
     wrapWidth                              (integer)
     justification                          (XPLMJustification_t)

]]--

--[[
   XLuaFontDrawStringRotated
   
   This function draws a null-terminated string rotated by the specified angle
   around the anchor point. The anchor point is determined by x, y, and the
   justification, just as in XPLMFontDrawString.
   
   - fontSize: the font size in pixels.
   - x, y: the anchor position of the baseline, in panel coordinates.
   - angle: the rotation angle in degrees, positive counterclockwise.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     font                                   (XPLMFontHandle)
     color                                  (integer)
     fontSize                               (number)
     x                                      (number)
     y                                      (number)
     string                                 (string)
     angle                                  (number)
     justification                          (XPLMJustification_t)

]]--

--[[
   XLuaCreateTextureAtlas
   
   This function creates a new, empty texture atlas. After creating the atlas,
   add images with the XPLMTextureAtlasAddImage or
   XPLMTextureAtlasAddImageFile family of functions, then call
   XPLMTextureAtlasBake before drawing.
   
   Returns an opaque atlas handle.
]]--
--[[
    Returns   : userdata<XPLMTextureAtlasRef>

    Parameters:
      None.
]]--

--[[
   XLuaDestroyTextureAtlas
   
   This function destroys a texture atlas and frees all associated GPU and CPU
   resources.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inTextureAtlas                         (XPLMTextureAtlasRef)

]]--

--[[
   XLuaTextureAtlasAddImageFile
   
   This function loads a PNG image file and adds it to the atlas as a single
   image. Call this before XPLMTextureAtlasBake.
   
   - inImageFilePath: the file system path to a PNG file.
   
   Returns the zero-based image index assigned to this image.
]]--
--[[
    Returns   : integer

    Parameters:
     inTextureAtlas                         (XPLMTextureAtlasRef)
     inImageFilePath                        (string)

]]--

--[[
   XLuaTextureAtlasAddImageFileSet
   
   This function loads a PNG image file and subdivides it into a grid of
   cells, adding each cell to the atlas as a separate image. This is useful
   for sprite sheets and image strip assets. Call this before
   XPLMTextureAtlasBake.
   
   - inImageFilePath: the file system path to a PNG file.
   - inCellsX: the number of columns to divide the image into.
   - inCellsY: the number of rows to divide the image into.
   
   Returns the zero-based image index of the first cell (top-left). Subsequent
   cells are numbered in row-major order: index + y * inCellsX + x.
]]--
--[[
    Returns   : integer

    Parameters:
     inTextureAtlas                         (XPLMTextureAtlasRef)
     inImageFilePath                        (string)
     inCellsX                               (integer)
     inCellsY                               (integer)

]]--

--[[
   XLuaTextureAtlasAddImage
   
   This function adds a single image from raw pixel data to the atlas. The
   pixel data must be RGBA format, 4 bytes per pixel, with rows ordered from
   top to bottom. Call this before XPLMTextureAtlasBake.
   
   - inImage: pointer to the raw RGBA pixel data.
   - inWidth: the image width in pixels.
   - inHeight: the image height in pixels.
   
   Returns the zero-based image index assigned to this image.
]]--
--[[
    Returns   : integer

    Parameters:
     inTextureAtlas                         (XPLMTextureAtlasRef)
     inImage                                (unsigned char *)
     inWidth                                (integer)
     inHeight                               (integer)

]]--

--[[
   XLuaTextureAtlasBake
   
   This function packs all previously added images into a GPU texture. You
   must call this after adding all images and before any draw calls. Once
   baked, you cannot add more images to the atlas.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inTextureAtlas                         (XPLMTextureAtlasRef)

]]--

--[[
   XLuaTextureAtlasGetImageWidth
   
   This function returns the width in pixels of a single image (or cell) in
   the atlas.
   
   Returns the image width in pixels.
]]--
--[[
    Returns   : integer

    Parameters:
     inTextureAtlas                         (XPLMTextureAtlasRef)
     inImageIndex                           (integer)

]]--

--[[
   XLuaTextureAtlasGetImageHeight
   
   This function returns the height in pixels of a single image (or cell) in
   the atlas.
   
   Returns the image height in pixels.
]]--
--[[
    Returns   : integer

    Parameters:
     inTextureAtlas                         (XPLMTextureAtlasRef)
     inImageIndex                           (integer)

]]--

--[[
   XLuaTextureAtlasGetImageUVMap
   
   This function returns the UV coordinates of an image within the atlas
   texture. This is useful for custom mesh rendering with
   XPLMTextureAtlasDrawMesh.
   
   - outUV: a pointer to an array of 4 floats that receives [s1, t1, s2, t2],
     where (s1, t1) is the bottom-left corner and (s2, t2) is the top-right
     corner in atlas texture space.
]]--
--[[
    Returns   : Table {
          ["outUV"]                         (array[4] of number)
    }

    Parameters:
     inTextureAtlas                         (XPLMTextureAtlasRef)
     inImageIndex                           (integer)

]]--

--[[
   XLuaTextureAtlasDrawAt
   
   This function draws an atlas image at its native resolution. The image is
   positioned with its top-left corner at (inX, inY) and extends rightward and
   downward by its native pixel dimensions.
   
   - inTintColor: a color that is multiplied with the texture. Use
     XPLMMakeColor(1, 1, 1, 1) for no tinting.
   - inX: the left edge of the image, in panel coordinates.
   - inY: the top edge of the image, in panel coordinates.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inTextureAtlas                         (XPLMTextureAtlasRef)
     inImageIndex                           (integer)
     inTintColor                            (integer)
     inX                                    (number)
     inY                                    (number)

]]--

--[[
   XLuaTextureAtlasDrawIn
   
   This function draws an atlas image scaled to fill a rectangular region. The
   image is stretched or compressed to exactly match the specified bounds.
   
   - inTintColor: a color that is multiplied with the texture.
   - inLeft, inTop, inRight, inBottom: the bounding rectangle in panel
     coordinates.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inTextureAtlas                         (XPLMTextureAtlasRef)
     inImageIndex                           (integer)
     inTintColor                            (integer)
     inLeft                                 (number)
     inTop                                  (number)
     inRight                                (number)
     inBottom                               (number)

]]--

--[[
   XLuaTextureAtlasDrawStretched
   
   This function draws an atlas image using 9-slice scaling into a rectangular
   region. The image is divided into a 3x3 grid (each slice being one third of
   the original width and height). The four corner slices are drawn at their
   native size, the four edge slices are stretched along one axis, and the
   center slice is stretched in both directions. This preserves corners and
   borders when scaling UI elements like buttons or panels.
   
   - inTintColor: a color that is multiplied with the texture.
   - inLeft, inTop, inRight, inBottom: the bounding rectangle in panel
     coordinates.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inTextureAtlas                         (XPLMTextureAtlasRef)
     inImageIndex                           (integer)
     inTintColor                            (integer)
     inLeft                                 (number)
     inTop                                  (number)
     inRight                                (number)
     inBottom                               (number)

]]--

--[[
   XLuaTextureAtlasDrawScaled
   
   This function draws an atlas image with arbitrary scaling, rotation, and
   positioning. The image is placed so that the atlas-space pivot point
   (inXAtlas, inYAtlas) aligns with the panel-space position (inXPanel,
   inYPanel), then scaled and rotated around that point.
   
   - inTintColor: a color that is multiplied with the texture.
   - inXPanel, inYPanel: the destination point in panel coordinates.
   - inXAtlas, inYAtlas: the pivot point within the image, in pixels from the
     image's bottom-left corner.
   - inXScale, inYScale: horizontal and vertical scale factors. 1.0 draws at
     native resolution.
   - inRotateCW: clockwise rotation in degrees around the pivot point.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inTextureAtlas                         (XPLMTextureAtlasRef)
     inImageIndex                           (integer)
     inTintColor                            (integer)
     inXPanel                               (number)
     inYPanel                               (number)
     inXAtlas                               (number)
     inYAtlas                               (number)
     inXScale                               (number)
     inYScale                               (number)
     inRotateCW                             (number)

]]--

--[[
   XLuaTextureAtlasDrawMesh
   
   This function draws an atlas image onto an arbitrary triangle-strip mesh.
   Each vertex specifies both a panel-space position and a normalized texture
   coordinate within the image (0.0 to 1.0). This gives you full control over
   how the image is mapped onto geometry.
   
   - inTintColor: a color that is multiplied with the texture.
   - vertices: an array of XPLMTextureVertex_t vertices defining the triangle
     strip.
   - count: the number of vertices. Must be at least 3.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inTextureAtlas                         (XPLMTextureAtlasRef)
     inImageIndex                           (integer)
     inTintColor                            (integer)
     vertices                               (array<table<XPLMTextureVertex_t>|XPLMTextureVertex_t>[])
     count                                  (integer)

]]--

--[[
   XLuaTransformPush
   
   This function saves the current transformation matrix onto the transform
   stack. Call XPLMTransformPop to restore it. Calls must be balanced.
]]--
--[[
    Returns   : Nothing.

    Parameters:
      None.
]]--

--[[
   XLuaTransformPop
   
   This function restores the transformation matrix from the top of the
   transform stack, undoing all translate, rotate, and scale operations since
   the matching XPLMTransformPush.
]]--
--[[
    Returns   : Nothing.

    Parameters:
      None.
]]--

--[[
   XLuaTransformTranslate
   
   This function translates (offsets) all subsequent drawing by the specified
   amounts. The translation is applied on top of the current transformation
   matrix.
   
   - dx: horizontal offset in pixels, positive to the right.
   - dy: vertical offset in pixels, positive upward.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     dx                                     (number)
     dy                                     (number)

]]--

--[[
   XLuaTransformRotate
   
   This function rotates all subsequent drawing around a center point. The
   rotation is applied on top of the current transformation matrix.
   
   - centerX, centerY: the center of rotation in panel coordinates.
   - angle: the rotation angle in degrees, positive counterclockwise.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     centerX                                (number)
     centerY                                (number)
     angle                                  (number)

]]--

--[[
   XLuaTransformScale
   
   This function scales all subsequent drawing relative to the origin of the
   current coordinate system. The scale is applied on top of the current
   transformation matrix.
   
   - scaleX: horizontal scale factor. 1.0 is no change, 2.0 doubles width.
   - scaleY: vertical scale factor. 1.0 is no change, 2.0 doubles height.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     scaleX                                 (number)
     scaleY                                 (number)

]]--

--[[
   XLuaScissorPush
   
   This function saves the current scissor rectangle onto the scissor stack.
   Call XPLMScissorPop to restore it. Calls must be balanced.
]]--
--[[
    Returns   : Nothing.

    Parameters:
      None.
]]--

--[[
   XLuaScissorPop
   
   This function restores the scissor rectangle from the top of the scissor
   stack, undoing any set or shrink operations since the matching
   XPLMScissorPush.
]]--
--[[
    Returns   : Nothing.

    Parameters:
      None.
]]--

--[[
   XLuaScissorSet
   
   This function sets an absolute scissor rectangle. Only pixels within this
   rectangle are drawn; everything outside is clipped.
   
   - top, left, bottom, right: the scissor bounds in panel coordinates.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     top                                    (integer)
     left                                   (integer)
     bottom                                 (integer)
     right                                  (integer)

]]--

--[[
   XLuaScissorShrink
   
   This function insets (shrinks) the current scissor rectangle by the
   specified amounts on each side. The result is the intersection of the
   current scissor rectangle and the new inset rectangle, so the drawable area
   can only get smaller. This is useful for nested clipping.
   
   - top: inset from the top edge, in pixels.
   - left: inset from the left edge, in pixels.
   - bottom: inset from the bottom edge, in pixels.
   - right: inset from the right edge, in pixels.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     top                                    (integer)
     left                                   (integer)
     bottom                                 (integer)
     right                                  (integer)

]]--

--[[
   XLuaBeginSetupStencilMask
   
   This function begins stencil mask setup. While in setup mode, drawing
   commands write to the stencil buffer instead of to the screen. Draw the
   shapes that define your mask region, then call XPLMEndSetupStencilMask to
   finish.
   
   - bits: the stencil bit pattern to write into the stencil buffer where
     geometry is drawn.
   - mask: a bitmask selecting which stencil bits are written.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     bits                                   (integer)
     mask                                   (integer)

]]--

--[[
   XLuaEndSetupStencilMask
   
   This function ends stencil mask setup. After this call, drawing commands
   once again render to the screen. Call XPLMUseStencilMask to activate the
   mask for subsequent drawing, or XPLMClearStencilMask to discard it.
]]--
--[[
    Returns   : Nothing.

    Parameters:
      None.
]]--

--[[
   XLuaUseStencilMask
   
   This function activates stencil testing. Subsequent drawing is clipped to
   the region defined during stencil setup: only pixels where the stencil
   buffer matches the specified bit pattern are drawn.
   
   - bits: the reference bit pattern to test against.
   - mask: a bitmask selecting which stencil bits participate in the test.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     bits                                   (integer)
     mask                                   (integer)

]]--

--[[
   XLuaClearStencilMask
   
   This function clears the stencil buffer and disables stencil testing.
   Subsequent drawing is no longer clipped by the stencil mask.
]]--
--[[
    Returns   : Nothing.

    Parameters:
      None.
]]--

--[[
This enumeration specifies how a touch zone responds to user interaction.
]]--

XPLMTouchZone = {
    -- The zone is registered but takes no action when touched.
    xplm_TouchZone_Nothing                   = 0,
    -- The zone fires an XPLMCommandRef when touched (begin on mouse-down, end on
    -- mouse-up).
    xplm_TouchZone_Command                   = 1,
    -- The zone delivers touch events to the callback registered via
    -- XPLMSetTouchEventHandler, identified by the zone's identifier field.
    xplm_TouchZone_Identifier                = 2,
}

--[[
   XLuaAccumulateTouchZone
   
   This function registers a touch zone for the current frame. Call this
   during your avionics drawing callback each frame for every interactive
   region on your panel. Zones registered later take priority over earlier
   ones when they overlap.
   
   Returns true if the zone is currently being clicked or held by the user,
   false otherwise. You can use this to provide visual feedback (for example,
   drawing a button in its pressed state).
]]--
--[[
    Returns   : boolean

    Parameters:
     inSpec                                 (XPLMTouchZoneSpec_t)

]]--

--[[
   XLuaSetTouchEventHandler
   
   This function registers a callback to receive touch events for zones of
   type xplm_TouchZone_Identifier on a specific avionics device. When the user
   interacts with an identifier-type zone, your callback is invoked with the
   zone's identifier and the mouse event details.
   
   - avionic: the avionics device handle (from XPLMRegisterAvionicsCallbacksEx
     or XPLMCreateAvionicsEx).
   - handler: your XPLMTouchEvent_f callback.
   - ref: a reference pointer passed through to your callback.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     avionic                                (XPLMAvionicsID)
     handler                                (XPLMTouchEvent_f)
     ref                                    (Any reference value)

]]--

--[[
   XLuaBeginRetainedDrawing
   
   This function begins recording drawing commands. All panel graphics calls
   made after this function and before XPLMEndRetainedDrawing are captured
   into a retained drawing instead of being rendered immediately.
   
   NOTE: Do not nest retained drawing sessions.
]]--
--[[
    Returns   : Nothing.

    Parameters:
      None.
]]--

--[[
   XLuaEndRetainedDrawing
   
   This function ends recording and returns a handle to the captured drawing
   commands. Subsequent panel graphics calls are once again rendered
   immediately.
   
   Returns an opaque handle to the retained drawing.
]]--
--[[
    Returns   : userdata<XPLMRetainedDrawing_t>

    Parameters:
      None.
]]--

--[[
   XLuaDrawRetained
   
   This function replays a previously recorded sequence of drawing commands.
   You can call this multiple times per frame and across multiple frames to
   efficiently re-draw the same content.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     drawing                                (XPLMRetainedDrawing_t)

]]--

--[[
   XLuaDestroyRetainedDrawing
   
   This function destroys a retained drawing and frees its resources.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     drawing                                (XPLMRetainedDrawing_t)

]]--

