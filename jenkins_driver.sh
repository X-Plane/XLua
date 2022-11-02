#!/usr/bin/env bash

# The Jenkins driver script is a bash script run by developers on their _local_ machine that _simulates_ the scripts 
# dispatched by Jenkins during a real bot-build.  It fills in the various build environment variables and then deploys
# the scripts in order.
#
# The idea is to keep this script in sync with the Jenkins environment, such that a build on Jenkins will work if this
# script works on 3 platforms. 

COMMITISH=`git rev-parse HEAD`
BUILD_TYPE=Release
BUILD_TARGETS=$1
WANT_CODESIGN=YES
WANT_UNIT_TESTS=YES

while : 
do
	case "$1" in
		"-n" | "--no_codesign")
			WANT_CODESIGN=NO
			shift
			;;
		"--no_unit_tests")
			WANT_UNIT_TESTS=NO
			shift
			;;
		*)
			break
			;;
	esac
done

#"C:\vs_2022\"
MSVC_ROOT="/mnt/c/Program Files/Microsoft Visual Studio/2022/Community"

if [[ `uname -a` == *Darwin* ]]; then
	PLATFORM=APL
elif [[ `uname -a` == *icrosoft* ]]; then
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


echo ================================================================================================================
echo = CHECKOUT 
echo ================================================================================================================
./jenkins/checkout.sh
echo ================================================================================================================
echo = BUILD 
echo ================================================================================================================
./jenkins/build.sh

if [[ $WANT_UNIT_TESTS == "YES" ]]; then
	echo ================================================================================================================
	echo = UNIT TESTS 
	echo ================================================================================================================
	./jenkins/unit_tests.sh
fi

echo ================================================================================================================
echo = ARCHIVE 
echo ================================================================================================================
./jenkins/archive.sh
