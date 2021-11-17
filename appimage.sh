#!/bin/bash

# Simple recipe to generate an appimage for this app
#
#
# Requirements:
#   * This must be run after a successfully build, and need to set the
#     APP var below to the path of the executable (default is the current
#     travis build place: build/src/gqrx)
#   * Must be run on a Linux version as old as the far distro you need to
#     support, tested successfully on Ubuntu 14.04 Trusty Tar
#   * If you plan to use the "-u" option you need to configure some things
#     for it to work, check this https://github.com/probonopd/uploadtool#usage
#
# On any troubles invoke stdevPavelmc in github

# Tweak this please: this is the path of the gqrx executable relative to
#the project root will reside after build
APP="build/apps/tqsl"

# No need to tweak below unless you move files on the actual project
DESKTOP="apps/tqsl.desktop"
ICON="apps/icons/key48.png"

# basic tests
if [ ! -f "$APP" ] ; then
    echo "Error: the app file is no in the path we need it, update the APP var on this script"
    exit 1
fi

if [ ! -f "$DESKTOP" ] ; then
    echo "Error: can't find the desktop file, please update the DESKTOP var on the scriot"
    exit 1
fi

if [ ! -f "$ICON" ] ; then
    echo "Error: can't find the default icon, please update the ICON var in the script"
    exit 1
fi

# download & set all needed tools
if [ -z `which linuxdeploy-x86_64.AppImage` ] ; then 
    wget -c -nv "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage"
fi
if [ -z `which linuxdeploy-plugin-appimage-x86_64.AppImage` ] ; then 
    wget -c -nv "https://github.com/linuxdeploy/linuxdeploy-plugin-appimage/releases/download/continuous/linuxdeploy-plugin-appimage-x86_64.AppImage"
fi

# make them executable
chmod a+x *.AppImage 2> /dev/null
sudo cp *.AppImage /usr/local/bin/

# clean log space
echo "==================================================================="
echo "                Starting to build the AppImage..."
echo "==================================================================="
echo ""

export VERSION=$(<apps/tqslversion.ver)

# version notice
echo "You are building TQSL version: $VERSION"
echo ""

# prepare the ground
rm -rdf AppDir 2> /dev/null
rm -rdf Tqsl-*.AppImage 2> /dev/null

# preliminar works
mkdir -p ./AppDir/
cp "$ICON" ./AppDir/TrustedQSL.png
ICON="./AppDir/TrustedQSL.png"
cp $DESKTOP ./AppDir/
sed -i s/"TrustedQSL.png"/"TrustedQSL"/ ./AppDir/tqsl.desktop
DESKTOP="./AppDir/tqsl.desktop"

# abra-cadabra
linuxdeploy-x86_64.AppImage -e "$APP" -d "$DESKTOP" -i "$ICON" --output appimage --appdir=./AppDir
RESULT=$?

# check build success
if [ $RESULT -ne 0 ] ; then
    # warning something gone wrong
    echo ""
    echo "ERROR: Aborting as something gone wrong, please check the logs"
    exit 1
else
    # success
    echo ""
    echo "Success build, check your file:"
    ls -lh TQSL-*.AppImage
fi
