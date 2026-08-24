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

# ─────────────────────────────────────────────────────────────────────────────
# Standalone vs in-tree
# This file is both a root project (our own GitHub Actions CI, which ships the
# binaries) and a subdirectory of the X-Plane tree. The X-Plane tree imposes its
# own compiler/runtime environment, so a few settings only make sense there.
# Everything below defaults to the standalone behaviour this project has always
# had; the in-tree branches are the exceptions.
# ─────────────────────────────────────────────────────────────────────────────
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    set(XLUA_IN_XPLANE_TREE FALSE)
    message(STATUS "XLua: standalone build")
else()
    set(XLUA_IN_XPLANE_TREE TRUE)
    message(STATUS "XLua: building inside the X-Plane tree")
endif()

if(NOT XLUA_IN_XPLANE_TREE)
    set(CMAKE_CXX_EXTENSIONS OFF)
endif()

# ─────────────────────────────────────────────────────────────────────────────
# LuaJIT source
# In-tree X-Plane builds get LuaJIT from conan — SDK/COMMON/CMakeLists.txt calls
# find_package(luajit) before add_subdirectory(), so the imported target exists by
# the time we are configured. Standalone builds (including XLua's own GitHub
# Actions CI) have no conan and fall back to the vendored libs in lua_sdk/.
# ─────────────────────────────────────────────────────────────────────────────
if(TARGET luajit::luajit)
    set(XLUA_LUAJIT_FROM_CONAN TRUE)
    message(STATUS "XLua: using conan LuaJIT")
else()
    set(XLUA_LUAJIT_FROM_CONAN FALSE)
    message(STATUS "XLua: using vendored LuaJIT from lua_sdk/")
endif()

# ─────────────────────────────────────────────────────────────────────────────
# Plugin target
# X-Plane loads .xpl files via dlopen/LoadLibrary, so MODULE is the right type.
# ─────────────────────────────────────────────────────────────────────────────
add_library(xlua2 MODULE
    src/xlua.cpp
    src/module.cpp
    src/lua_helpers.cpp
	src/shared_lua_helpers.cpp
    src/xpcommands.cpp
    src/xlua_command_bindings.cpp
    src/xpdatarefs.cpp
    src/xpfuncs.cpp
	src/shared_xpfuncs.cpp
    src/xptimers.cpp
    src/xlua_imgui.cpp
    src/xlua_imgui_context.cpp
    src/xlua2_window_helpers.cpp

    imgui_lua_bindings/imgui_lua_bindings.cpp
    imgui/imgui.cpp
	imgui/imgui_demo.cpp
    imgui/imgui_draw.cpp
    imgui/imgui_tables.cpp
    imgui/imgui_widgets.cpp
)

# ────────────────────────────────────────────────────────────────────────────
# Lua binding glue, and the XPLM headers it was generated against
#
# These two always move together. The glue includes "XPLMDefs.h" and friends
# unqualified, so whichever CHeaders directory lands first on the include path
# wins, and glue generated from a newer SDK will not compile against older
# headers. In-tree both come from xplanesdk, so the bindings always match the
# XPLM this build actually exports; standalone uses the snapshot committed here.
# ────────────────────────────────────────────────────────────────────────────
set(XLUA_GLUE_BASE
    XLua_Register_glue.cpp
    XPLMCamera_glue.cpp
    XPLMDataAccess_glue.cpp
    XPLMDefs_glue.cpp
    XPLMDisplay_glue.cpp
    XPLMGraphics_glue.cpp
    XPLMInstance_glue.cpp
    XPLMMap_glue.cpp
    XPLMMenus_glue.cpp
    XPLMNavigation_glue.cpp
    XPLMPanelGraphics_glue.cpp
    XPLMPlanes_glue.cpp
    XPLMPlugin_glue.cpp
    XPLMProcessing_glue.cpp
    XPLMScenery_glue.cpp
    XPLMSound_glue.cpp
    XPLMUtilities_glue.cpp
    XPLMWeather_glue.cpp
)

if(XLUA_IN_XPLANE_TREE)
    # Explicit list, never a glob: a configured build directory can still hold glue
    # left over from an older set of XML masters, which would not compile.
    foreach(g IN LISTS XLUA_GLUE_BASE)
        list(APPEND XLUA_GLUE_SOURCES
            "${CMAKE_BINARY_DIR}/SDK/COMMON/xplanesdk/Src/HeaderParser/XLua_glue/${g}")
    endforeach()
    set_source_files_properties(${XLUA_GLUE_SOURCES} PROPERTIES GENERATED TRUE)
else()
    foreach(g IN LISTS XLUA_GLUE_BASE)
        list(APPEND XLUA_GLUE_SOURCES "${PROJECT_SOURCE_DIR}/SDK/XLua_glue/${g}")
    endforeach()
endif()

target_sources(xlua2 PRIVATE ${XLUA_GLUE_SOURCES})

if(XLUA_IN_XPLANE_TREE)
    # XPLM_VERSIONS is CACHE INTERNAL, so it is readable here once xplanesdk has been
    # added — which SDK/COMMON/CMakeLists.txt does before us. Not CORE_DEFINITIONS:
    # the top level fills that in after add_subdirectory(SDK), so it is empty here.
    # XPLMPG1 is deliberately absent — the generated XPLMPanelGraphics.h gates on
    # XPLM440, and XPLMPG1 appears nowhere in the tree.
    foreach(def ${XPLM_VERSIONS})
        target_compile_definitions(xlua2 PRIVATE ${def}=1)
    endforeach()
else()
    target_compile_definitions(xlua2 PRIVATE
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
        # The committed XPLMPanelGraphics.h still gates on XPLMPG1, unlike the
        # generated one.
        XPLMPG1=1
    )
endif()

target_compile_definitions(xlua2 PRIVATE LUA_BINDINGS_LOCAL_STATE)

# Strip the default "lib" prefix and use .xpl on all platforms.
set_target_properties(xlua2 PROPERTIES
    PREFIX ""
    SUFFIX ".xpl"
)

target_include_directories(xlua2 PRIVATE
    "${PROJECT_SOURCE_DIR}/imgui"
    "${PROJECT_SOURCE_DIR}/src"
)

if(XLUA_IN_XPLANE_TREE)
    # XPWidgets -> XPLM -> sdk_headers gives us the generated XPLM/Widgets headers,
    # the libraries this tree actually built, and an ordering edge onto header
    # generation. Same path register_plugin() uses for every other in-tree plugin.
    target_link_libraries(xlua2 PRIVATE XPWidgets)
    # Mandatory, not belt-and-braces: linking sdk_headers supplies the include dirs,
    # but the build-order edge for the generated .cpp files does not cross
    # directories on its own.
    add_dependencies(xlua2 sdk_headers_target)
else()
    target_include_directories(xlua2 PRIVATE
        "${PROJECT_SOURCE_DIR}/SDK/CHeaders/XPLM"
        "${PROJECT_SOURCE_DIR}/SDK/CHeaders/Widgets"
    )
endif()

# ─────────────────────────────────────────────────────────────────────────────
# Windows (x64 only — 32-bit X-Plane is discontinued)
# ─────────────────────────────────────────────────────────────────────────────
if(WIN32)
    target_include_directories(xlua2 PRIVATE
        "${PROJECT_SOURCE_DIR}/fmod/win/studio/inc"
        "${PROJECT_SOURCE_DIR}/fmod/win/core/inc"
    )

    set_target_properties(xlua2 PROPERTIES
        OUTPUT_NAME "xlua2"
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/win_x64"
        # Keep multi-config generators (Visual Studio) flat — no Release/ subdir.
        LIBRARY_OUTPUT_DIRECTORY_DEBUG          "${CMAKE_BINARY_DIR}/win_x64"
        LIBRARY_OUTPUT_DIRECTORY_RELEASE        "${CMAKE_BINARY_DIR}/win_x64"
        LIBRARY_OUTPUT_DIRECTORY_RELWITHDEBINFO "${CMAKE_BINARY_DIR}/win_x64"
        LIBRARY_OUTPUT_DIRECTORY_MINSIZEREL     "${CMAKE_BINARY_DIR}/win_x64"
    )

    target_compile_definitions(xlua2 PRIVATE
        IBM=1 APL=0 LIN=0
        WIN32 _WINDOWS _USRDLL SIMDATA_EXPORTS
        _CRT_SECURE_NO_WARNINGS
    )

    target_compile_options(xlua2 PRIVATE /W3)

    if(NOT XLUA_IN_XPLANE_TREE)
        # Standalone CI builds with --config Release, so these all match.
        set_target_properties(xlua2 PROPERTIES
            # Static CRT — matches <RuntimeLibrary>MultiThreaded[Debug]</RuntimeLibrary>,
            # and required by lua_sdk/lua51.lib, which carries /DEFAULTLIB:LIBCMT.
            MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")

        target_compile_definitions(xlua2 PRIVATE
            $<$<CONFIG:Debug>:_DEBUG>
            $<$<NOT:$<CONFIG:Debug>>:NDEBUG>)

        target_compile_options(xlua2 PRIVATE
            $<$<CONFIG:Release>:/O2 /Oi /Gy /GF>   # MaxSpeed, inline, func-level linking, string pool
            $<$<CONFIG:Debug>:/Od /Zi>)
    else()
        # No MSVC_RUNTIME_LIBRARY in-tree: "MultiThreaded$<$<CONFIG:Debug>:Debug>"
        # matches no X-Plane config name (DEV_NOOPT, DEV_OPT, NODEV_OPT, ...), so it
        # always picked the release CRT while build_flags() injected /D_DEBUG — and
        # MSVC keys #pragma detect_mismatch off _DEBUG, not off /MT. Inherit
        # CMAKE_MSVC_RUNTIME_LIBRARY from cmake/windows.cmake instead. The CONFIG
        # genexes above are dead in-tree for the same reason; optimisation comes
        # from build_flags().
        #
        # A MODULE reads CMAKE_MODULE_LINKER_FLAGS, which the X-Plane tree never
        # sets, so unlike every other plugin we would get no PDB. Ask for one.
        target_link_options(xlua2 PRIVATE /DEBUG)
    endif()

    target_link_libraries(xlua2 PRIVATE Opengl32.lib)

    if(NOT XLUA_IN_XPLANE_TREE)
        target_link_libraries(xlua2 PRIVATE
            "${PROJECT_SOURCE_DIR}/SDK/Libraries/Win/XPLM_64.lib"
            "${PROJECT_SOURCE_DIR}/SDK/Libraries/Win/XPWidgets_64.lib"
        )
    endif()

# ─────────────────────────────────────────────────────────────────────────────
# macOS — universal binary (x86_64 + arm64), Mach-O bundle (mh_bundle)
# ─────────────────────────────────────────────────────────────────────────────
elseif(APPLE)
    target_include_directories(xlua2 PRIVATE
        "${PROJECT_SOURCE_DIR}/fmod/mac/studio/inc"
        "${PROJECT_SOURCE_DIR}/fmod/mac/core/inc"
    )

    set_target_properties(xlua2 PROPERTIES
        OUTPUT_NAME "mac"
        LIBRARY_OUTPUT_DIRECTORY            "${CMAKE_BINARY_DIR}/mac_x64"
        LIBRARY_OUTPUT_DIRECTORY_DEBUG      "${CMAKE_BINARY_DIR}/mac_x64"
        LIBRARY_OUTPUT_DIRECTORY_RELEASE    "${CMAKE_BINARY_DIR}/mac_x64"
        # Suppress version fields (DYLIB_COMPATIBILITY_VERSION / DYLIB_CURRENT_VERSION = "")
        MACHO_COMPATIBILITY_VERSION ""
        MACHO_CURRENT_VERSION       ""
        # Don't inherit @loader_path/../Frameworks from an enclosing app build.
        INSTALL_RPATH ""
    )

    # Standalone builds ship this binary, so it must stay a universal build at the
    # historical deployment target. Neither can work in-tree: conan packages are
    # built one arch at a time, and libc++ marks std::filesystem — which xlua.cpp
    # uses — unavailable before macOS 10.15, a hard compile error. In-tree we
    # follow whatever the enclosing build sets.
    if(NOT XLUA_IN_XPLANE_TREE)
        set_target_properties(xlua2 PROPERTIES
            # Universal binary — matches ONLY_ACTIVE_ARCH = NO with default ARCHS
            OSX_ARCHITECTURES     "x86_64;arm64"
            # Matches target-level MACOSX_DEPLOYMENT_TARGET = 10.11
            OSX_DEPLOYMENT_TARGET "10.11")
    endif()

    target_compile_definitions(xlua2 PRIVATE APL=1 IBM=0 LIN=0)

    # GCC_SYMBOLS_PRIVATE_EXTERN = YES → -fvisibility=hidden
    target_compile_options(xlua2 PRIVATE -fvisibility=hidden)

    find_library(OPENGL_LIB       OpenGL       REQUIRED)
    find_library(COREFOUNDATION_LIB CoreFoundation REQUIRED)

    target_link_libraries(xlua2 PRIVATE
        ${OPENGL_LIB}
        ${COREFOUNDATION_LIB}
    )

    if(NOT XLUA_IN_XPLANE_TREE)
        # Frameworks — searched relative to SDK/Libraries/Mac (FRAMEWORK_SEARCH_PATHS)
        find_library(XPLM_LIB      XPLM      REQUIRED
            HINTS "${PROJECT_SOURCE_DIR}/SDK/Libraries/Mac")
        find_library(XPWIDGETS_LIB XPWidgets REQUIRED
            HINTS "${PROJECT_SOURCE_DIR}/SDK/Libraries/Mac")
        target_link_libraries(xlua2 PRIVATE ${XPLM_LIB} ${XPWIDGETS_LIB})
    endif()

    # Export only the five X-Plane plugin entry points; hide everything else.
    # Matches OTHER_LDFLAGS -Wl,-exported_symbol pairs in pbxproj.
    # Skipped under a sanitizer so the runtime can interpose freely and so reports
    # symbolize — same reasoning as cmake/linux.cmake in the X-Plane tree.
    if(NOT SANITIZE)
        target_link_options(xlua2 PRIVATE
            -Wl,-exported_symbol,_XPluginStart
            -Wl,-exported_symbol,_XPluginEnable
            -Wl,-exported_symbol,_XPluginDisable
            -Wl,-exported_symbol,_XPluginStop
            -Wl,-exported_symbol,_XPluginReceiveMessage
        )
    endif()

# ─────────────────────────────────────────────────────────────────────────────
# Linux (x86_64 only)
# ─────────────────────────────────────────────────────────────────────────────
elseif(UNIX)
    target_include_directories(xlua2 PRIVATE
        "${PROJECT_SOURCE_DIR}/fmod/lin/studio/inc"
        "${PROJECT_SOURCE_DIR}/fmod/lin/core/inc"
    )

    set_target_properties(xlua2 PROPERTIES
        OUTPUT_NAME "lin"
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lin_x64"
    )

    target_compile_definitions(xlua2 PRIVATE APL=0 IBM=0 LIN=1)

    # -fPIC is load-bearing, not redundant: the X-Plane tree puts -fno-PIE in
    # directory-scope compile options (cmake/clang.cmake), which overrides the -fPIC
    # CMake adds automatically for a MODULE. Target options come last, so this wins.
    # Drop it and the link fails with "relocation R_X86_64_32S ... can not be used
    # when making a shared object".
    target_compile_options(xlua2 PRIVATE
        -m64
        -fPIC
        -fvisibility=hidden
    )

    if(XLUA_IN_XPLANE_TREE)
        # Match the X-Plane SDK's plugins, which force legacy libGL over GLVND.
        set(OpenGL_GL_PREFERENCE LEGACY)
    endif()
    find_package(OpenGL REQUIRED)

    target_link_libraries(xlua2 PRIVATE OpenGL::GL)

    # Everything below is an X-Plane-tree concern only. A standalone build just uses
    # the compiler's own C++ runtime, which is why this project never linked libc++
    # explicitly — and ubuntu-latest, where our CI runs, has no libc++.a at all.
    if(XLUA_IN_XPLANE_TREE)
        # Linking XPWidgets drags the SDK's whole interface onto our link line,
        # including fmod, which this plugin never calls — without --as-needed those
        # become DT_NEEDED entries on an artifact that ships inside every aircraft.
        # Libraries we genuinely use (XPLM, XPWidgets) are unaffected.
        target_link_options(xlua2 PRIVATE -Wl,--as-needed)

        # The X-Plane tree compiles -stdlib=libc++ -nostdlib++ and links with the
        # `clang` driver, so no C++ runtime is linked for us. Because we deliberately
        # omit --no-undefined (see below), forgetting this links clean and then fails
        # at dlopen — X-Plane exports almost nothing, so std::* never resolves.
        # -nostdlib++ at link time stops the driver adding libstdc++ on top.
        target_link_options(xlua2 PRIVATE -nostdlib++)

        if(DYNAMIC_LIBCXX)
            target_link_libraries(xlua2 PRIVATE c++ c++abi)
        else()
            # Absolute paths rather than "libc++.a": CMake rewrites a bare libfoo.a
            # link item to -lfoo, and ld then prefers libc++.so wherever both are
            # installed. This plugin is committed into aircraft and shipped, so it
            # must not pick up a libc++.so.1 dependency a customer may not have.
            # libc++ before libc++abi — libc++.a references __cxa_* from libc++abi.a.
            find_library(XLUA_LIBCXX_A    NAMES libc++.a    REQUIRED)
            find_library(XLUA_LIBCXXABI_A NAMES libc++abi.a REQUIRED)
            target_link_libraries(xlua2 PRIVATE ${XLUA_LIBCXX_A} ${XLUA_LIBCXXABI_A})
        endif()

        # LuaJIT comes from conan as a static archive, so nothing needs finding at
        # runtime — without this CMake bakes the local conan cache path in as
        # RUNPATH, and that would ship inside every aircraft's copy of the plugin.
        set_target_properties(xlua2 PROPERTIES SKIP_BUILD_RPATH TRUE)
    endif()

    target_link_options(xlua2 PRIVATE
        -m64
        -static-libgcc
        # --no-undefined is omitted intentionally: XPLM symbols are unresolved
        # at link time and resolved at runtime by X-Plane (matches Makefile).
    )

    # Restrict exported symbols to those listed in exports.txt.
    # No quotes around the path — CMake escapes them, causing ld to treat
    # the quotes as part of the filename.  The path contains no spaces so
    # quoting is unnecessary.
    # Skipped under a sanitizer, mirroring cmake/linux.cmake in the X-Plane tree.
    if(NOT SANITIZE)
        target_link_options(xlua2 PRIVATE
            -Wl,--version-script=${PROJECT_SOURCE_DIR}/exports.txt
        )
    endif()

else()
    message(FATAL_ERROR "Unsupported platform")
endif()

# ─────────────────────────────────────────────────────────────────────────────
# LuaJIT
# Sources include <lua.h>, <lua.hpp> and <luajit.h> by include path (the same way
# the MOBILE build already did), so both branches below just have to put the right
# directory in front of them.
# ─────────────────────────────────────────────────────────────────────────────
if(XLUA_LUAJIT_FROM_CONAN)
    target_link_libraries(xlua2 PRIVATE luajit::luajit)
else()
    # lua_sdk/ first: its headers are the ones the prebuilt static libs were built
    # from. luajit/src supplies lua.hpp and luajit.h, which lua_sdk/ does not carry.
    target_include_directories(xlua2 PRIVATE
        "${PROJECT_SOURCE_DIR}/lua_sdk"
        "${PROJECT_SOURCE_DIR}/luajit/src"
    )

    if(WIN32)
        target_link_libraries(xlua2 PRIVATE "${PROJECT_SOURCE_DIR}/lua_sdk/lua51.lib")
    elseif(APPLE)
        target_link_libraries(xlua2 PRIVATE "${PROJECT_SOURCE_DIR}/lua_sdk/libluajit_mac.a")
    else()
        target_link_libraries(xlua2 PRIVATE "${PROJECT_SOURCE_DIR}/lua_sdk/libluajit.a")
    endif()
endif()

# A MODULE reads CMAKE_MODULE_LINKER_FLAGS, which the X-Plane tree never sets, so
# -fsanitize= reaches our compiles but not our link. Pass it through explicitly;
# the runtime itself still comes from the host process at dlopen time.
if(UNIX AND SANITIZE)
    target_link_options(xlua2 PRIVATE -fsanitize=${SANITIZE})
endif()
