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

cd packages/animations
flutter analyze --no-fatal-infos
flutter test
