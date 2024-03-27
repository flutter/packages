#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
set -e

# Allow analyzing packages that use a dev dependency with a higher minimum
# Flutter/Dart version than the package itself. Non-client code doesn't need to
# work in legacy versions.
#
# This requires the --lib-only flag below.
.ci/scripts/tool_runner.sh remove-dev-dependencies

# This uses --run-on-dirty-packages rather than --packages-for-branch
# since only the packages changed by 'make-deps-path-based' need to be
# re-checked.
.ci/scripts/tool_runner.sh analyze --lib-only \
    --skip-if-not-supporting-flutter-version="$CHANNEL" \
    --custom-analysis=script/configs/custom_analysis.yaml

# Restore the tree to a clean state, to avoid accidental issues if
# other script steps are added to the enclosing task.
git checkout .
