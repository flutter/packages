#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
set -e
# Ensure that the create/boot pipeline fails if `create` fails
set -o pipefail

# The name here must match remove_simulator.sh
readonly DEVICE_NAME=Flutter-iPhone
readonly DEVICE=com.apple.CoreSimulator.SimDeviceType.iPhone-14
readonly OS=com.apple.CoreSimulator.SimRuntime.iOS-16-4

# Delete any existing devices named Flutter-iPhone. Having more than one may
# cause issues when builds target the device.
echo -e "Deleting any existing devices names $DEVICE_NAME..."
RESULT=0
while [[ $RESULT == 0 ]]; do
    xcrun simctl delete "$DEVICE_NAME" || RESULT=1
    if [ $RESULT == 0 ]; then
        echo -e "Deleted $DEVICE_NAME"
    fi
done
echo -e ""

echo -e "\nCreating $DEVICE_NAME $DEVICE $OS ...\n"
xcrun simctl create "$DEVICE_NAME" "$DEVICE" "$OS" | xargs xcrun simctl boot
xcrun simctl list
