#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
set -e

output_dir="$1"

# The output directory here must match the directory in
# build_all_packages_app_legacy.sh
dart ./script/tool/bin/flutter_plugin_tools.dart create-all-packages-app \
    --legacy-source=.ci/legacy_project/all_packages --output-dir="$output_dir"/ \
    --exclude script/configs/exclude_all_packages_app.yaml
