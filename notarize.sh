#!/bin/bash

# World's stupidest notarization script for XLua.  Run from whatever folder has the
# Mac xlua.xpl file.
#
# The running machine must have Apple ID credentials pre-registered in the key chain under
# the KC item AC_PASSWORD

rm xlua.zip
zip -r xlua.zip "xlua.xpl"

xcrun notarytool submit xlua.zip \
                   --keychain-profile "AC_PASSWORD" \
                   --wait \
                   --timeout 10m

rm xlua.zip
