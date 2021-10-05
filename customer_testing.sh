#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# This file is used by
# https://github.com/flutter/tests/tree/master/registry/flutter_packages.test
# to run the tests of certain packages in this repository as a presubmit
# for the flutter/flutter repository.
# Changes to this file (and any tests in this repository) are only honored
# after the commit hash in the "flutter_packages.test" mentioned above has been
# updated.
# Remember to also update the Windows version (customer_testing.bat) when
# changing this file.

set -e

pushd packages/animations
flutter analyze --no-fatal-infos
flutter test
popd

pushd packages/rfw

# Update the examples packages so that the analysis doesn't get confused.
pushd example/remote
flutter packages get
popd
pushd example/wasm
flutter packages get
popd

flutter analyze --no-fatal-infos
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    # We only run the full tests on Linux because golden files differ
    # from platform to platform.
    flutter test
fi
# The next script verifies that the coverage is not regressed; it does
# not verify goldens. (It does run all the tests though, so it still
# catches logic issues on other platforms, just not issue that only
# affect golden files.)
./run_tests.sh
popd
