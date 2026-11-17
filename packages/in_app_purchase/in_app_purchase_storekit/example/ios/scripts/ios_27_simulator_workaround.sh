#!/bin/sh
# Copyright 2013 The Flutter Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Warms up StoreKit Testing on cold iOS simulators.
#
# On the iOS 27 simulator, the first process that creates an SKTestSession
# connects to storekitd before the test configuration is pushed to the device,
# so storekitd decides it is in the sandbox environment and every StoreKit
# Testing call hangs until it times out. Subsequent processes work because the
# configuration now exists on the device. Apple lists this as fixed in the
# iOS 27.3 release notes ("StoreKit Testing in Xcode" > "Resolved Issues"):
# https://developer.apple.com/documentation/ios-ipados-release-notes/ios-ipados-27_3-release-notes
#
# As a workaround, this runs a single non-purchase test in a throwaway process
# before the real test host launches, so the configuration is already on the
# simulator when the real tests run.
#
# This script is invoked as a Test pre-action in Runner.xcscheme and relies on
# the build settings Xcode provides to pre-actions (PROJECT_DIR, BUILD_DIR,
# CONFIGURATION, TARGET_DEVICE_IDENTIFIER, TARGET_DEVICE_PLATFORM_NAME).
#
# TODO(LouiseHsu): Remove this script and the pre-action in Runner.xcscheme once
# CI runs on an iOS simulator runtime that includes the fix (iOS 27.3+).
# See https://github.com/flutter/flutter/issues/195494.

# Guard against recursion: the nested xcodebuild below runs this pre-action too.
if [ -n "$STOREKIT_WARMUP" ]; then
  exit 0
fi

if [ "$TARGET_DEVICE_PLATFORM_NAME" != "iphonesimulator" ]; then
  exit 0
fi

# On CI, FLUTTER_LOGS_DIR is uploaded as a build artifact (see
# script/tool/lib/src/common/core.dart), so the log survives the run.
log_file="${FLUTTER_LOGS_DIR:-${TMPDIR:-/tmp}}/storekit_warmup.log"
# A healthy warm-up takes well under a minute. Bound it so a hung nested
# xcodebuild cannot stall the real test run.
timeout_seconds=300

# Run the warm-up in a background subshell so the whole thing (boot wait
# included) is bounded by the timeout below.
(
  # Wait for the simulator to finish booting before launching the test host.
  # Launching into a half-booted simulator can fail with "No such process".
  # This is a no-op if the simulator is already booted. Both commands get a
  # clean environment so they do not inherit the outer build's settings.
  env -i HOME="$HOME" PATH="$PATH" DEVELOPER_DIR="$DEVELOPER_DIR" \
    xcrun simctl bootstatus "$TARGET_DEVICE_IDENTIFIER" -b

  # Any test whose setUp creates an SKTestSession works here; keep the name in
  # sync if that test is renamed, or the warm-up silently stops working.
  exec env -i HOME="$HOME" PATH="$PATH" DEVELOPER_DIR="$DEVELOPER_DIR" STOREKIT_WARMUP=1 \
    xcodebuild test-without-building \
      -workspace "$PROJECT_DIR/Runner.xcworkspace" -scheme Runner \
      -configuration "$CONFIGURATION" -destination "id=$TARGET_DEVICE_IDENTIFIER" \
      -derivedDataPath "$BUILD_DIR/../.." \
      -only-testing:RunnerTests/InAppPurchase2PluginTests/testCanMakePayments
) > "$log_file" 2>&1 &
warmup_pid=$!

elapsed=0
while kill -0 "$warmup_pid" 2>/dev/null && [ "$elapsed" -lt "$timeout_seconds" ]; do
  sleep 5
  elapsed=$((elapsed + 5))
done

# xcodebuild does not surface pre-action output, so record the outcome in the
# log file as well as on stdout.
report() {
  echo "$1"
  echo "$1" >> "$log_file"
}

if kill -0 "$warmup_pid" 2>/dev/null; then
  kill "$warmup_pid" 2>/dev/null
  wait "$warmup_pid" 2>/dev/null
  report "warning: StoreKit Testing warm-up timed out after ${timeout_seconds}s; see $log_file"
elif wait "$warmup_pid"; then
  report "StoreKit Testing warm-up succeeded in ${elapsed}s (log: $log_file)"
else
  report "warning: StoreKit Testing warm-up failed; see $log_file"
fi

# Never fail the real test run because of the warm-up; the worst case is the
# original hang, which the real tests will report.
exit 0
