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

# 1. Modify Dart source file
sed -i.bak 's/@visibleForTesting/@visibleForTesting \/\/ Eval comment/' "$DART_FILE" && rm -f "${DART_FILE}.bak"

# 2. Modify Dart test file (so Dart side has a matching test update)
sed -i.bak 's/void main() {/void main() { \/\/ Eval test comment/' "$DART_TEST" && rm -f "${DART_TEST}.bak"

# 3. Modify Java source file WITHOUT updating CameraTest.java in android/src/test/
sed -i.bak 's/super(pigeonRegistrar);/super(pigeonRegistrar); \/\/ Eval comment/' "$JAVA_FILE" && rm -f "${JAVA_FILE}.bak"

# Commit so git status is clean and git diff against origin/main shows all three files
cd "$PACKAGE_DIR" || exit 1
git add "$DART_FILE" "$DART_TEST" "$JAVA_FILE"
git commit -m "eval: mixed Dart and Java changes without native unit test"
