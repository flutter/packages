#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# The name here must match create_simulator.sh
readonly DEVICE_NAME=Flutter-iPhone

xcrun simctl shutdown "$DEVICE_NAME"
xcrun simctl delete "$DEVICE_NAME"
xcrun simctl list
