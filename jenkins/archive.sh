#!/usr/bin/env bash

case "$PLATFORM" in
"IBM")
	echo jenkins/build_products/lua_win.xpl
	;;
"APL")
	echo jenkins/build_products/lua_mac.xpl
	;;
"LIN")
	echo jenkins/build_products/lua_lin.xpl
	;;
esac

