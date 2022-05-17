#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

dart pub global run flutter_plugin_tools test --exclude=script/configs/windows_unit_tests_exceptions.yaml \
  --packages-for-branch --log-timing
