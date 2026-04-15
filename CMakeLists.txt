cmake_minimum_required(VERSION 3.19)

project(xlua
    VERSION 2.0
    DESCRIPTION "XLua — Lua scripting plugin for X-Plane"
    LANGUAGES CXX
)

# ─────────────────────────────────────────────────────────────────────────────
# Global C++ standard (matches -std=c++11 / CLANG_CXX_LANGUAGE_STANDARD=c++0x)
# ─────────────────────────────────────────────────────────────────────────────
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# ─────────────────────────────────────────────────────────────────────────────
# Plugin target
# X-Plane loads .xpl files via dlopen/LoadLibrary, so MODULE is the right type.
# ─────────────────────────────────────────────────────────────────────────────
add_library(xlua MODULE
    src/xlua.cpp
    src/module.cpp
    src/lua_helpers.cpp
	src/shared_lua_helpers.cpp
    src/xpcommands.cpp
    src/xpdatarefs.cpp
    src/xpfuncs.cpp
	src/shared_xpfuncs.cpp
    src/xptimers.cpp

    src/FloatingWindows/FLWIntegration.cpp
    src/FloatingWindows/FloatingWindow.cpp
    src/FloatingWindows/ImGUIIntegration.cpp

    imgui_lua_bindings/imgui_lua_bindings.cpp
    imgui/imgui.cpp
	imgui/imgui_demo.cpp
    imgui/imgui_draw.cpp
    imgui/imgui_tables.cpp
    imgui/imgui_widgets.cpp

	SDK/XLua_glue/XLua_Register_glue.cpp
	SDK/XLua_glue/XPLMCamera_glue.cpp
	SDK/XLua_glue/XPLMDataAccess_glue.cpp
	SDK/XLua_glue/XPLMDefs_glue.cpp
	SDK/XLua_glue/XPLMDisplay_glue.cpp
	SDK/XLua_glue/XPLMGraphics_glue.cpp
	SDK/XLua_glue/XPLMInstance_glue.cpp
	SDK/XLua_glue/XPLMMap_glue.cpp
	SDK/XLua_glue/XPLMMenus_glue.cpp
	SDK/XLua_glue/XPLMNavigation_glue.cpp
	SDK/XLua_glue/XPLMPlanes_glue.cpp
	SDK/XLua_glue/XPLMPlugin_glue.cpp
	SDK/XLua_glue/XPLMProcessing_glue.cpp
	SDK/XLua_glue/XPLMPanelGraphics_glue.cpp
	SDK/XLua_glue/XPLMScenery_glue.cpp
	SDK/XLua_glue/XPLMSound_glue.cpp
	SDK/XLua_glue/XPLMUtilities_glue.cpp
	SDK/XLua_glue/XPLMWeather_glue.cpp
)

target_compile_definitions(xlua PRIVATE
    XPLM200=1
    XPLM210=1
    XPLM300=1
    XPLM301=1
    XPLM302=1
    XPLM303=1
    XPLM400=1
    XPLM410=1
    XPLM420=1
    XPLM430=1
    XPLM440=1
    XPLMPG1=1
    -DLUA_BINDINGS_LOCAL_STATE
)

# Strip the default "lib" prefix and use .xpl on all platforms.
set_target_properties(xlua PROPERTIES
    PREFIX ""
    SUFFIX ".xpl"
)

target_include_directories(xlua PRIVATE
    "${CMAKE_SOURCE_DIR}/lua_sdk"
    "${CMAKE_SOURCE_DIR}/SDK/CHeaders/XPLM"
    "${CMAKE_SOURCE_DIR}/SDK/CHeaders/Widgets"
    "${CMAKE_SOURCE_DIR}/imgui"
    "${CMAKE_SOURCE_DIR}/src"
    "${CMAKE_SOURCE_DIR}/src/FloatingWindows"
)

# ─────────────────────────────────────────────────────────────────────────────
# Windows (x64 only — 32-bit X-Plane is discontinued)
# ─────────────────────────────────────────────────────────────────────────────
if(WIN32)
    target_include_directories(xlua PRIVATE
        "${CMAKE_SOURCE_DIR}/fmod/win/studio/inc"
        "${CMAKE_SOURCE_DIR}/fmod/win/core/inc"
    )

    set_target_properties(xlua PROPERTIES
        OUTPUT_NAME "xlua"
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/win_x64"
        # Keep multi-config generators (Visual Studio) flat — no Release/ subdir.
        LIBRARY_OUTPUT_DIRECTORY_DEBUG          "${CMAKE_BINARY_DIR}/win_x64"
        LIBRARY_OUTPUT_DIRECTORY_RELEASE        "${CMAKE_BINARY_DIR}/win_x64"
        LIBRARY_OUTPUT_DIRECTORY_RELWITHDEBINFO "${CMAKE_BINARY_DIR}/win_x64"
        LIBRARY_OUTPUT_DIRECTORY_MINSIZEREL     "${CMAKE_BINARY_DIR}/win_x64"
        # Static CRT — matches <RuntimeLibrary>MultiThreaded[Debug]</RuntimeLibrary>
        MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>"
    )

    target_compile_definitions(xlua PRIVATE
        IBM=1 APL=0 LIN=0
        WIN32 _WINDOWS _USRDLL SIMDATA_EXPORTS
        _CRT_SECURE_NO_WARNINGS
        $<$<CONFIG:Debug>:_DEBUG>
        $<$<NOT:$<CONFIG:Debug>>:NDEBUG>
    )

    target_compile_options(xlua PRIVATE
        /W3
        $<$<CONFIG:Release>:/O2 /Oi /Gy /GF>   # MaxSpeed, inline, func-level linking, string pool
        $<$<CONFIG:Debug>:/Od /Zi>
    )

    target_link_libraries(xlua PRIVATE
        "${CMAKE_SOURCE_DIR}/SDK/Libraries/Win/XPLM_64.lib"
        "${CMAKE_SOURCE_DIR}/SDK/Libraries/Win/XPWidgets_64.lib"
        "${CMAKE_SOURCE_DIR}/lua_sdk/lua51.lib"
        Opengl32.lib
    )

# ─────────────────────────────────────────────────────────────────────────────
# macOS — universal binary (x86_64 + arm64), Mach-O bundle (mh_bundle)
# ─────────────────────────────────────────────────────────────────────────────
elseif(APPLE)
    target_include_directories(xlua PRIVATE
        "${CMAKE_SOURCE_DIR}/fmod/mac/studio/inc"
        "${CMAKE_SOURCE_DIR}/fmod/mac/core/inc"
    )

    set_target_properties(xlua PROPERTIES
        OUTPUT_NAME "mac"
        LIBRARY_OUTPUT_DIRECTORY            "${CMAKE_BINARY_DIR}/mac_x64"
        LIBRARY_OUTPUT_DIRECTORY_DEBUG      "${CMAKE_BINARY_DIR}/mac_x64"
        LIBRARY_OUTPUT_DIRECTORY_RELEASE    "${CMAKE_BINARY_DIR}/mac_x64"
        # Universal binary — matches ONLY_ACTIVE_ARCH = NO with default ARCHS
        OSX_ARCHITECTURES        "x86_64;arm64"
        # Matches target-level MACOSX_DEPLOYMENT_TARGET = 10.11
        OSX_DEPLOYMENT_TARGET    "10.11"
        # Suppress version fields (DYLIB_COMPATIBILITY_VERSION / DYLIB_CURRENT_VERSION = "")
        MACHO_COMPATIBILITY_VERSION ""
        MACHO_CURRENT_VERSION       ""
    )

    target_compile_definitions(xlua PRIVATE APL=1 IBM=0 LIN=0)

    # GCC_SYMBOLS_PRIVATE_EXTERN = YES → -fvisibility=hidden
    target_compile_options(xlua PRIVATE -fvisibility=hidden)

    # Frameworks — searched relative to SDK/Libraries/Mac (FRAMEWORK_SEARCH_PATHS)
    find_library(OPENGL_LIB       OpenGL       REQUIRED)
    find_library(COREFOUNDATION_LIB CoreFoundation REQUIRED)
    find_library(XPLM_LIB         XPLM         REQUIRED
        HINTS "${CMAKE_SOURCE_DIR}/SDK/Libraries/Mac")
    find_library(XPWIDGETS_LIB    XPWidgets    REQUIRED
        HINTS "${CMAKE_SOURCE_DIR}/SDK/Libraries/Mac")

    target_link_libraries(xlua PRIVATE
        ${OPENGL_LIB}
        ${COREFOUNDATION_LIB}
        ${XPLM_LIB}
        ${XPWIDGETS_LIB}
        # LuaJIT universal static lib (matches OTHER_LDFLAGS entry in pbxproj)
        "${CMAKE_SOURCE_DIR}/lua_sdk/libluajit_mac.a"
    )

    # Export only the five X-Plane plugin entry points; hide everything else.
    # Matches OTHER_LDFLAGS -Wl,-exported_symbol pairs in pbxproj.
    target_link_options(xlua PRIVATE
        -Wl,-exported_symbol,_XPluginStart
        -Wl,-exported_symbol,_XPluginEnable
        -Wl,-exported_symbol,_XPluginDisable
        -Wl,-exported_symbol,_XPluginStop
        -Wl,-exported_symbol,_XPluginReceiveMessage
    )

# ─────────────────────────────────────────────────────────────────────────────
# Linux (x86_64 only)
# ─────────────────────────────────────────────────────────────────────────────
elseif(UNIX)
    target_include_directories(xlua PRIVATE
        "${CMAKE_SOURCE_DIR}/fmod/lin/studio/inc"
        "${CMAKE_SOURCE_DIR}/fmod/lin/core/inc"
    )

    set_target_properties(xlua PROPERTIES
        OUTPUT_NAME "lin"
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lin_x64"
    )

    target_compile_definitions(xlua PRIVATE APL=0 IBM=0 LIN=1)

    target_compile_options(xlua PRIVATE
        -m64
        -fPIC
        -fvisibility=hidden
    )

    find_package(OpenGL REQUIRED)

    # LuaJIT static lib from lua_sdk/
    target_link_libraries(xlua PRIVATE
        OpenGL::GL
        "${CMAKE_SOURCE_DIR}/lua_sdk/libluajit.a"
    )

    target_link_options(xlua PRIVATE
        -m64
        -static-libgcc
        # Restrict exported symbols to those listed in exports.txt.
        # No quotes around the path — CMake escapes them, causing ld to treat
        # the quotes as part of the filename.  The path contains no spaces so
        # quoting is unnecessary.
        -Wl,--version-script=${CMAKE_SOURCE_DIR}/exports.txt
        # --no-undefined is omitted intentionally: XPLM symbols are unresolved
        # at link time and resolved at runtime by X-Plane (matches Makefile).
    )

else()
    message(FATAL_ERROR "Unsupported platform")
endif()
