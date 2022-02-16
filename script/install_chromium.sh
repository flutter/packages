#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
set -e
set -x

# The build of Chromium used to test web functionality.
#
# Chromium builds can be located here: https://commondatastorage.googleapis.com/chromium-browser-snapshots/index.html?prefix=Linux_x64/
# 
# Set CHROMIUM_BUILD env-var to let the script know what to download.

: "${CHROMIUM_BUILD:=950363}" # Default value for the CHROMIUM_BUILD env.
echo "Downloading CHROMIUM_BUILD=${CHROMIUM_BUILD}"

mkdir .chromium
wget "https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F${CHROMIUM_BUILD}%2Fchrome-linux.zip?alt=media" -O .chromium/chromium.zip
unzip .chromium/chromium.zip -d .chromium/
export CHROME_EXECUTABLE=$(pwd)/.chromium/chrome-linux/chrome
echo $CHROME_EXECUTABLE
$CHROME_EXECUTABLE --version
