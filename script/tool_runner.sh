#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# The tool expects to be run from the repo root.
cd "$REPO_DIR"
dart pub global run flutter_plugin_tools "$@" --packages-for-branch \
  --log-timing $BUILD_SHARDING
