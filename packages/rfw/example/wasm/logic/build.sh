#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -ex

clang++ --target=wasm32 -nostdlib "-Wl,--export-all" "-Wl,--no-entry" -o calculator.wasm calculator.cc
dart encode.dart calculator.rfwtxt calculator.rfw
