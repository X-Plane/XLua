#ifndef _XPLMPanelGraphics_h_
#define _XPLMPanelGraphics_h_

/*
 * Copyright 2005-2026 Laminar Research, Sandy Barbour and Ben Supnik All
 * rights reserved.  See license.txt for usage. X-Plane SDK Version: 4.0.0
 *
 */

/***************************************************************************
 * XPLMPanelGraphics
 ***************************************************************************/
/*
 * The XPLMPanelGraphics API provides a 2-D drawing toolkit for avionics
 * screens and instrument panels. You use these routines from within an
 * avionics drawing callback (registered via XPLMRegisterAvionicsCallbacksEx
 * or XPLMCreateAvionicsEx) to draw lines, polygons, text, and images onto the
 * panel surface.
 * 
 * All drawing is expressed in panel coordinates: X increases to the right and
 * Y increases upward. Drawing commands are buffered and rendered by X-Plane
 * at the end of your callback; you do not manage OpenGL state directly.
 * 
 * Drawing State
 * ---
 * 
 * Panel graphics functions modify a shared drawing state that includes a
 * transformation matrix, a scissor (clip) rectangle, and a stencil mask. Each
 * of these has a push/pop stack so you can save and restore state around
 * localized drawing operations.
 * 
 * Drawing Order
 * ---
 * 
 * Primitives are drawn in the order you submit them. Later drawing calls
 * paint over earlier ones. Use the retained-drawing API to record a sequence
 * of draw calls once and replay it efficiently on subsequent frames.
 *
 */


#include "XPLMDefs.h"

#include "XPLMUtilities.h"

#include "XPLMDisplay.h"

#ifdef __cplusplus
extern "C" {
#endif


#if defined(XPLM440)
/***************************************************************************
 * PANEL GRAPHICS primitives
 ***************************************************************************/
/*
 * These routines draw 2-D vector primitives: lines, line strips, line loops,
 * filled polygons, and quad strips.
 * 
 * Line-based primitives (Lines, LineStrip, LineLoop) have four variants:
 * 
 * - Base variant: uniform color, default line width.
 * - WithWidth variant: uniform color, caller-specified line width.
 * - "c" variant: per-vertex color (using XPLMVertexColor_t), default line
 *   width.
 * - "c" + WithWidth variant: per-vertex color and caller-specified line
 *   width.
 * 
 * They also have a Stipple variant that draws dashed lines with a
 * caller-specified dash length and line width.
 * 
 * Filled primitives (Polygon, Quadstrip) have no line width, so they come in
 * only the base and "c" variants.
 *
 */


/*
 * XPLMVertex_t
 * 
 * A 2-D vertex with an x and y position in panel coordinates.
 *
 */
typedef struct {

    /* Horizontal position in panel coordinates, pixels.                          */
     float                     x;

    /* Vertical position in panel coordinates, pixels.                            */
     float                     y;
} XPLMVertex_t;

/*
 * XPLMVertexColor_t
 * 
 * A 2-D vertex with an x and y position in panel coordinates and a per-vertex
 * color. Use this struct with the "c" drawing variants to assign a different
 * color to each vertex; colors are interpolated across the primitive.
 *
 */
typedef struct {

    /* Horizontal position in panel coordinates, pixels.                          */
     float                     x;

    /* Vertical position in panel coordinates, pixels.                            */
     float                     y;

    /* Packed ABGR color as returned by XPLMMakeColor.                            */
     uint32_t                  color;
} XPLMVertexColor_t;

/*
 * XPLMMakeColor
 * 
 * This function packs four floating-point color components into a single
 * uint32_t suitable for use with all panel graphics drawing routines. Each
 * component is in the range 0.0 to 1.0 and is clamped before packing. The
 * returned value is in ABGR byte order (alpha in the high byte, red in the
 * low byte).
 *
 */
/* Thread-safe. This call may be used from threads.                              */
XPLM_API uint32_t   XPLMMakeColor(
                         float                red,
                         float                green,
                         float                blue,
                         float                alpha);

/*
 * XPLMLines
 * 
 * This function draws disconnected line segments. Every pair of vertices
 * defines one segment: the first segment runs from vertices[0] to
 * vertices[1], the second from vertices[2] to vertices[3], and so on.
 * 
 * - count: the number of vertices. Should be even; an odd trailing vertex is
 *   ignored.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMLines(
                         uint32_t             color,
                         const XPLMVertex_t   vertices[],
                         int                  count);

/*
 * XPLMLinesWithWidth
 * 
 * This function draws disconnected line segments with a caller-specified line
 * width. Vertex interpretation is the same as XPLMLines.
 * 
 * - lineWidth: the line width in pixels.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMLinesWithWidth(
                         uint32_t             color,
                         float                lineWidth,
                         const XPLMVertex_t   vertices[],
                         int                  count);

/*
 * XPLMLinesc
 * 
 * This function draws disconnected line segments with per-vertex colors.
 * Vertex interpretation is the same as XPLMLines; colors are interpolated
 * along each segment.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMLinesc(
                         const XPLMVertexColor_t vertices[],
                         int                  count);

/*
 * XPLMLinescWithWidth
 * 
 * This function draws disconnected line segments with per-vertex colors and a
 * caller-specified line width.
 * 
 * - lineWidth: the line width in pixels.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMLinescWithWidth(
                         float                lineWidth,
                         const XPLMVertexColor_t vertices[],
                         int                  count);

/*
 * XPLMLinesStipple
 * 
 * This function draws disconnected dashed line segments. Vertex
 * interpretation is the same as XPLMLines. The dash pattern alternates
 * between drawn and undrawn segments of equal length.
 * 
 * - dashLength: the length of each dash and gap, in pixels.
 * - lineWidth: the line width in pixels.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMLinesStipple(
                         uint32_t             color,
                         const XPLMVertex_t   pts[],
                         int                  count,
                         float                dashLength,
                         float                lineWidth);

/*
 * XPLMLineStrip
 * 
 * This function draws a connected line strip. Vertices are connected in
 * order: a segment from vertices[0] to vertices[1], then from vertices[1] to
 * vertices[2], and so on. The last vertex is not connected back to the first.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMLineStrip(
                         uint32_t             color,
                         const XPLMVertex_t   pts[],
                         int                  count);

/*
 * XPLMLineStripWithWidth
 * 
 * This function draws a connected line strip with a caller-specified line
 * width. Vertex interpretation is the same as XPLMLineStrip.
 * 
 * - lineWidth: the line width in pixels.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMLineStripWithWidth(
                         uint32_t             color,
                         float                lineWidth,
                         const XPLMVertex_t   pts[],
                         int                  count);

/*
 * XPLMLineStripc
 * 
 * This function draws a connected line strip with per-vertex colors. Vertex
 * interpretation is the same as XPLMLineStrip; colors are interpolated along
 * each segment.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMLineStripc(
                         const XPLMVertexColor_t pts[],
                         int                  count);

/*
 * XPLMLineStripcWithWidth
 * 
 * This function draws a connected line strip with per-vertex colors and a
 * caller-specified line width.
 * 
 * - lineWidth: the line width in pixels.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMLineStripcWithWidth(
                         float                lineWidth,
                         const XPLMVertexColor_t pts[],
                         int                  count);

/*
 * XPLMLineStripStipple
 * 
 * This function draws a connected dashed line strip. Vertex interpretation is
 * the same as XPLMLineStrip. The dash pattern alternates between drawn and
 * undrawn segments of equal length.
 * 
 * - dashLength: the length of each dash and gap, in pixels.
 * - lineWidth: the line width in pixels.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMLineStripStipple(
                         uint32_t             color,
                         const XPLMVertex_t   pts[],
                         int                  count,
                         float                dashLength,
                         float                lineWidth);

/*
 * XPLMLineLoop
 * 
 * This function draws a closed line loop. Vertices are connected in order,
 * and the last vertex is automatically connected back to the first, forming a
 * closed shape. The interior is not filled.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMLineLoop(
                         uint32_t             color,
                         const XPLMVertex_t   pts[],
                         int                  count);

/*
 * XPLMLineLoopWithWidth
 * 
 * This function draws a closed line loop with a caller-specified line width.
 * Vertex interpretation is the same as XPLMLineLoop.
 * 
 * - lineWidth: the line width in pixels.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMLineLoopWithWidth(
                         uint32_t             color,
                         float                lineWidth,
                         const XPLMVertex_t   pts[],
                         int                  count);

/*
 * XPLMLineLoopc
 * 
 * This function draws a closed line loop with per-vertex colors. Vertex
 * interpretation is the same as XPLMLineLoop; colors are interpolated along
 * each segment.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMLineLoopc(
                         const XPLMVertexColor_t pts[],
                         int                  count);

/*
 * XPLMLineLoopcWithWidth
 * 
 * This function draws a closed line loop with per-vertex colors and a
 * caller-specified line width.
 * 
 * - lineWidth: the line width in pixels.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMLineLoopcWithWidth(
                         float                lineWidth,
                         const XPLMVertexColor_t pts[],
                         int                  count);

/*
 * XPLMLineLoopStipple
 * 
 * This function draws a closed dashed line loop. Vertex interpretation is the
 * same as XPLMLineLoop. The dash pattern alternates between drawn and undrawn
 * segments of equal length.
 * 
 * - dashLength: the length of each dash and gap, in pixels.
 * - lineWidth: the line width in pixels.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMLineLoopStipple(
                         uint32_t             color,
                         const XPLMVertex_t   pts[],
                         int                  count,
                         float                dashLength,
                         float                lineWidth);

/*
 * XPLMPolygon
 * 
 * This function draws a filled convex polygon. The vertices define the
 * outline of the polygon, and the interior is filled with the specified
 * color.
 * 
 * - count: the number of vertices. You must provide at least 3 vertices.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMPolygon(
                         uint32_t             color,
                         const XPLMVertex_t   vertices[],
                         int                  count);

/*
 * XPLMPolygonc
 * 
 * This function draws a filled convex polygon with per-vertex colors. Colors
 * are interpolated across the polygon interior.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMPolygonc(
                         const XPLMVertexColor_t vertices[],
                         int                  count);

/*
 * XPLMQuadstrip
 * 
 * This function draws a series of connected filled quadrilaterals. Vertices
 * are taken in pairs: the first quad is formed by vertices[0], vertices[1],
 * vertices[2], vertices[3]; the next quad shares its leading edge with the
 * previous one, formed by vertices[2], vertices[3], vertices[4], vertices[5];
 * and so on.
 * 
 * - count: the number of vertices. Must be even and at least 4.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMQuadstrip(
                         uint32_t             color,
                         const XPLMVertex_t   vertices[],
                         int                  count);

/*
 * XPLMQuadstripc
 * 
 * This function draws a quad strip with per-vertex colors. Vertex
 * interpretation is the same as XPLMQuadstrip; colors are interpolated across
 * each quad.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMQuadstripc(
                         const XPLMVertexColor_t vertices[],
                         int                  count);
#endif /* XPLM440 */

#if defined(XPLM440)
/***************************************************************************
 * PANEL GRAPHICS fonts
 ***************************************************************************/
/*
 * These routines create fonts from TrueType font files and draw text onto the
 * panel. You create a font handle, add one or more TTF faces to it, then use
 * the handle to measure and draw strings. Font handles must be destroyed when
 * no longer needed.
 *
 */


/*
 * XPLMCharSet_t
 * 
 * This enumeration specifies the character set for a font created with
 * XPLMCreateFont. The character set determines which glyphs are rasterized
 * and available for drawing.
 *
 */
enum {

    /* Digits 0-9 and common numeric punctuation only.                            */
    xplm_CharSetDigits                       = 0,


    /* The printable ASCII character range (codes 32-126).                        */
    xplm_CharSetASCII                        = 1,


    /* Full Unicode support; glyphs are rasterized on demand.                     */
    xplm_CharSetUnicode                      = 2,


};
typedef int XPLMCharSet_t;

/*
 * XPLMJustification_t
 * 
 * This enumeration specifies horizontal text justification for the font
 * drawing routines. The x and y position you pass to a drawing function is
 * the baseline of the text at the anchor point determined by justification:
 * left-aligned text anchors at the left edge, centered text at the midpoint,
 * and right-aligned text at the right edge.
 *
 */
enum {

    /* Left-justified; x is the left edge of the string.                          */
    xplm_JustLeft                            = 0,


    /* Center-justified; x is the horizontal center of the string.                */
    xplm_JustCenter                          = 1,


    /* Right-justified; x is the right edge of the string.                        */
    xplm_JustRight                           = 2,


};
typedef int XPLMJustification_t;

/*
 * XPLMFontMetrics_t
 * 
 * XPLMFontMetrics_t receives font measurement data from XPLMFontGetMetrics.
 * The structure may be expanded in future SDKs - always set structSize to the
 * size of your structure in bytes.
 *
 */
typedef struct {

    /* Set to sizeof(XPLMFontMetrics_t).                                          */
     int                       structSize;

    /* Total line height including leading, in pixels.                            */
     float                     lineHeight;

    /* Distance from the baseline to the top of the tallest glyph, in pixels.     */
     float                     lineAscent;

    /* Distance from the baseline to the bottom of the lowest descender, in       *
     * pixels. This value is positive.                                            */
     float                     lineDescent;
} XPLMFontMetrics_t;

/*
 * XPLMFontHandle
 * 
 * An opaque handle to a font created by XPLMCreateFont. Pass this handle to
 * the font measurement and drawing routines. Destroy the handle with
 * XPLMDestroyFont when you are done with it.
 *
 */
typedef void* XPLMFontHandle;

/*
 * XPLMCreateFont
 * 
 * This function creates a new font handle. The character set determines which
 * glyphs are available for rendering. After creating the font, add one or
 * more TrueType faces with XPLMFontAddFace before drawing.
 * 
 * Returns an opaque font handle.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API XPLMFontHandle XPLMCreateFont(
                         XPLMCharSet_t        charset);

/*
 * XPLMDestroyFont
 * 
 * This function destroys a font handle and frees all associated resources.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMDestroyFont(
                         XPLMFontHandle       font);

/*
 * XPLMFontAddFace
 * 
 * This function adds a TrueType font face to an existing font handle. You may
 * add multiple faces to a single font to provide fallback glyphs; if a glyph
 * is not found in the first face, subsequent faces are searched in the order
 * they were added.
 * 
 * - ttf_path: a file system path to a .ttf or .otf font file.
 * 
 * Returns 1 if the face was loaded and added, or 0 if it could not be. When
 * this returns 0 the font is left exactly as it was, so you can try another
 * path, and a message explaining what went wrong is sent to your error
 * callback (see XPLMSetErrorCallback) and written to Log.txt.
 * 
 * Drawing with a font that has no faces draws nothing; it is not an error.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API int        XPLMFontAddFace(
                         XPLMFontHandle       font,
                         char const*          ttf_path);

/*
 * XPLMFontGetMetrics
 * 
 * This function returns line metrics for a font at a given size. The metrics
 * describe the vertical dimensions of a line of text and are useful for
 * computing text layout.
 * 
 * - fontSize: the font size in pixels.
 * - outMetrics: receives the computed metrics. You must set
 *   outMetrics->structSize before calling.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMFontGetMetrics(
                         XPLMFontHandle       font,
                         float                fontSize,
                         XPLMFontMetrics_t*   outMetrics);

/*
 * XPLMFontMeasureString
 * 
 * This function returns the width in pixels that a string would occupy if
 * drawn at the given font size. The string is not drawn.
 * 
 * Returns the horizontal advance width, in pixels.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API float      XPLMFontMeasureString(
                         XPLMFontHandle       font,
                         float                fontSize,
                         char const*          string);

/*
 * XPLMFontGetLineCount
 * 
 * This function calculates how many lines a string would occupy if
 * word-wrapped to the specified width at the given font size.
 * 
 * Returns the number of lines.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API int        XPLMFontGetLineCount(
                         XPLMFontHandle       font,
                         float                fontSize,
                         char const*          string,
                         float                width);

/*
 * XPLMFontFitForward
 * 
 * This function returns the number of characters from the beginning of a
 * string that fit within the specified width at the given font size.
 * Characters are measured left to right.
 * 
 * Returns a character count.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API int        XPLMFontFitForward(
                         XPLMFontHandle       font,
                         float                fontSize,
                         char const*          string,
                         float                width);

/*
 * XPLMFontFitReverse
 * 
 * This function returns the number of characters in the input string that
 * must be skipped to fit the reset of the string into the specified space.
 * This is useful for right-aligning a truncated string.
 * 
 * Returns a character count - the number of characters that must be removed
 * to fit.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API int        XPLMFontFitReverse(
                         XPLMFontHandle       font,
                         float                fontSize,
                         char const*          string,
                         float                width);

/*
 * XPLMFontDrawString
 * 
 * This function draws a null-terminated string at the specified position with
 * the given font, size, color, and justification. The x and y coordinates
 * specify the baseline position at the justification anchor point.
 * 
 * - fontSize: the font size in pixels.
 * - x, y: the anchor position of the baseline, in panel coordinates.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMFontDrawString(
                         XPLMFontHandle       font,
                         uint32_t             color,
                         float                fontSize,
                         float                x,
                         float                y,
                         char const*          string,
                         XPLMJustification_t  justification);

/*
 * XPLMFontDrawStringFixedSpacing
 * 
 * This function draws a null-terminated string using fixed character spacing
 * instead of the font's natural proportional spacing. Each character occupies
 * exactly fixedSpacing pixels horizontally, regardless of the glyph's actual
 * width. This is useful for numeric readouts where digits must not shift as
 * values change.
 * 
 * - fontSize: the font size in pixels.
 * - x, y: the anchor position of the baseline, in panel coordinates.
 * - fixedSpacing: the horizontal advance per character, in pixels.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMFontDrawStringFixedSpacing(
                         XPLMFontHandle       font,
                         uint32_t             color,
                         float                fontSize,
                         float                x,
                         float                y,
                         char const*          string,
                         int                  fixedSpacing,
                         XPLMJustification_t  justification);

/*
 * XPLMFontDrawStringWordWrapped
 * 
 * This function draws a null-terminated string with automatic word wrapping.
 * Text is broken at word boundaries to fit within the specified wrap width.
 * Lines are stacked downward from the initial y position, spaced by the
 * font's line height.
 * 
 * - fontSize: the font size in pixels.
 * - x, y: the anchor position of the first line's baseline, in panel
 *   coordinates.
 * - wrapWidth: the maximum line width in pixels before wrapping.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMFontDrawStringWordWrapped(
                         XPLMFontHandle       font,
                         uint32_t             color,
                         float                fontSize,
                         float                x,
                         float                y,
                         char const*          string,
                         int                  wrapWidth,
                         XPLMJustification_t  justification);

/*
 * XPLMFontDrawStringRotated
 * 
 * This function draws a null-terminated string rotated by the specified angle
 * around the anchor point. The anchor point is determined by x, y, and the
 * justification, just as in XPLMFontDrawString.
 * 
 * - fontSize: the font size in pixels.
 * - x, y: the anchor position of the baseline, in panel coordinates.
 * - angle: the rotation angle in degrees, positive clockwise.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMFontDrawStringRotated(
                         XPLMFontHandle       font,
                         uint32_t             color,
                         float                fontSize,
                         float                x,
                         float                y,
                         char const*          string,
                         float                angle,
                         XPLMJustification_t  justification);
#endif /* XPLM440 */

#if defined(XPLM440)
/***************************************************************************
 * PANEL GRAPHICS Texture atlas
 ***************************************************************************/
/*
 * These routines manage texture atlases for drawing images on the panel. A
 * texture atlas packs multiple source images into a single GPU texture for
 * efficient rendering. The typical workflow is:
 * 
 * - Create an atlas with XPLMCreateTextureAtlas.
 * - Add images from files or raw pixel data. Each image (or cell of an image
 *   set) receives a zero-based index.
 * - Call XPLMTextureAtlasBake to upload the atlas to the GPU.
 * - Draw images using the DrawAt, DrawIn, DrawStretched, DrawScaled, or
 *   DrawMesh routines.
 * - Destroy the atlas with XPLMDestroyTextureAtlas when it is no longer
 *   needed.
 * 
 * All images are stored as RGBA, 4 bytes per pixel.
 *
 */


/*
 * XPLMTextureAtlasRef
 * 
 * An opaque handle to a texture atlas. Create one with XPLMCreateTextureAtlas
 * and destroy it with XPLMDestroyTextureAtlas.
 *
 */
typedef void * XPLMTextureAtlasRef;

/*
 * XPLMTextureVertex_t
 * 
 * A vertex for textured mesh drawing. Combines a position in panel
 * coordinates with normalized texture coordinates within the image.
 * 
 * Texture coordinates are always relative to the image you are drawing, never
 * to the atlas sheet it happens to be packed into. This is true for both
 * XPLMTextureAtlasDrawMesh and XPLMTextureSourceDrawMesh, so the same vertex
 * array means the same thing to either one.
 *
 */
typedef struct {

    /* Horizontal position in panel coordinates, pixels.                          */
     float                     x;

    /* Vertical position in panel coordinates, pixels.                            */
     float                     y;

    /* Horizontal texture coordinate, 0.0 (left) to 1.0 (right), within the image.*/
     float                     s;

    /* Vertical texture coordinate, 0.0 (bottom) to 1.0 (top), within the image.  */
     float                     t;
} XPLMTextureVertex_t;

/*
 * XPLMCreateTextureAtlas
 * 
 * This function creates a new, empty texture atlas. After creating the atlas,
 * add images with the XPLMTextureAtlasAddImage or
 * XPLMTextureAtlasAddImageFile family of functions, then call
 * XPLMTextureAtlasBake before drawing.
 * 
 * Returns an opaque atlas handle.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API XPLMTextureAtlasRef XPLMCreateTextureAtlas(void);

/*
 * XPLMDestroyTextureAtlas
 * 
 * This function destroys a texture atlas and frees all associated GPU and CPU
 * resources.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMDestroyTextureAtlas(
                         XPLMTextureAtlasRef  inTextureAtlas);

/*
 * XPLMTextureAtlasAddImageFile
 * 
 * This function loads a PNG image file and adds it to the atlas as a single
 * image. Call this before XPLMTextureAtlasBake.
 * 
 * - inImageFilePath: the file system path to a PNG file.
 * 
 * Returns the zero-based image index assigned to this image.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API int        XPLMTextureAtlasAddImageFile(
                         XPLMTextureAtlasRef  inTextureAtlas,
                         const char *         inImageFilePath);

/*
 * XPLMTextureAtlasAddImageFileSet
 * 
 * This function loads a PNG image file and subdivides it into a grid of
 * cells, adding each cell to the atlas as a separate image. This is useful
 * for sprite sheets and image strip assets. Call this before
 * XPLMTextureAtlasBake.
 * 
 * - inImageFilePath: the file system path to a PNG file.
 * - inCellsX: the number of columns to divide the image into.
 * - inCellsY: the number of rows to divide the image into.
 * 
 * Returns the zero-based image index of the first cell (top-left). Subsequent
 * cells are numbered in row-major order: index + y * inCellsX + x.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API int        XPLMTextureAtlasAddImageFileSet(
                         XPLMTextureAtlasRef  inTextureAtlas,
                         const char *         inImageFilePath,
                         int                  inCellsX,
                         int                  inCellsY);

/*
 * XPLMTextureAtlasAddImage
 * 
 * This function adds a single image from raw pixel data to the atlas. The
 * pixel data must be RGBA format, 4 bytes per pixel, with rows ordered from
 * top to bottom. Call this before XPLMTextureAtlasBake.
 * 
 * - inImage: pointer to the raw RGBA pixel data.
 * - inWidth: the image width in pixels.
 * - inHeight: the image height in pixels.
 * 
 * Returns the zero-based image index assigned to this image.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API int        XPLMTextureAtlasAddImage(
                         XPLMTextureAtlasRef  inTextureAtlas,
                         const unsigned char * inImage,
                         int                  inWidth,
                         int                  inHeight);

/*
 * XPLMTextureAtlasAddImageSet
 * 
 * This function adds raw pixel data to the atlas, subdividing it into a grid
 * of cells. Each cell is added as a separate image. The pixel data must be
 * RGBA format, 4 bytes per pixel, with rows ordered from top to bottom. Call
 * this before XPLMTextureAtlasBake.
 * 
 * - inImage: pointer to the raw RGBA pixel data.
 * - inWidth: the total image width in pixels.
 * - inHeight: the total image height in pixels.
 * - inCellsX: the number of columns to divide the image into.
 * - inCellsY: the number of rows to divide the image into.
 * 
 * Returns the zero-based image index of the first cell. Subsequent cells are
 * numbered in row-major order: index + y * inCellsX + x.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API int        XPLMTextureAtlasAddImageSet(
                         XPLMTextureAtlasRef  inTextureAtlas,
                         const uint8_t        inImage[],
                         int                  inWidth,
                         int                  inHeight,
                         int                  inCellsX,
                         int                  inCellsY);

/*
 * XPLMTextureAtlasBake
 * 
 * This function packs all previously added images into a GPU texture. You
 * must call this after adding all images and before any draw calls. Once
 * baked, you cannot add more images to the atlas.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMTextureAtlasBake(
                         XPLMTextureAtlasRef  inTextureAtlas);

/*
 * XPLMTextureAtlasGetImageWidth
 * 
 * This function returns the width in pixels of a single image (or cell) in
 * the atlas.
 * 
 * Returns the image width in pixels.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API int        XPLMTextureAtlasGetImageWidth(
                         XPLMTextureAtlasRef  inTextureAtlas,
                         int                  inImageIndex);

/*
 * XPLMTextureAtlasGetImageHeight
 * 
 * This function returns the height in pixels of a single image (or cell) in
 * the atlas.
 * 
 * Returns the image height in pixels.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API int        XPLMTextureAtlasGetImageHeight(
                         XPLMTextureAtlasRef  inTextureAtlas,
                         int                  inImageIndex);

/*
 * XPLMTextureAtlasDrawAt
 * 
 * This function draws an atlas image at its native resolution. The image is
 * positioned with its top-left corner at (inX, inY) and extends rightward and
 * downward by its native pixel dimensions.
 * 
 * - inTintColor: a color that is multiplied with the texture. Use
 *   XPLMMakeColor(1, 1, 1, 1) for no tinting.
 * - inX: the left edge of the image, in panel coordinates.
 * - inY: the top edge of the image, in panel coordinates.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMTextureAtlasDrawAt(
                         XPLMTextureAtlasRef  inTextureAtlas,
                         int                  inImageIndex,
                         uint32_t             inTintColor,
                         float                inX,
                         float                inY);

/*
 * XPLMTextureAtlasDrawIn
 * 
 * This function draws an atlas image scaled to fill a rectangular region. The
 * image is stretched or compressed to exactly match the specified bounds.
 * 
 * - inTintColor: a color that is multiplied with the texture.
 * - inLeft, inTop, inRight, inBottom: the bounding rectangle in panel
 *   coordinates.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMTextureAtlasDrawIn(
                         XPLMTextureAtlasRef  inTextureAtlas,
                         int                  inImageIndex,
                         uint32_t             inTintColor,
                         float                inLeft,
                         float                inTop,
                         float                inRight,
                         float                inBottom);

/*
 * XPLMTextureAtlasDrawStretched
 * 
 * This function draws an atlas image using 9-slice scaling into a rectangular
 * region. The image is divided into a 3x3 grid (each slice being one third of
 * the original width and height). The four corner slices are drawn at their
 * native size, the four edge slices are stretched along one axis, and the
 * center slice is stretched in both directions. This preserves corners and
 * borders when scaling UI elements like buttons or panels.
 * 
 * - inTintColor: a color that is multiplied with the texture.
 * - inLeft, inTop, inRight, inBottom: the bounding rectangle in panel
 *   coordinates.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMTextureAtlasDrawStretched(
                         XPLMTextureAtlasRef  inTextureAtlas,
                         int                  inImageIndex,
                         uint32_t             inTintColor,
                         float                inLeft,
                         float                inTop,
                         float                inRight,
                         float                inBottom);

/*
 * XPLMTextureAtlasDrawScaled
 * 
 * This function draws an atlas image with arbitrary scaling, rotation, and
 * positioning. The image is placed so that the atlas-space pivot point
 * (inXAtlas, inYAtlas) aligns with the panel-space position (inXPanel,
 * inYPanel), then scaled and rotated around that point.
 * 
 * - inTintColor: a color that is multiplied with the texture.
 * - inXPanel, inYPanel: the destination point in panel coordinates.
 * - inXAtlas, inYAtlas: the pivot point within the image, in pixels from the
 *   image's bottom-left corner.
 * - inXScale, inYScale: horizontal and vertical scale factors. 1.0 draws at
 *   native resolution.
 * - inRotateCW: clockwise rotation in degrees around the pivot point.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMTextureAtlasDrawScaled(
                         XPLMTextureAtlasRef  inTextureAtlas,
                         int                  inImageIndex,
                         uint32_t             inTintColor,
                         float                inXPanel,
                         float                inYPanel,
                         float                inXAtlas,
                         float                inYAtlas,
                         float                inXScale,
                         float                inYScale,
                         float                inRotateCW);

/*
 * XPLMTextureAtlasDrawMesh
 * 
 * This function draws an atlas image onto an arbitrary triangle-strip mesh.
 * Each vertex specifies both a panel-space position and a normalized texture
 * coordinate within the image (0.0 to 1.0). This gives you full control over
 * how the image is mapped onto geometry.
 * 
 * Texture coordinates are relative to the image, not to the atlas sheet; the
 * mapping onto wherever the image was packed is applied for you, exactly as
 * it is for the other atlas drawing routines. One consequence is that the
 * same vertex array can be drawn with any inImageIndex - you do not have to
 * rebuild the mesh to switch images.
 * 
 * Coordinates outside 0.0 to 1.0 are not clamped, and will sample whatever
 * neighboring image shares the atlas sheet. Keep them in range.
 * 
 * - inTintColor: a color that is multiplied with the texture.
 * - vertices: an array of XPLMTextureVertex_t vertices defining the triangle
 *   strip.
 * - count: the number of vertices. Must be at least 3.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMTextureAtlasDrawMesh(
                         XPLMTextureAtlasRef  inTextureAtlas,
                         int                  inImageIndex,
                         uint32_t             inTintColor,
                         const XPLMTextureVertex_t vertices[],
                         int                  count);
#endif /* XPLM440 */

#if defined(XPLM440)
/***************************************************************************
 * PANEL GRAPHICS radar texture
 ***************************************************************************/
/*
 * These routines draw stock simulator textures, such as weather radar
 * displays, into your avionics panel. Unlike texture atlas images which are
 * loaded from files you provide, texture sources are live textures rendered
 * by the simulator each frame. If the aircraft does not have the requested
 * hardware (e.g. no weather radar installed), the draw call is silently
 * skipped.
 *
 */


/*
 * XPLMTextureSource
 * 
 * An XPLMTextureSource identifies a stock simulator texture that can be drawn
 * with the texture source drawing functions.
 *
 */
enum {

    /* The pilot-side weather radar display.                                      */
    xplm_Texture_WeatherRadar1               = 0,


    /* The copilot-side weather radar display.                                    */
    xplm_Texture_WeatherRadar2               = 1,


};
typedef int XPLMTextureSource;

/*
 * XPLMTextureSourceDrawIn
 * 
 * This function draws a texture source scaled to fill a rectangular region.
 * The texture is stretched or compressed to exactly match the specified
 * bounds.
 * 
 * - tex: the texture source to draw.
 * - tint: a color that is multiplied with the texture. Use XPLMMakeColor(1,
 *   1, 1, 1) for no tinting.
 * - left, top, right, bottom: the bounding rectangle in panel coordinates.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMTextureSourceDrawIn(
                         XPLMTextureSource    tex,
                         uint32_t             tint,
                         int                  left,
                         int                  top,
                         int                  right,
                         int                  bottom);

/*
 * XPLMTextureSourceDrawMesh
 * 
 * This function draws a texture source onto an arbitrary triangle-strip mesh.
 * Each vertex specifies both a panel-space position and a normalized texture
 * coordinate (0.0 to 1.0) within the source texture. This gives you full
 * control over how the texture is mapped onto geometry.
 * 
 * - tex: the texture source to draw.
 * - tint: a color that is multiplied with the texture.
 * - mesh: an array of XPLMTextureVertex_t vertices defining the triangle
 *   strip.
 * - count: the number of vertices. Must be at least 3.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMTextureSourceDrawMesh(
                         XPLMTextureSource    tex,
                         uint32_t             tint,
                         const XPLMTextureVertex_t mesh[],
                         int                  count);
#endif /* XPLM440 */

#if defined(XPLM440)
/***************************************************************************
 * PANEL_GRAPHICS transform/scissors/masks
 ***************************************************************************/
/*
 * These routines modify the drawing state for subsequent panel graphics
 * calls. The transformation matrix controls the position, rotation, and scale
 * of all drawing. The scissor rectangle clips drawing to a rectangular
 * region. The stencil mask clips drawing to an arbitrary shape.
 * 
 * Each state type has a push/pop stack. Always push before modifying state
 * and pop to restore the previous state when you are done.
 *
 */


/*
 * XPLMTransformPush
 * 
 * This function saves the current transformation matrix onto the transform
 * stack. Call XPLMTransformPop to restore it. Calls must be balanced.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMTransformPush(void);

/*
 * XPLMTransformPop
 * 
 * This function restores the transformation matrix from the top of the
 * transform stack, undoing all translate, rotate, and scale operations since
 * the matching XPLMTransformPush.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMTransformPop(void);

/*
 * XPLMTransformTranslate
 * 
 * This function translates (offsets) all subsequent drawing by the specified
 * amounts. The translation is applied on top of the current transformation
 * matrix.
 * 
 * - dx: horizontal offset in pixels, positive to the right.
 * - dy: vertical offset in pixels, positive upward.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMTransformTranslate(
                         float                dx,
                         float                dy);

/*
 * XPLMTransformRotate
 * 
 * This function rotates all subsequent drawing around a center point. The
 * rotation is applied on top of the current transformation matrix.
 * 
 * - centerX, centerY: the center of rotation in panel coordinates.
 * - angle: the rotation angle in degrees, positive counterclockwise.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMTransformRotate(
                         float                centerX,
                         float                centerY,
                         float                angle);

/*
 * XPLMTransformScale
 * 
 * This function scales all subsequent drawing relative to the origin of the
 * current coordinate system. The scale is applied on top of the current
 * transformation matrix.
 * 
 * - scaleX: horizontal scale factor. 1.0 is no change, 2.0 doubles width.
 * - scaleY: vertical scale factor. 1.0 is no change, 2.0 doubles height.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMTransformScale(
                         float                scaleX,
                         float                scaleY);

/*
 * XPLMScissorPush
 * 
 * This function saves the current scissor rectangle onto the scissor stack.
 * Call XPLMScissorPop to restore it. Calls must be balanced.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMScissorPush(void);

/*
 * XPLMScissorPop
 * 
 * This function restores the scissor rectangle from the top of the scissor
 * stack, undoing any set or shrink operations since the matching
 * XPLMScissorPush.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMScissorPop(void);

/*
 * XPLMScissorSet
 * 
 * This function sets an absolute scissor rectangle. Only pixels within this
 * rectangle are drawn; everything outside is clipped.
 * 
 * - left, top, right, bottom: the scissor bounds in panel coordinates.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMScissorSet(
                         int                  left,
                         int                  top,
                         int                  right,
                         int                  bottom);

/*
 * XPLMScissorIntersect
 * 
 * This function sets the scissors box to the intersection of the existing
 * scissors box. The result is always a same or smaller drawable area. This is
 * useful for nested clipping.
 * 
 * - left: inset from the left edge, in pixels.
 * - top: inset from the top edge, in pixels.
 * - right: inset from the right edge, in pixels.
 * - bottom: inset from the bottom edge, in pixels.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMScissorIntersect(
                         int                  left,
                         int                  top,
                         int                  right,
                         int                  bottom);

/*
 * XPLMBeginSetupStencilMask
 * 
 * This function begins stencil mask setup. While in setup mode, drawing
 * commands write to the stencil buffer instead of to the screen. Draw the
 * shapes that define your mask region, then call XPLMEndSetupStencilMask to
 * finish.
 * 
 * - bits: the stencil bit pattern to write into the stencil buffer where
 *   geometry is drawn.
 * - mask: a bitmask selecting which stencil bits are written.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMBeginSetupStencilMask(
                         unsigned int         bits,
                         unsigned int         mask);

/*
 * XPLMEndSetupStencilMask
 * 
 * This function ends stencil mask setup. After this call, drawing commands
 * once again render to the screen. Call XPLMUseStencilMask to activate the
 * mask for subsequent drawing, or XPLMClearStencilMask to discard it.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMEndSetupStencilMask(void);

/*
 * XPLMUseStencilMask
 * 
 * This function activates stencil testing. Subsequent drawing is clipped to
 * the region defined during stencil setup: only pixels where the stencil
 * buffer matches the specified bit pattern are drawn.
 * 
 * - bits: the reference bit pattern to test against.
 * - mask: a bitmask selecting which stencil bits participate in the test.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMUseStencilMask(
                         unsigned int         bits,
                         unsigned int         mask);

/*
 * XPLMClearStencilMask
 * 
 * This function clears the stencil buffer and disables stencil testing.
 * Subsequent drawing is no longer clipped by the stencil mask.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMClearStencilMask(void);
#endif /* XPLM440 */

#if defined(XPLM440)
/***************************************************************************
 * PANEL GRAPHICS Hot Zones
 ***************************************************************************/
/*
 * These routines define interactive touch zones on a panel surface. You call
 * XPLMAccumulateTouchZone during your drawing callback to declare rectangular
 * regions that respond to mouse clicks or touches. Each zone can either fire
 * an X-Plane command automatically or deliver raw touch events to a callback
 * you register with XPLMAvionicsSetTouchEventHandler.
 *
 */


/*
 * XPLMTouchZone
 * 
 * This enumeration specifies how a touch zone responds to user interaction.
 *
 */
enum {

    /* The zone is registered but takes no action when touched.                   */
    xplm_TouchZone_Nothing                   = 0,


    /* The zone fires an XPLMCommandRef when touched (begin on mouse-down, end on *
     * mouse-up).                                                                 */
    xplm_TouchZone_Command                   = 1,


    /* The zone delivers touch events to the callback registered via              *
     * XPLMAvionicsSetTouchEventHandler, identified by the zone's identifier      *
     * field.                                                                     */
    xplm_TouchZone_Identifier                = 2,


};
typedef int XPLMTouchZone;

/*
 * XPLMTouchEvent_f
 * 
 * Your touch event callback is invoked when the user interacts with a touch
 * zone whose type is xplm_TouchZone_Identifier. You receive the zone's
 * identifier, the mouse status, the current position, the delta from the
 * initial click point, and the mouse button involved.
 *
 */
typedef void (* XPLMTouchEvent_f)(
                         int                  identifier,
                         XPLMMouseStatus      status,
                         int                  x,
                         int                  y,
                         int                  dx,
                         int                  dy,
                         int                  button,
                         void*                ref);

/*
 * XPLMTouchZoneSpec_t
 * 
 * XPLMTouchZoneSpec_t describes a single interactive touch zone on the panel.
 * Pass a pointer to this struct to XPLMAccumulateTouchZone during your
 * drawing callback. The structure may be expanded in future SDKs - always set
 * structSize to the size of your structure in bytes.
 *
 */
typedef struct {

    /* Set to sizeof(XPLMTouchZoneSpec_t).                                        */
     int                       structSize;

    /* How the zone responds to interaction.                                      */
     XPLMTouchZone             type;

    /* The command to fire. Only used when type is xplm_TouchZone_Command.        */
     XPLMCommandRef            command;

    /* An integer you assign to identify this zone in your XPLMTouchEvent_f       *
     * callback. Only used when type is xplm_TouchZone_Identifier.                */
     int                       identifier;

    /* Left edge of the zone, in panel coordinates.                               */
     int                       left;

    /* Top edge of the zone, in panel coordinates.                                */
     int                       top;

    /* Right edge of the zone, in panel coordinates.                              */
     int                       right;

    /* Bottom edge of the zone, in panel coordinates.                             */
     int                       bottom;
} XPLMTouchZoneSpec_t;

/*
 * XPLMAccumulateTouchZone
 * 
 * This function registers a touch zone for the current frame. Call this
 * during your avionics drawing callback each frame for every interactive
 * region on your panel. Zones registered later take priority over earlier
 * ones when they overlap.
 * 
 * Returns true if the zone is currently being clicked or held by the user,
 * false otherwise. You can use this to provide visual feedback (for example,
 * drawing a button in its pressed state).
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API int        XPLMAccumulateTouchZone(
                         XPLMTouchZoneSpec_t * inSpec);

/*
 * XPLMAvionicsSetTouchEventHandler
 * 
 * This function registers a callback to receive touch events for zones of
 * type xplm_TouchZone_Identifier on a specific avionics device. When the user
 * interacts with an identifier-type zone, your callback is invoked with the
 * zone's identifier and the mouse event details.
 * 
 * - avionic: the avionics device handle (from XPLMRegisterAvionicsCallbacksEx
 *   or XPLMCreateAvionicsEx).
 * - handler: your XPLMTouchEvent_f callback.
 * - ref: a reference pointer passed through to your callback.
 *
 */
/* Thread-safe. This call may be used from threads.                              */
XPLM_API void       XPLMAvionicsSetTouchEventHandler(
                         XPLMAvionicsID       avionic,
                         XPLMTouchEvent_f     handler,                /* Can be NULL */
                         void*                ref);

/*
 * XPLMWindowSetTouchEventHandler
 *
 */
/* Thread-safe. This call may be used from threads.                              */
XPLM_API void       XPLMWindowSetTouchEventHandler(
                         XPLMWindowID         window,
                         XPLMTouchEvent_f     handler,                /* Can be NULL */
                         void*                ref);
#endif /* XPLM440 */

#if defined(XPLM440)
/***************************************************************************
 * PANEL GRAPHICS Retained Drawing
 ***************************************************************************/
/*
 * These routines let you record a sequence of panel graphics drawing commands
 * and replay them efficiently on subsequent frames. This is useful for static
 * or infrequently changing parts of a display: record once, then replay each
 * frame without reissuing individual draw calls.
 * 
 * WARNING: A retained drawing captures references to the texture atlases and
 * fonts used during recording. If you destroy a texture atlas or font that
 * was used in a retained drawing, you must also destroy that retained drawing
 * - replaying it will reference invalid resources.
 *
 */


/*
 * XPLMRetainedDrawing_t
 * 
 * An opaque handle to a recorded sequence of drawing commands. Create one by
 * bracketing draw calls between XPLMBeginRetainedDrawing and
 * XPLMEndRetainedDrawing. Destroy it with XPLMDestroyRetainedDrawing when it
 * is no longer needed.
 *
 */
typedef void * XPLMRetainedDrawing_t;

/*
 * XPLMBeginRetainedDrawing
 * 
 * This function begins recording drawing commands. All panel graphics calls
 * made after this function and before XPLMEndRetainedDrawing are captured
 * into a retained drawing instead of being rendered immediately.
 * 
 * NOTE: Do not nest retained drawing sessions.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMBeginRetainedDrawing(void);

/*
 * XPLMEndRetainedDrawing
 * 
 * This function ends recording and returns a handle to the captured drawing
 * commands. Subsequent panel graphics calls are once again rendered
 * immediately.
 * 
 * Returns an opaque handle to the retained drawing.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API XPLMRetainedDrawing_t XPLMEndRetainedDrawing(void);

/*
 * XPLMDrawRetained
 * 
 * This function replays a previously recorded sequence of drawing commands.
 * You can call this multiple times per frame and across multiple frames to
 * efficiently re-draw the same content.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMDrawRetained(
                         XPLMRetainedDrawing_t drawing);

/*
 * XPLMDestroyRetainedDrawing
 * 
 * This function destroys a retained drawing and frees its resources.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMDestroyRetainedDrawing(
                         XPLMRetainedDrawing_t drawing);
#endif /* XPLM440 */

#if defined(XPLM440)
/***************************************************************************
 * PANEL GRAPHICS synthetic vision
 ***************************************************************************/
/*
 * These routines let you draw the simulator's Synthetic Vision Technology
 * (SVT) terrain rendering into your avionics panel. SVT provides a 3-D
 * perspective view of terrain, runways, obstacles, and optional overlays such
 * as flight path hoops, traffic, and airport signs. The view is always
 * centered on the user aircraft and uses the selected AHRS source for
 * attitude.
 * 
 * Create an SVT display with XPLMCreateSVTDisplay and draw it with
 * XPLMSVTDisplayDrawIn. Each display instance manages its own terrain tile
 * loading and GPU state, so you can have multiple independent SVT views (e.g.
 * pilot and copilot PFDs at different scales). Which visual layers are drawn
 * is chosen per draw call, not per display.
 * 
 * SVT rendering works on any aircraft, regardless of whether the stock
 * cockpit has a G1000 or other SVT-capable avionics installed.
 *
 */


/*
 * XPLMSVTFeatures
 * 
 * Bit flags that control which visual layers an SVT display renders. Combine
 * flags with bitwise OR to enable multiple layers.
 *
 */
enum {

    /* 3-D terrain mesh with elevation coloring.                                  */
    xplm_SVT_Terrain                         = 1,


    /* Runway outlines, centerline stripes, and numbers.                          */
    xplm_SVT_Runways                         = 2,


    /* Obstacle markers (towers, masts, etc.).                                    */
    xplm_SVT_Obstacles                       = 4,


    /* Flight path guidance hoops along the active route.                         */
    xplm_SVT_FlightPath                      = 8,


    /* TCAS traffic symbols.                                                      */
    xplm_SVT_Traffic                         = 16,


    /* Airport identification signs near airports.                                */
    xplm_SVT_AirportSigns                    = 32,


    /* ILS approach guidance hoops.                                               */
    xplm_SVT_ILSHoops                        = 64,


    /* Horizon line and heading reference.                                        */
    xplm_SVT_HorizonHeading                  = 128,


    /* All visual layers enabled.                                                 */
    xplm_SVT_All                             = 255,


};
typedef int XPLMSVTFeatures;

/*
 * XPLMCreateSVT_t
 * 
 * Parameters for creating an SVT display. Set structSize to the size of your
 * struct so that future SDK versions can add fields without breaking existing
 * plugins.
 *
 */
typedef struct {

    /* Set to sizeof(XPLMCreateSVT_t).                                            */
     int                       structSize;

    /* 0 for pilot-side AHRS, 1 for copilot-side AHRS.                            */
     int                       pilotIndex;

    /* Vertical scale of the 3-d view, in pixels per degree at the center of the  *
     * display.  Must be greater than zero; the G1000 PFD uses 14.                */
     float                     pixelsPerDegree;
} XPLMCreateSVT_t;

/*
 * XPLMSVTDisplayRef
 * 
 * An opaque handle to an SVT display instance. Create one with
 * XPLMCreateSVTDisplay and destroy it with XPLMDestroySVTDisplay.
 *
 */
typedef void * XPLMSVTDisplayRef;

/*
 * XPLMCreateSVTDisplay
 * 
 * This function creates a new SVT display instance. The display begins
 * loading terrain tiles for the current aircraft position immediately. You
 * can draw it as soon as tiles are available; before that, the draw call is a
 * no-op.
 * 
 * The pixelsPerDegree scale and the rectangle you pass to
 * XPLMSVTDisplayDrawIn together determine the field of view: the rectangle is
 * simply the scale applied to the view's angular extent. So drawing into a
 * bigger rectangle at the same scale shows _more_ of the world at the same
 * magnification rather than zooming in, and to zoom you change the scale, not
 * the rectangle. Pick the same scale your pitch ladder uses and the 3-d
 * horizon will line up with your artificial horizon.
 * 
 * Which visual layers are rendered is a property of the draw call, not of the
 * display - see XPLMSVTDisplayDrawIn.
 * 
 * The returned handle must be destroyed with XPLMDestroySVTDisplay when no
 * longer needed. Handles are automatically destroyed when the owning plugin
 * is unloaded.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API XPLMSVTDisplayRef XPLMCreateSVTDisplay(
                         XPLMCreateSVT_t *    params);

/*
 * XPLMDestroySVTDisplay
 * 
 * This function destroys an SVT display and frees all associated resources.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMDestroySVTDisplay(
                         XPLMSVTDisplayRef    svt);

/*
 * XPLMSVTCustomData_t
 *
 */
typedef struct {

    /* pitch override (degrees).                                                  */
     float                     pitchDeg;

    /* roll/bank override (degrees).                                              */
     float                     rollDeg;

    /* magnetic heading override (degrees).                                       */
     float                     headingMagDeg;

    /* magnetic variation override (degrees).                                     */
     float                     magVarDeg;

    /* indicated altitude override (feet).                                        */
     float                     indicatedAltFt;

    /* altimeter setting override ( inHg).                                        */
     float                     baroSettingInHg;

    /* HSI source override.                                                       */
     int                       hsiSource;

    /* horizontal CDI deviation override (float).                                 */
     float                     hdefDots;

    /* vertical GS deviation override (float).                                    */
     float                     vdefDots;
} XPLMSVTCustomData_t;

/*
 * XPLMSVTDisplayDrawIn
 * 
 * This function renders the SVT display directly into the active panel
 * surface within the specified rectangular region. SVT sets up its own 3-D
 * perspective projection to fit the rectangle, so no transform stack
 * manipulation is needed.
 * 
 * The features parameter controls which visual layers are rendered for this
 * draw call. Pass a bitwise OR of XPLMSVTFeatures flags.
 * 
 * This function must be called from within an avionics drawing callback. If
 * terrain tiles have not finished loading yet, this function does nothing.
 * 
 * - svt: the SVT display handle.
 * - features: bitwise OR of XPLMSVTFeatures flags to enable for this draw
 *   call.
 * - left, top, right, bottom: the bounding rectangle in panel coordinates.
 * - dataOverrides. Pass nullptr for default sim state.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMSVTDisplayDrawIn(
                         XPLMSVTDisplayRef    svt,
                         XPLMSVTFeatures      features,
                         int                  left,
                         int                  top,
                         int                  right,
                         int                  bottom,
                         XPLMSVTCustomData_t* dataOverrides);         /* Can be NULL */
#endif /* XPLM440 */

#if defined(XPLM440)
/***************************************************************************
 * PANEL GRAPHICS map display
 ***************************************************************************/
/*
 * These routines let you draw the base map for a navigation display (ND) or
 * multi-function display (MFD) into your avionics panel. The base map
 * provides layers for terrain, topography, bodies of water, EGPWS terrain
 * warnings, airport taxi layouts, NEXRAD and cloud tops. These are drawn with
 * a transverse Mercator projection centered near the map's datum.
 * 
 * Create a map display with XPLMCreateMapDisplay and draw it with
 * XPLMMapDisplayDrawIn. Each map instance manages its own terrain tile
 * loading and GPU state, so you can have multiple independent views (e.g.
 * pilot and copilot PFDs with different layers visible).
 * 
 * To draw your own symbology on top - airports, a flight plan, traffic - use
 * XPLMMapDisplayProject to turn a latitude/longitude into a pixel position,
 * and XPLMMapDisplayUnproject to turn a click back into a latitude/longitude.
 * Both take the same XPLMMapDrawInfo_t you draw with, so they describe
 * exactly the projection that draw call produces.
 * 
 * The base map works on any aircraft, regardless of whether the stock cockpit
 * has an FMS or other avionics installed.
 *
 */


/*
 * XPLMMapLayers
 * 
 * Bit flags that control which visual layers a map display renders. Combine
 * flags with bitwise OR to enable multiple layers. NOTE: Not all layers can
 * be combined. You can display terrain and water and taxiways at the same 
 * time, but you cannot display weather radar and EGPWS at the same time. 
 * Only one of NEXRAD or Cloud IR can be displayed. Airport details (taxiways)
 * are only visible at close-in zoom levels.
 *
 */
enum {

    /* Radar composite reflectivity.                                              */
    xplm_Map_Nexrad                          = 1,


    /* Infrared false-color cloud tops.                                           */
    xplm_Map_IR                              = 2,


    /* Topography (elevation color scale, not taking aircraft altitude into       *
     * account).                                                                  */
    xplm_Map_Topo                            = 4,


    /* Terrain (terrain elevation relative to aircraft altitude).                 */
    xplm_Map_Terrain                         = 8,


    /* Bodies of water.                                                           */
    xplm_Map_Water                           = 16,


    /* Terrain warnings (relative to aircraft altitude, trajectory and landing    *
     * gear position).                                                            */
    xplm_Map_EGPWS                           = 32,


    /* Raw 0-255 texture of terrain elevation for plugin use.                     */
    xplm_Map_raw_elev                        = 64,


    /* Airport runway and taxiway layouts.                                        */
    xplm_Map_safe_taxi                       = 128,


};
typedef int XPLMMapLayers;

/*
 * XPLMEGPWSStyle
 * 
 * Flag that controls how the map's EGPWS display layer is rendered.
 *
 */
enum {

    /* Terrain is drawn as small dithered blocks (common in most airliner         *
     * avionics).                                                                 */
    xplm_EGPWS_Style_Blocky                  = 0,


    /* Terrain countours are smooth and curved (common in modern avionics).       */
    xplm_EGPWS_Style_Smooth                  = 1,


};
typedef int XPLMEGPWSStyle;

/*
 * XPLMMapCustomData_t
 * 
 * Per-frame description of what a map display should show: where it is
 * centered, how it is oriented, how far it reaches, and what the terrain
 * layers should shade against.
 * 
 * Two fields set the scale, and they are deliberately a matching pair:
 * roseRadius is the distance from the center of the map out to the compass
 * rose in pixels, and mapRange is that same distance in nautical miles. So
 * setting mapRange to 40 puts the rose edge 40 nm from the aircraft, exactly
 * like the range knob on a real EFIS control panel - and a centered rose
 * therefore spans 80 nm across.
 * 
 * Set structSize to the size of your struct so that future SDK versions can
 * add fields without breaking existing plugins.
 *
 */
typedef struct {

    /* Set to sizeof(XPLMMapCustomData_t).                                        */
     int                       structSize;

    /* datum lat (degrees).                                                       */
     float                     datLat;

    /* datum lon (degrees).                                                       */
     float                     datLon;

    /* map center x coordinate (pixels).                                          */
     int                       ctrX;

    /* map center y coordinate (pixels).                                          */
     int                       ctrY;

    /* center of the map out to the compass rose (pixels).                        */
     int                       roseRadius;

    /* center of the map out to the compass rose (nautical miles).                */
     float                     mapRange;

    /* map orientation (0=north up, 1=Track up, 2=Hdg up, 3=custom).              */
     int                       orientation;

    /* terrain warning altitude (red, feet).                                      */
     float                     terrainWarn;

    /* terrain caution altitude (yellow, feet).                                   */
     float                     terrainCaution;

    /* ownship altitude (feet).                                                   */
     float                     acfAlt;

    /* ownship gear status (1=gear down).                                         */
     int                       gearDown;

    /* if map orientation is custom, the true heading that points up (so 90 puts  *
     * east at the top and true north to the left).                               */
     float                     trueRotation;

    /* altitude in feet of the nearest runway, used for EGPWS terrain display.    */
     float                     nearestRwyElev;

    /* brightness of the EGPWS overlay.                                           */
     float                     egpwsBrightness;

    /* style of the EGPWS overlay.                                                */
     XPLMEGPWSStyle            egpwsStyle;
} XPLMMapCustomData_t;

/*
 * XPLMCreateMap_t
 * 
 * Parameters for creating a base map display. Set structSize to the size of
 * your struct so that future SDK versions can add fields without breaking
 * existing plugins.
 *
 */
typedef struct {

    /* Set to sizeof(XPLMCreateMap_t).                                            */
     int                       structSize;

    /* 0 for pilot-side GPS position, 1 for copilot-side GPS position.            */
     int                       pilotIndex;
} XPLMCreateMap_t;

/*
 * XPLMMapDisplayRef
 * 
 * An opaque handle to a map display instance. Create one with
 * XPLMCreateMapDisplay and destroy it with XPLMDestroyMapDisplay.
 *
 */
typedef void * XPLMMapDisplayRef;

/*
 * XPLMMapDrawInfo_t
 * 
 * Which layers a map shows and where on the panel it goes.
 * 
 * Pass the same XPLMMapDrawInfo_t and the same XPLMMapCustomData_t to
 * XPLMMapDisplayDrawIn and to the projection routines, and the projection you
 * query is provably the projection you drew - so your symbology cannot end up
 * a frame or a zoom step out of step with the terrain under it.
 * 
 * Set structSize to the size of your struct so that future SDK versions can
 * add fields without breaking existing plugins.
 *
 */
typedef struct {

    /* Set to sizeof(XPLMMapDrawInfo_t).                                          */
     int                       structSize;

    /* Bitwise OR of XPLMMapLayers flags to show.                                 */
     XPLMMapLayers             layers;

    /* Bounding rectangle in panel coordinates.                                   */
     int                       left;

    /* Bounding rectangle in panel coordinates.                                   */
     int                       top;

    /* Bounding rectangle in panel coordinates.                                   */
     int                       right;

    /* Bounding rectangle in panel coordinates.                                   */
     int                       bottom;
} XPLMMapDrawInfo_t;

/*
 * XPLMCreateMapDisplay
 * 
 * This function creates a new map display instance. The display begins
 * loading terrain tiles for the current aircraft position immediately. You
 * can draw it as soon as tiles are available; before that, the draw call is a
 * no-op.
 * 
 * The returned handle must be destroyed with XPLMDestroyMapDisplay when no
 * longer needed. Handles are automatically destroyed when the owning plugin
 * is unloaded.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API XPLMMapDisplayRef XPLMCreateMapDisplay(
                         XPLMCreateMap_t *    params);

/*
 * XPLMDestroyMapDisplay
 * 
 * This function destroys a map display and frees all associated resources.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMDestroyMapDisplay(
                         XPLMMapDisplayRef    map);

/*
 * XPLMMapDisplayDrawIn
 * 
 * This function renders the map display directly into the active panel
 * surface within the rectangle given by info. Map sets up its own projection
 * to fit that rectangle, so no transform stack manipulation is needed.
 * 
 * info->layers controls which visual layers are rendered. Note that some
 * layers are mutually exclusive, such as NEXRAD and EGPWS or NEXRAD and IR.
 * The airport details layer is only visible at very close zoom levels.
 * 
 * This function must be called from within an avionics drawing callback. If
 * terrain tiles have not finished loading yet, this function does nothing.
 * 
 * dataOverrides may be NULL, in which case the map follows the sim's own
 * navigation display: centered on the user aircraft in the middle of the
 * rectangle, rose radius half the shorter side of it, range taken from the
 * EFIS range knob, and track-up or north-up according to the sim's map mode.
 * The pilotIndex you created the map with selects which side's range and
 * altitude are used.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMMapDisplayDrawIn(
                         XPLMMapDisplayRef    map,
                         XPLMMapDrawInfo_t *  info,
                         XPLMMapCustomData_t * dataOverrides);         /* Can be NULL */

/*
 * XPLMMapDisplayProject
 * 
 * Turns a latitude/longitude into a position in panel coordinates, for the
 * map that info describes. This is the inverse of XPLMMapDisplayUnproject.
 * 
 * Pass the same info you draw that map with and you get the projection that
 * draw call produces, whether you call this before or after
 * XPLMMapDisplayDrawIn. So the usual pattern - project your symbols, draw the
 * map, then draw the symbols on top - lines up exactly, with no need to cache
 * anything between frames.
 * 
 * Unlike XPLMMapDisplayDrawIn, this does not have to be called from a drawing
 * callback; it is equally valid from a click handler or a flight loop.
 * 
 * Returns 1 on success. Returns 0, leaving outX and outY untouched, if the
 * map's terrain tiles have not loaded yet or if the point has no position on
 * this map.
 * 
 * Note that the returned coordinates are in the same space as info's
 * rectangle, and like that rectangle they do not account for the panel
 * graphics transform stack.
 * 
 * Passing NULL for dataOverrides projects the sim's own navigation display
 * view, the same one XPLMMapDisplayDrawIn draws with NULL.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API int        XPLMMapDisplayProject(
                         XPLMMapDisplayRef    map,
                         XPLMMapDrawInfo_t *  info,
                         XPLMMapCustomData_t * dataOverrides,          /* Can be NULL */
                         double               latitude,
                         double               longitude,
                         float *              outX,
                         float *              outY);

/*
 * XPLMMapDisplayUnproject
 * 
 * Turns a position in panel coordinates back into a latitude/longitude, for
 * the map that info describes. This is the inverse of XPLMMapDisplayProject.
 * 
 * Use this to turn a touch or click on your map into a place in the world -
 * for picking a waypoint, or reading out the position under the cursor.
 * 
 * Unlike XPLMMapDisplayDrawIn, this does not have to be called from a drawing
 * callback; it is equally valid from a click handler or a flight loop.
 * 
 * Returns 1 on success. Returns 0, leaving outLatitude and outLongitude
 * untouched, if the map's terrain tiles have not loaded yet or if the point
 * does not correspond to anywhere on the earth.
 * 
 * Passing NULL for dataOverrides projects the sim's own navigation display
 * view, the same one XPLMMapDisplayDrawIn draws with NULL.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API int        XPLMMapDisplayUnproject(
                         XPLMMapDisplayRef    map,
                         XPLMMapDrawInfo_t *  info,
                         XPLMMapCustomData_t * dataOverrides,          /* Can be NULL */
                         float                x,
                         float                y,
                         double *             outLatitude,
                         double *             outLongitude);

/*
 * XPLMMapDisplayScaleMeter
 * 
 * Returns how many pixels correspond to one meter at a given point on the map
 * that info describes. Use it to size symbols and range rings so they stay
 * correct as the range changes.
 * 
 * Returns 0 if the map's terrain tiles have not loaded yet.
 * 
 * Passing NULL for dataOverrides projects the sim's own navigation display
 * view, the same one XPLMMapDisplayDrawIn draws with NULL.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API float      XPLMMapDisplayScaleMeter(
                         XPLMMapDisplayRef    map,
                         XPLMMapDrawInfo_t *  info,
                         XPLMMapCustomData_t * dataOverrides,          /* Can be NULL */
                         float                x,
                         float                y);

/*
 * XPLMMapDisplayGetNorthHeading
 * 
 * Returns the heading, in degrees clockwise from straight up on the display,
 * at which true north lies at a given point on the map that info describes.
 * ADD it to a true heading to get the angle to draw that heading at.
 * 
 * This accounts both for the map's own rotation - a heading-up map is turned
 * to put the aircraft's nose at the top - and for the projection's
 * convergence, which tilts north away from vertical as you move away from the
 * map's center.
 * 
 * Returns 0 if the map's terrain tiles have not loaded yet.
 * 
 * Passing NULL for dataOverrides projects the sim's own navigation display
 * view, the same one XPLMMapDisplayDrawIn draws with NULL.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API float      XPLMMapDisplayGetNorthHeading(
                         XPLMMapDisplayRef    map,
                         XPLMMapDrawInfo_t *  info,
                         XPLMMapCustomData_t * dataOverrides,          /* Can be NULL */
                         float                x,
                         float                y);

/*
 * XPLMMapDisplayGetTerrainAltitudes
 * 
 * This function returns the lowest and highest altitude shown on the map's
 * EGPWS terrain display.
 * 
 * Note that those altitudes are only available if the map has been drawn with
 * the xplm_Map_EGPWS layer. If altitudes are not available, the function
 * returns false, and the altitude pointers are not modified.
 * 
 * This function must be called from within an avionics drawing callback.
 * 
 * - map: the map display handle.
 * - min: a pointer to the minimum altitude.
 * - max: a pointer to the maximum altitude.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API int        XPLMMapDisplayGetTerrainAltitudes(
                         XPLMMapDisplayRef    map,
                         float*               min,                    /* Can be NULL */
                         float*               max);                   /* Can be NULL */
#endif /* XPLM440 */

#if defined(XPLM440)
/***************************************************************************
 * IMGUI HELPERS
 ***************************************************************************/
/*
 * These routines let panel-graphics-content-type windows render textured
 * indexed triangle meshes that exactly match the layout produced by Dear
 * ImGui's `ImDrawData`, so a plugin can plug an ImGui frame straight into
 * X-Plane panel graphics.
 * 
 * Coordinate system: positions are in window-LOCAL pixels with TOP-LEFT
 * origin (matches Dear ImGui). Scissors are in the same coordinate space. The
 * host translates these against the current panel-graphics origin and flips Y
 * for you.
 * 
 * Vertex layout (matches `ImDrawVert` exactly): each vertex is 5 floats =
 * 20 bytes, in this order: pos.x, pos.y, uv.x, uv.y, RGBA8 packed as a
 *  uint32_t in little-endian byte order (R is the low byte). The vertex
 *  stride passed in `XPLMMesh_t::vertices` must be 5 floats per vertex.
 * 
 * Color and alpha: vertex colors and texture pixels are interpreted as
 * **straight (non-pre-multiplied) alpha** and blended accordingly. Submit
 *   ImGui's `ImDrawData` verts and font atlas as-is (no premultiply) -- this
 *   matches ImGui's own defaults.
 * 
 * Sampler: bilinear filter, clamp-to-edge in both dimensions, no mipmaps. UV
 * coordinates outside [0,1] sample the edge texels (no wrap).
 * 
 * Scissor: the per-`XPLMDrawCall_t` scissor rect is in {left, top, right,
 * bottom} order (top-left origin). Zero-width or zero-height rects produce no
 * output. The scissor state is automatically saved on entry to
 * `XPLMDrawCalls` and restored on exit, so subsequent panel-graphics calls in
 *  the same frame are unaffected.
 * 
 * Plugin-callable from inside a panel-graphics window's draw callback only.
 *
 */


/*
 * XPLMDrawCall_t
 * 
 * A single draw call within an `XPLMMesh_t`. Each call binds a texture and a
 * scissor rect, then draws `element_count` indices starting at
 * `idx_offset`. `vtx_offset` is added to each fetched index by the GPU
 *  (matching `glDrawElementsBaseVertex` semantics) -- this lets a single mesh
 *  hold multiple sub-meshes whose indices are written relative to their own
 *  start.
 *
 */
typedef struct {

    /* Texture handle from XPLMCreateTexture. That is the ONLY valid source - this*
     * is not a general texture handle, and passing anything else (an             *
     * XPLMTextureAtlasRef, say) is undefined behavior, not a no-op.              */
     void *                    tex_ref;

    /* Clip rect: {left, top, right, bottom} in window-local top-left coords.     */
     float                     scissors[4];

    /* First index into XPLMMesh_t::indices to use.                               */
     int                       idx_offset;

    /* Number of indices to consume (must be a multiple of 3 for triangles). Zero *
     * is allowed and produces no output.                                         */
     int                       element_count;

    /* Added to each fetched index before vertex lookup.                          */
     int                       vtx_offset;
} XPLMDrawCall_t;

/*
 * XPLMMesh_t
 * 
 * A vertex/index buffer pair shared across one or more `XPLMDrawCall_t`
 * entries. The `vertices` array must be `5 * vertex_count` floats long
 * matching the layout described in the IMGUI HELPERS component desc. Indices
 * are 16-bit unsigned, matching `ImDrawIdx` at its default (`#define
 * ImDrawIdx unsigned short`).
 *
 */
typedef struct {

     int                       vertex_count;

    /* Pointer to vertex_count * 5 floats.                                        */
     const float *             vertices;

     int                       index_count;

     const uint16_t*           indices;
} XPLMMesh_t;

/*
 * XPLMCreateTexture
 * 
 * Creates a GPU texture from a contiguous RGBA8 byte buffer. The buffer is
 * read top-to-bottom, with byte order R, G, B, A per pixel. Any width and
 * height are accepted, including non-power-of-two and 1-pixel-wide strips;
 * the host does not require power-of-two dimensions.
 * 
 * The returned handle is opaque; pass it to `XPLMDrawCall_t::tex_ref` and
 * free it with `XPLMDestroyTexture` when done. The sampler used at draw time
 * is bilinear, clamp-to-edge, no mipmaps.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void *     XPLMCreateTexture(
                         const unsigned char * rgba_image,
                         int                  width,
                         int                  height);

/*
 * XPLMDestroyTexture
 * 
 * Frees a texture obtained from `XPLMCreateTexture`. Do not use the handle
 * after calling this. It is safe to create and destroy textures every frame.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMDestroyTexture(
                         void *               tex_ref);

/*
 * XPLMDrawCalls
 * 
 * Renders `inCount` draw calls against the shared `inMesh`. Issues one GPU
 * dispatch per call (each can rebind texture and scissor) but uploads the
 * mesh only once. `inCount = 0` is a no-op. `element_count = 0` on a specific
 * draw call is also a no-op for that call.
 * 
 * The scissor state is saved on entry and restored on exit; subsequent
 * panel-graphics primitives in the same frame are unaffected.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMDrawCalls(
                         const XPLMMesh_t *   inMesh,
                         int                  inCount,
                         const XPLMDrawCall_t inDrawCalls[]);
#endif /* XPLM440 */
#ifdef __cplusplus
}
#endif

#endif
