#!/bin/bash
# Copyright 2013 The Flutter Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Checks out a branch that is behind upstream/main by 1 commit, makes a local commit,
# and verifies that pre-push-skill detects the branch is behind upstream and stops
# immediately without modifying pubspec.yaml or CHANGELOG.md.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(cd "$SCRIPT_DIR/../../../../.." && pwd)"
DART_FILE="$PACKAGE_DIR/lib/src/camerax_library.dart"

cd "$PACKAGE_DIR" || exit 1

# 1. Fetch upstream main with depth of at least 2 to ensure upstream/main~1 is available
git fetch --depth=2 upstream main

# 2. Checkout a new temporary branch 'eval_behind_upstream' starting 1 commit behind upstream/main
git checkout -B eval_behind_upstream upstream/main~1

# 3. Make a local change and commit it so our HEAD is behind upstream/main and diverged
echo "// Eval comment" >> "$DART_FILE"
git add "$DART_FILE"
git -c user.name="Author" -c user.email="author@example.com" commit -m "eval: local commit while behind upstream/main"
