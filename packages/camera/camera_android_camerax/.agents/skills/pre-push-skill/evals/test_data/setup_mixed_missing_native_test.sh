#!/bin/bash
# Copyright 2013 The Flutter Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Modifies both a Dart source/test pair and a native Java source file (without its native test),
# and commits the change to test that pre-push-skill detects the missing native test in a mixed PR.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(cd "$SCRIPT_DIR/../../../../.." && pwd)"
DART_FILE="$PACKAGE_DIR/lib/src/camerax_library.dart"
DART_TEST="$PACKAGE_DIR/test/android_camera_camerax_test.dart"
JAVA_FILE="$PACKAGE_DIR/android/src/main/java/io/flutter/plugins/camerax/CameraProxyApi.java"

# 1. Modify Dart source file and test file
echo "// Eval comment" >> "$DART_FILE"
echo "// Eval test comment" >> "$DART_TEST"

# 2. Modify Java source file WITHOUT updating CameraTest.java in android/src/test/
echo "// Eval comment" >> "$JAVA_FILE"

# Commit so git status is clean and git diff against origin/main shows all three files
cd "$PACKAGE_DIR" || exit 1
git add "$DART_FILE" "$DART_TEST" "$JAVA_FILE"
git commit -m "eval: mixed Dart and Java changes without native unit test"
