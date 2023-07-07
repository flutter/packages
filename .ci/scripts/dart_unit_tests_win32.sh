#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
set -e

dart ./script/tool/bin/flutter_plugin_tools.dart dart-test \
  --exclude=script/configs/windows_unit_tests_exceptions.yaml \
  --packages-for-branch --log-timing
