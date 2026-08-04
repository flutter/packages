#!/bin/bash
# Copyright 2013 The Flutter Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Modifies a native Java file and its corresponding test file,
# and commits the change to test that pre-push-skill verifies native tests pass and are included.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(cd "$SCRIPT_DIR/../../../../.." && pwd)"
JAVA_FILE="$PACKAGE_DIR/android/src/main/java/io/flutter/plugins/camerax/CameraProxyApi.java"
TEST_FILE="$PACKAGE_DIR/android/src/test/java/io/flutter/plugins/camerax/CameraTest.java"

# Modify CameraProxyApi.java and CameraTest.java
echo "// Eval comment" >> "$JAVA_FILE"
echo "// Eval test comment" >> "$TEST_FILE"

# Commit so git status is clean and git diff against origin/main shows both files
cd "$PACKAGE_DIR" || exit 1
git add "$JAVA_FILE" "$TEST_FILE"
git commit -m "eval: temporary commit with Java change and test update"
