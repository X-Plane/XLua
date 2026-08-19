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

TYPE
   XPLMChar   = AnsiChar;
   XPLMString = PAnsiChar;
   PXPLMString = ^XPLMString;

CONST
{$IFDEF MSWINDOWS}
   XPLM_DLL = 'XPLM_64.dll';
{$ENDIF}
{$IFDEF DARWIN}
   XPLM_DLL = 'XPLM.framework/XPLM';
{$ENDIF}
{$IFDEF LINUX}
   XPLM_DLL = 'XPLM_64.so';
{$ENDIF}
{$IFDEF XPLM440}
{___________________________________________________________________________
 * PANEL GRAPHICS primitives
 ___________________________________________________________________________}
{
   These routines draw 2-D vector primitives: lines, line strips, line loops,
   filled polygons, and quad strips.
   
   Line-based primitives (Lines, LineStrip, LineLoop) have four variants:
   
   - Base variant: uniform color, default line width.
   - WithWidth variant: uniform color, caller-specified line width.
   - "c" variant: per-vertex color (using XPLMVertexColor_t), default line
     width.
   - "c" + WithWidth variant: per-vertex color and caller-specified line
     width.
   
   They also have a Stipple variant that draws dashed lines with a
   caller-specified dash length and line width.
   
   Filled primitives (Polygon, Quadstrip) have no line width, so they come in
   only the base and "c" variants.
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
     color                    : Cardinal;
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
                                        alpha               : Single) : Cardinal;
    cdecl; external XPLM_DLL;

   {
    XPLMLines
    
    This function draws disconnected line segments. Every pair of vertices
    defines one segment: the first segment runs from vertices[0] to
    vertices[1], the second from vertices[2] to vertices[3], and so on.
    
    - count: the number of vertices. Must be even.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMLines(
                                        color               : Cardinal;
                                        vertices            : PXPLMVertex_t;
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
                                        color               : Cardinal;
                                        lineWidth           : Single;
                                        vertices            : PXPLMVertex_t;
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
                                        vertices            : PXPLMVertexColor_t;
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
                                        vertices            : PXPLMVertexColor_t;
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
                                        color               : Cardinal;
                                        pts                 : PXPLMVertex_t;
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
                                        color               : Cardinal;
                                        pts                 : PXPLMVertex_t;
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
                                        color               : Cardinal;
                                        lineWidth           : Single;
                                        pts                 : PXPLMVertex_t;
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
                                        pts                 : PXPLMVertexColor_t;
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
                                        pts                 : PXPLMVertexColor_t;
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
                                        color               : Cardinal;
                                        pts                 : PXPLMVertex_t;
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
                                        color               : Cardinal;
                                        pts                 : PXPLMVertex_t;
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
                                        color               : Cardinal;
                                        lineWidth           : Single;
                                        pts                 : PXPLMVertex_t;
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
                                        pts                 : PXPLMVertexColor_t;
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
                                        pts                 : PXPLMVertexColor_t;
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
                                        color               : Cardinal;
                                        pts                 : PXPLMVertex_t;
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
                                        color               : Cardinal;
                                        vertices            : PXPLMVertex_t;
                                        count               : Integer);
    cdecl; external XPLM_DLL;

   {
    XPLMPolygonc
    
    This function draws a filled convex polygon with per-vertex colors. Colors
    are interpolated across the polygon interior.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMPolygonc(
                                        vertices            : PXPLMVertexColor_t;
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
                                        color               : Cardinal;
                                        vertices            : PXPLMVertex_t;
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
                                        vertices            : PXPLMVertexColor_t;
                                        count               : Integer);
    cdecl; external XPLM_DLL;

{$ENDIF XPLM440}
{$IFDEF XPLM440}
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
   XPLMFontHandle = pointer;
   PXPLMFontHandle = ^XPLMFontHandle;

   {
    XPLMCreateFont
    
    This function creates a new font handle. The character set determines which
    glyphs are available for rendering. After creating the font, add one or
    more TrueType faces with XPLMFontAddFace before drawing.
    
    Returns an opaque font handle.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   FUNCTION XPLMCreateFont(
                                        charset             : XPLMCharSet_t) : XPLMFontHandle;
    cdecl; external XPLM_DLL;

   {
    XPLMDestroyFont
    
    This function destroys a font handle and frees all associated resources.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMDestroyFont(
                                        font                : XPLMFontHandle);
    cdecl; external XPLM_DLL;

   {
    XPLMFontAddFace
    
    This function adds a TrueType font face to an existing font handle. You may
    add multiple faces to a single font to provide fallback glyphs; if a glyph
    is not found in the first face, subsequent faces are searched in the order
    they were added.
    
    - ttf_path: a file system path to a .ttf or .otf font file.
    
    Returns 1 if the face was loaded and added, or 0 if it could not be. When
    this returns 0 the font is left exactly as it was, so you can try another
    path, and a message explaining what went wrong is sent to your error
    callback (see XPLMSetErrorCallback) and written to Log.txt.
    
    Drawing with a font that has no faces draws nothing; it is not an error.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   FUNCTION XPLMFontAddFace(
                                        font                : XPLMFontHandle;
                                        ttf_path            : XPLMString) : Integer;
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
                                        font                : XPLMFontHandle;
                                        fontSize            : Single;
                                        outMetrics          : PXPLMFontMetrics_t);
    cdecl; external XPLM_DLL;

   {
    XPLMFontMeasureString
    
    This function returns the width in pixels that a string would occupy if
    drawn at the given font size. The string is not drawn.
    
    Returns the horizontal advance width, in pixels.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   FUNCTION XPLMFontMeasureString(
                                        font                : XPLMFontHandle;
                                        fontSize            : Single;
                                        &string             : XPLMString) : Single;
    cdecl; external XPLM_DLL;

   {
    XPLMFontGetLineCount
    
    This function calculates how many lines a string would occupy if
    word-wrapped to the specified width at the given font size.
    
    Returns the number of lines.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   FUNCTION XPLMFontGetLineCount(
                                        font                : XPLMFontHandle;
                                        fontSize            : Single;
                                        &string             : XPLMString;
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
                                        font                : XPLMFontHandle;
                                        fontSize            : Single;
                                        &string             : XPLMString;
                                        width               : Single) : Integer;
    cdecl; external XPLM_DLL;

   {
    XPLMFontFitReverse
    
    This function returns the number of characters in the input string that
    must be skipped to fit the reset of the string into the specified space.
    This is useful for right-aligning a truncated string.
    
    Returns a character count - the number of characters that must be removed
    to fit.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   FUNCTION XPLMFontFitReverse(
                                        font                : XPLMFontHandle;
                                        fontSize            : Single;
                                        &string             : XPLMString;
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
                                        font                : XPLMFontHandle;
                                        color               : Cardinal;
                                        fontSize            : Single;
                                        x                   : Single;
                                        y                   : Single;
                                        &string             : XPLMString;
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
                                        font                : XPLMFontHandle;
                                        color               : Cardinal;
                                        fontSize            : Single;
                                        x                   : Single;
                                        y                   : Single;
                                        &string             : XPLMString;
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
                                        font                : XPLMFontHandle;
                                        color               : Cardinal;
                                        fontSize            : Single;
                                        x                   : Single;
                                        y                   : Single;
                                        &string             : XPLMString;
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
    - angle: the rotation angle in degrees, positive clockwise.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMFontDrawStringRotated(
                                        font                : XPLMFontHandle;
                                        color               : Cardinal;
                                        fontSize            : Single;
                                        x                   : Single;
                                        y                   : Single;
                                        &string             : XPLMString;
                                        angle               : Single;
                                        justification       : XPLMJustification_t);
    cdecl; external XPLM_DLL;

{$ENDIF XPLM440}
{$IFDEF XPLM440}
{___________________________________________________________________________
 * PANEL GRAPHICS Texture atlas
 ___________________________________________________________________________}
{
   These routines manage texture atlases for drawing images on the panel. A
   texture atlas packs multiple source images into a single GPU texture for
   efficient rendering. The typical workflow is:
   
   - Create an atlas with XPLMCreateTextureAtlas.
   - Add images from files or raw pixel data. Each image (or cell of an image
     set) receives a zero-based index. Every routine below that takes an
     inImageIndex requires an index that one of the add routines returned to
     you.
   - Call XPLMTextureAtlasBake to upload the atlas to the GPU.
   - Draw images using the DrawAt, DrawIn, DrawStretched, DrawScaled, or
     DrawMesh routines.
   - Destroy the atlas with XPLMDestroyTextureAtlas when it is no longer
     needed.
   
   All images are stored as RGBA, 4 bytes per pixel.
   
   That order is a requirement, not a suggestion. An atlas is either being
   filled or baked, and most routines here have a precondition on which of the
   two it is: the XPLMTextureAtlasAddImage family and XPLMTextureAtlasBake
   require an atlas that has not been baked, and every draw routine requires
   one that has. Each routine states its own precondition below. X-Plane
   reports a violated precondition to your error callback and to Log.txt so
   that you can find it, but a violated precondition is a bug in your plugin,
   so no return value is defined for one - do not write code that tests for
   it.
   
   XPLMDestroyTextureAtlas, XPLMTextureAtlasGetImageWidth and
   XPLMTextureAtlasGetImageHeight have no precondition on the bake state -
   they are legal at any point in an atlas's life. In particular you can
   measure your images before you bake, which is usually when you want to
   know: laying out a panel around art you have added but not yet packed.
}


TYPE
   {
    XPLMTextureAtlasRef
    
    An opaque handle to a texture atlas. Create one with XPLMCreateTextureAtlas
    and destroy it with XPLMDestroyTextureAtlas.
   }
   XPLMTextureAtlasRef = pointer;
   PXPLMTextureAtlasRef = ^XPLMTextureAtlasRef;

   {
    XPLMTextureVertex_t
    
    A vertex for textured mesh drawing. Combines a position in panel
    coordinates with normalized texture coordinates within the image.
    
    Texture coordinates are always relative to the image you are drawing, never
    to the atlas sheet it happens to be packed into. This is true for both
    XPLMTextureAtlasDrawMesh and XPLMTextureSourceDrawMesh, so the same vertex
    array means the same thing to either one.
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
   FUNCTION XPLMCreateTextureAtlas: XPLMTextureAtlasRef;
    cdecl; external XPLM_DLL;

   {
    XPLMDestroyTextureAtlas
    
    This function destroys a texture atlas and frees all associated GPU and CPU
    resources.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMDestroyTextureAtlas(
                                        inTextureAtlas      : XPLMTextureAtlasRef);
    cdecl; external XPLM_DLL;

   {
    XPLMTextureAtlasAddImageFile
    
    This function loads a PNG image file and adds it to the atlas as a single
    image. The atlas must not have been baked yet.
    
    - inImageFilePath: the file system path to a PNG file.
    
    Returns the zero-based image index assigned to this image.
    
    Returns -1 if the image could not be loaded.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   FUNCTION XPLMTextureAtlasAddImageFile(
                                        inTextureAtlas      : XPLMTextureAtlasRef;
                                        inImageFilePath     : XPLMString) : Integer;
    cdecl; external XPLM_DLL;

   {
    XPLMTextureAtlasAddImageFileSet
    
    This function loads a PNG image file and subdivides it into a grid of
    cells, adding each cell to the atlas as a separate image. This is useful
    for sprite sheets and image strip assets. The atlas must not have been
    baked yet.
    
    - inImageFilePath: the file system path to a PNG file.
    - inCellsX: the number of columns to divide the image into.
    - inCellsY: the number of rows to divide the image into.
    
    Returns the zero-based image index of the first cell (top-left). Subsequent
    cells are numbered in row-major order: index + y * inCellsX + x.
    
    Returns -1 if the image could not be loaded.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   FUNCTION XPLMTextureAtlasAddImageFileSet(
                                        inTextureAtlas      : XPLMTextureAtlasRef;
                                        inImageFilePath     : XPLMString;
                                        inCellsX            : Integer;
                                        inCellsY            : Integer) : Integer;
    cdecl; external XPLM_DLL;

   {
    XPLMTextureAtlasAddImage
    
    This function adds a single image from raw pixel data to the atlas. The
    pixel data must be RGBA format, 4 bytes per pixel, with rows ordered from
    top to bottom. The atlas must not have been baked yet.
    
    - inImage: pointer to the raw RGBA pixel data.
    - inWidth: the image width in pixels.
    - inHeight: the image height in pixels.
    
    Returns the zero-based image index assigned to this image.
    
    Returns -1 if the image could not be loaded.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   FUNCTION XPLMTextureAtlasAddImage(
                                        inTextureAtlas      : XPLMTextureAtlasRef;
                                        inImage             : PByte;
                                        inWidth             : Integer;
                                        inHeight            : Integer) : Integer;
    cdecl; external XPLM_DLL;

   {
    XPLMTextureAtlasAddImageSet
    
    This function adds raw pixel data to the atlas, subdividing it into a grid
    of cells. Each cell is added as a separate image. The pixel data must be
    RGBA format, 4 bytes per pixel, with rows ordered from top to bottom. The
    atlas must not have been baked yet.
    
    - inImage: pointer to the raw RGBA pixel data.
    - inWidth: the total image width in pixels.
    - inHeight: the total image height in pixels.
    - inCellsX: the number of columns to divide the image into.
    - inCellsY: the number of rows to divide the image into.
    
    Returns the zero-based image index of the first cell. Subsequent cells are
    numbered in row-major order: index + y * inCellsX + x.
    
    Returns -1 if the image could not be loaded.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   FUNCTION XPLMTextureAtlasAddImageSet(
                                        inTextureAtlas      : XPLMTextureAtlasRef;
                                        inImage             : PByte;
                                        inWidth             : Integer;
                                        inHeight            : Integer;
                                        inCellsX            : Integer;
                                        inCellsY            : Integer) : Integer;
    cdecl; external XPLM_DLL;

   {
    XPLMTextureAtlasBake
    
    This function packs all previously added images into a GPU texture. Call it
    after adding all of your images and before any draw calls. The atlas must
    not have been baked yet - an atlas is baked exactly once, and takes no more
    images after that.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMTextureAtlasBake(
                                        inTextureAtlas      : XPLMTextureAtlasRef);
    cdecl; external XPLM_DLL;

   {
    XPLMTextureAtlasGetImageWidth
    
    This function returns the width in pixels of a single image (or cell) in
    the atlas. This works both before and after XPLMTextureAtlasBake, and
    returns the same answer either way - packing an atlas never resizes your
    images.
    
    Returns the image width in pixels.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   FUNCTION XPLMTextureAtlasGetImageWidth(
                                        inTextureAtlas      : XPLMTextureAtlasRef;
                                        inImageIndex        : Integer) : Integer;
    cdecl; external XPLM_DLL;

   {
    XPLMTextureAtlasGetImageHeight
    
    This function returns the height in pixels of a single image (or cell) in
    the atlas. This works both before and after XPLMTextureAtlasBake, and
    returns the same answer either way - packing an atlas never resizes your
    images.
    
    Returns the image height in pixels.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   FUNCTION XPLMTextureAtlasGetImageHeight(
                                        inTextureAtlas      : XPLMTextureAtlasRef;
                                        inImageIndex        : Integer) : Integer;
    cdecl; external XPLM_DLL;

   {
    XPLMTextureAtlasDrawAt
    
    This function draws an atlas image at its native resolution. The image is
    positioned with its top-left corner at (inX, inY) and extends rightward and
    downward by its native pixel dimensions. The atlas must already be baked.
    
    - inTintColor: a color that is multiplied with the texture. Use
      XPLMMakeColor(1, 1, 1, 1) for no tinting.
    - inX: the left edge of the image, in panel coordinates.
    - inY: the top edge of the image, in panel coordinates.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMTextureAtlasDrawAt(
                                        inTextureAtlas      : XPLMTextureAtlasRef;
                                        inImageIndex        : Integer;
                                        inTintColor         : Cardinal;
                                        inX                 : Single;
                                        inY                 : Single);
    cdecl; external XPLM_DLL;

   {
    XPLMTextureAtlasDrawIn
    
    This function draws an atlas image scaled to fill a rectangular region. The
    image is stretched or compressed to exactly match the specified bounds. The
    atlas must already be baked.
    
    - inTintColor: a color that is multiplied with the texture.
    - inLeft, inTop, inRight, inBottom: the bounding rectangle in panel
      coordinates.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMTextureAtlasDrawIn(
                                        inTextureAtlas      : XPLMTextureAtlasRef;
                                        inImageIndex        : Integer;
                                        inTintColor         : Cardinal;
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
    borders when scaling UI elements like buttons or panels. The atlas must
    already be baked.
    
    - inTintColor: a color that is multiplied with the texture.
    - inLeft, inTop, inRight, inBottom: the bounding rectangle in panel
      coordinates.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMTextureAtlasDrawStretched(
                                        inTextureAtlas      : XPLMTextureAtlasRef;
                                        inImageIndex        : Integer;
                                        inTintColor         : Cardinal;
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
    inYPanel), then scaled and rotated around that point. The atlas must
    already be baked.
    
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
                                        inTextureAtlas      : XPLMTextureAtlasRef;
                                        inImageIndex        : Integer;
                                        inTintColor         : Cardinal;
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
    
    Texture coordinates are relative to the image, not to the atlas sheet; the
    mapping onto wherever the image was packed is applied for you, exactly as
    it is for the other atlas drawing routines. One consequence is that the
    same vertex array can be drawn with any inImageIndex - you do not have to
    rebuild the mesh to switch images.
    
    Coordinates outside 0.0 to 1.0 are not clamped, and will sample whatever
    neighboring image shares the atlas sheet. Keep them in range.
    
    - inTintColor: a color that is multiplied with the texture.
    - vertices: an array of XPLMTextureVertex_t vertices defining the triangle
      strip.
    - count: the number of vertices. Must be at least 3.
    
    The atlas must already be baked.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMTextureAtlasDrawMesh(
                                        inTextureAtlas      : XPLMTextureAtlasRef;
                                        inImageIndex        : Integer;
                                        inTintColor         : Cardinal;
                                        vertices            : PXPLMTextureVertex_t;
                                        count               : Integer);
    cdecl; external XPLM_DLL;

{$ENDIF XPLM440}
{$IFDEF XPLM440}
{___________________________________________________________________________
 * PANEL GRAPHICS radar texture
 ___________________________________________________________________________}
{
   These routines draw stock simulator textures, such as weather radar
   displays, into your avionics panel. Unlike texture atlas images which are
   loaded from files you provide, texture sources are live textures rendered
   by the simulator each frame. If the aircraft does not have the requested
   hardware (e.g. no weather radar installed), the draw call is silently
   skipped.
}


   {
    XPLMTextureSource
    
    An XPLMTextureSource identifies a stock simulator texture that can be drawn
    with the texture source drawing functions.
   }
TYPE
   XPLMTextureSource = (
     { The pilot-side weather radar display.                                      }
      xplm_Texture_WeatherRadar1               = 0
 
     { The copilot-side weather radar display.                                    }
     ,xplm_Texture_WeatherRadar2               = 1
 
   );
   PXPLMTextureSource = ^XPLMTextureSource;

   {
    XPLMTextureSourceDrawIn
    
    This function draws a texture source scaled to fill a rectangular region.
    The texture is stretched or compressed to exactly match the specified
    bounds.
    
    - tex: the texture source to draw.
    - tint: a color that is multiplied with the texture. Use XPLMMakeColor(1,
      1, 1, 1) for no tinting.
    - left, top, right, bottom: the bounding rectangle in panel coordinates.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMTextureSourceDrawIn(
                                        tex                 : XPLMTextureSource;
                                        tint                : Cardinal;
                                        left                : Integer;
                                        top                 : Integer;
                                        right               : Integer;
                                        bottom              : Integer);
    cdecl; external XPLM_DLL;

   {
    XPLMTextureSourceDrawMesh
    
    This function draws a texture source onto an arbitrary triangle-strip mesh.
    Each vertex specifies both a panel-space position and a normalized texture
    coordinate (0.0 to 1.0) within the source texture. This gives you full
    control over how the texture is mapped onto geometry.
    
    - tex: the texture source to draw.
    - tint: a color that is multiplied with the texture.
    - mesh: an array of XPLMTextureVertex_t vertices defining the triangle
      strip.
    - count: the number of vertices. Must be at least 3.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMTextureSourceDrawMesh(
                                        tex                 : XPLMTextureSource;
                                        tint                : Cardinal;
                                        mesh                : PXPLMTextureVertex_t;
                                        count               : Integer);
    cdecl; external XPLM_DLL;

{$ENDIF XPLM440}
{$IFDEF XPLM440}
{___________________________________________________________________________
 * PANEL_GRAPHICS transform/scissors/masks
 ___________________________________________________________________________}
{
   These routines modify the drawing state for subsequent panel graphics
   calls. The transformation matrix controls the position, rotation, and scale
   of all drawing. The scissor rectangle clips drawing to a rectangular
   region. The stencil mask clips drawing to an arbitrary shape.
   
   The transform and the scissor rectangle each have a push/pop stack. Always
   push before modifying either one and pop to restore the previous state when
   you are done. For the transform this is required, not merely good manners:
   XPLMTransformTranslate, XPLMTransformRotate and XPLMTransformScale must be
   called inside a XPLMTransformPush/XPLMTransformPop pair; calling one
   outside a pair is an error. X-Plane does not push a transform scope around
   your drawing callback, so a transform with no enclosing push has no defined
   end.
   
   Scissor rectangles ride the transform stack, exactly like the drawing they
   clip: the rectangle you pass is in panel coordinates and is put through the
   transform in force when you set it. Once set, it stays where you set it - a
   later transform does not move it, and popping the scissor stack restores
   whatever rectangle was in force before the matching push.
   
   Rotation is the one transform a rectangle cannot survive, because an
   axis-aligned rectangle cannot describe a rotated one. Calling any of these
   while a rotation is in effect is an error, reported to Log.txt and through
   your error callback:
   
   - XPLMScissorSet and XPLMScissorIntersect
   - XPLMAccumulateTouchZone
   - XPLMDrawCalls, whose draw calls carry their own scissor rectangles
   - XPLMSVTDisplayDrawIn and XPLMMapDisplayDrawIn, which clip themselves
   - XPLMDrawRetained, if the retained drawing contains any of the above
   
   Translate and scale are fine for all of them, and are applied for you.
   
   The stencil has no stack. Instead the stencil buffer holds up to eight
   independent one-bit masks, and you select which of them clips your drawing
   by calling XPLMUseStencilMask as often as you like. X-Plane restores the
   stencil state for you at the end of your drawing callback.
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
    
    Must be called inside a XPLMTransformPush/XPLMTransformPop pair.
    
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
    
    Must be called inside a XPLMTransformPush/XPLMTransformPop pair.
    
    While a rotation is in effect, you may not use any routine that works with
    an axis-aligned rectangle - scissors, touch zones, XPLMDrawCalls, and the
    SVT and map draw-ins. See the section description above for the full list.
    This is decided by whether you called this function, not by the angle you
    passed: a rotation of zero degrees still counts. Keep rotations in as tight
    a push/pop scope as you can, so those routines are available again after
    the pop.
    
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
    
    Must be called inside a XPLMTransformPush/XPLMTransformPop pair.
    
    Neither factor may be zero: a zero scale collapses the coordinate system
    onto a line, so a position expressed in it can no longer be recovered.
    Negative factors are fine and mirror your drawing.
    
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
    
    - left, top, right, bottom: the scissor bounds in panel coordinates.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMScissorSet(
                                        left                : Integer;
                                        top                 : Integer;
                                        right               : Integer;
                                        bottom              : Integer);
    cdecl; external XPLM_DLL;

   {
    XPLMScissorIntersect
    
    This function sets the scissor rectangle to the intersection of the current
    scissor rectangle and the rectangle you pass in. The result is always the
    same or a smaller drawable area. This is useful for nested clipping.
    
    - left, top, right, bottom: the scissor bounds in panel coordinates, the
      same coordinate space used by XPLMScissorSet.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMScissorIntersect(
                                        left                : Integer;
                                        top                 : Integer;
                                        right               : Integer;
                                        bottom              : Integer);
    cdecl; external XPLM_DLL;

   {
    XPLMBeginSetupStencilMask
    
    This function begins stencil mask setup. While in setup mode, drawing
    commands write to the stencil buffer instead of to the screen. Draw the
    shapes that define your mask region, then call XPLMEndSetupStencilMask to
    finish.
    
    The stencil buffer is eight bits wide, so you can record up to eight
    independent masks and pick among them later with XPLMUseStencilMask - one
    bit per mask - without having to re-draw them.
    
    - bits: the stencil bit pattern to write into the stencil buffer where
      geometry is drawn.
    - mask: a bitmask selecting which stencil bits are written.
    
    Both parameters must be in the range 0 to 255, and every bit set in bits
    must also be set in mask - a bit outside the mask can never be written.
    Stencil testing must be off (see XPLMUseStencilMask) when you call this.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMBeginSetupStencilMask(
                                        bits                : Cardinal;
                                        mask                : Cardinal);
    cdecl; external XPLM_DLL;

   {
    XPLMEndSetupStencilMask
    
    This function ends stencil mask setup. After this call, drawing commands
    once again render to the screen, and stencil testing is off. Call
    XPLMUseStencilMask to start drawing through the mask you just recorded.
    
    The mask stays in the stencil buffer until you overwrite it or call
    XPLMClearStencilMask, so you may record several masks up front and then
    switch among them.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMEndSetupStencilMask;
    cdecl; external XPLM_DLL;

   {
    XPLMUseStencilMask
    
    This function selects which stencil mask clips your drawing. Subsequent
    drawing is clipped to the region you recorded with
    XPLMBeginSetupStencilMask: only pixels where the stencil buffer matches the
    specified bit pattern are drawn.
    
    - bits: the reference bit pattern to test against.
    - mask: a bitmask selecting which stencil bits participate in the test.
    
    Both parameters must be in the range 0 to 255, and every bit set in bits
    must also be set in mask - a bit outside the mask can never match.
    
    You may call this as often as you like within one drawing callback to
    switch between masks you have recorded; each call replaces the previous
    test. Pass (0, 0) to stop stencil testing entirely. You do not have to do
    that at the end of your callback - X-Plane turns stencil testing off for
    you, and for a window it also clears any mask you recorded, so nothing you
    draw leaks into another window.
    
    This function may not be called between XPLMBeginSetupStencilMask and
    XPLMEndSetupStencilMask.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMUseStencilMask(
                                        bits                : Cardinal;
                                        mask                : Cardinal);
    cdecl; external XPLM_DLL;

   {
    XPLMClearStencilMask
    
    This function erases the entire stencil buffer, discarding every mask you
    have recorded. It does not change whether stencil testing is on - use
    XPLMUseStencilMask(0, 0) for that.
    
    Because this throws away all eight masks at once, you rarely need it: to
    stop drawing through a mask, call XPLMUseStencilMask(0, 0), and to replace
    one, just record over it. It is safe to call at any time as a way of asking
    for a known starting state, even if you have recorded nothing.
    
    Stencil testing must be off, and you may not call this between
    XPLMBeginSetupStencilMask and XPLMEndSetupStencilMask.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMClearStencilMask;
    cdecl; external XPLM_DLL;

{$ENDIF XPLM440}
{$IFDEF XPLM440}
{___________________________________________________________________________
 * PANEL GRAPHICS Hot Zones
 ___________________________________________________________________________}
{
   These routines define interactive touch zones on a panel surface. You call
   XPLMAccumulateTouchZone during your drawing callback to declare rectangular
   regions that respond to mouse clicks or touches. Each zone can either fire
   an X-Plane command automatically or deliver raw touch events to a callback
   you register with XPLMAvionicsSetTouchEventHandler.
   
   A touch zone rides the transform stack, exactly like the drawing it sits on
   top of. Declare the zone in the same coordinates you drew in and X-Plane
   applies the transform in force for you - do not offset or scale the
   rectangle yourself, or the transform will be applied twice. This is the
   whole point: draw a button and put a zone on it using the same numbers,
   under any combination of translates and scales, and the two stay together.
   
   The transform runs both ways, so your XPLMTouchEvent_f never has to undo it
   either. The x and y you receive are in the coordinate system that was in
   force when you declared the zone, and dx and dy are scaled to match - you
   can compare them directly against the numbers you drew with.
   
   Two limits follow from a zone being an axis-aligned rectangle:
   
   - Do not declare a zone while a rotation is in effect. An axis-aligned
     rectangle cannot describe a rotated graphic, so this is an error.
   - A zone cannot be declared inside a XPLMBeginRetainedDrawing recording. A
     zone is per-frame state rather than drawing, and a retained drawing holds
     drawing only. Accumulate your zones outside the recording, once per
     frame; they are cheap to re-declare and are meant to be re-declared.
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
    
    The position and the deltas are in the coordinate system that was in force
    when you declared the zone with XPLMAccumulateTouchZone, so they are
    directly comparable to the numbers you drew and declared with - you do not
    need to undo the transform stack, and you do not need the window or device
    geometry to make sense of them. The coordinate system is latched when the
    gesture begins, so every event in one drag arrives in the same space even
    if you move or rescale the zone part way through.
   }
     XPLMTouchEvent_f = PROCEDURE(
                                    identifier          : Integer;
                                    status              : XPLMMouseStatus;
                                    x                   : Integer;
                                    y                   : Integer;
                                    dx                  : Integer;
                                    dy                  : Integer;
                                    button              : Integer;
                                    ref                 : pointer); cdecl;    { Can be nil }

   {
    XPLMTouchZoneSpec_t
    
    XPLMTouchZoneSpec_t describes a single interactive touch zone on the panel.
    Pass a pointer to this struct to XPLMAccumulateTouchZone during your
    drawing callback. The structure may be expanded in future SDKs - always set
    structSize to the size of your structure in bytes.
   }
   XPLMTouchZoneSpec_t = RECORD
     { Set to sizeof(XPLMTouchZoneSpec_t). This is checked; a size X-Plane does   }
     { not recognise is an error and is reported.                                 }
     structSize               : Integer;
     { How the zone responds to interaction.                                      }
     &type                    : XPLMTouchZone;
     { The command to fire. Only used when type is xplm_TouchZone_Command.        }
     command                  : XPLMCommandRef;
     { An integer you assign to identify this zone in your XPLMTouchEvent_f       }
     { callback. Only used when type is xplm_TouchZone_Identifier.                }
     identifier               : Integer;
     { Left edge of the zone, in the coordinates you are drawing in. X-Plane      }
     { applies the transform stack for you - do not pre-offset this.              }
     left                     : Integer;
     { Top edge of the zone, in the coordinates you are drawing in. X-Plane       }
     { applies the transform stack for you - do not pre-offset this.              }
     top                      : Integer;
     { Right edge of the zone, in the coordinates you are drawing in. X-Plane     }
     { applies the transform stack for you - do not pre-offset this.              }
     right                    : Integer;
     { Bottom edge of the zone, in the coordinates you are drawing in. X-Plane    }
     { applies the transform stack for you - do not pre-offset this.              }
     bottom                   : Integer;
   END;
   PXPLMTouchZoneSpec_t = ^XPLMTouchZoneSpec_t;

   {
    XPLMAccumulateTouchZone
    
    This function registers a touch zone for the current frame. Call this
    during your avionics drawing callback each frame for every interactive
    region on your panel. Zones registered later take priority over earlier
    ones when they overlap.
    
    The rectangle is in the coordinates you are drawing in: X-Plane puts it
    through the transform stack for you, so pass the same numbers you drew the
    button with and do not apply the offset or scale yourself.
    
    Returns true if the zone is currently being clicked or held by the user,
    false otherwise. You can use this to provide visual feedback (for example,
    drawing a button in its pressed state).
    
    Calling this while a rotation is in effect, or while recording a retained
    drawing, is an error. See the section description above for why.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   FUNCTION XPLMAccumulateTouchZone(
                                        inSpec              : PXPLMTouchZoneSpec_t) : Integer;
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
                                        handler             : XPLMTouchEvent_f;    { Can be nil }
                                        ref                 : pointer);    { Can be nil }
    cdecl; external XPLM_DLL;

   {
    XPLMWindowSetTouchEventHandler
    
    This function registers a callback to receive touch events for zones of
    type xplm_TouchZone_Identifier accumulated by a window's drawing callback.
    It is the window equivalent of XPLMAvionicsSetTouchEventHandler.
    
    Note that only the registration is thread safe. Your XPLMTouchEvent_f
    itself is always called on the main thread, so it is free to call anything
    a callback may normally call - including XPLMGetWindowGeometry. In practice
    you should not need the geometry: the coordinates you are handed are
    already in the space you declared the zone in.
    
    - window: the window whose touch zones this handler serves.
    - handler: your XPLMTouchEvent_f callback.
    - ref: a reference pointer passed through to your callback.
   }
    { Thread-safe. This call may be used from threads.                              }
   PROCEDURE XPLMWindowSetTouchEventHandler(
                                        window              : XPLMWindowID;
                                        handler             : XPLMTouchEvent_f;    { Can be nil }
                                        ref                 : pointer);    { Can be nil }
    cdecl; external XPLM_DLL;

{$ENDIF XPLM440}
{$IFDEF XPLM440}
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
   XPLMRetainedDrawing_t = pointer;
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
   FUNCTION XPLMEndRetainedDrawing: XPLMRetainedDrawing_t;
    cdecl; external XPLM_DLL;

   {
    XPLMDrawRetained
    
    This function replays a previously recorded sequence of drawing commands.
    You can call this multiple times per frame and across multiple frames to
    efficiently re-draw the same content.
    
    The drawing happens where you replay it, in the state in force at that
    point, so you can freely translate, scale and rotate a retained drawing to
    place it - this is one of the main reasons to use one.
    
    The exception is a drawing that contains something axis-aligned: scissors,
    XPLMDrawCalls, an SVT display or a map display. Replaying such a drawing
    while a rotation is in effect is an error. Translate and scale are always
    fine.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMDrawRetained(
                                        drawing             : XPLMRetainedDrawing_t);
    cdecl; external XPLM_DLL;

   {
    XPLMDestroyRetainedDrawing
    
    This function destroys a retained drawing and frees its resources.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMDestroyRetainedDrawing(
                                        drawing             : XPLMRetainedDrawing_t);
    cdecl; external XPLM_DLL;

{$ENDIF XPLM440}
{$IFDEF XPLM440}
{___________________________________________________________________________
 * PANEL GRAPHICS synthetic vision
 ___________________________________________________________________________}
{
   These routines let you draw the simulator's Synthetic Vision Technology
   (SVT) terrain rendering into your avionics panel. SVT provides a 3-D
   perspective view of terrain, runways, obstacles, and optional overlays such
   as flight path hoops, traffic, and airport signs. The view is always
   centered on the user aircraft and uses the selected AHRS source for
   attitude.
   
   Create an SVT display with XPLMCreateSVTDisplay and draw it with
   XPLMSVTDisplayDrawIn. Each display instance manages its own terrain tile
   loading and GPU state, so you can have multiple independent SVT views (e.g.
   pilot and copilot PFDs at different scales). Which visual layers are drawn
   is chosen per draw call, not per display.
   
   SVT rendering works on any aircraft, regardless of whether the stock
   cockpit has a G1000 or other SVT-capable avionics installed.
}


   {
    XPLMSVTFeatures
    
    Bit flags that control which visual layers an SVT display renders. Combine
    flags with bitwise OR to enable multiple layers.
   }
TYPE
   XPLMSVTFeatures = (
     { 3-D terrain mesh with elevation coloring.                                  }
      xplm_SVT_Terrain                         = 1
 
     { Runway outlines, centerline stripes, and numbers.                          }
     ,xplm_SVT_Runways                         = 2
 
     { Obstacle markers (towers, masts, etc.).                                    }
     ,xplm_SVT_Obstacles                       = 4
 
     { Flight path guidance hoops along the active route.                         }
     ,xplm_SVT_FlightPath                      = 8
 
     { TCAS traffic symbols.                                                      }
     ,xplm_SVT_Traffic                         = 16
 
     { Airport identification signs near airports.                                }
     ,xplm_SVT_AirportSigns                    = 32
 
     { ILS approach guidance hoops.                                               }
     ,xplm_SVT_ILSHoops                        = 64
 
     { Horizon line and heading reference.                                        }
     ,xplm_SVT_HorizonHeading                  = 128
 
     { All visual layers enabled.                                                 }
     ,xplm_SVT_All                             = 255
 
   );
   PXPLMSVTFeatures = ^XPLMSVTFeatures;

   {
    XPLMCreateSVT_t
    
    Parameters for creating an SVT display. Set structSize to the size of your
    struct so that future SDK versions can add fields without breaking existing
    plugins.
   }
   XPLMCreateSVT_t = RECORD
     { Set to sizeof(XPLMCreateSVT_t).                                            }
     structSize               : Integer;
     { 0 for pilot-side AHRS, 1 for copilot-side AHRS.                            }
     pilotIndex               : Integer;
     { Vertical scale of the 3-d view, in pixels per degree at the center of the  }
     { display.  Must be greater than zero; the G1000 PFD uses 14.                }
     pixelsPerDegree          : Single;
   END;
   PXPLMCreateSVT_t = ^XPLMCreateSVT_t;

   {
    XPLMSVTDisplayRef
    
    An opaque handle to an SVT display instance. Create one with
    XPLMCreateSVTDisplay and destroy it with XPLMDestroySVTDisplay.
   }
   XPLMSVTDisplayRef = pointer;
   PXPLMSVTDisplayRef = ^XPLMSVTDisplayRef;

   {
    XPLMCreateSVTDisplay
    
    This function creates a new SVT display instance. The display begins
    loading terrain tiles for the current aircraft position immediately. You
    can draw it as soon as tiles are available; before that, the draw call is a
    no-op.
    
    The pixelsPerDegree scale and the rectangle you pass to
    XPLMSVTDisplayDrawIn together determine the field of view: the rectangle is
    simply the scale applied to the view's angular extent. So drawing into a
    bigger rectangle at the same scale shows _more_ of the world at the same
    magnification rather than zooming in, and to zoom you change the scale, not
    the rectangle. Pick the same scale your pitch ladder uses and the 3-d
    horizon will line up with your artificial horizon.
    
    Which visual layers are rendered is a property of the draw call, not of the
    display - see XPLMSVTDisplayDrawIn.
    
    The returned handle must be destroyed with XPLMDestroySVTDisplay when no
    longer needed. Handles are automatically destroyed when the owning plugin
    is unloaded.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   FUNCTION XPLMCreateSVTDisplay(
                                        params              : PXPLMCreateSVT_t) : XPLMSVTDisplayRef;
    cdecl; external XPLM_DLL;

   {
    XPLMDestroySVTDisplay
    
    This function destroys an SVT display and frees all associated resources.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMDestroySVTDisplay(
                                        svt                 : XPLMSVTDisplayRef);
    cdecl; external XPLM_DLL;

   {
    XPLMSVTCustomData_t
   }
TYPE
   XPLMSVTCustomData_t = RECORD
     { pitch override (degrees).                                                  }
     pitchDeg                 : Single;
     { roll/bank override (degrees).                                              }
     rollDeg                  : Single;
     { magnetic heading override (degrees).                                       }
     headingMagDeg            : Single;
     { magnetic variation override (degrees).                                     }
     magVarDeg                : Single;
     { indicated altitude override (feet).                                        }
     indicatedAltFt           : Single;
     { altimeter setting override ( inHg).                                        }
     baroSettingInHg          : Single;
     { HSI source override.                                                       }
     hsiSource                : Integer;
     { horizontal CDI deviation override (float).                                 }
     hdefDots                 : Single;
     { vertical GS deviation override (float).                                    }
     vdefDots                 : Single;
   END;
   PXPLMSVTCustomData_t = ^XPLMSVTCustomData_t;

   {
    XPLMSVTDisplayDrawIn
    
    This function renders the SVT display directly into the active panel
    surface within the specified rectangular region. SVT sets up its own 3-D
    perspective projection to fit the rectangle, so no transform stack
    manipulation is needed.
    
    The features parameter controls which visual layers are rendered for this
    draw call. Pass a bitwise OR of XPLMSVTFeatures flags.
    
    This function must be called from within an avionics drawing callback. If
    terrain tiles have not finished loading yet, this function does nothing.
    
    - svt: the SVT display handle.
    - features: bitwise OR of XPLMSVTFeatures flags to enable for this draw
      call.
    - left, top, right, bottom: the bounding rectangle in panel coordinates.
    - dataOverrides. Pass nullptr for default sim state.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMSVTDisplayDrawIn(
                                        svt                 : XPLMSVTDisplayRef;
                                        features            : XPLMSVTFeatures;
                                        left                : Integer;
                                        top                 : Integer;
                                        right               : Integer;
                                        bottom              : Integer;
                                        dataOverrides       : PXPLMSVTCustomData_t);    { Can be nil }
    cdecl; external XPLM_DLL;

{$ENDIF XPLM440}
{$IFDEF XPLM440}
{___________________________________________________________________________
 * PANEL GRAPHICS map display
 ___________________________________________________________________________}
{
   These routines let you draw the base map for a navigation display (ND) or
   multi-function display (MFD) into your avionics panel. The base map
   provides layers for terrain, topography, bodies of water, EGPWS terrain
   warnings, airport taxi layouts, NEXRAD and cloud tops. These are drawn with
   a transverse Mercator projection centered near the map's datum.
   
   Create a map display with XPLMCreateMapDisplay and draw it with
   XPLMMapDisplayDrawIn. Each map instance manages its own terrain tile
   loading and GPU state, so you can have multiple independent views (e.g.
   pilot and copilot PFDs with different layers visible).
   
   To draw your own symbology on top - airports, a flight plan, traffic - use
   XPLMMapDisplayProject to turn a latitude/longitude into a pixel position,
   and XPLMMapDisplayUnproject to turn a click back into a latitude/longitude.
   Both take the same XPLMMapDrawInfo_t you draw with, so they describe
   exactly the projection that draw call produces.
   
   The base map works on any aircraft, regardless of whether the stock cockpit
   has an FMS or other avionics installed.
}


   {
    XPLMMapLayers
    
    Bit flags that control which visual layers a map display renders. Combine
    flags with bitwise OR to enable multiple layers. NOTE: Not all layers can
    be combined. You can display terrain and water and taxiways at the same 
    time, but you cannot display weather radar and EGPWS at the same time. 
    Only one of NEXRAD or Cloud IR can be displayed. Airport details (taxiways)
    are only visible at close-in zoom levels.
   }
TYPE
   XPLMMapLayers = (
     { Radar composite reflectivity.                                              }
      xplm_Map_Nexrad                          = 1
 
     { Infrared false-color cloud tops.                                           }
     ,xplm_Map_IR                              = 2
 
     { Topography (elevation color scale, not taking aircraft altitude into       }
     { account).                                                                  }
     ,xplm_Map_Topo                            = 4
 
     { Terrain (terrain elevation relative to aircraft altitude).                 }
     ,xplm_Map_Terrain                         = 8
 
     { Bodies of water.                                                           }
     ,xplm_Map_Water                           = 16
 
     { Terrain warnings (relative to aircraft altitude, trajectory and landing    }
     { gear position).                                                            }
     ,xplm_Map_EGPWS                           = 32
 
     { Raw 0-255 texture of terrain elevation for plugin use.                     }
     ,xplm_Map_raw_elev                        = 64
 
     { Airport runway and taxiway layouts.                                        }
     ,xplm_Map_safe_taxi                       = 128
 
   );
   PXPLMMapLayers = ^XPLMMapLayers;

   {
    XPLMEGPWSStyle
    
    Flag that controls how the map's EGPWS display layer is rendered.
   }
   XPLMEGPWSStyle = (
     { Terrain is drawn as small dithered blocks (common in most airliner         }
     { avionics).                                                                 }
      xplm_EGPWS_Style_Blocky                  = 0
 
     { Terrain countours are smooth and curved (common in modern avionics).       }
     ,xplm_EGPWS_Style_Smooth                  = 1
 
   );
   PXPLMEGPWSStyle = ^XPLMEGPWSStyle;

   {
    XPLMMapCustomData_t
    
    Per-frame description of what a map display should show: where it is
    centered, how it is oriented, how far it reaches, and what the terrain
    layers should shade against.
    
    centerX and centerY are in the same panel coordinates as the rectangle in
    XPLMMapDrawInfo_t, NOT relative to that rectangle. This is the point the
    map is centered on and the point it rotates about - the same sense as
    XPLMTransformRotate's center. For a map centered in its own rectangle it is
    ((left+right)/2, (bottom+top)/2). It is also the same space
    XPLMMapDisplayProject reports positions in, so you can put a symbol on the
    map without offsetting anything yourself.
    
    The center need not be the rectangle's midpoint, and may sit on or outside
    its edge: pushing it down toward the bottom edge puts more of the map ahead
    of the aircraft, which is how an EFIS arc mode is laid out.
    
    Two fields set the scale, and they are deliberately a matching pair:
    roseRadius is the distance from the center of the map out to the compass
    rose in pixels, and mapRange is that same distance in nautical miles. So
    setting mapRange to 40 puts the rose edge 40 nm from the aircraft, exactly
    like the range knob on a real EFIS control panel - and a centered rose
    therefore spans 80 nm across.
    
    Set structSize to the size of your struct so that future SDK versions can
    add fields without breaking existing plugins.
   }
   XPLMMapCustomData_t = RECORD
     { Set to sizeof(XPLMMapCustomData_t). This is checked; a size X-Plane does   }
     { not recognise is an error and is reported. X-Plane never modifies the      }
     { structure you pass.                                                        }
     structSize               : Integer;
     { datum lat (degrees).                                                       }
     datLat                   : Single;
     { datum lon (degrees).                                                       }
     datLon                   : Single;
     { map center x, in the same panel coordinates as XPLMMapDrawInfo_t's         }
     { rectangle.                                                                 }
     centerX                  : Integer;
     { map center y, in the same panel coordinates as XPLMMapDrawInfo_t's         }
     { rectangle.                                                                 }
     centerY                  : Integer;
     { center of the map out to the compass rose (pixels).                        }
     roseRadius               : Integer;
     { center of the map out to the compass rose (nautical miles).                }
     mapRange                 : Single;
     { map orientation (0=north up, 1=Track up, 2=Hdg up, 3=custom).              }
     orientation              : Integer;
     { terrain warning altitude (red, feet).                                      }
     terrainWarn              : Single;
     { terrain caution altitude (yellow, feet).                                   }
     terrainCaution           : Single;
     { ownship altitude (feet).                                                   }
     acfAlt                   : Single;
     { ownship gear status (1=gear down).                                         }
     gearDown                 : Integer;
     { if map orientation is custom, the true heading that points up (so 90 puts  }
     { east at the top and true north to the left).                               }
     trueRotation             : Single;
     { altitude in feet of the nearest runway, used for EGPWS terrain display.    }
     nearestRwyElev           : Single;
     { brightness of the EGPWS overlay.                                           }
     egpwsBrightness          : Single;
     { style of the EGPWS overlay. Must be one of the XPLMEGPWSStyle constants.   }
     egpwsStyle               : XPLMEGPWSStyle;
   END;
   PXPLMMapCustomData_t = ^XPLMMapCustomData_t;

   {
    XPLMCreateMap_t
    
    Parameters for creating a base map display. Set structSize to the size of
    your struct so that future SDK versions can add fields without breaking
    existing plugins.
   }
   XPLMCreateMap_t = RECORD
     { Set to sizeof(XPLMCreateMap_t).                                            }
     structSize               : Integer;
     { 0 for pilot-side GPS position, 1 for copilot-side GPS position.            }
     pilotIndex               : Integer;
   END;
   PXPLMCreateMap_t = ^XPLMCreateMap_t;

   {
    XPLMMapDisplayRef
    
    An opaque handle to a map display instance. Create one with
    XPLMCreateMapDisplay and destroy it with XPLMDestroyMapDisplay.
   }
   XPLMMapDisplayRef = pointer;
   PXPLMMapDisplayRef = ^XPLMMapDisplayRef;

   {
    XPLMMapDrawInfo_t
    
    Which layers a map shows and where on the panel it goes.
    
    Pass the same XPLMMapDrawInfo_t and the same XPLMMapCustomData_t to
    XPLMMapDisplayDrawIn and to the projection routines, and the projection you
    query is provably the projection you drew - so your symbology cannot end up
    a frame or a zoom step out of step with the terrain under it.
    
    Set structSize to the size of your struct so that future SDK versions can
    add fields without breaking existing plugins.
   }
   XPLMMapDrawInfo_t = RECORD
     { Set to sizeof(XPLMMapDrawInfo_t).                                          }
     structSize               : Integer;
     { Bitwise OR of XPLMMapLayers flags to show.                                 }
     layers                   : XPLMMapLayers;
     { Bounding rectangle in panel coordinates.                                   }
     left                     : Integer;
     { Bounding rectangle in panel coordinates.                                   }
     top                      : Integer;
     { Bounding rectangle in panel coordinates.                                   }
     right                    : Integer;
     { Bounding rectangle in panel coordinates.                                   }
     bottom                   : Integer;
   END;
   PXPLMMapDrawInfo_t = ^XPLMMapDrawInfo_t;

   {
    XPLMCreateMapDisplay
    
    This function creates a new map display instance. The display begins
    loading terrain tiles for the current aircraft position immediately. You
    can draw it as soon as tiles are available; before that, the draw call is a
    no-op.
    
    The returned handle must be destroyed with XPLMDestroyMapDisplay when no
    longer needed. Handles are automatically destroyed when the owning plugin
    is unloaded.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   FUNCTION XPLMCreateMapDisplay(
                                        params              : PXPLMCreateMap_t) : XPLMMapDisplayRef;
    cdecl; external XPLM_DLL;

   {
    XPLMDestroyMapDisplay
    
    This function destroys a map display and frees all associated resources.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMDestroyMapDisplay(
                                        map                 : XPLMMapDisplayRef);
    cdecl; external XPLM_DLL;

   {
    XPLMMapDisplayDrawIn
    
    This function renders the map display directly into the active panel
    surface within the rectangle given by info. Map sets up its own projection
    to fit that rectangle, so no transform stack manipulation is needed.
    
    info->layers controls which visual layers are rendered. Note that some
    layers are mutually exclusive, such as NEXRAD and EGPWS or NEXRAD and IR.
    The airport details layer is only visible at very close zoom levels.
    
    This function must be called from within an avionics drawing callback. If
    terrain tiles have not finished loading yet, this function does nothing.
    
    dataOverrides may be NULL, in which case the map follows the sim's own
    navigation display: centered on the user aircraft in the middle of the
    rectangle, rose radius half the shorter side of it, range taken from the
    EFIS range knob, and track-up or north-up according to the sim's map mode.
    The pilotIndex you created the map with selects which side's range and
    altitude are used.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMMapDisplayDrawIn(
                                        map                 : XPLMMapDisplayRef;
                                        info                : PXPLMMapDrawInfo_t;
                                        dataOverrides       : PXPLMMapCustomData_t);    { Can be nil }
    cdecl; external XPLM_DLL;

   {
    XPLMMapDisplayProject
    
    Turns a latitude/longitude into a position in panel coordinates, for the
    map that info describes. This is the inverse of XPLMMapDisplayUnproject.
    
    Pass the same info you draw that map with and you get the projection that
    draw call produces, whether you call this before or after
    XPLMMapDisplayDrawIn. So the usual pattern - project your symbols, draw the
    map, then draw the symbols on top - lines up exactly, with no need to cache
    anything between frames.
    
    Unlike XPLMMapDisplayDrawIn, this does not have to be called from a drawing
    callback; it is equally valid from a click handler or a flight loop.
    
    Returns 1 on success. Returns 0, leaving outX and outY untouched, if the
    map's terrain tiles have not loaded yet or if the point has no position on
    this map.
    
    Note that the returned coordinates are in the same space as info's
    rectangle, and like that rectangle they do not account for the panel
    graphics transform stack. That is deliberate, and it is what you want: you
    take these coordinates and hand them to a drawing call -
    XPLMTextureAtlasDrawAt to put a VOR symbol on the map, say - and that
    drawing call applies the transform. Applying it here as well would apply it
    twice.
    
    Passing NULL for dataOverrides projects the sim's own navigation display
    view, the same one XPLMMapDisplayDrawIn draws with NULL.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   FUNCTION XPLMMapDisplayProject(
                                        map                 : XPLMMapDisplayRef;
                                        info                : PXPLMMapDrawInfo_t;
                                        dataOverrides       : PXPLMMapCustomData_t;    { Can be nil }
                                        latitude            : Real;
                                        longitude           : Real;
                                        outX                : PSingle;
                                        outY                : PSingle) : Integer;
    cdecl; external XPLM_DLL;

   {
    XPLMMapDisplayUnproject
    
    Turns a position back into a latitude/longitude, for the map that info
    describes. This is the inverse of XPLMMapDisplayProject, and like it, x and
    y are in the same space as info's rectangle rather than in transformed
    coordinates.
    
    Use this to turn a touch or click on your map into a place in the world -
    for picking a waypoint, or reading out the position under the cursor. This
    needs no adjustment on your part in either of its two uses. For a touch,
    the coordinates your XPLMTouchEvent_f receives are already in the space you
    declared the zone in, so as long as you put the zone down under the same
    transform as the map, they are the space this function wants. For culling,
    you already hold your own drawing coordinates, which are likewise
    untransformed. In both cases, running the transform stack over the input -
    in either direction - would be the bug.
    
    Unlike XPLMMapDisplayDrawIn, this does not have to be called from a drawing
    callback; it is equally valid from a click handler or a flight loop, where
    there is no transform stack at all.
    
    Returns 1 on success. Returns 0, leaving outLatitude and outLongitude
    untouched, if the map's terrain tiles have not loaded yet or if the point
    does not correspond to anywhere on the earth.
    
    Passing NULL for dataOverrides projects the sim's own navigation display
    view, the same one XPLMMapDisplayDrawIn draws with NULL.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   FUNCTION XPLMMapDisplayUnproject(
                                        map                 : XPLMMapDisplayRef;
                                        info                : PXPLMMapDrawInfo_t;
                                        dataOverrides       : PXPLMMapCustomData_t;    { Can be nil }
                                        x                   : Single;
                                        y                   : Single;
                                        outLatitude         : PReal;
                                        outLongitude        : PReal) : Integer;
    cdecl; external XPLM_DLL;

   {
    XPLMMapDisplayScaleMeter
    
    Returns how many pixels correspond to one meter at a given point on the map
    that info describes. Use it to size symbols and range rings so they stay
    correct as the range changes.
    
    Returns 0 if the map's terrain tiles have not loaded yet.
    
    Passing NULL for dataOverrides projects the sim's own navigation display
    view, the same one XPLMMapDisplayDrawIn draws with NULL.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   FUNCTION XPLMMapDisplayScaleMeter(
                                        map                 : XPLMMapDisplayRef;
                                        info                : PXPLMMapDrawInfo_t;
                                        dataOverrides       : PXPLMMapCustomData_t;    { Can be nil }
                                        x                   : Single;
                                        y                   : Single) : Single;
    cdecl; external XPLM_DLL;

   {
    XPLMMapDisplayGetNorthHeading
    
    Returns the heading, in degrees clockwise from straight up on the display,
    at which true north lies at a given point on the map that info describes.
    ADD it to a true heading to get the angle to draw that heading at.
    
    This accounts both for the map's own rotation - a heading-up map is turned
    to put the aircraft's nose at the top - and for the projection's
    convergence, which tilts north away from vertical as you move away from the
    map's center.
    
    Returns 0 if the map's terrain tiles have not loaded yet.
    
    Passing NULL for dataOverrides projects the sim's own navigation display
    view, the same one XPLMMapDisplayDrawIn draws with NULL.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   FUNCTION XPLMMapDisplayGetNorthHeading(
                                        map                 : XPLMMapDisplayRef;
                                        info                : PXPLMMapDrawInfo_t;
                                        dataOverrides       : PXPLMMapCustomData_t;    { Can be nil }
                                        x                   : Single;
                                        y                   : Single) : Single;
    cdecl; external XPLM_DLL;

   {
    XPLMMapDisplayGetTerrainAltitudes
    
    This function returns the lowest and highest altitude shown on the map's
    EGPWS terrain display.
    
    Note that those altitudes are only available if the map has been drawn with
    the xplm_Map_EGPWS layer. If altitudes are not available, the function
    returns false, and the altitude pointers are not modified.
    
    This function must be called from within an avionics drawing callback.
    
    - map: the map display handle.
    - min: a pointer to the minimum altitude.
    - max: a pointer to the maximum altitude.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   FUNCTION XPLMMapDisplayGetTerrainAltitudes(
                                        map                 : XPLMMapDisplayRef;
                                        min                 : PSingle;    { Can be nil }
                                        max                 : PSingle) : Integer;    { Can be nil }
    cdecl; external XPLM_DLL;

{$ENDIF XPLM440}
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
 
     ,xplm_PGO_polygonc                        = 18
 
     ,xplm_PGO_quadstrip                       = 19
 
     ,xplm_PGO_quadstripc                      = 20
 
     ,xplm_PGO_drawstring                      = 21
 
     ,xplm_PGO_drawstring_fixed_width          = 22
 
     ,xplm_PGO_drawstring_word_wrapped         = 23
 
     ,xplm_PGO_drawstring_rotated              = 24
 
     ,xplm_PGO_drawtexture                     = 25
 
     ,xplm_PGO_transform_push                  = 26
 
     ,xplm_PGO_transform_pop                   = 27
 
     ,xplm_PGO_transform_translate             = 28
 
     ,xplm_PGO_transform_rotate                = 29
 
     ,xplm_PGO_transform_scale                 = 30
 
     ,xplm_PGO_scissor_push                    = 31
 
     ,xplm_PGO_scissor_pop                     = 32
 
     ,xplm_PGO_scissor_set                     = 33
 
     ,xplm_PGO_scissor_shrink                  = 34
 
     ,xplm_PGO_stencil_begin                   = 35
 
     ,xplm_PGO_stencil_end                     = 36
 
     ,xplm_PGO_stencil_use                     = 37
 
     ,xplm_PGO_stencil_clear                   = 38
 
     ,xplm_PGO_draw_svt                        = 39
 
     ,xplm_PGO_draw_map                        = 40
 
     ,xplm_PGO_drawcalls                       = 41
 
   );
   PXPLMPGOpcode = ^XPLMPGOpcode;










   {
    XPAtlasEntry
   }
   XPAtlasEntry = RECORD
     storage                  : PByte;
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


















{$IFDEF XPLM440}
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
   **straight (non-pre-multiplied) alpha** and blended accordingly. Submit
     ImGui's `ImDrawData` verts and font atlas as-is (no premultiply) -- this
     matches ImGui's own defaults.
   
   Sampler: bilinear filter, clamp-to-edge in both dimensions, no mipmaps. UV
   coordinates outside [0,1] sample the edge texels (no wrap).
   
   Scissor: the per-`XPLMDrawCall_t` scissor rect is in (left, top, right,
   bottom) order (top-left origin). Zero-width or zero-height rects produce no
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
     { Texture handle from XPLMCreateTexture. That is the ONLY valid source - this}
     { is not a general texture handle, and passing anything else (an             }
     { XPLMTextureAtlasRef, say) is undefined behavior, not a no-op.              }
     tex_ref                  : pointer;
     { Clip rect: (left, top, right, bottom) in window-local top-left coords.     }
     scissors                 : array[0..4 - 1] of Single;
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
     vertices                 : PSingle;
     index_count              : Integer;
     indices                  : PWord;
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
                                        rgba_image          : PByte;
                                        width               : Integer;
                                        height              : Integer) : pointer;
    cdecl; external XPLM_DLL;

   {
    XPLMDestroyTexture
    
    Frees a texture obtained from `XPLMCreateTexture`. Do not use the handle
    after calling this. It is safe to create and destroy textures every frame.
   }
    { NOT thread-safe. Use ONLY from the main thread, in callbacks.                 }
   PROCEDURE XPLMDestroyTexture(
                                        tex_ref             : pointer);
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
                                        inMesh              : PXPLMMesh_t;
                                        inCount             : Integer;
                                        inDrawCalls         : PXPLMDrawCall_t);
    cdecl; external XPLM_DLL;

{$ENDIF XPLM440}
{___________________________________________________________________________
 * IMGUI HELPERS glue
 ___________________________________________________________________________}






IMPLEMENTATION

END.
