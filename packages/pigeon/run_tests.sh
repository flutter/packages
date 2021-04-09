###############################################################################
# run_tests.sh
#
# This runs all the different types of tests for pigeon.  It should be run from
# the directory that contains the script.
###############################################################################

# exit when any command fails
set -ex

JAVA_LINTER=checkstyle-8.41-all.jar
JAVA_FORMATTER=google-java-format-1.3-all-deps.jar
GOOGLE_CHECKS=google_checks.xml
GOOGLE_CHECKS_VERSION=7190c47ca5515ad8cb827bc4065ae7664d2766c1
JAVA_ERROR_PRONE=error_prone_core-2.5.1-with-dependencies.jar
DATAFLOW_SHADED=dataflow-shaded-3.7.1.jar
JFORMAT_STRING=jFormatString-3.0.0.jar
JAVA_VERSION=$(java -version 2>&1 | head -1 | cut -d'"' -f2 | sed '/^1\./s///' | cut -d'.' -f1)
JAVAC_JAR=javac-9+181-r4173-1.jar
if [ $JAVA_VERSION == "8" ]; then
  JAVAC_BOOTCLASSPATH="-J-Xbootclasspath/p:ci/$JAVAC_JAR"
else
  JAVAC_BOOTCLASSPATH=
fi

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
    --no-dart_null_safety \
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
    --java_package foo

  java -jar ci/$JAVA_FORMATTER --replace "$temp_dir/Pigeon.java"
  java -jar ci/$JAVA_LINTER -c "ci/$GOOGLE_CHECKS" "$temp_dir/Pigeon.java"
  if ! javac \
    $JAVAC_BOOTCLASSPATH \
    -XDcompilePolicy=simple \
    -processorpath "ci/$JAVA_ERROR_PRONE:ci/$DATAFLOW_SHADED:ci/$JFORMAT_STRING" \
    '-Xplugin:ErrorProne -Xep:CatchingUnchecked:ERROR' \
    -classpath "$flutter_bin/cache/artifacts/engine/android-x64/flutter.jar" \
    $temp_dir/Pigeon.java; then
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
    --dart_out $temp_dir/pigeon.dart

  dartanalyzer $temp_dir/pigeon.dart --fatal-infos --fatal-warnings --packages ./e2e_tests/test_objc/.packages
  rm -rf $temp_dir
}

###############################################################################
# Get java linter / formatter
###############################################################################
if [ ! -f "ci/$JAVA_LINTER" ]; then
  curl -L https://github.com/checkstyle/checkstyle/releases/download/checkstyle-8.41/$JAVA_LINTER > "ci/$JAVA_LINTER"
fi
if [ ! -f "ci/$JAVA_FORMATTER" ]; then
  curl -L https://github.com/google/google-java-format/releases/download/google-java-format-1.3/$JAVA_FORMATTER > "ci/$JAVA_FORMATTER"
fi
if [ ! -f "ci/$GOOGLE_CHECKS" ]; then
  curl -L https://raw.githubusercontent.com/checkstyle/checkstyle/$GOOGLE_CHECKS_VERSION/src/main/resources/$GOOGLE_CHECKS > "ci/$GOOGLE_CHECKS"
fi
if [ ! -f "ci/$JAVA_ERROR_PRONE" ]; then
  curl https://repo1.maven.org/maven2/com/google/errorprone/error_prone_core/2.5.1/$JAVA_ERROR_PRONE > "ci/$JAVA_ERROR_PRONE"
fi
if [ ! -f "ci/$DATAFLOW_SHADED" ]; then
  curl https://repo1.maven.org/maven2/org/checkerframework/dataflow-shaded/3.7.1/$DATAFLOW_SHADED > "ci/$DATAFLOW_SHADED"
fi
if [ ! -f "ci/$JFORMAT_STRING" ]; then
  curl https://repo1.maven.org/maven2/com/google/code/findbugs/jFormatString/3.0.0/$JFORMAT_STRING > "ci/$JFORMAT_STRING"
fi
if [ ! -f "ci/$JAVAC_JAR" ]; then
  curl https://repo1.maven.org/maven2/com/google/errorprone/javac/9+181-r4173-1/$JAVAC_JAR > "ci/$JAVAC_JAR"
fi


###############################################################################
# Dart analysis and unit tests
###############################################################################
pub get
dart analyze bin
dart analyze lib
dart test

###############################################################################
# Execute without arguments test
###############################################################################
pub run pigeon 1> /dev/null

###############################################################################
# Run unit tests on generated Dart code.
###############################################################################
pushd $PWD
pub run pigeon \
    --input pigeons/message.dart \
    --dart_out platform_tests/flutter_null_safe_unit_tests/lib/null_safe_pigeon.dart
cd platform_tests/flutter_null_safe_unit_tests
flutter pub get
flutter test test/null_safe_test.dart 
popd

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
test_pigeon_ios ./pigeons/async_handlers.dart
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

###############################################################################
# iOS unit tests on generated code.
###############################################################################
pub run pigeon \
  --no-dart_null_safety \
  --input pigeons/message.dart \
  --dart_out /dev/null \
  --objc_header_out platform_tests/ios_unit_tests/ios/Runner/messages.h \
  --objc_source_out platform_tests/ios_unit_tests/ios/Runner/messages.m
pub run pigeon \
  --no-dart_null_safety \
  --input pigeons/async_handlers.dart \
  --dart_out /dev/null \
  --objc_header_out platform_tests/ios_unit_tests/ios/Runner/async_handlers.h \
  --objc_source_out platform_tests/ios_unit_tests/ios/Runner/async_handlers.m
clang-format -i platform_tests/ios_unit_tests/ios/Runner/messages.h
clang-format -i platform_tests/ios_unit_tests/ios/Runner/messages.m
clang-format -i platform_tests/ios_unit_tests/ios/Runner/async_handlers.h
clang-format -i platform_tests/ios_unit_tests/ios/Runner/async_handlers.m
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
