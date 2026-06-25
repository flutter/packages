#!/bin/bash
# Copyright 2013 The Flutter Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
set -e

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly REPO_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

cd "$REPO_DIR/packages/camera/camera_android_camerax"
flutter pub run dart_code_linter:metrics analyze lib --set-exit-on-violation-level=warning
