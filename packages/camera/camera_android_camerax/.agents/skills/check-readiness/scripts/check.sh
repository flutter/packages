#!/bin/bash
# Copyright 2013 The Flutter Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Stop on first error
set -e

# Get the directory of this script, then go up to camera_android_camerax root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CAMERAX_DIR="$SCRIPT_DIR/../../../.."

echo "🔍 Checking if environment is ready for new work..."

# 1. Check symlinks resolve
echo "1️⃣  Checking skill symlinks..."
broken_links=$(find "$CAMERAX_DIR/.agents/skills" -type l ! -exec test -e {} \; -print)
if [ -n "$broken_links" ]; then
  echo "❌ Error: Found broken symlinks in .agents/skills:"
  echo "$broken_links"
  exit 1
fi
echo "✅ All symlinks resolve correctly."

# 2. Check git state
echo "2️⃣  Checking git state..."
# Check the whole repository git state
if [ -n "$(git status --porcelain)" ]; then
  echo "❌ Error: Git working directory is not clean. Please commit or stash your changes before starting new work."
  exit 1
fi
echo "✅ Git working directory is clean."

# 3. Check dart and flutter
echo "3️⃣  Checking Flutter and Dart..."
if ! command -v flutter &> /dev/null; then
  echo "❌ Error: 'flutter' is not on the PATH."
  exit 1
fi
if ! command -v dart &> /dev/null; then
  echo "❌ Error: 'dart' is not on the PATH."
  exit 1
fi
echo "✅ Flutter and Dart are on the PATH."

# 4. Check dependencies in camera_android_camerax
echo "4️⃣  Checking dependencies in camera_android_camerax..."
cd "$CAMERAX_DIR"
if ! flutter pub get; then
  echo "❌ Error: Failed to resolve dependencies."
  exit 1
fi
echo "✅ Dependencies are resolved and ready."

echo "🎉 Environment is fully ready!"
