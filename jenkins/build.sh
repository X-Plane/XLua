#!/usr/bin/env bash

if [ -z "${PLATFORM}" ]; then
	echo "PLATFORM not set properly - it must be one of APL IBM or LIN"
	exit 1
fi

function clean() {
	rm -rf xlua.xcarchive
	rm -rf xlua_mac.zip
	rm -rf Debug
	rm -rf Release
	mkdir -p jenkins/build_products
}

echo Removing old build products... 
rm -rf jenkins/build_products/
clean

case "$PLATFORM" in
"IBM")
	MSBUILD="$MSVC_ROOT"/MSBuild/Current/Bin/MSBuild.exe 
	"$MSBUILD" xlua.vcxproj /t:Clean		
	"$MSBUILD" /m /p:Configuration="Release" /p:Platform="x64" xlua.vcxproj
	echo mv Release/plugins/win_x64/xlua.pdb jenkins/build_products/xlua_win.pdb
	mv Release/plugins/win_x64/xlua.pdb jenkins/build_products/win_x64/xlua.pdb
	echo mv Release/plugins/win_x64/xlua.xpl jenkins/build_products/xlua_win.xpl
	mv Release/plugins/win_x64/xlua.xpl jenkins/build_products/win_x64/xlua.xpl
	;;
"APL")
	
	echo Cleaning...
	xcodebuild \
		-scheme xlua \
		-config Release \
		-project xlua.xcodeproj \
		clean

	echo Compiling...
	xcodebuild \
		-scheme xlua \
		-config Release \
		-project xlua.xcodeproj \
		-archivePath XLua.xcarchive \
		CODE_SIGN_STYLE="Manual" \
		CODE_SIGN_IDENTITY="Developer ID Application: Laminar Research (LPH4NFE92D)" \
		archive

	if [ $WANT_CODESIGN == "YES" ]; then
		echo Notarizing...
		./build-tools/mac/notarization.sh \
				xlua_mac.zip \
				xlua.xcarchive/Products/usr/local/lib/xlua.xpl \
				no-staple
	fi

 	mkdir -p jenkins/build_products/mac_x64
	mv xlua.xcarchive/Products/usr/local/lib/xlua.xpl jenkins/build_products/mac_x64/xlua.xpl
	;;
"LIN")
	make clean
	make
  	mkdir -p jenkins/build_products/lin_x64
	cp build/xlua/lin_x64/xlua.xpl jenkins/build_products/lin_x64/xlua.xpl
	;;
*)
	echo "PLATFORM not set properly - it must be one of APL IBM or LIN"
	exit 1
	;;
esac
