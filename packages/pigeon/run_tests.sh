#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

###############################################################################
# run_tests.sh
#
# This runs all the different types of tests for pigeon.  It should be run from
# the directory that contains the script.
###############################################################################

# exit when any command fails
set -e

###############################################################################
# Helper Functions
###############################################################################

print_usage() {
  echo "usage: ./run_tests.sh [-l] [-t test_name]

flags:
  -t test_name: Run only specified test.
  -l          : List available tests.
"
}

###############################################################################
# Stages
###############################################################################
run_dart_unittests() {
  dart run tool/run_tests.dart -t dart_unittests --skip-generation
}

test_command_line() {
  dart --snapshot-kind=kernel --snapshot=bin/pigeon.dart.dill bin/pigeon.dart
  run_pigeon="dart bin/pigeon.dart.dill --copyright_header ./copyright_header.txt"
  # Test with no arguments.
  $run_pigeon 1>/dev/null
  # Test one_language flag. With this flag specified, java_out can be generated
  # without dart_out.
  $run_pigeon \
    --input pigeons/message.dart \
    --one_language \
    --java_out stdout \
    | grep "public class Message">/dev/null
  # Test dartOut in ConfigurePigeon overrides output.
  $run_pigeon --input pigeons/configure_pigeon_dart_out.dart 1>/dev/null
  # Make sure AST generation exits correctly.
  $run_pigeon --input pigeons/message.dart --one_language --ast_out /dev/null
}

run_flutter_unittests() {
  dart run tool/run_tests.dart -t flutter_unittests --skip-generation
}

run_mock_handler_tests() {
  dart run tool/run_tests.dart -t mock_handler_tests --skip-generation
}

run_ios_swift_unittests() {
  dart run tool/run_tests.dart -t ios_swift_unittests --skip-generation
}

run_ios_swift_e2e_tests() {
  dart run tool/run_tests.dart -t ios_swift_integration_tests --skip-generation
}

run_macos_swift_unittests() {
  dart run tool/run_tests.dart -t macos_swift_unittests --skip-generation
}

run_macos_swift_e2e_tests() {
  dart run tool/run_tests.dart -t macos_swift_integration_tests --skip-generation
}

run_android_kotlin_unittests() {
  dart run tool/run_tests.dart -t android_kotlin_unittests --skip-generation
}

run_android_kotlin_e2e_tests() {
  dart run tool/run_tests.dart -t android_kotlin_integration_tests --skip-generation
}

run_ios_objc_unittests() {
  dart run tool/run_tests.dart -t ios_objc_unittests --skip-generation
}

# TODO(stuartmorgan): Remove once run_ios_objc_unittests works in CI; see
# related TODOs below.
run_ios_legacy_unittests() {
  dart run tool/run_tests.dart -t ios_objc_legacy_unittests --skip-generation
}

run_ios_objc_e2e_tests() {
  dart run tool/run_tests.dart -t ios_objc_integration_tests --skip-generation
}

run_android_unittests() {
  dart run tool/run_tests.dart -t android_java_unittests --skip-generation
}

run_android_java_e2e_tests() {
  dart run tool/run_tests.dart -t android_java_integration_tests --skip-generation
}

###############################################################################
# main
###############################################################################
should_run_android_unittests=true
should_run_dart_unittests=true
should_run_flutter_unittests=true
# TODO(stuartmorgan): Enable by default once CI issues are solved; see
# https://github.com/flutter/packages/pull/2816.
should_run_ios_objc_e2e_tests=false
# TODO(stuartmorgan): Enable the new version by default and remove the legacy
# version once CI issues are solved; see
# https://github.com/flutter/packages/pull/2816.
should_run_ios_objc_unittests=false
should_run_ios_legacy_unittests=true
should_run_ios_swift_unittests=true
# Currently these are testing exactly the same thing as macos_swift_e2e_tests,
# so we don't need to run both by default. This should become `true` if any
# iOS-only tests are added (e.g., for a feature not supported by macOS).
should_run_ios_swift_e2e_tests=false
should_run_mock_handler_tests=true
should_run_macos_swift_unittests=true
should_run_macos_swift_e2e_tests=true
should_run_android_kotlin_unittests=true
# Default to false until there is CI support. See
# https://github.com/flutter/flutter/issues/111505
should_run_android_java_e2e_tests=false
should_run_android_kotlin_e2e_tests=false
while getopts "t:l?h" opt; do
  case $opt in
  t)
    should_run_android_unittests=false
    should_run_dart_unittests=false
    should_run_flutter_unittests=false
    should_run_ios_objc_unittests=false
    should_run_ios_objc_e2e_tests=false
    should_run_ios_legacy_unittests=false
    should_run_ios_swift_unittests=false
    should_run_ios_swift_e2e_tests=false
    should_run_mock_handler_tests=false
    should_run_macos_swift_unittests=false
    should_run_macos_swift_e2e_tests=false
    should_run_android_kotlin_unittests=false
    should_run_android_java_e2e_tests=false
    should_run_android_kotlin_e2e_tests=false
    case $OPTARG in
    # TODO(stuartmorgan): Rename to include "java".
    android_unittests) should_run_android_unittests=true ;;
    android_java_e2e_tests) should_run_android_java_e2e_tests=true ;;
    dart_unittests) should_run_dart_unittests=true ;;
    flutter_unittests) should_run_flutter_unittests=true ;;
    ios_objc_e2e_tests) should_run_ios_objc_e2e_tests=true ;;
    ios_objc_unittests) should_run_ios_objc_unittests=true ;;
    ios_unittests) should_run_ios_legacy_unittests=true ;;
    ios_swift_unittests) should_run_ios_swift_unittests=true ;;
    ios_swift_e2e_tests) should_run_ios_swift_e2e_tests=true ;;
    mock_handler_tests) should_run_mock_handler_tests=true ;;
    macos_swift_unittests) should_run_macos_swift_unittests=true ;;
    macos_swift_e2e_tests) should_run_macos_swift_e2e_tests=true ;;
    android_kotlin_unittests) should_run_android_kotlin_unittests=true ;;
    android_kotlin_e2e_tests) should_run_android_kotlin_e2e_tests=true ;;
    *)
      echo "unrecognized test: $OPTARG"
      exit 1
      ;;
    esac
    ;;
  l)
    echo "available tests for -t:
  android_unittests        - Unit tests on generated Java code.
  android_java_e2e_tests   - Integration tests on generated Java code on Android.
  android_kotlin_unittests - Unit tests on generated Kotlin code on Android.
  android_kotlin_e2e_tests - Integration tests on generated Kotlin code on Android.
  dart_unittests           - Unit tests on and analysis on Pigeon's implementation.
  flutter_unittests        - Unit tests and analysis on generated Dart code.
  ios_objc_unittests       - Unit tests on generated Obj-C code.
  ios_unittests            - Legacy unit tests on generated Obj-C code. Use ios_objc_unittests instead.
  ios_objc_e2e_tests       - Integration tests on generated Obj-C code.
  ios_swift_unittests      - Unit tests on generated Swift code.
  ios_swift_e2e_tests      - Integration tests on generated Swift code on iOS.
  mock_handler_tests       - Unit tests on generated Dart mock handler code.
  macos_swift_unittests    - Unit tests on generated Swift code on macOS.
  macos_swift_e2e_tests    - Integration tests on generated Swift code on macOS.
  "
    exit 1
    ;;
  \h)
    print_usage
    exit 1
    ;;
  \?)
    print_usage
    exit 1
    ;;
  ?)
    print_usage
    exit 1
    ;;
  esac
done

##############################################################################
dart pub get

# Pre-generate platform_test output files, which most tests rely on existing.
dart run tool/generate.dart

test_command_line
if [ "$should_run_dart_unittests" = true ]; then
  run_dart_unittests
fi
if [ "$should_run_flutter_unittests" = true ]; then
  run_flutter_unittests
fi
if [ "$should_run_mock_handler_tests" = true ]; then
  run_mock_handler_tests
fi
if [ "$should_run_ios_objc_unittests" = true ]; then
  run_ios_objc_unittests
fi
if [ "$should_run_ios_legacy_unittests" = true ]; then
  run_ios_legacy_unittests
fi
if [ "$should_run_ios_swift_unittests" = true ]; then
  run_ios_swift_unittests
fi
if [ "$should_run_ios_swift_e2e_tests" = true ]; then
  run_ios_swift_e2e_tests
fi
if [ "$should_run_ios_objc_e2e_tests" = true ]; then
  run_ios_objc_e2e_tests
fi
if [ "$should_run_android_unittests" = true ]; then
  run_android_unittests
fi
if [ "$should_run_android_java_e2e_tests" = true ]; then
  run_android_java_e2e_tests
fi
if [ "$should_run_macos_swift_unittests" = true ]; then
  run_macos_swift_unittests
fi
if [ "$should_run_macos_swift_e2e_tests" = true ]; then
  run_macos_swift_e2e_tests
fi
if [ "$should_run_android_kotlin_unittests" = true ]; then
  run_android_kotlin_unittests
fi
if [ "$should_run_android_kotlin_e2e_tests" = true ]; then
  run_android_kotlin_e2e_tests
fi
