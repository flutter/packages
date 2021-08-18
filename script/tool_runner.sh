#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

ACTIONS=("$@")

BRANCH_NAME="${BRANCH_NAME:-"$(git rev-parse --abbrev-ref HEAD)"}"
if [[ "${BRANCH_NAME}" == "master" ]]; then
  echo "Running for all packages"
  (cd "$REPO_DIR" && dart pub global run flutter_plugin_tools "${ACTIONS[@]}" $BUILD_SHARDING)
else
  (cd "$REPO_DIR" && dart pub global run flutter_plugin_tools "${ACTIONS[@]}" --run-on-changed-packages $BUILD_SHARDING)
fi
