#!/bin/sh
# Builds a LuaJIT for the sanitizer tests from the luajit submodule.
# Usage: tests/build_test_luajit.sh <output folder>
# The library is <output folder>/src/libluajit.a.
#
# This LuaJIT is different from the shipped one in three ways:
#   - It uses the system allocator, so AddressSanitizer sees each Lua object that is freed.
#   - LUA_USE_APICHECK and LUA_USE_ASSERT make LuaJIT stop on a wrong use of its C API, for
#     example a call into a coroutine that is suspended.
#   - It is compiled with AddressSanitizer.
set -e
src=$(cd "$(dirname "$0")/../luajit" && pwd)
out=$1
mkdir -p "$out"
cp -R "$src/." "$out/"
make -C "$out" -j4 BUILDMODE=static MACOSX_DEPLOYMENT_TARGET=11.0 \
	XCFLAGS="-DLUAJIT_USE_SYSMALLOC -DLUA_USE_APICHECK -DLUA_USE_ASSERT" \
	CFLAGS="-fsanitize=address -fno-omit-frame-pointer -g" LDFLAGS="-fsanitize=address"
