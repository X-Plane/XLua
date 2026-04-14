#!/usr/bin/env bash

if [ -z "${PLATFORM}" ]; then
	echo "PLATFORM not set properly - it must be one of APL IBM or LIN"
	exit 1
fi

WANT_CODESIGN="${WANT_CODESIGN:-NO}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-$(pwd)/DerivedData}"

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
	mv Release/plugins/win_x64/xlua.pdb jenkins/build_products/xlua_win.pdb
	echo mv Release/plugins/win_x64/xlua.xpl jenkins/build_products/xlua_win.xpl
	mv Release/plugins/win_x64/xlua.xpl jenkins/build_products/xlua_win.xpl
	;;
"APL")
	
	CODE_SIGN_ARGS=()
	if [ "${WANT_CODESIGN}" == "YES" ]; then
		CODE_SIGN_ARGS=(
			CODE_SIGN_STYLE="Manual"
			CODE_SIGN_IDENTITY="Developer ID Application: Laminar Research (LPH4NFE92D)"
		)
	else
		CODE_SIGN_ARGS=(
			CODE_SIGNING_ALLOWED=NO
			CODE_SIGN_STYLE="Manual"
			CODE_SIGN_IDENTITY=""
		)
	fi

	echo Cleaning...
	xcodebuild \
		-scheme xlua \
		-config Release \
		-project xlua.xcodeproj \
		-derivedDataPath "${DERIVED_DATA_PATH}" \
		"${CODE_SIGN_ARGS[@]}" \
		clean

	echo Compiling...
	xcodebuild \
		-scheme xlua \
		-config Release \
		-project xlua.xcodeproj \
		-archivePath XLua.xcarchive \
		-derivedDataPath "${DERIVED_DATA_PATH}" \
		"${CODE_SIGN_ARGS[@]}" \
		archive

	if [ "${WANT_CODESIGN}" == "YES" ]; then
		echo Notarizing...
		./build-tools/mac/notarization.sh \
				xlua_mac.zip \
				xlua.xcarchive/Products/usr/local/lib/xlua.xpl \
				no-staple
	fi
	
	mv xlua.xcarchive/Products/usr/local/lib/xlua.xpl jenkins/build_products/xlua_mac.xpl
	;;
"LIN")
	make clean
	make
	cp build/xlua/64/lin.xpl jenkins/build_products/xlua_lin.xpl
	;;
*)
	echo "PLATFORM not set properly - it must be one of APL IBM or LIN"
	exit 1
	;;
esac
