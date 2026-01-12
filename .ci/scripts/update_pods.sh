#!/bin/bash
# Copyright 2013 The Flutter Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
set -e

# Ensure that the pods repos are up to date, since analyze will not check for
# the latest versions of pods, so can use stale Flutter or FlutterMacOS pods
# for analysis otherwise.
pod repo update --verbose
