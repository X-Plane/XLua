#!/usr/bin/env bash

case "$PLATFORM" in
"IBM")
	echo jenkins/build_products/win_x64/xlua.xpl
	;;
"APL")
	echo jenkins/build_products/mac_x64/xlua.xpl
	;;
"LIN")
	echo jenkins/build_products/lin_x64/xlua.xpl
	;;
esac

