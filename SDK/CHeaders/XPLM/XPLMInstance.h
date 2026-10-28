#ifndef _XPLMInstance_h_
#define _XPLMInstance_h_

/*
 * Copyright 2005-2026 Laminar Research, Sandy Barbour and Ben Supnik All
 * rights reserved.  See license.txt for usage. X-Plane SDK Version: 4.0.0
 *
 */

/***************************************************************************
 * XPLMInstance
 ***************************************************************************/
/*
 * This API provides instanced drawing of X-Plane objects (.obj files). In
 * contrast to old drawing APIs, which required you to draw your own objects
 * per-frame, the instancing API allows you to simply register an OBJ for
 * drawing, then move or manipulate it later (as needed).
 * 
 * This provides one tremendous benefit: it keeps all dataref operations for
 * your object in one place. Because datarefs access may be done from the main
 * thread only, allowing dataref access anywhere is a serious performance
 * bottleneck for the simulator - the whole simulator has to pause and wait
 * for each dataref access. This performance penalty will only grow worse as
 * X-Plane moves toward an ever more heavily multithreaded engine.
 * 
 * The instancing API allows X-Plane to isolate all dataref manipulations for
 * all plugin object drawing to one place, potentially providing huge
 * performance gains.
 * 
 * Here's how it works:
 * 
 * When an instance is created, it provides a list of all datarefs you want to
 * manipulate for the OBJ in the future. This list of datarefs replaces the
 * ad-hoc collections of dataref objects previously used by art assets. Then,
 * per-frame, you can manipulate the instance by passing in a "block" of
 * packed floats representing the current values of the datarefs for your
 * instance. (Note that the ordering of this set of packed floats must exactly
 * match the ordering of the datarefs when you created your instance.)
 *
 */


#include "XPLMDefs.h"

#include "XPLMScenery.h"

#ifdef __cplusplus
extern "C" {
#endif


/***************************************************************************
 * Instance Creation and Destruction
 ***************************************************************************/
/*
 * Registers and unregisters instances.
 *
 */


/*
 * XPLMInstanceRef
 * 
 * An opaque handle to an instance.
 *
 */
typedef void * XPLMInstanceRef;

/*
 * XPLMCreateInstance
 * 
 * XPLMCreateInstance creates a new instance, managed by your plug-in, and
 * returns a handle to the instance. A few important requirements:
 * 
 * * The object passed in must be fully loaded and returned from the XPLM
 *   before you can create your instance; you cannot pass a null obj ref, nor
 *   can you change the ref later.
 * 
 * * If you use any custom datarefs in your object, they must be registered
 *   before the object is loaded. This is true even if their data will be
 *   provided via the instance dataref list.
 * 
 * * The instance dataref array must be a valid pointer to a null-terminated
 *   array.  That is, if you do not want any datarefs, you must pass a pointer
 *   to a one-element array containing a null item.  You cannot pass null for
 *   the array itself.
 * 
 * - datarefs: a NULL-terminated list of dataref identifiers. E.g., {
 *   "sim/aircraft/view/acf_peX", "sim/aircraft/view/acf_peY",
 *   "sim/aircraft/view/acf_peZ", NULL }
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API XPLMInstanceRef XPLMCreateInstance(
                         XPLMObjectRef        obj,
                         char const*          datarefs[]);

#if defined(XPLM420)
/*
 * XPLMInstanceSetAutoShift
 * 
 * XPLMInstanceSetAutoShift tells X-Plane to move the location of your
 * instance every time the sim\'s local coordinate sytem changes, so that a
 * static instance does not have to be moved. Without this, a plugin is
 * responsible for updating an instance's local position when the  coordinate
 * system shifts. Use this for static instances that you would not otherwise
 * have to move.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMInstanceSetAutoShift(
                         XPLMInstanceRef      instance);
#endif /* XPLM420 */

/*
 * XPLMDestroyInstance
 * 
 * XPLMDestroyInstance destroys and deallocates your instance; once called,
 * you are still responsible for releasing the OBJ ref.
 * 
 * Tip: you can release your OBJ ref after you call XPLMCreateInstance as long
 * as you never use it again; the instance will maintain its own reference to
 * the OBJ and the object OBJ be deallocated when the instance is destroyed.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMDestroyInstance(
                         XPLMInstanceRef      instance);

/***************************************************************************
 * Multi-Object Instance Creation
 ***************************************************************************/
/*
 * Create an instance out of one or more objects with a single extensible
 * call.
 *
 */


#if defined(XPLM440)
/*
 * XPLMCoordinateSpace_t
 * 
 * This enum defines the coordinate space used to interpret the positions of
 * an instance created with XPLMCreateInstanceEx(). By default, instances are
 * in world space (the sim's global cartesian coordinate system). You can
 * instead place an instance relative to an aircraft - either its interior or
 * its exterior - or relative to the camera. Interior and exterior aircraft
 * spaces use the same transform today; the distinction lets X-Plane light the
 * objects correctly in a future release.
 *
 */
enum {

    /* Position is in global OGL/tangent-plane coordinates (default).             */
    xplm_CoordSpace_World                    = 0,


    /* Position is relative to an aircraft's CG and body axes (+X right wing, +Y  *
     * up, +Z tail), for objects inside the cockpit/cabin.                        */
    xplm_CoordSpace_AircraftInterior         = 1,


    /* Position is relative to an aircraft's CG and body axes (+X right wing, +Y  *
     * up, +Z tail), for objects mounted on the exterior.                         */
    xplm_CoordSpace_AircraftExterior         = 2,


    /* Position is relative to the camera/view position and orientation.          */
    xplm_CoordSpace_Camera                   = 3,


};
typedef int XPLMCoordinateSpace_t;
#endif /* XPLM440 */

#if defined(XPLM440)
/*
 * XPLMInstanceObject_t
 * 
 * XPLMInstanceObject_t describes a single object within a multi-object
 * instance: the object itself plus a fixed offset from the instance's origin.
 * Every object in an instance moves rigidly together when you reposition the
 * instance with XPLMInstanceSetPosition; this offset places each object
 * relative to that shared origin and never changes after the instance is
 * created.
 *
 */
typedef struct {

    /* A fully-loaded object to draw as part of the instance.                     */
     XPLMObjectRef             object;

    /* X offset from the instance origin, in instance-local coordinates.          */
     float                     x;

    /* Y offset from the instance origin, in instance-local coordinates.          */
     float                     y;

    /* Z offset from the instance origin, in instance-local coordinates.          */
     float                     z;

    /* Pitch of this object relative to the instance, in degrees, positive up.    */
     float                     pitch;

    /* Heading of this object relative to the instance, in degrees, clockwise.    */
     float                     heading;

    /* Roll of this object relative to the instance, in degrees.                  */
     float                     roll;
} XPLMInstanceObject_t;
#endif /* XPLM440 */

#if defined(XPLM440)
/*
 * XPLMCreateInstance_t
 * 
 * XPLMCreateInstance_t defines all of the parameters used to create an
 * instance via XPLMCreateInstanceEx(). It is a strict superset of the older
 * XPLMCreateInstance() call: it lets you build an instance out of more than
 * one object, choose the coordinate space, and enable auto-shift, all in a
 * single call. The structure will be expanded in future SDK versions to
 * include more features. Always set the structSize member to the size of your
 * struct in bytes!
 *
 */
typedef struct {

    /* Used to inform XPLMCreateInstanceEx() of the SDK version you compiled      *
     * against; should always be set to sizeof(XPLMCreateInstance_t).             */
     int                       structSize;

    /* An array of objects (each with its own offset) that make up the instance.  *
     * Must point to at least objectCount entries.                                */
     const XPLMInstanceObject_t * objects;

    /* The number of entries in the objects array. Must be at least 1.            */
     int                       objectCount;

    /* A single NULL-terminated list of dataref identifiers shared by every object*
     * in the instance, exactly as in XPLMCreateInstance(). The data you later    *
     * pass to XPLMInstanceSetPosition() fills one shared block for all objects.  *
     * You cannot pass null for the array itself.                                 */
     const char **             datarefs;

    /* The coordinate space in which instance positions are interpreted (see      *
     * XPLMCoordinateSpace_t). Use xplm_CoordSpace_World for the classic behavior.*/
     XPLMCoordinateSpace_t     coordinateSpace;

    /* Aircraft index (0 = user aircraft). Only used when coordinateSpace is      *
     * xplm_CoordSpace_AircraftInterior or xplm_CoordSpace_AircraftExterior.      */
     int                       aircraftIndex;

    /* If non-zero, enables auto-shift (see XPLMInstanceSetAutoShift). Ignored for*
     * non-world coordinate spaces.                                               */
     int                       autoShift;
} XPLMCreateInstance_t;
#endif /* XPLM440 */

#if defined(XPLM440)
/*
 * XPLMCreateInstanceEx
 * 
 * XPLMCreateInstanceEx creates a new instance from one or more objects and
 * returns a handle to it. It is a strict superset of XPLMCreateInstance(): in
 * addition to a single object, you can register several objects that draw and
 * move together as one rigid group, and you can choose the coordinate space
 * and auto-shift behavior up front in the same call.
 * 
 * The same requirements as XPLMCreateInstance() apply: every object must be
 * fully loaded before you create the instance, any custom datarefs your
 * objects use must be registered before the objects are loaded, and the
 * dataref list must be a valid pointer to a NULL-terminated array. The
 * dataref list is shared by all objects in the instance.
 * 
 * The set of objects is fixed when the instance is created; you cannot add or
 * remove objects later. Destroy the instance with XPLMDestroyInstance()
 * exactly as for an instance made with XPLMCreateInstance().
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API XPLMInstanceRef XPLMCreateInstanceEx(
                         const XPLMCreateInstance_t * inParams);
#endif /* XPLM440 */

/***************************************************************************
 * Instance Manipulation
 ***************************************************************************/


/*
 * XPLMInstanceSetPosition
 * 
 * Updates both the position of the instance and all datarefs you registered
 * for it.  Call this from a flight loop callback or UI callback.
 * 
 * __DO_NOT__ call XPLMInstanceSetPosition from a drawing callback; the whole
 * point of instancing is that you do not need any drawing callbacks. Setting
 * instance data from a drawing callback may have undefined consequences, and
 * the drawing callback hurts FPS unnecessarily.  
 * 
 * The memory pointed to by the data pointer must be large enough to hold one
 * float for every dataref you have registered, and must contain valid
 * floating point data.
 * 
 * BUG: before X-Plane 11.50, if you have no dataref registered, you must
 * still pass a valid pointer for data and not null.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMInstanceSetPosition(
                         XPLMInstanceRef      instance,
                         const XPLMDrawInfo_t * new_position,
                         const float          data[]);

#if defined(XPLM420)
/*
 * XPLMInstanceSetPositionDouble
 * 
 * Updates both the position of the instance and all datarefs you registered
 * for it.  Call this from a flight loop callback or UI callback.
 * 
 * __DO_NOT__ call XPLMInstanceSetPositionDouble from a drawing callback; the
 * whole point of instancing is that you do not need any drawing  callbacks.
 * Setting instance data from a drawing callback may have undefined
 * consequences, and the drawing callback hurts FPS unnecessarily.  
 * 
 * The memory pointed to by the data pointer must be large enough to hold one
 * float for every dataref you have registered, and must contain valid
 * floating point data.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMInstanceSetPositionDouble(
                         XPLMInstanceRef      instance,
                         const XPLMDrawInfoDouble_t * new_position,
                         const float          data[]);
#endif /* XPLM420 */

#if defined(XPLM440)
/*
 * XPLMInstanceSetCoordinateSpace
 * 
 * XPLMInstanceSetCoordinateSpace changes the coordinate space used to
 * interpret the positions you pass to XPLMInstanceSetPosition or
 * XPLMInstanceSetPositionDouble. You can set the coordinate space once up
 * front with XPLMCreateInstanceEx(), or change it on the fly with this call.
 * By default, positions are in world space. In aircraft space, positions are
 * relative to the specified aircraft's CG and body axes; in camera space,
 * positions are relative to the camera/view.
 * 
 * For the two aircraft spaces (xplm_CoordSpace_AircraftInterior and
 * xplm_CoordSpace_AircraftExterior), aircraft_index specifies which aircraft
 * (0 = user's aircraft). For world and camera space, aircraft_index is
 * ignored.
 * 
 * Changing the coordinate space does not make the instance jump: X-Plane
 * re-expresses the instance's current world location in the new space, so the
 * object stays exactly where it is and then begins tracking the new parent.
 * After the change it is up to you to feed positions that are correct for the
 * new space - pushing the old space's numbers again will move the object.
 * 
 * Auto-shift (XPLMInstanceSetAutoShift) is independent of the coordinate
 * space: changing the space does not turn auto-shift off, but auto-shift only
 * has an effect while the instance is in world space.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
XPLM_API void       XPLMInstanceSetCoordinateSpace(
                         XPLMInstanceRef      instance,
                         XPLMCoordinateSpace_t space,
                         int                  aircraft_index);
#endif /* XPLM440 */
#ifdef __cplusplus
}
#endif

#endif
