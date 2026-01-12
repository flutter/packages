#!/bin/bash
# Copyright 2013 The Flutter Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# This script is mentioned in the README.md file.

# This script is also called from: ../../customer_testing.sh

set -e
pushd test_coverage; dart pub get; popd
set -x
dart --enable-asserts test_coverage/bin/test_coverage.dart "$@"
