#!/usr/bin/env bash

# unit_tests.sh
#
# unit_tests is run by Jeknins post-checkout, post-build to run unit tests.  If unit tests will be run,
# the WANT_UNIT_TEST environment variable will have been "YES" for build so that extra unit test code 
# can be compiled.

echo No unit tests for XLua yet.

echo COMMITISH=$COMMITISH
echo BUILD_TYPE=$BUILD_TYPE
echo BUILD_TARGETS=$BUILD_TARGETS
echo WANT_CODESIGN=$WANT_CODESIGN
echo WANT_UNIT_TESTS=$WANT_UNIT_TESTS
echo PLATFORM=$PLATFORM

