#!/bin/bash
# Copyright 2013 The Flutter Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
set -e

dart ./script/tool/bin/flutter_plugin_tools.dart drive-examples --windows \
   --exclude=script/configs/exclude_integration_win32.yaml \
   --packages-for-branch --log-timing $PACKAGE_SHARDING
