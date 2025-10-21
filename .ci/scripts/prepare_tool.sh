#!/bin/bash
# Copyright 2013 The Flutter Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
set -e

# To set FETCH_HEAD for "git merge-base" to work
git fetch origin main

cd script/tool
dart pub get
