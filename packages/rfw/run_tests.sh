#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Please update these targets when you update this package.
# Please ensure that test coverage continues to be 100%.

TARGET_LINES=2134
TARGET_PERCENT=100
LAST_UPDATE="2021-08-30"

# ----------------------------------------------------------------------

# This script is mentioned in the README.md file.

set -e

if [ "$CHANNEL" == "stable" ]; then
    # For now these are disabled because this package has never been supported
    # on the stable channel and requires newer language features that have not
    # yet shipped to a stable build. -Hixie, 2021-08-30
    echo "Skipping tests on stable channel."
    exit 0
fi

rm -rf coverage
# We run with --update-goldens because the goal here is not to verify the tests
# pass but to verify the coverage, and the goldens are not always going to pass
# when run on different platforms (e.g. on Cirrus we run this on a mac but the
# goldens expect a linux box).
flutter test --coverage --update-goldens
ACTUAL=`lcov -l coverage/lcov.info | tail -1 | cut -d '|' -f 2 | cut -d '%' -f 2`
# We only check the TARGET_LINES matches, not the TARGET_PERCENT,
# because we expect the percentage to drop over time as Dart fixes
# various bugs in how it determines what lines are coverable.
if [ $ACTUAL -lt $TARGET_LINES ]; then
    echo
    echo "                      ╭──────────────────────────────╮"
    echo "                      │ COVERAGE REGRESSION DETECTED │"
    echo "                      ╰──────────────────────────────╯"
    echo
    lcov --quiet --list coverage/lcov.info
    echo
    echo "Coverage has reduced to only" $ACTUAL "lines. This is lower than it was"
    echo "as of $LAST_UPDATE, when coverage was $TARGET_PERCENT%, covering $TARGET_LINES lines."
    echo "Please add sufficient tests to get coverage back to 100%, and update"
    echo "run_tests.sh to have the appropriate targets."
    echo
    echo "When in doubt, ask @Hixie for advice. Thanks!"
    exit 1
fi
rm -rf coverage
