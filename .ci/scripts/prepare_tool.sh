#!/bin/bash
# Copyright 2013 The Flutter Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
set -e

# Ensure that 'main' is present for diffing.
git fetch origin main
git branch main origin/main

cd script/tool
dart pub get
