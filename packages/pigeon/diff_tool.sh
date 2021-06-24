#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

###############################################################################
# A tool that helps you check the Pigeon output for a given file across
# different versions of Pigeon.
#
# The comparison will be made between the currently checked out sha and the one
# provided as an argument.
#
# usage: ./diff_tool.sh <sha for commit to test against> <path to pigeon file>
###############################################################################

xHash=$1
pigeonPath=$2
diffTool="diff -ru"
gitTool="git -c advice.detachedHead=false"

generate_everything() {
  local inputPath=$1
  local outputDir=$2
  pub run pigeon \
    --input "$inputPath" \
    --dart_out "$outputDir/dart.dart" \
    --java_out "$outputDir/java.dart" \
    --objc_header_out "$outputDir/objc.h" \
    --objc_source_out "$outputDir/objc.m"
}

yHash=$(git rev-parse HEAD)
xDir=$(mktemp -d -t $xHash)
yDir=$(mktemp -d -t $yHash)
inputPath=$yDir/input.dart
cp "$pigeonPath" "$inputPath"
$gitTool checkout $xHash 1> /dev/null
generate_everything $inputPath $xDir
$gitTool checkout $yHash 1> /dev/null
generate_everything $inputPath $yDir
$diffTool "$yDir" "$xDir"
rm -rf "$yDir"
rm -rf "$xDir"
