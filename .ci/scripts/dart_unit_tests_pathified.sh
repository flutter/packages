#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
set -e

# Pathify the dependencies on changed packages (excluding major version
# changes, which won't affect clients).
.ci/scripts/tool_runner.sh make-deps-path-based --target-dependencies-with-non-breaking-updates
# This uses --run-on-dirty-packages rather than --packages-for-branch
# since only the packages changed by 'make-deps-path-based' need to be
# re-checked.
dart ./script/tool/bin/flutter_plugin_tools.dart dart-test --run-on-dirty-packages \
    --log-timing --exclude=script/configs/dart_unit_tests_exceptions.yaml \
    "$@" $PACKAGE_SHARDING
# Restore the tree to a clean state, to avoid accidental issues if
# other script steps are added to the enclosing task.
git checkout .
