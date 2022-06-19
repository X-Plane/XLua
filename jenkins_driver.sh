#!/usr/bin/env bash



COMMITISH=`git rev-parse HEAD`
BUILD_TYPE=Release
BUILD_TARGETS=$1
WANT_CODESIGN=YES
WANT_UNIT_TESTS=YES

#"C:\vs_2022\"
MSVC_ROOT="/mnt/c/Program Files/Microsoft Visual Studio/2022/Community"

if [[ `uname -a` == *Darwin* ]]; then
	PLATFORM=APL
elif [[ `uname -a` == *Microsoft* ]]; then
	PLATFORM=IBM
else
	PLATFORM=LIN
fi

export COMMITISH
export BUILD_TYPE
export BUILD_TARGETS
export WANT_CODESIGN
export WANT_UNIT_TESTS
export PLATFORM
export MSVC_ROOT


./jenkins/checkout.sh
./jenkins/build.sh
./jenkins/archive.sh
