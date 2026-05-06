{
   Copyright 2005-2026 Laminar Research, Sandy Barbour and Ben Supnik All
   rights reserved.  See license.txt for usage. X-Plane SDK Version: 4.0.0
}

UNIT XPLMPanelGraphics;
INTERFACE
{
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
}

USES
    XPLMDefs, XPLMUtilities, XPLMDisplay;
   {$A4}
{$IFDEF XPLMPG1}
{___________________________________________________________________________
 * PANEL GRAPHICS primitives
 ___________________________________________________________________________}
{
   These routines draw 2-D vector primitives: lines, line strips, line loops,
   filled polygons, and quad strips. Each primitive type has up to four
   variants:
   
   - Base variant: uniform color, default line width.
   - WithWidth variant: uniform color, caller-specified line width.
   - "c" variant: per-vertex color (using XPLMVertexColor_t), default line
     width.
   - "c" + WithWidth variant: per-vertex color and caller-specified line
     width.
   
   Line-based primitives (Lines, LineStrip, LineLoop) also have a Stipple
   variant that draws dashed lines with a caller-specified dash length and
   line width.
}


   {
    XPLMVertex_t
    
    A 2-D vertex with an x and y position in panel coordinates.
   }
TYPE
   XPLMVertex_t = RECORD
     { Horizontal position in panel coordinates, pixels.                          }
     x                        : Single;
     { Vertical position in panel coordinates, pixels.                            }
     y                        : Single;
   END;
   PXPLMVertex_t = ^XPLMVertex_t;

   {
    XPLMVertexColor_t
    
    A 2-D vertex with an x and y position in panel coordinates and a per-vertex
    color. Use this struct with the "c" drawing variants to assign a different
    color to each vertex; colors are interpolated across the primitive.
   }
   XPLMVertexColor_t = RECORD
     { Horizontal position in panel coordinates, pixels.                          }
     x                        : Single;
     { Vertical position in panel coordinates, pixels.                            }
     y                        : Single;
     { Packed ABGR color as returned by XPLMMakeColor.                            }
     color                    : uint32_t;
   END;
   PXPLMVertexColor_t = ^XPLMVertexColor_t;

   {
    XPLMMakeColor
    
    This function packs four floating-point color components into a single
    uint32_t suitable for use with all panel graphics drawing routines. Each
    component is in the range 0.0 to 1.0 and is clamped before packing. The
    returned value is in ABGR byte order (alpha in the high byte, red in the
    low byte).
   }
    { Thread-safe. This call may be used from threads.                              }
   FUNCTION XPLMMakeColor(
                                        red                 : Single;
                                        green               : Single;
                                        blue                : Single;
                                        alpha               : Single) : uint32_t;
    cdecl; external XPLM_DLL;

   {
    XPLMLines
    
    This function draws disconnected line segments. Every pair of vertices
    defines one segment: the first segment runs from vertices[0] to
    vertices[1], the second from vertices[2] to vertices[3], and so on.
    
    - count: the number of vertices. Should be even; an odd trailing vertex is
      ignored.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMLines(
                                        color               : uint32_t;
                                        vertices[]          : PXPLMVertex_t;
                                        count               : Integer);
    cdecl; external XPLM_DLL;

   {
    XPLMLinesWithWidth
    
    This function draws disconnected line segments with a caller-specified line
    width. Vertex interpretation is the same as XPLMLines.
    
    - lineWidth: the line width in pixels.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMLinesWithWidth(
                                        color               : uint32_t;
                                        lineWidth           : Single;
                                        vertices[]          : PXPLMVertex_t;
                                        count               : Integer);
    cdecl; external XPLM_DLL;

   {
    XPLMLinesc
    
    This function draws disconnected line segments with per-vertex colors.
    Vertex interpretation is the same as XPLMLines; colors are interpolated
    along each segment.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMLinesc(
                                        vertices[]          : PXPLMVertexColor_t;
                                        count               : Integer);
    cdecl; external XPLM_DLL;

   {
    XPLMLinescWithWidth
    
    This function draws disconnected line segments with per-vertex colors and a
    caller-specified line width.
    
    - lineWidth: the line width in pixels.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMLinescWithWidth(
                                        lineWidth           : Single;
                                        vertices[]          : PXPLMVertexColor_t;
                                        count               : Integer);
    cdecl; external XPLM_DLL;

   {
    XPLMLinesStipple
    
    This function draws disconnected dashed line segments. Vertex
    interpretation is the same as XPLMLines. The dash pattern alternates
    between drawn and undrawn segments of equal length.
    
    - dashLength: the length of each dash and gap, in pixels.
    - lineWidth: the line width in pixels.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMLinesStipple(
                                        color               : uint32_t;
                                        pts[]               : PXPLMVertex_t;
                                        count               : Integer;
                                        dashLength          : Single;
                                        lineWidth           : Single);
    cdecl; external XPLM_DLL;

   {
    XPLMLineStrip
    
    This function draws a connected line strip. Vertices are connected in
    order: a segment from vertices[0] to vertices[1], then from vertices[1] to
    vertices[2], and so on. The last vertex is not connected back to the first.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMLineStrip(
                                        color               : uint32_t;
                                        pts[]               : PXPLMVertex_t;
                                        count               : Integer);
    cdecl; external XPLM_DLL;

   {
    XPLMLineStripWithWidth
    
    This function draws a connected line strip with a caller-specified line
    width. Vertex interpretation is the same as XPLMLineStrip.
    
    - lineWidth: the line width in pixels.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMLineStripWithWidth(
                                        color               : uint32_t;
                                        lineWidth           : Single;
                                        pts[]               : PXPLMVertex_t;
                                        count               : Integer);
    cdecl; external XPLM_DLL;

   {
    XPLMLineStripc
    
    This function draws a connected line strip with per-vertex colors. Vertex
    interpretation is the same as XPLMLineStrip; colors are interpolated along
    each segment.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMLineStripc(
                                        pts[]               : PXPLMVertexColor_t;
                                        count               : Integer);
    cdecl; external XPLM_DLL;

   {
    XPLMLineStripcWithWidth
    
    This function draws a connected line strip with per-vertex colors and a
    caller-specified line width.
    
    - lineWidth: the line width in pixels.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMLineStripcWithWidth(
                                        lineWidth           : Single;
                                        pts[]               : PXPLMVertexColor_t;
                                        count               : Integer);
    cdecl; external XPLM_DLL;

   {
    XPLMLineStripStipple
    
    This function draws a connected dashed line strip. Vertex interpretation is
    the same as XPLMLineStrip. The dash pattern alternates between drawn and
    undrawn segments of equal length.
    
    - dashLength: the length of each dash and gap, in pixels.
    - lineWidth: the line width in pixels.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMLineStripStipple(
                                        color               : uint32_t;
                                        pts[]               : PXPLMVertex_t;
                                        count               : Integer;
                                        dashLength          : Single;
                                        lineWidth           : Single);
    cdecl; external XPLM_DLL;

   {
    XPLMLineLoop
    
    This function draws a closed line loop. Vertices are connected in order,
    and the last vertex is automatically connected back to the first, forming a
    closed shape. The interior is not filled.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMLineLoop(
                                        color               : uint32_t;
                                        pts[]               : PXPLMVertex_t;
                                        count               : Integer);
    cdecl; external XPLM_DLL;

   {
    XPLMLineLoopWithWidth
    
    This function draws a closed line loop with a caller-specified line width.
    Vertex interpretation is the same as XPLMLineLoop.
    
    - lineWidth: the line width in pixels.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMLineLoopWithWidth(
                                        color               : uint32_t;
                                        lineWidth           : Single;
                                        pts[]               : PXPLMVertex_t;
                                        count               : Integer);
    cdecl; external XPLM_DLL;

   {
    XPLMLineLoopc
    
    This function draws a closed line loop with per-vertex colors. Vertex
    interpretation is the same as XPLMLineLoop; colors are interpolated along
    each segment.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMLineLoopc(
                                        pts[]               : PXPLMVertexColor_t;
                                        count               : Integer);
    cdecl; external XPLM_DLL;

   {
    XPLMLineLoopcWithWidth
    
    This function draws a closed line loop with per-vertex colors and a
    caller-specified line width.
    
    - lineWidth: the line width in pixels.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMLineLoopcWithWidth(
                                        lineWidth           : Single;
                                        pts[]               : PXPLMVertexColor_t;
                                        count               : Integer);
    cdecl; external XPLM_DLL;

   {
    XPLMLineLoopStipple
    
    This function draws a closed dashed line loop. Vertex interpretation is the
    same as XPLMLineLoop. The dash pattern alternates between drawn and undrawn
    segments of equal length.
    
    - dashLength: the length of each dash and gap, in pixels.
    - lineWidth: the line width in pixels.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMLineLoopStipple(
                                        color               : uint32_t;
                                        pts[]               : PXPLMVertex_t;
                                        count               : Integer;
                                        dashLength          : Single;
                                        lineWidth           : Single);
    cdecl; external XPLM_DLL;

   {
    XPLMPolygon
    
    This function draws a filled convex polygon. The vertices define the
    outline of the polygon, and the interior is filled with the specified
    color.
    
    - count: the number of vertices. You must provide at least 3 vertices.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMPolygon(
                                        color               : uint32_t;
                                        vertices[]          : PXPLMVertex_t;
                                        count               : Integer);
    cdecl; external XPLM_DLL;

   {
    XPLMPolygonWithWidth
    
    This function draws a filled convex polygon with a caller-specified outline
    width. The interior is filled and an outline is drawn at the given width.
    
    - lineWidth: the outline width in pixels.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMPolygonWithWidth(
                                        color               : uint32_t;
                                        lineWidth           : Single;
                                        vertices[]          : PXPLMVertex_t;
                                        count               : Integer);
    cdecl; external XPLM_DLL;

   {
    XPLMPolygonc
    
    This function draws a filled convex polygon with per-vertex colors. Colors
    are interpolated across the polygon interior.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMPolygonc(
                                        vertices[]          : PXPLMVertexColor_t;
                                        count               : Integer);
    cdecl; external XPLM_DLL;

   {
    XPLMPolygoncWithWidth
    
    This function draws a filled convex polygon with per-vertex colors and a
    caller-specified outline width.
    
    - lineWidth: the outline width in pixels.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMPolygoncWithWidth(
                                        lineWidth           : Single;
                                        vertices[]          : PXPLMVertexColor_t;
                                        count               : Integer);
    cdecl; external XPLM_DLL;

   {
    XPLMQuadstrip
    
    This function draws a series of connected filled quadrilaterals. Vertices
    are taken in pairs: the first quad is formed by vertices[0], vertices[1],
    vertices[2], vertices[3]; the next quad shares its leading edge with the
    previous one, formed by vertices[2], vertices[3], vertices[4], vertices[5];
    and so on.
    
    - count: the number of vertices. Must be even and at least 4.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMQuadstrip(
                                        color               : uint32_t;
                                        vertices[]          : PXPLMVertex_t;
                                        count               : Integer);
    cdecl; external XPLM_DLL;

   {
    XPLMQuadstripWithWidth
    
    This function draws a quad strip with a caller-specified outline width.
    Vertex interpretation is the same as XPLMQuadstrip.
    
    - lineWidth: the outline width in pixels.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMQuadstripWithWidth(
                                        color               : uint32_t;
                                        lineWidth           : Single;
                                        vertices[]          : PXPLMVertex_t;
                                        count               : Integer);
    cdecl; external XPLM_DLL;

   {
    XPLMQuadstripc
    
    This function draws a quad strip with per-vertex colors. Vertex
    interpretation is the same as XPLMQuadstrip; colors are interpolated across
    each quad.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMQuadstripc(
                                        vertices[]          : PXPLMVertexColor_t;
                                        count               : Integer);
    cdecl; external XPLM_DLL;

   {
    XPLMQuadstripcWithWidth
    
    This function draws a quad strip with per-vertex colors and a
    caller-specified outline width.
    
    - lineWidth: the outline width in pixels.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMQuadstripcWithWidth(
                                        lineWidth           : Single;
                                        vertices[]          : PXPLMVertexColor_t;
                                        count               : Integer);
    cdecl; external XPLM_DLL;

{$ENDIF XPLMPG1}
{$IFDEF XPLMPG1}
{___________________________________________________________________________
 * PANEL GRAPHICS fonts
 ___________________________________________________________________________}
{
   These routines create fonts from TrueType font files and draw text onto the
   panel. You create a font handle, add one or more TTF faces to it, then use
   the handle to measure and draw strings. Font handles must be destroyed when
   no longer needed.
}


   {
    XPLMCharSet_t
    
    This enumeration specifies the character set for a font created with
    XPLMCreateFont. The character set determines which glyphs are rasterized
    and available for drawing.
   }
TYPE
   XPLMCharSet_t = (
     { Digits 0-9 and common numeric punctuation only.                            }
      xplm_CharSetDigits                       = 0
 
     { The printable ASCII character range (codes 32-126).                        }
     ,xplm_CharSetASCII                        = 1
 
     { Full Unicode support; glyphs are rasterized on demand.                     }
     ,xplm_CharSetUnicode                      = 2
 
   );
   PXPLMCharSet_t = ^XPLMCharSet_t;

   {
    XPLMJustification_t
    
    This enumeration specifies horizontal text justification for the font
    drawing routines. The x and y position you pass to a drawing function is
    the baseline of the text at the anchor point determined by justification:
    left-aligned text anchors at the left edge, centered text at the midpoint,
    and right-aligned text at the right edge.
   }
   XPLMJustification_t = (
     { Left-justified; x is the left edge of the string.                          }
      xplm_JustLeft                            = 0
 
     { Center-justified; x is the horizontal center of the string.                }
     ,xplm_JustCenter                          = 1
 
     { Right-justified; x is the right edge of the string.                        }
     ,xplm_JustRight                           = 2
 
   );
   PXPLMJustification_t = ^XPLMJustification_t;

   {
    XPLMFontMetrics_t
    
    XPLMFontMetrics_t receives font measurement data from XPLMFontGetMetrics.
    The structure may be expanded in future SDKs - always set structSize to the
    size of your structure in bytes.
   }
   XPLMFontMetrics_t = RECORD
     { Set to sizeof(XPLMFontMetrics_t).                                          }
     structSize               : Integer;
     { Total line height including leading, in pixels.                            }
     lineHeight               : Single;
     { Distance from the baseline to the top of the tallest glyph, in pixels.     }
     lineAscent               : Single;
     { Distance from the baseline to the bottom of the lowest descender, in       }
     { pixels. This value is positive.                                            }
     lineDescent              : Single;
   END;
   PXPLMFontMetrics_t = ^XPLMFontMetrics_t;

   {
    XPLMFontHandle
    
    An opaque handle to a font created by XPLMCreateFont. Pass this handle to
    the font measurement and drawing routines. Destroy the handle with
    XPLMDestroyFont when you are done with it.
   }
   XPLMFontHandle = Pvoid*;
   PXPLMFontHandle = ^XPLMFontHandle;

   {
    XPLMCreateFont
    
    This function creates a new font handle. The character set determines which
    glyphs are available for rendering. After creating the font, add one or
    more TrueType faces with XPLMFontAddFace before drawing.
    
    Returns an opaque font handle.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMCreateFont(
                                        charset             : XPLMCharSet_t);
    cdecl; external XPLM_DLL;

   {
    XPLMDestroyFont
    
    This function destroys a font handle and frees all associated resources.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMDestroyFont(
                                   VAR  font                : );
    cdecl; external XPLM_DLL;

   {
    XPLMFontAddFace
    
    This function adds a TrueType font face to an existing font handle. You may
    add multiple faces to a single font to provide fallback glyphs; if a glyph
    is not found in the first face, subsequent faces are searched in the order
    they were added.
    
    - ttf_path: a file system path to a .ttf or .otf font file.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMFontAddFace(
                                   VAR  font                : ;
                                        ttf_path            : P*);
    cdecl; external XPLM_DLL;

   {
    XPLMFontGetMetrics
    
    This function returns line metrics for a font at a given size. The metrics
    describe the vertical dimensions of a line of text and are useful for
    computing text layout.
    
    - fontSize: the font size in pixels.
    - outMetrics: receives the computed metrics. You must set
      outMetrics->structSize before calling.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMFontGetMetrics(
                                   VAR  font                : ;
                                        fontSize            : Single;
                                        outMetrics          : PXPLMFontMetrics_t*);
    cdecl; external XPLM_DLL;

   {
    XPLMFontMeasureString
    
    This function returns the width in pixels that a string would occupy if
    drawn at the given font size. The string is not drawn.
    
    Returns the horizontal advance width, in pixels.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   FUNCTION XPLMFontMeasureString(
                                   VAR  font                : ;
                                        fontSize            : Single;
                                        string              : P*) : Single;
    cdecl; external XPLM_DLL;

   {
    XPLMFontGetLineCount
    
    This function calculates how many lines a string would occupy if
    word-wrapped to the specified width at the given font size.
    
    Returns the number of lines.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   FUNCTION XPLMFontGetLineCount(
                                   VAR  font                : ;
                                        fontSize            : Single;
                                        string              : P*;
                                        width               : Single) : Integer;
    cdecl; external XPLM_DLL;

   {
    XPLMFontFitForward
    
    This function returns the number of characters from the beginning of a
    string that fit within the specified width at the given font size.
    Characters are measured left to right.
    
    Returns a character count.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   FUNCTION XPLMFontFitForward(
                                   VAR  font                : ;
                                        fontSize            : Single;
                                        string              : P*;
                                        width               : Single) : Integer;
    cdecl; external XPLM_DLL;

   {
    XPLMFontFitReverse
    
    This function returns the number of characters from the end of a string
    that fit within the specified width at the given font size. Characters are
    measured right to left. This is useful for right-aligning a truncated
    string.
    
    Returns a character count.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   FUNCTION XPLMFontFitReverse(
                                   VAR  font                : ;
                                        fontSize            : Single;
                                        string              : P*;
                                        width               : Single) : Integer;
    cdecl; external XPLM_DLL;

   {
    XPLMFontDrawString
    
    This function draws a null-terminated string at the specified position with
    the given font, size, color, and justification. The x and y coordinates
    specify the baseline position at the justification anchor point.
    
    - fontSize: the font size in pixels.
    - x, y: the anchor position of the baseline, in panel coordinates.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMFontDrawString(
                                   VAR  font                : ;
                                        color               : uint32_t;
                                        fontSize            : Single;
                                        x                   : Single;
                                        y                   : Single;
                                        string              : P*;
                                        justification       : XPLMJustification_t);
    cdecl; external XPLM_DLL;

   {
    XPLMFontDrawStringFixedSpacing
    
    This function draws a null-terminated string using fixed character spacing
    instead of the font's natural proportional spacing. Each character occupies
    exactly fixedSpacing pixels horizontally, regardless of the glyph's actual
    width. This is useful for numeric readouts where digits must not shift as
    values change.
    
    - fontSize: the font size in pixels.
    - x, y: the anchor position of the baseline, in panel coordinates.
    - fixedSpacing: the horizontal advance per character, in pixels.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMFontDrawStringFixedSpacing(
                                   VAR  font                : ;
                                        color               : uint32_t;
                                        fontSize            : Single;
                                        x                   : Single;
                                        y                   : Single;
                                        string              : P*;
                                        fixedSpacing        : Integer;
                                        justification       : XPLMJustification_t);
    cdecl; external XPLM_DLL;

   {
    XPLMFontDrawStringWordWrapped
    
    This function draws a null-terminated string with automatic word wrapping.
    Text is broken at word boundaries to fit within the specified wrap width.
    Lines are stacked downward from the initial y position, spaced by the
    font's line height.
    
    - fontSize: the font size in pixels.
    - x, y: the anchor position of the first line's baseline, in panel
      coordinates.
    - wrapWidth: the maximum line width in pixels before wrapping.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMFontDrawStringWordWrapped(
                                   VAR  font                : ;
                                        color               : uint32_t;
                                        fontSize            : Single;
                                        x                   : Single;
                                        y                   : Single;
                                        string              : P*;
                                        wrapWidth           : Integer;
                                        justification       : XPLMJustification_t);
    cdecl; external XPLM_DLL;

   {
    XPLMFontDrawStringRotated
    
    This function draws a null-terminated string rotated by the specified angle
    around the anchor point. The anchor point is determined by x, y, and the
    justification, just as in XPLMFontDrawString.
    
    - fontSize: the font size in pixels.
    - x, y: the anchor position of the baseline, in panel coordinates.
    - angle: the rotation angle in degrees, positive counterclockwise.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMFontDrawStringRotated(
                                   VAR  font                : ;
                                        color               : uint32_t;
                                        fontSize            : Single;
                                        x                   : Single;
                                        y                   : Single;
                                        string              : P*;
                                        angle               : Single;
                                        justification       : XPLMJustification_t);
    cdecl; external XPLM_DLL;

{$ENDIF XPLMPG1}
{$IFDEF XPLMPG1}
{___________________________________________________________________________
 * PANEL GRAPHICS Texture atlas
 ___________________________________________________________________________}
{
   These routines manage texture atlases for drawing images on the panel. A
   texture atlas packs multiple source images into a single GPU texture for
   efficient rendering. The typical workflow is:
   
   - Create an atlas with XPLMCreateTextureAtlas.
   - Add images from files or raw pixel data. Each image (or cell of an image
     set) receives a zero-based index.
   - Call XPLMTextureAtlasBake to upload the atlas to the GPU.
   - Draw images using the DrawAt, DrawIn, DrawStretched, DrawScaled, or
     DrawMesh routines.
   - Destroy the atlas with XPLMDestroyTextureAtlas when it is no longer
     needed.
   
   All images are stored as RGBA, 4 bytes per pixel.
}


TYPE
   {
    XPLMTextureAtlasRef
    
    An opaque handle to a texture atlas. Create one with XPLMCreateTextureAtlas
    and destroy it with XPLMDestroyTextureAtlas.
   }
   XPLMTextureAtlasRef = Pvoid *;
   PXPLMTextureAtlasRef = ^XPLMTextureAtlasRef;

   {
    XPLMTextureVertex_t
    
    A vertex for textured mesh drawing. Combines a position in panel
    coordinates with normalized texture coordinates within the image.
   }
   XPLMTextureVertex_t = RECORD
     { Horizontal position in panel coordinates, pixels.                          }
     x                        : Single;
     { Vertical position in panel coordinates, pixels.                            }
     y                        : Single;
     { Horizontal texture coordinate, 0.0 (left) to 1.0 (right), within the image.}
     s                        : Single;
     { Vertical texture coordinate, 0.0 (bottom) to 1.0 (top), within the image.  }
     t                        : Single;
   END;
   PXPLMTextureVertex_t = ^XPLMTextureVertex_t;

   {
    XPLMCreateTextureAtlas
    
    This function creates a new, empty texture atlas. After creating the atlas,
    add images with the XPLMTextureAtlasAddImage or
    XPLMTextureAtlasAddImageFile family of functions, then call
    XPLMTextureAtlasBake before drawing.
    
    Returns an opaque atlas handle.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMCreateTextureAtlas;
    cdecl; external XPLM_DLL;

   {
    XPLMDestroyTextureAtlas
    
    This function destroys a texture atlas and frees all associated GPU and CPU
    resources.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMDestroyTextureAtlas(
                                   VAR  inTextureAtlas      : );
    cdecl; external XPLM_DLL;

   {
    XPLMTextureAtlasAddImageFile
    
    This function loads a PNG image file and adds it to the atlas as a single
    image. Call this before XPLMTextureAtlasBake.
    
    - inImageFilePath: the file system path to a PNG file.
    
    Returns the zero-based image index assigned to this image.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   FUNCTION XPLMTextureAtlasAddImageFile(
                                   VAR  inTextureAtlas      : ;
                                        inImageFilePath     : Pchar *) : Integer;
    cdecl; external XPLM_DLL;

   {
    XPLMTextureAtlasAddImageFileSet
    
    This function loads a PNG image file and subdivides it into a grid of
    cells, adding each cell to the atlas as a separate image. This is useful
    for sprite sheets and image strip assets. Call this before
    XPLMTextureAtlasBake.
    
    - inImageFilePath: the file system path to a PNG file.
    - inCellsX: the number of columns to divide the image into.
    - inCellsY: the number of rows to divide the image into.
    
    Returns the zero-based image index of the first cell (top-left). Subsequent
    cells are numbered in row-major order: index + y * inCellsX + x.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   FUNCTION XPLMTextureAtlasAddImageFileSet(
                                   VAR  inTextureAtlas      : ;
                                        inImageFilePath     : Pchar *;
                                        inCellsX            : Integer;
                                        inCellsY            : Integer) : Integer;
    cdecl; external XPLM_DLL;

   {
    XPLMTextureAtlasAddImage
    
    This function adds a single image from raw pixel data to the atlas. The
    pixel data must be RGBA format, 4 bytes per pixel, with rows ordered from
    top to bottom. Call this before XPLMTextureAtlasBake.
    
    - inImage: pointer to the raw RGBA pixel data.
    - inWidth: the image width in pixels.
    - inHeight: the image height in pixels.
    
    Returns the zero-based image index assigned to this image.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   FUNCTION XPLMTextureAtlasAddImage(
                                   VAR  inTextureAtlas      : ;
                                        inImage             : Punsigned char *;
                                        inWidth             : Integer;
                                        inHeight            : Integer) : Integer;
    cdecl; external XPLM_DLL;

   {
    XPLMTextureAtlasAddImageSet
    
    This function adds raw pixel data to the atlas, subdividing it into a grid
    of cells. Each cell is added as a separate image. The pixel data must be
    RGBA format, 4 bytes per pixel, with rows ordered from top to bottom. Call
    this before XPLMTextureAtlasBake.
    
    - inImage: pointer to the raw RGBA pixel data.
    - inWidth: the total image width in pixels.
    - inHeight: the total image height in pixels.
    - inCellsX: the number of columns to divide the image into.
    - inCellsY: the number of rows to divide the image into.
    
    Returns the zero-based image index of the first cell. Subsequent cells are
    numbered in row-major order: index + y * inCellsX + x.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   FUNCTION XPLMTextureAtlasAddImageSet(
                                   VAR  inTextureAtlas      : ;
                                        inImage[]           : Puint8_t;
                                        inWidth             : Integer;
                                        inHeight            : Integer;
                                        inCellsX            : Integer;
                                        inCellsY            : Integer) : Integer;
    cdecl; external XPLM_DLL;

   {
    XPLMTextureAtlasBake
    
    This function packs all previously added images into a GPU texture. You
    must call this after adding all images and before any draw calls. Once
    baked, you cannot add more images to the atlas.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMTextureAtlasBake(
                                   VAR  inTextureAtlas      : );
    cdecl; external XPLM_DLL;

   {
    XPLMTextureAtlasGetImageWidth
    
    This function returns the width in pixels of a single image (or cell) in
    the atlas.
    
    Returns the image width in pixels.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   FUNCTION XPLMTextureAtlasGetImageWidth(
                                   VAR  inTextureAtlas      : ;
                                        inImageIndex        : Integer) : Integer;
    cdecl; external XPLM_DLL;

   {
    XPLMTextureAtlasGetImageHeight
    
    This function returns the height in pixels of a single image (or cell) in
    the atlas.
    
    Returns the image height in pixels.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   FUNCTION XPLMTextureAtlasGetImageHeight(
                                   VAR  inTextureAtlas      : ;
                                        inImageIndex        : Integer) : Integer;
    cdecl; external XPLM_DLL;

   {
    XPLMTextureAtlasGetImageUVMap
    
    This function returns the UV coordinates of an image within the atlas
    texture. This is useful for custom mesh rendering with
    XPLMTextureAtlasDrawMesh.
    
    - outUV: a pointer to an array of 4 floats that receives [s1, t1, s2, t2],
      where (s1, t1) is the bottom-left corner and (s2, t2) is the top-right
      corner in atlas texture space.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMTextureAtlasGetImageUVMap(
                                   VAR  inTextureAtlas      : ;
                                        inImageIndex        : Integer;
                                        outUV[4]            : PSingle);
    cdecl; external XPLM_DLL;

   {
    XPLMTextureAtlasDrawAt
    
    This function draws an atlas image at its native resolution. The image is
    positioned with its top-left corner at (inX, inY) and extends rightward and
    downward by its native pixel dimensions.
    
    - inTintColor: a color that is multiplied with the texture. Use
      XPLMMakeColor(1, 1, 1, 1) for no tinting.
    - inX: the left edge of the image, in panel coordinates.
    - inY: the top edge of the image, in panel coordinates.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMTextureAtlasDrawAt(
                                   VAR  inTextureAtlas      : ;
                                        inImageIndex        : Integer;
                                        inTintColor         : uint32_t;
                                        inX                 : Single;
                                        inY                 : Single);
    cdecl; external XPLM_DLL;

   {
    XPLMTextureAtlasDrawIn
    
    This function draws an atlas image scaled to fill a rectangular region. The
    image is stretched or compressed to exactly match the specified bounds.
    
    - inTintColor: a color that is multiplied with the texture.
    - inLeft, inTop, inRight, inBottom: the bounding rectangle in panel
      coordinates.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMTextureAtlasDrawIn(
                                   VAR  inTextureAtlas      : ;
                                        inImageIndex        : Integer;
                                        inTintColor         : uint32_t;
                                        inLeft              : Single;
                                        inTop               : Single;
                                        inRight             : Single;
                                        inBottom            : Single);
    cdecl; external XPLM_DLL;

   {
    XPLMTextureAtlasDrawStretched
    
    This function draws an atlas image using 9-slice scaling into a rectangular
    region. The image is divided into a 3x3 grid (each slice being one third of
    the original width and height). The four corner slices are drawn at their
    native size, the four edge slices are stretched along one axis, and the
    center slice is stretched in both directions. This preserves corners and
    borders when scaling UI elements like buttons or panels.
    
    - inTintColor: a color that is multiplied with the texture.
    - inLeft, inTop, inRight, inBottom: the bounding rectangle in panel
      coordinates.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMTextureAtlasDrawStretched(
                                   VAR  inTextureAtlas      : ;
                                        inImageIndex        : Integer;
                                        inTintColor         : uint32_t;
                                        inLeft              : Single;
                                        inTop               : Single;
                                        inRight             : Single;
                                        inBottom            : Single);
    cdecl; external XPLM_DLL;

   {
    XPLMTextureAtlasDrawScaled
    
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
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMTextureAtlasDrawScaled(
                                   VAR  inTextureAtlas      : ;
                                        inImageIndex        : Integer;
                                        inTintColor         : uint32_t;
                                        inXPanel            : Single;
                                        inYPanel            : Single;
                                        inXAtlas            : Single;
                                        inYAtlas            : Single;
                                        inXScale            : Single;
                                        inYScale            : Single;
                                        inRotateCW          : Single);
    cdecl; external XPLM_DLL;

   {
    XPLMTextureAtlasDrawMesh
    
    This function draws an atlas image onto an arbitrary triangle-strip mesh.
    Each vertex specifies both a panel-space position and a normalized texture
    coordinate within the image (0.0 to 1.0). This gives you full control over
    how the image is mapped onto geometry.
    
    - inTintColor: a color that is multiplied with the texture.
    - vertices: an array of XPLMTextureVertex_t vertices defining the triangle
      strip.
    - count: the number of vertices. Must be at least 3.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMTextureAtlasDrawMesh(
                                   VAR  inTextureAtlas      : ;
                                        inImageIndex        : Integer;
                                        inTintColor         : uint32_t;
                                        vertices[]          : PXPLMTextureVertex_t;
                                        count               : Integer);
    cdecl; external XPLM_DLL;

{$ENDIF XPLMPG1}
{$IFDEF XPLMPG1}
{___________________________________________________________________________
 * PANEL_GRAPHICS transform/scissors/masks
 ___________________________________________________________________________}
{
   These routines modify the drawing state for subsequent panel graphics
   calls. The transformation matrix controls the position, rotation, and scale
   of all drawing. The scissor rectangle clips drawing to a rectangular
   region. The stencil mask clips drawing to an arbitrary shape.
   
   Each state type has a push/pop stack. Always push before modifying state
   and pop to restore the previous state when you are done.
}


   {
    XPLMTransformPush
    
    This function saves the current transformation matrix onto the transform
    stack. Call XPLMTransformPop to restore it. Calls must be balanced.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMTransformPush;
    cdecl; external XPLM_DLL;

   {
    XPLMTransformPop
    
    This function restores the transformation matrix from the top of the
    transform stack, undoing all translate, rotate, and scale operations since
    the matching XPLMTransformPush.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMTransformPop;
    cdecl; external XPLM_DLL;

   {
    XPLMTransformTranslate
    
    This function translates (offsets) all subsequent drawing by the specified
    amounts. The translation is applied on top of the current transformation
    matrix.
    
    - dx: horizontal offset in pixels, positive to the right.
    - dy: vertical offset in pixels, positive upward.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMTransformTranslate(
                                        dx                  : Single;
                                        dy                  : Single);
    cdecl; external XPLM_DLL;

   {
    XPLMTransformRotate
    
    This function rotates all subsequent drawing around a center point. The
    rotation is applied on top of the current transformation matrix.
    
    - centerX, centerY: the center of rotation in panel coordinates.
    - angle: the rotation angle in degrees, positive counterclockwise.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMTransformRotate(
                                        centerX             : Single;
                                        centerY             : Single;
                                        angle               : Single);
    cdecl; external XPLM_DLL;

   {
    XPLMTransformScale
    
    This function scales all subsequent drawing relative to the origin of the
    current coordinate system. The scale is applied on top of the current
    transformation matrix.
    
    - scaleX: horizontal scale factor. 1.0 is no change, 2.0 doubles width.
    - scaleY: vertical scale factor. 1.0 is no change, 2.0 doubles height.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMTransformScale(
                                        scaleX              : Single;
                                        scaleY              : Single);
    cdecl; external XPLM_DLL;

   {
    XPLMScissorPush
    
    This function saves the current scissor rectangle onto the scissor stack.
    Call XPLMScissorPop to restore it. Calls must be balanced.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMScissorPush;
    cdecl; external XPLM_DLL;

   {
    XPLMScissorPop
    
    This function restores the scissor rectangle from the top of the scissor
    stack, undoing any set or shrink operations since the matching
    XPLMScissorPush.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMScissorPop;
    cdecl; external XPLM_DLL;

   {
    XPLMScissorSet
    
    This function sets an absolute scissor rectangle. Only pixels within this
    rectangle are drawn; everything outside is clipped.
    
    - top, left, bottom, right: the scissor bounds in panel coordinates.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMScissorSet(
                                        top                 : Integer;
                                        left                : Integer;
                                        bottom              : Integer;
                                        right               : Integer);
    cdecl; external XPLM_DLL;

   {
    XPLMScissorShrink
    
    This function insets (shrinks) the current scissor rectangle by the
    specified amounts on each side. The result is the intersection of the
    current scissor rectangle and the new inset rectangle, so the drawable area
    can only get smaller. This is useful for nested clipping.
    
    - top: inset from the top edge, in pixels.
    - left: inset from the left edge, in pixels.
    - bottom: inset from the bottom edge, in pixels.
    - right: inset from the right edge, in pixels.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMScissorShrink(
                                        top                 : Integer;
                                        left                : Integer;
                                        bottom              : Integer;
                                        right               : Integer);
    cdecl; external XPLM_DLL;

   {
    XPLMBeginSetupStencilMask
    
    This function begins stencil mask setup. While in setup mode, drawing
    commands write to the stencil buffer instead of to the screen. Draw the
    shapes that define your mask region, then call XPLMEndSetupStencilMask to
    finish.
    
    - bits: the stencil bit pattern to write into the stencil buffer where
      geometry is drawn.
    - mask: a bitmask selecting which stencil bits are written.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMBeginSetupStencilMask(
                                        bits                : unsigned int;
                                        mask                : unsigned int);
    cdecl; external XPLM_DLL;

   {
    XPLMEndSetupStencilMask
    
    This function ends stencil mask setup. After this call, drawing commands
    once again render to the screen. Call XPLMUseStencilMask to activate the
    mask for subsequent drawing, or XPLMClearStencilMask to discard it.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMEndSetupStencilMask;
    cdecl; external XPLM_DLL;

   {
    XPLMUseStencilMask
    
    This function activates stencil testing. Subsequent drawing is clipped to
    the region defined during stencil setup: only pixels where the stencil
    buffer matches the specified bit pattern are drawn.
    
    - bits: the reference bit pattern to test against.
    - mask: a bitmask selecting which stencil bits participate in the test.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMUseStencilMask(
                                        bits                : unsigned int;
                                        mask                : unsigned int);
    cdecl; external XPLM_DLL;

   {
    XPLMClearStencilMask
    
    This function clears the stencil buffer and disables stencil testing.
    Subsequent drawing is no longer clipped by the stencil mask.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMClearStencilMask;
    cdecl; external XPLM_DLL;

{$ENDIF XPLMPG1}
{$IFDEF XPLMPG1}
{___________________________________________________________________________
 * PANEL GRAPHICS Hot Zones
 ___________________________________________________________________________}
{
   These routines define interactive touch zones on a panel surface. You call
   XPLMAccumulateTouchZone during your drawing callback to declare rectangular
   regions that respond to mouse clicks or touches. Each zone can either fire
   an X-Plane command automatically or deliver raw touch events to a callback
   you register with XPLMAvionicsSetTouchEventHandler.
}


   {
    XPLMTouchZone
    
    This enumeration specifies how a touch zone responds to user interaction.
   }
TYPE
   XPLMTouchZone = (
     { The zone is registered but takes no action when touched.                   }
      xplm_TouchZone_Nothing                   = 0
 
     { The zone fires an XPLMCommandRef when touched (begin on mouse-down, end on }
     { mouse-up).                                                                 }
     ,xplm_TouchZone_Command                   = 1
 
     { The zone delivers touch events to the callback registered via              }
     { XPLMAvionicsSetTouchEventHandler, identified by the zone's identifier      }
     { field.                                                                     }
     ,xplm_TouchZone_Identifier                = 2
 
   );
   PXPLMTouchZone = ^XPLMTouchZone;

   {
    XPLMTouchEvent_f
    
    Your touch event callback is invoked when the user interacts with a touch
    zone whose type is xplm_TouchZone_Identifier. You receive the zone's
    identifier, the mouse status, the current position, the delta from the
    initial click point, and the mouse button involved.
   }
     XPLMTouchEvent_f = PROCEDURE(
                                    identifier          : Integer;
                                    status              : XPLMMouseStatus;
                                    x                   : Integer;
                                    y                   : Integer;
                                    dx                  : Integer;
                                    dy                  : Integer;
                                    button              : Integer;
                                    ref                 : Pvoid*); cdecl;    { Can be nil }

   {
    XPLMTouchZoneSpec_t
    
    XPLMTouchZoneSpec_t describes a single interactive touch zone on the panel.
    Pass a pointer to this struct to XPLMAccumulateTouchZone during your
    drawing callback. The structure may be expanded in future SDKs - always set
    structSize to the size of your structure in bytes.
   }
   XPLMTouchZoneSpec_t = RECORD
     { Set to sizeof(XPLMTouchZoneSpec_t).                                        }
     structSize               : Integer;
     { How the zone responds to interaction.                                      }
     type                     : XPLMTouchZone;
     { The command to fire. Only used when type is xplm_TouchZone_Command.        }
     command                  : XPLMCommandRef;
     { An integer you assign to identify this zone in your XPLMTouchEvent_f       }
     { callback. Only used when type is xplm_TouchZone_Identifier.                }
     identifier               : Integer;
     { Left edge of the zone, in panel coordinates.                               }
     left                     : Integer;
     { Top edge of the zone, in panel coordinates.                                }
     top                      : Integer;
     { Right edge of the zone, in panel coordinates.                              }
     right                    : Integer;
     { Bottom edge of the zone, in panel coordinates.                             }
     bottom                   : Integer;
   END;
   PXPLMTouchZoneSpec_t = ^XPLMTouchZoneSpec_t;

   {
    XPLMAccumulateTouchZone
    
    This function registers a touch zone for the current frame. Call this
    during your avionics drawing callback each frame for every interactive
    region on your panel. Zones registered later take priority over earlier
    ones when they overlap.
    
    Returns true if the zone is currently being clicked or held by the user,
    false otherwise. You can use this to provide visual feedback (for example,
    drawing a button in its pressed state).
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   FUNCTION XPLMAccumulateTouchZone(
                                        inSpec              : PXPLMTouchZoneSpec_t *) : Integer;
    cdecl; external XPLM_DLL;

   {
    XPLMAvionicsSetTouchEventHandler
    
    This function registers a callback to receive touch events for zones of
    type xplm_TouchZone_Identifier on a specific avionics device. When the user
    interacts with an identifier-type zone, your callback is invoked with the
    zone's identifier and the mouse event details.
    
    - avionic: the avionics device handle (from XPLMRegisterAvionicsCallbacksEx
      or XPLMCreateAvionicsEx).
    - handler: your XPLMTouchEvent_f callback.
    - ref: a reference pointer passed through to your callback.
   }
    { Thread-safe. This call may be used from threads.                              }
   PROCEDURE XPLMAvionicsSetTouchEventHandler(
                                        avionic             : XPLMAvionicsID;
                                        handler             : PXPLMTouchEvent_f;    { Can be nil }
                                        ref                 : Pvoid*);    { Can be nil }
    cdecl; external XPLM_DLL;

   {
    XPLMWindowSetTouchEventHandler
   }
    { Thread-safe. This call may be used from threads.                              }
   PROCEDURE XPLMWindowSetTouchEventHandler(
                                        window              : XPLMWindowID;
                                        handler             : PXPLMTouchEvent_f;    { Can be nil }
                                        ref                 : Pvoid*);    { Can be nil }
    cdecl; external XPLM_DLL;

{$ENDIF XPLMPG1}
{$IFDEF XPLMPG1}
{___________________________________________________________________________
 * PANEL GRAPHICS Retained Drawing
 ___________________________________________________________________________}
{
   These routines let you record a sequence of panel graphics drawing commands
   and replay them efficiently on subsequent frames. This is useful for static
   or infrequently changing parts of a display: record once, then replay each
   frame without reissuing individual draw calls.
   
   WARNING: A retained drawing captures references to the texture atlases and
   fonts used during recording. If you destroy a texture atlas or font that
   was used in a retained drawing, you must also destroy that retained drawing
   - replaying it will reference invalid resources.
}


TYPE
   {
    XPLMRetainedDrawing_t
    
    An opaque handle to a recorded sequence of drawing commands. Create one by
    bracketing draw calls between XPLMBeginRetainedDrawing and
    XPLMEndRetainedDrawing. Destroy it with XPLMDestroyRetainedDrawing when it
    is no longer needed.
   }
   XPLMRetainedDrawing_t = Pvoid *;
   PXPLMRetainedDrawing_t = ^XPLMRetainedDrawing_t;

   {
    XPLMBeginRetainedDrawing
    
    This function begins recording drawing commands. All panel graphics calls
    made after this function and before XPLMEndRetainedDrawing are captured
    into a retained drawing instead of being rendered immediately.
    
    NOTE: Do not nest retained drawing sessions.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMBeginRetainedDrawing;
    cdecl; external XPLM_DLL;

   {
    XPLMEndRetainedDrawing
    
    This function ends recording and returns a handle to the captured drawing
    commands. Subsequent panel graphics calls are once again rendered
    immediately.
    
    Returns an opaque handle to the retained drawing.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMEndRetainedDrawing;
    cdecl; external XPLM_DLL;

   {
    XPLMDrawRetained
    
    This function replays a previously recorded sequence of drawing commands.
    You can call this multiple times per frame and across multiple frames to
    efficiently re-draw the same content.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMDrawRetained(
                                   VAR  drawing             : );
    cdecl; external XPLM_DLL;

   {
    XPLMDestroyRetainedDrawing
    
    This function destroys a retained drawing and frees its resources.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMDestroyRetainedDrawing(
                                   VAR  drawing             : );
    cdecl; external XPLM_DLL;

{$ENDIF XPLMPG1}
{___________________________________________________________________________
 * Host API
 ___________________________________________________________________________}

CONST
   XPLMPanelGraphicsHostApiVersion = 0;

   {
    XPLMPGOpcode
   }
TYPE
   XPLMPGOpcode = (
      xplm_PGO_term                            = 1
 
     ,xplm_PGO_lines                           = 2
 
     ,xplm_PGO_lines_width                     = 3
 
     ,xplm_PGO_linesc                          = 4
 
     ,xplm_PGO_linesc_width                    = 5
 
     ,xplm_PGO_lines_stipple                   = 6
 
     ,xplm_PGO_linestrip                       = 7
 
     ,xplm_PGO_linestrip_width                 = 8
 
     ,xplm_PGO_linestripc                      = 9
 
     ,xplm_PGO_linestripc_width                = 10
 
     ,xplm_PGO_linestrip_stipple               = 11
 
     ,xplm_PGO_lineloop                        = 12
 
     ,xplm_PGO_lineloop_width                  = 13
 
     ,xplm_PGO_lineloopc                       = 14
 
     ,xplm_PGO_lineloopc_width                 = 15
 
     ,xplm_PGO_lineloop_stipple                = 16
 
     ,xplm_PGO_polygon                         = 17
 
     ,xplm_PGO_polygon_width                   = 18
 
     ,xplm_PGO_polygonc                        = 19
 
     ,xplm_PGO_polygonc_width                  = 20
 
     ,xplm_PGO_quadstrip                       = 21
 
     ,xplm_PGO_quadstrip_width                 = 22
 
     ,xplm_PGO_quadstripc                      = 23
 
     ,xplm_PGO_quadstripc_width                = 24
 
     ,xplm_PGO_drawstring                      = 25
 
     ,xplm_PGO_drawstring_fixed_width          = 26
 
     ,xplm_PGO_drawstring_word_wrapped         = 27
 
     ,xplm_PGO_drawstring_rotated              = 28
 
     ,xplm_PGO_drawtexture                     = 29
 
     ,xplm_PGO_transform_push                  = 30
 
     ,xplm_PGO_transform_pop                   = 31
 
     ,xplm_PGO_transform_translate             = 32
 
     ,xplm_PGO_transform_rotate                = 33
 
     ,xplm_PGO_transform_scale                 = 34
 
     ,xplm_PGO_scissor_push                    = 35
 
     ,xplm_PGO_scissor_pop                     = 36
 
     ,xplm_PGO_scissor_set                     = 37
 
     ,xplm_PGO_scissor_shrink                  = 38
 
     ,xplm_PGO_stencil_begin                   = 39
 
     ,xplm_PGO_stencil_end                     = 40
 
     ,xplm_PGO_stencil_use                     = 41
 
     ,xplm_PGO_stencil_clear                   = 42
 
   );
   PXPLMPGOpcode = ^XPLMPGOpcode;










   {
    XPAtlasEntry
   }
   XPAtlasEntry = RECORD
     storage                  : Punsigned char *;
     width                    : Integer;
     height                   : Integer;
     cells_x                  : Integer;
     cells_y                  : Integer;
   END;
   PXPAtlasEntry = ^XPAtlasEntry;

   {
    XPAtlasMetrics
   }
   XPAtlasMetrics = RECORD
     s1                       : Single;
     t1                       : Single;
     s2                       : Single;
     t2                       : Single;
     width                    : Single;
     height                   : Single;
   END;
   PXPAtlasMetrics = ^XPAtlasMetrics;







{$IFDEF XPLMPG1}
{___________________________________________________________________________
 * IMGUI HELPERS
 ___________________________________________________________________________}
{
   These routines let panel-graphics-content-type windows render textured
   indexed triangle meshes that exactly match the layout produced by Dear
   ImGui's `ImDrawData`, so a plugin can plug an ImGui frame straight into
   X-Plane panel graphics.
   
   Coordinate system: positions are in window-LOCAL pixels with TOP-LEFT
   origin (matches Dear ImGui). Scissors are in the same coordinate space. The
   host translates these against the current panel-graphics origin and flips Y
   for you.
   
   Vertex layout (matches `ImDrawVert` exactly): each vertex is 5 floats =
   20 bytes, in this order: pos.x, pos.y, uv.x, uv.y, RGBA8 packed as a
    uint32_t in little-endian byte order (R is the low byte). The vertex
    stride passed in `XPLMMesh_t::vertices` must be 5 floats per vertex.
   
   Color and alpha: vertex colors and texture pixels are interpreted as
   **pre-multiplied alpha**. If you have straight-alpha source data, multiply
     RGB by alpha (and divide by 255 if integers) before submitting.
   
   Sampler: bilinear filter, clamp-to-edge in both dimensions, no mipmaps. UV
   coordinates outside [0,1] sample the edge texels (no wrap).
   
   Scissor: the per-`XPLMDrawCall_t` scissor rect is in {left, top, right,
   bottom} order (top-left origin). Zero-width or zero-height rects produce no
   output. The scissor state is automatically saved on entry to
   `XPLMDrawCalls` and restored on exit, so subsequent panel-graphics calls in
    the same frame are unaffected.
   
   Plugin-callable from inside a panel-graphics window's draw callback only.
}


   {
    XPLMDrawCall_t
    
    A single draw call within an `XPLMMesh_t`. Each call binds a texture and a
    scissor rect, then draws `element_count` indices starting at
    `idx_offset`. `vtx_offset` is added to each fetched index by the GPU
     (matching `glDrawElementsBaseVertex` semantics) -- this lets a single mesh
     hold multiple sub-meshes whose indices are written relative to their own
     start.
   }
TYPE
   XPLMDrawCall_t = RECORD
     { Texture handle from XPLMCreateTexture, or any pointer the host returned for}
     { a texture.                                                                 }
     tex_ref                  : Pvoid *;
     { Clip rect: {left, top, right, bottom} in window-local top-left coords.     }
     scissors[4]              : PSingle;
     { First index into XPLMMesh_t::indices to use.                               }
     idx_offset               : Integer;
     { Number of indices to consume (must be a multiple of 3 for triangles). Zero }
     { is allowed and produces no output.                                         }
     element_count            : Integer;
     { Added to each fetched index before vertex lookup.                          }
     vtx_offset               : Integer;
   END;
   PXPLMDrawCall_t = ^XPLMDrawCall_t;

   {
    XPLMMesh_t
    
    A vertex/index buffer pair shared across one or more `XPLMDrawCall_t`
    entries. The `vertices` array must be `5 * vertex_count` floats long
    matching the layout described in the IMGUI HELPERS component desc. Indices
    are 16-bit unsigned, matching `ImDrawIdx` at its default (`#define
    ImDrawIdx unsigned short`).
   }
   XPLMMesh_t = RECORD
     vertex_count             : Integer;
     { Pointer to vertex_count * 5 floats.                                        }
     vertices                 : Pfloat *;
     index_count              : Integer;
     indices                  : Puint16_t*;
   END;
   PXPLMMesh_t = ^XPLMMesh_t;

   {
    XPLMCreateTexture
    
    Creates a GPU texture from a contiguous RGBA8 byte buffer. The buffer is
    read top-to-bottom, with byte order R, G, B, A per pixel. Any width and
    height are accepted, including non-power-of-two and 1-pixel-wide strips;
    the host does not require power-of-two dimensions.
    
    The returned handle is opaque; pass it to `XPLMDrawCall_t::tex_ref` and
    free it with `XPLMDestroyTexture` when done. The sampler used at draw time
    is bilinear, clamp-to-edge, no mipmaps.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   FUNCTION XPLMCreateTexture(
                                        rgba_image          : Punsigned char *;
                                        width               : Integer;
                                        height              : Integer) : Pvoid *;
    cdecl; external XPLM_DLL;

   {
    XPLMDestroyTexture
    
    Frees a texture obtained from `XPLMCreateTexture`. Do not use the handle
    after calling this. It is safe to create and destroy textures every frame.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMDestroyTexture(
                                        tex_ref             : Pvoid *);
    cdecl; external XPLM_DLL;

   {
    XPLMDrawCalls
    
    Renders `inCount` draw calls against the shared `inMesh`. Issues one GPU
    dispatch per call (each can rebind texture and scissor) but uploads the
    mesh only once. `inCount = 0` is a no-op. `element_count = 0` on a specific
    draw call is also a no-op for that call.
    
    The scissor state is saved on entry and restored on exit; subsequent
    panel-graphics primitives in the same frame are unaffected.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMDrawCalls(
                                        inMesh              : PXPLMMesh_t *;
                                        inCount             : Integer;
                                        inDrawCalls[]       : PXPLMDrawCall_t);
    cdecl; external XPLM_DLL;

{$ENDIF XPLMPG1}
{___________________________________________________________________________
 * IMGUI HELPERS glue
 ___________________________________________________________________________}





IMPLEMENTATION

END.
