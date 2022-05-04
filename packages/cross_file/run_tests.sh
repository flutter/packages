#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# This script runs browser tests for this package,
# as described on the README.md.
# This script is run by the `custom-test` CI step.
# VM unit tests are run by the `test` check.

set -e
dart test -p chrome
