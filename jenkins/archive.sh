#!/usr/bin/env bash

case "$PLATFORM" in
"IBM")
	echo jenkins/build_products/xlua_win.xpl
	;;
"APL")
	echo jenkins/build_products/xlua_mac.xpl
	;;
"LIN")
	echo jenkins/build_products/xlua_lin.xpl
	;;
esac

