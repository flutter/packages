#!/bin/bash
# Copyright 2013 The Flutter Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Simulates a failure of the cross_skill_rubric.json by modifying files incorrectly.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_ROOT="$(cd "$SCRIPT_DIR/../../" && pwd)"

# 1. Modify a sibling package (Violates scope_limitation)
# We append a comment to a file in the sibling directory.
# README.md is highly unlikely to be moved or deleted.
echo "<!-- dummy eval modification -->" >> "$PACKAGE_ROOT/../camera_android/README.md"

# 2. Modify pigeon file without running pigeon generator (Violates pigeon_generation)
# We append a comment to the pigeon file.
echo "// dummy eval modification" >> "$PACKAGE_ROOT/pigeons/camerax_library.dart"

# 3. Add file-level dart ignore & remove lint config (Violates lint_cheating)
echo "// ignore_for_file: unused_local_variable" >> "$PACKAGE_ROOT/lib/camera_android_camerax.dart"
rm -f "$PACKAGE_ROOT/analysis_options.yaml"
