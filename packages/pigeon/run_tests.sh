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
# Variables
###############################################################################
flutter=$(which flutter)
flutter_bin=$(dirname $flutter)
framework_path="$flutter_bin/cache/artifacts/engine/ios/"

java_linter=checkstyle-8.41-all.jar
java_formatter=google-java-format-1.3-all-deps.jar
google_checks=google_checks.xml
google_checks_version=7190c47ca5515ad8cb827bc4065ae7664d2766c1
java_error_prone=error_prone_core-2.5.1-with-dependencies.jar
dataflow_shaded=dataflow-shaded-3.7.1.jar
jformat_string=jFormatString-3.0.0.jar
java_version=$(java -version 2>&1 | head -1 | cut -d'"' -f2 | sed '/^1\./s///' | cut -d'.' -f1)
javac_jar=javac-9+181-r4173-1.jar
if [ $java_version == "8" ]; then
  javac_bootclasspath="-J-Xbootclasspath/p:ci/$javac_jar"
else
  javac_bootclasspath=
fi
run_pigeon="dart bin/pigeon.dart.dill --copyright_header ./copyright_header.txt"

###############################################################################
# Helper Functions
###############################################################################

# Create a temporary directory in a way that works on both Linux and macOS.
#
# The mktemp commands have slighly semantics on the BSD systems vs GNU systems.
mktmpdir() {
  mktemp -d flutter_pigeon.XXXXXX 2>/dev/null || mktemp -d -t flutter_pigeon.
}

# test_pigeon_android(<path to pigeon file>)
#
# Compiles the pigeon file to a temp directory and attempts to compile the java
# code.
# TODO(stuartmorgan): Remove this in favor of unit testing all files, which
# already includes compilation.
test_pigeon_android() {
  echo "test_pigeon_android($1)"
  temp_dir=$(mktmpdir)

  $run_pigeon \
    --input $1 \
    --dart_out $temp_dir/pigeon.dart \
    --java_out $temp_dir/Pigeon.java \
    --java_package foo

  java -jar ci/$java_formatter --replace "$temp_dir/Pigeon.java"
  java -jar ci/$java_linter -c "ci/$google_checks" "$temp_dir/Pigeon.java"
  if ! javac \
    $javac_bootclasspath \
    -XDcompilePolicy=simple \
    -processorpath "ci/$java_error_prone:ci/$dataflow_shaded:ci/$jformat_string" \
    '-Xplugin:ErrorProne -Xep:CatchingUnchecked:ERROR' \
    -classpath "$flutter_bin/cache/artifacts/engine/android-x64/flutter.jar" \
    $temp_dir/Pigeon.java; then
    echo "javac $temp_dir/Pigeon.java failed"
    exit 1
  fi

  rm -rf $temp_dir
}

# test_null_safe_dart(<path to pigeon file>)
#
# Compiles the pigeon file to a temp directory and attempts to run the dart
# analyzer on it.
# TODO(stuartmorgan): Remove this in favor of analyzing test_plugin.
test_pigeon_dart() {
  echo "test_pigeon_dart($1, $2)"
  local flutter_project_dir=$2

  $run_pigeon \
    --input $1 \
    --dart_out $flutter_project_dir/lib/pigeon.dart

  dart analyze $flutter_project_dir/lib/pigeon.dart --fatal-infos --fatal-warnings

  rm $flutter_project_dir/lib/pigeon.dart
}

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
get_java_linter_formatter() {
  if [ ! -f "ci/$java_linter" ]; then
    curl -L https://github.com/checkstyle/checkstyle/releases/download/checkstyle-8.41/$java_linter >"ci/$java_linter"
  fi
  if [ ! -f "ci/$java_formatter" ]; then
    curl -L https://github.com/google/google-java-format/releases/download/google-java-format-1.3/$java_formatter >"ci/$java_formatter"
  fi
  if [ ! -f "ci/$google_checks" ]; then
    curl -L https://raw.githubusercontent.com/checkstyle/checkstyle/$google_checks_version/src/main/resources/$google_checks >"ci/$google_checks"
  fi
  if [ ! -f "ci/$java_error_prone" ]; then
    curl https://repo1.maven.org/maven2/com/google/errorprone/error_prone_core/2.5.1/$java_error_prone >"ci/$java_error_prone"
  fi
  if [ ! -f "ci/$dataflow_shaded" ]; then
    curl https://repo1.maven.org/maven2/org/checkerframework/dataflow-shaded/3.7.1/$dataflow_shaded >"ci/$dataflow_shaded"
  fi
  if [ ! -f "ci/$jformat_string" ]; then
    curl https://repo1.maven.org/maven2/com/google/code/findbugs/jFormatString/3.0.0/$jformat_string >"ci/$jformat_string"
  fi
  if [ ! -f "ci/$javac_jar" ]; then
    curl https://repo1.maven.org/maven2/com/google/errorprone/javac/9+181-r4173-1/$javac_jar >"ci/$javac_jar"
  fi
}

run_dart_unittests() {
  dart run tool/run_tests.dart -t dart_unittests --skip-generation
}

test_command_line() {
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

run_macos_swift_unittests() {
  dart run tool/run_tests.dart -t mac_swift_unittests --skip-generation
}

run_android_kotlin_unittests() {
  dart run tool/run_tests.dart -t android_kotlin_unittests --skip-generation
}

run_dart_compilation_tests() {
  local temp_dir=$(mktmpdir)
  local flutter_project_dir=$temp_dir/project

  flutter create --platforms="android" $flutter_project_dir 1> /dev/null

  test_pigeon_dart ./pigeons/all_void.dart $flutter_project_dir
  test_pigeon_dart ./pigeons/async_handlers.dart $flutter_project_dir
  test_pigeon_dart ./pigeons/host2flutter.dart $flutter_project_dir
  test_pigeon_dart ./pigeons/list.dart $flutter_project_dir
  test_pigeon_dart ./pigeons/message.dart $flutter_project_dir
  test_pigeon_dart ./pigeons/void_arg_flutter.dart $flutter_project_dir
  test_pigeon_dart ./pigeons/void_arg_host.dart $flutter_project_dir
  test_pigeon_dart ./pigeons/voidflutter.dart $flutter_project_dir
  test_pigeon_dart ./pigeons/voidhost.dart $flutter_project_dir

  rm -rf $temp_dir
}

run_ios_unittests() {
  pushd $PWD
  cd platform_tests/ios_unit_tests
  flutter build ios --simulator
  cd ios
  xcodebuild \
    -workspace Runner.xcworkspace \
    -scheme RunnerTests \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 8' \
    test
  popd
}

run_ios_e2e_tests() {
  DARTLE_H="e2e_tests/test_objc/ios/Runner/dartle.h"
  DARTLE_M="e2e_tests/test_objc/ios/Runner/dartle.m"
  DARTLE_DART="e2e_tests/test_objc/lib/dartle.dart"
  $run_pigeon \
    --input pigeons/message.dart \
    --dart_out $DARTLE_DART \
    --objc_header_out $DARTLE_H \
    --objc_source_out $DARTLE_M \
  dart format $DARTLE_DART

  pushd $PWD
  cd e2e_tests/test_objc
  flutter build ios -t test_driver/e2e_test.dart --simulator
  # TODO(gaaclarke): Transition to integration_test. `e2e` has been deprecated
  # and has stopped working.
  # cd ios
  # xcodebuild \
  #   -workspace Runner.xcworkspace \
  #   -scheme RunnerTests \
  #   -sdk iphonesimulator \
  #   -destination 'platform=iOS Simulator,name=iPhone 8' \
  #   test
  popd
}

run_android_unittests() {
  pushd $PWD
  cd platform_tests/alternate_language_test_plugin/example
  if [ ! -f "android/gradlew" ]; then
    flutter build apk --debug
  fi
  cd android
  ./gradlew test
  popd
}

###############################################################################
# main
###############################################################################
should_run_android_unittests=true
should_run_dart_compilation_tests=true
should_run_dart_unittests=true
should_run_flutter_unittests=true
should_run_ios_e2e_tests=true
should_run_ios_unittests=true
should_run_ios_swift_unittests=true
should_run_mock_handler_tests=true
should_run_macos_swift_unittests=true
should_run_android_kotlin_unittests=true
while getopts "t:l?h" opt; do
  case $opt in
  t)
    should_run_android_unittests=false
    should_run_dart_compilation_tests=false
    should_run_dart_unittests=false
    should_run_flutter_unittests=false
    should_run_ios_e2e_tests=false
    should_run_ios_unittests=false
    should_run_ios_swift_unittests=false
    should_run_mock_handler_tests=false
    should_run_macos_swift_unittests=false
    should_run_android_kotlin_unittests=false
    case $OPTARG in
    # TODO(stuartmorgan): Rename to include "java".
    android_unittests) should_run_android_unittests=true ;;
    dart_compilation_tests) should_run_dart_compilation_tests=true ;;
    dart_unittests) should_run_dart_unittests=true ;;
    flutter_unittests) should_run_flutter_unittests=true ;;
    ios_e2e_tests) should_run_ios_e2e_tests=true ;;
    # TODO(stuartmorgan): Rename to include "objc".
    ios_unittests) should_run_ios_unittests=true ;;
    ios_swift_unittests) should_run_ios_swift_unittests=true ;;
    mock_handler_tests) should_run_mock_handler_tests=true ;;
    macos_swift_unittests) should_run_macos_swift_unittests=true ;;
    android_kotlin_unittests) should_run_android_kotlin_unittests=true ;;
    *)
      echo "unrecognized test: $OPTARG"
      exit 1
      ;;
    esac
    ;;
  l)
    echo "available tests for -t:
  android_unittests        - Unit tests on generated Java code.
  android_kotlin_unittests - Unit tests on generated Kotlin code on Android.
  dart_compilation_tests   - Compilation tests on generated Dart code.
  dart_unittests           - Unit tests on and analysis on Pigeon's implementation.
  flutter_unittests        - Unit tests on generated Dart code.
  ios_e2e_tests            - End-to-end objc tests run on iOS Simulator
  ios_unittests            - Unit tests on generated Objc code.
  ios_swift_unittests      - Unit tests on generated Swift code.
  mock_handler_tests       - Unit tests on generated Dart mock handler code.
  macos_swift_unittests    - Unit tests on generated Swift code on macOS.
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
dart --snapshot-kind=kernel --snapshot=bin/pigeon.dart.dill bin/pigeon.dart

# Pre-generate platform_test output files, which most tests rely on existing.
dart run tool/generate.dart

if [ "$should_run_android_unittests" = true ]; then
  get_java_linter_formatter
fi
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
if [ "$should_run_dart_compilation_tests" = true ]; then
  run_dart_compilation_tests
fi
if [ "$should_run_ios_unittests" = true ]; then
  run_ios_unittests
fi
if [ "$should_run_ios_swift_unittests" = true ]; then
  run_ios_swift_unittests
fi
if [ "$should_run_ios_e2e_tests" = true ]; then
  run_ios_e2e_tests
fi
if [ "$should_run_android_unittests" = true ]; then
  run_android_unittests
fi
if [ "$should_run_macos_swift_unittests" = true ]; then
  run_macos_swift_unittests
fi
if [ "$should_run_android_kotlin_unittests" = true ]; then
  run_android_kotlin_unittests
fi
