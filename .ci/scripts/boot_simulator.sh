#!/bin/bash
# Copyright 2013 The Flutter Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
set -e

# The name here must match create_simulator.sh
readonly DEVICE_NAME=Flutter-iPhone

# Allow boot to fail; cases like "Unable to boot device in current state: Booted"
# exit with failure.
xcrun simctl boot "$DEVICE_NAME" || :
echo -e ""
xcrun simctl list
