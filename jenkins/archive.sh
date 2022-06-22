#!/usr/bin/env bash

case "$PLATFORM" in
"IBM")
	echo jenkins/build_productsx/lua_win.xpl
	;;
"APL")
	echo jenkins/build_productsx/lua_mac.xpl
	;;
"LIN")
	echo jenkins/build_productsx/lua_lin.xpl
	;;
esac

