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

# TODO(blasten): Enable on stable when possible.
# https://github.com/flutter/flutter/issues/75187
if [[ "$CHANNEL" == "stable" ]]; then
  exit 0
fi

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
# analyzer on it with and without null safety turned on.
test_pigeon_dart() {
  echo "test_pigeon_dart($1)"
  temp_dir_1=$(mktmpdir)
  temp_dir_2=$(mktmpdir)

  $run_pigeon \
    --input $1 \
    --dart_out $temp_dir_1/pigeon.dart &
  null_safe_gen_pid=$!

  $run_pigeon \
    --no-dart_null_safety \
    --input $1 \
    --dart_out $temp_dir_2/pigeon.dart &
  non_null_safe_gen_pid=$!

  wait $null_safe_gen_pid
  wait $non_null_safe_gen_pid

  # `./e2e_tests/test_objc/.packages` is used to get access to Flutter since
  # Pigeon doesn't depend on Flutter.
  dartanalyzer $temp_dir_1/pigeon.dart --fatal-infos --fatal-warnings --packages ./e2e_tests/test_objc/.packages &
  null_safe_analyze_pid=$!
  dartanalyzer $temp_dir_2/pigeon.dart --fatal-infos --fatal-warnings --packages ./e2e_tests/test_objc/.packages &
  non_null_safe_analyze_pid=$!

  wait $null_safe_analyze_pid
  wait $non_null_safe_analyze_pid

  rm -rf $temp_dir_1
  rm -rf $temp_dir_2
}

print_usage() {
  echo "usage: ./run_tests.sh [-l] [-t test_name]

flags:
  -t test_name: Run only specified test.
  -l          : List available tests.
"
}

gen_ios_unittests_code() {
  local input=$1
  local prefix=$2
  local filename=${input##*/}
  local name="${filename%.dart}"
  $run_pigeon \
    --input $input \
    --objc_prefix "$prefix" \
    --dart_out /dev/null \
    --objc_header_out platform_tests/ios_unit_tests/ios/Runner/$name.gen.h \
    --objc_source_out platform_tests/ios_unit_tests/ios/Runner/$name.gen.m
}

gen_android_unittests_code() {
  local input=$1
  local javaName=$2
  local javaOut="platform_tests/android_unit_tests/android/app/src/main/java/com/example/android_unit_tests/$javaName.java"
  $run_pigeon \
    --input $input \
    --dart_out /dev/null \
    --java_out $javaOut \
    --java_package "com.example.android_unit_tests"

  java -jar ci/$java_formatter --replace $javaOut
  java -jar ci/$java_linter -c "ci/$google_checks" "$javaOut"
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
  dart analyze bin
  dart analyze lib
  dart test
}

test_running_without_arguments() {
  $run_pigeon 1>/dev/null
}

run_flutter_unittests() {
  pushd $PWD
  $run_pigeon \
    --input pigeons/flutter_unittests.dart \
    --dart_out platform_tests/flutter_null_safe_unit_tests/lib/null_safe_pigeon.dart
  $run_pigeon \
    --input pigeons/all_datatypes.dart \
    --dart_out platform_tests/flutter_null_safe_unit_tests/lib/all_datatypes.dart
  cd platform_tests/flutter_null_safe_unit_tests
  flutter pub get
  flutter test test/null_safe_test.dart
  flutter test test/all_datatypes_test.dart
  popd
}

run_mock_handler_tests() {
  pushd $PWD
  $run_pigeon \
    --input pigeons/message.dart \
    --dart_out mock_handler_tester/test/message.dart \
    --dart_test_out mock_handler_tester/test/test.dart
  dartfmt -w mock_handler_tester/test/message.dart
  dartfmt -w mock_handler_tester/test/test.dart
  cd mock_handler_tester
  flutter test
  popd
}

run_dart_compilation_tests() {
  # DEPRECATED: These tests are deprecated, use run_flutter_unittests instead.
  # Make sure the artifacts are present.
  flutter precache
  # Make sure flutter dependencies are available.
  pushd $PWD
  cd e2e_tests/test_objc/
  flutter pub get
  popd
  test_pigeon_dart ./pigeons/async_handlers.dart
  test_pigeon_dart ./pigeons/host2flutter.dart
  test_pigeon_dart ./pigeons/list.dart
  test_pigeon_dart ./pigeons/message.dart
  test_pigeon_dart ./pigeons/void_arg_flutter.dart
  test_pigeon_dart ./pigeons/void_arg_host.dart
  test_pigeon_dart ./pigeons/voidflutter.dart
  test_pigeon_dart ./pigeons/voidhost.dart
}

run_ios_unittests() {
  gen_ios_unittests_code ./pigeons/all_datatypes.dart ""
  gen_ios_unittests_code ./pigeons/async_handlers.dart ""
  gen_ios_unittests_code ./pigeons/enum.dart "AC"
  gen_ios_unittests_code ./pigeons/host2flutter.dart ""
  gen_ios_unittests_code ./pigeons/list.dart "LST"
  gen_ios_unittests_code ./pigeons/message.dart ""
  gen_ios_unittests_code ./pigeons/void_arg_flutter.dart "VAF"
  gen_ios_unittests_code ./pigeons/void_arg_host.dart "VAH"
  gen_ios_unittests_code ./pigeons/voidflutter.dart "VF"
  gen_ios_unittests_code ./pigeons/voidhost.dart "VH"
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
  PIGEON_JAVA="e2e_tests/test_objc/android/app/src/main/java/io/flutter/plugins/Pigeon.java"
  $run_pigeon \
    --input pigeons/message.dart \
    --dart_out $DARTLE_DART \
    --objc_header_out $DARTLE_H \
    --objc_source_out $DARTLE_M \
    --java_out $PIGEON_JAVA
  dartfmt -w $DARTLE_DART

  pushd $PWD
  cd e2e_tests/test_objc
  flutter build ios -t test_driver/e2e_test.dart --simulator
  cd ios
  xcodebuild \
    -workspace Runner.xcworkspace \
    -scheme RunnerTests \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 8' \
    test
  popd
}

run_formatter() {
  cd ../..
  pub global activate flutter_plugin_tools && pub global run flutter_plugin_tools format 2>/dev/null
}

run_android_unittests() {
  pushd $PWD
  gen_android_unittests_code ./pigeons/all_datatypes.dart AllDatatypes
  gen_android_unittests_code ./pigeons/android_unittests.dart Pigeon
  gen_android_unittests_code ./pigeons/async_handlers.dart AsyncHandlers
  gen_android_unittests_code ./pigeons/host2flutter.dart Host2Flutter
  gen_android_unittests_code ./pigeons/java_double_host_api.dart JavaDoubleHostApi
  gen_android_unittests_code ./pigeons/list.dart PigeonList
  gen_android_unittests_code ./pigeons/message.dart MessagePigeon
  gen_android_unittests_code ./pigeons/void_arg_flutter.dart VoidArgFlutter
  gen_android_unittests_code ./pigeons/void_arg_host.dart VoidArgHost
  gen_android_unittests_code ./pigeons/voidflutter.dart VoidFlutter
  gen_android_unittests_code ./pigeons/voidhost.dart VoidHost
  cd platform_tests/android_unit_tests
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
should_run_formatter=true
should_run_ios_e2e_tests=true
should_run_ios_unittests=true
should_run_mock_handler_tests=true
while getopts "t:l?h" opt; do
  case $opt in
  t)
    should_run_android_unittests=false
    should_run_dart_compilation_tests=false
    should_run_dart_unittests=false
    should_run_flutter_unittests=false
    should_run_formatter=false
    should_run_ios_e2e_tests=false
    should_run_ios_unittests=false
    should_run_mock_handler_tests=false
    case $OPTARG in
    android_unittests) should_run_android_unittests=true ;;
    dart_compilation_tests) should_run_dart_compilation_tests=true ;;
    dart_unittests) should_run_dart_unittests=true ;;
    flutter_unittests) should_run_flutter_unittests=true ;;
    ios_e2e_tests) should_run_ios_e2e_tests=true ;;
    ios_unittests) should_run_ios_unittests=true ;;
    mock_handler_tests) should_run_mock_handler_tests=true ;;
    *)
      echo "unrecognized test: $OPTARG"
      exit 1
      ;;
    esac
    ;;
  l)
    echo "available tests for -t:
  android_unittests      - Unit tests on generated Java code.
  dart_compilation_tests - Compilation tests on generated Dart code.
  dart_unittests         - Unit tests on and analysis on Pigeon's implementation.
  flutter_unittests      - Unit tests on generated Dart code.
  ios_e2e_tests          - End-to-end objc tests run on iOS Simulator
  ios_unittests          - Unit tests on generated Objc code.
  mock_handler_tests     - Unit tests on generated Dart mock handler code.
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
pub get
dart --snapshot-kind=kernel --snapshot=bin/pigeon.dart.dill bin/pigeon.dart
if [ "$should_run_android_unittests" = true ]; then
  get_java_linter_formatter
fi
test_running_without_arguments
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
if [ "$should_run_ios_e2e_tests" = true ]; then
  run_ios_e2e_tests
fi
if [ "$should_run_android_unittests" = true ]; then
  run_android_unittests
fi
if [ "$should_run_formatter" = true ]; then
  run_formatter
fi
