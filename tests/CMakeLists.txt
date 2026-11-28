# The xlua_tests program: all sources of the xlua2 plugin, linked with a fake XPLM, and catch2 tests.
# Configure with -DXLUA_BUILD_TESTS=ON, build the xlua_tests target, then run ctest.
# ctest runs each test case in its own process, because XLua keeps state in static variables.

find_package(Python3 REQUIRED COMPONENTS Interpreter)
include(${CMAKE_CURRENT_SOURCE_DIR}/catch2/Catch.cmake)

# The LuaJIT library to link. The default is the library that the plugin ships with. The sanitizer
# job links a LuaJIT built from the luajit submodule with the system allocator and with API checks.
if(APPLE)
    set(XLUA_TEST_LUAJIT "${PROJECT_SOURCE_DIR}/lua_sdk/libluajit_mac.a" CACHE FILEPATH "LuaJIT library for xlua_tests")
else()
    set(XLUA_TEST_LUAJIT "${PROJECT_SOURCE_DIR}/lua_sdk/libluajit.a" CACHE FILEPATH "LuaJIT library for xlua_tests")
endif()

get_target_property(xlua_sources xlua2 SOURCES)
get_target_property(xlua_definitions xlua2 COMPILE_DEFINITIONS)
get_target_property(xlua_includes xlua2 INCLUDE_DIRECTORIES)
list(TRANSFORM xlua_sources PREPEND "${PROJECT_SOURCE_DIR}/")

# Weak no-op definitions of all XPLM functions. fake_xplm.cpp overrides the ones that the tests use.
set(xplm_headers "${PROJECT_SOURCE_DIR}/SDK/CHeaders/XPLM")
file(GLOB xplm_header_files "${xplm_headers}/*.h")
set(stub_flags)
foreach(d ${xlua_definitions})
    list(APPEND stub_flags "-D${d}")
endforeach()
foreach(i ${xlua_includes})
    list(APPEND stub_flags "-I${i}")
endforeach()
if(CMAKE_OSX_SYSROOT)
    list(APPEND stub_flags -isysroot ${CMAKE_OSX_SYSROOT})
endif()
add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/xplm_stubs.cpp
    COMMAND Python3::Interpreter ${CMAKE_CURRENT_SOURCE_DIR}/gen_xplm_stubs.py
            ${xplm_headers} ${CMAKE_CURRENT_BINARY_DIR}/xplm_stubs.cpp ${CMAKE_CXX_COMPILER} ${stub_flags}
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/gen_xplm_stubs.py ${xplm_header_files}
    VERBATIM)

add_executable(xlua_tests
    ${xlua_sources}
    ${CMAKE_CURRENT_BINARY_DIR}/xplm_stubs.cpp
    catch2/catch_amalgamated.cpp
    fake_xplm.cpp
    host.cpp
    test_commands.cpp
    test_lifetime.cpp
    test_start.cpp
)

target_compile_definitions(xlua_tests PRIVATE
    ${xlua_definitions}
    XLUA_INIT_LUA="${PROJECT_SOURCE_DIR}/deploy/init.lua"
    XLUA_TEST_SCRIPTS="${CMAKE_CURRENT_SOURCE_DIR}/scripts"
)
target_include_directories(xlua_tests PRIVATE ${xlua_includes} ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(xlua_tests PRIVATE "${XLUA_TEST_LUAJIT}" ${CMAKE_DL_LIBS})
if(UNIX AND NOT APPLE)
    target_link_libraries(xlua_tests PRIVATE pthread)
endif()

catch_discover_tests(xlua_tests
    DISCOVERY_MODE PRE_TEST
    PROPERTIES TIMEOUT 60)
