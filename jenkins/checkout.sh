#!/usr/bin/env bash

# checkout.sh
#
# checkout is run by Jeknins post-checkout, pre-build to complete any additional code setup tasks.  Examples
# might include updating or setting up submodules or decompressing compressed libraries and other build
# dependencies that vary with branch.


# Since XLua has no such dependencies as of now, we simply echo out the Jenkins environment for reference.
echo No additional checkout steps necessarr for XLua

echo COMMITISH=$COMMITISH
echo BUILD_TYPE=$BUILD_TYPE
echo BUILD_TARGETS=$BUILD_TARGETS
echo WANT_CODESIGN=$WANT_CODESIGN
echo WANT_UNIT_TESTS=$WANT_UNIT_TESTS
echo PLATFORM=$PLATFORM

