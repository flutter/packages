###############################################################################
# run_tests.sh
#
# This runs all the different types of tests for pigeon.  It should be run from
# the directory that contains the script.
###############################################################################

# exit when any command fails
set -ex

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

###############################################################################
# Functions
###############################################################################

# Create a temporary directory in a way that works on both Linux and macOS.
#
# The mktemp commands have slighly semantics on the BSD systems vs GNU systems.
mktmpdir() {
  mktemp -d flutter_pigeon.XXXXXX 2>/dev/null || mktemp -d -t flutter_pigeon.
}

# test_pigeon_ios(<path to pigeon file>)
#
# Compiles the pigeon file to a temp directory and attempts to compile the code
# and runs the dart analyzer on the generated dart code.
test_pigeon_ios() {
  temp_dir=$(mktmpdir)

  pub run pigeon \
    --input $1 \
    --dart_out $temp_dir/pigeon.dart \
    --objc_header_out $temp_dir/pigeon.h \
    --objc_source_out $temp_dir/pigeon.m

  xcrun clang \
    -arch arm64 \
    -isysroot $(xcrun --sdk iphoneos --show-sdk-path) \
    -F $framework_path \
    -F $framework_path/Flutter.xcframework/ios-armv7_arm64 \
    -Werror \
    -fobjc-arc \
    -c $temp_dir/pigeon.m \
    -o $temp_dir/pigeon.o

  rm -rf $temp_dir
}

# test_pigeon_android(<path to pigeon file>)
#
# Compiles the pigeon file to a temp directory and attempts to compile the code.
test_pigeon_android() {
  temp_dir=$(mktmpdir)

  pub run pigeon \
    --input $1 \
    --dart_out $temp_dir/pigeon.dart \
    --java_out $temp_dir/Pigeon.java \

  if ! javac $temp_dir/Pigeon.java \
      -Xlint:unchecked \
      -classpath "$flutter_bin/cache/artifacts/engine/android-x64/flutter.jar"; then
    echo "javac $temp_dir/Pigeon.java failed"
    exit 1
  fi

  dartfmt -w $temp_dir/pigeon.dart
  dartanalyzer $temp_dir/pigeon.dart --fatal-infos --fatal-warnings --packages ./e2e_tests/test_objc/.packages

  rm -rf $temp_dir
}

# test_null_safe_dart(<path to pigeon file>)
#
# Compiles the pigeon file to a temp directory and attempts to run the dart
# analyzer on it with null safety turned on.
test_null_safe_dart() {
  temp_dir=$(mktmpdir)

  pub run pigeon \
    --input $1 \
    --dart_null_safety \
    --dart_out $temp_dir/pigeon.dart

  dartanalyzer $temp_dir/pigeon.dart --fatal-infos --fatal-warnings --packages ./e2e_tests/test_objc/.packages
  rm -rf $temp_dir
}

###############################################################################
# Dart analysis and unit tests
###############################################################################
pub get
dartanalyzer bin lib
pub run test test/

###############################################################################
# Execute without arguments test
###############################################################################
pub run pigeon 1> /dev/null

###############################################################################
# Mock handler flutter tests.
###############################################################################
pushd $PWD
pub run pigeon \
  --input pigeons/message.dart \
  --dart_out mock_handler_tester/test/message.dart \
  --dart_test_out mock_handler_tester/test/test.dart
dartfmt -w mock_handler_tester/test/message.dart
dartfmt -w mock_handler_tester/test/test.dart
cd mock_handler_tester
flutter test
popd

###############################################################################
# Compilation tests (Code is generated and compiled)
###############################################################################
# Make sure the artifacts are present.
flutter precache
# Make sure flutter dependencies are available.
pushd $PWD
cd e2e_tests/test_objc/
flutter pub get
popd
test_null_safe_dart ./pigeons/message.dart
test_pigeon_android ./pigeons/voidflutter.dart
test_pigeon_android ./pigeons/voidhost.dart
test_pigeon_android ./pigeons/host2flutter.dart
test_pigeon_android ./pigeons/message.dart
test_pigeon_android ./pigeons/void_arg_host.dart
test_pigeon_android ./pigeons/void_arg_flutter.dart
test_pigeon_android ./pigeons/list.dart
test_pigeon_android ./pigeons/all_datatypes.dart
test_pigeon_android ./pigeons/async_handlers.dart
test_pigeon_ios ./pigeons/message.dart
test_pigeon_ios ./pigeons/host2flutter.dart
test_pigeon_ios ./pigeons/voidhost.dart
test_pigeon_ios ./pigeons/voidflutter.dart
test_pigeon_ios ./pigeons/void_arg_host.dart
test_pigeon_ios ./pigeons/void_arg_flutter.dart
test_pigeon_ios ./pigeons/list.dart
test_pigeon_ios ./pigeons/all_datatypes.dart
# Not implemented yet.
# test_pigeon_ios ./pigeons/async_handlers.dart

###############################################################################
# iOS unit tests on generated code.
###############################################################################
pub run pigeon \
  --input pigeons/message.dart \
  --dart_out /dev/null \
  --objc_header_out platform_tests/ios_unit_tests/ios/Runner/messages.h \
  --objc_source_out platform_tests/ios_unit_tests/ios/Runner/messages.m
clang-format -i platform_tests/ios_unit_tests/ios/Runner/messages.h
clang-format -i platform_tests/ios_unit_tests/ios/Runner/messages.m
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

###############################################################################
# End-to-end (e2e) integration tests.
###############################################################################
DARTLE_H="e2e_tests/test_objc/ios/Runner/dartle.h"
DARTLE_M="e2e_tests/test_objc/ios/Runner/dartle.m"
DARTLE_DART="e2e_tests/test_objc/lib/dartle.dart"
PIGEON_JAVA="e2e_tests/test_objc/android/app/src/main/java/io/flutter/plugins/Pigeon.java"
pub run pigeon \
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

###############################################################################
# Run the formatter on generated code.
###############################################################################
cd ../..
pub global activate flutter_plugin_tools && pub global run flutter_plugin_tools format
