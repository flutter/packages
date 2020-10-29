#!/bin/bash
set -e
set -x

# The build of Chromium used to test web functionality.
#
# Chromium builds can be located here: https://commondatastorage.googleapis.com/chromium-browser-snapshots/index.html?prefix=Linux_x64/
CHROMIUM_BUILD=768968

mkdir .chromium
wget "https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F${CHROMIUM_BUILD}%2Fchrome-linux.zip?alt=media" -O .chromium/chromium.zip
unzip .chromium/chromium.zip -d .chromium/
export CHROME_EXECUTABLE=$(pwd)/.chromium/chrome-linux/chrome
echo $CHROME_EXECUTABLE
$CHROME_EXECUTABLE --version
