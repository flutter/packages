#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
set -e

# Decide what exclusion file to use, the normal or "wasm" depending on $1
if [ "$1" = "--wasm" ]; then
    EXCLUDE="script/configs/exclude_all_packages_app_wasm.yaml"
else
    EXCLUDE="script/configs/exclude_all_packages_app.yaml"
fi

# Delete ./all_packages if it exists already
rm -rf ./all_packages

dart ./script/tool/bin/flutter_plugin_tools.dart create-all-packages-app \
    --output-dir=. --exclude $EXCLUDE
