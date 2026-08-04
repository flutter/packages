#!/bin/bash
# Copyright 2013 The Flutter Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Modifies a native Java file without updating a corresponding test file,
# and commits the change to test that pre-push-skill detects missing native tests.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(cd "$SCRIPT_DIR/../../../../.." && pwd)"
JAVA_FILE="$PACKAGE_DIR/android/src/main/java/io/flutter/plugins/camerax/CameraProxyApi.java"

# Add a harmless comment inside CameraProxyApi.java
sed -i.bak 's/super(pigeonRegistrar);/super(pigeonRegistrar); \/\/ Eval comment/' "$JAVA_FILE" && rm -f "${JAVA_FILE}.bak"

# Commit so git status is clean and git diff against origin/main shows the Java change
cd "$PACKAGE_DIR" || exit 1
git add "$JAVA_FILE"
git commit -m "eval: temporary commit with Java change and no test update"
