#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# The name here must match remove_simulator.sh
readonly DEVICE_NAME=Flutter-iPhone
readonly DEVICE=com.apple.CoreSimulator.SimDeviceType.iPhone-14
readonly OS=com.apple.CoreSimulator.SimRuntime.iOS-16-4

xcrun simctl list
xcrun simctl create "$DEVICE_NAME" "$DEVICE" "$OS" | xargs xcrun simctl boot
