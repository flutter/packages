#!/bin/bash
# Copyright 2013 The Flutter Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
set -e

platform="$1"
build_mode="$2"
output_dir="$3"
shift 3
cd "$output_dir"/all_packages
flutter build "$platform" --"$build_mode" "$@"
