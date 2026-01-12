#!/bin/bash
# Copyright 2013 The Flutter Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -e

# This file runs the repo tooling (see TOOL_PATH) in a configuration that's
# common to almost all of the CI usage, avoiding the need to pass the same
# flags (e.g., --packages-for-branch) in every CI invocation.
#
# For local use, directly run `dart run <tool path>`.

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly REPO_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
readonly TOOL_PATH="$REPO_DIR/script/tool/bin/flutter_plugin_tools.dart"

# Ensure that the tool dependencies have been fetched.
(pushd "$REPO_DIR/script/tool" && dart pub get && popd) >/dev/null

# The tool expects to be run from the repo root.
cd "$REPO_DIR"
# Run from the in-tree source.
# PACKAGE_SHARDING is (optionally) set in CI configuration. See .ci.yaml
dart run "$TOOL_PATH" "$@" --packages-for-branch --log-timing $PACKAGE_SHARDING
