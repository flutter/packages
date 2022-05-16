#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Exclude flutter_image because its tests need a test server, so are run via custom_package_tests.
# Exclude xgd_directories because it is a Linux only package.
dart pub global run flutter_plugin_tools test --exclude=flutter_image,fuchsia_ctl,xgd_directories \
  --packages-for-branch --log-timing
