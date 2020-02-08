# exit when any command fails
set -e

flutter=$(which flutter)
flutter_bin=$(dirname $flutter)
framework_path="$flutter_bin/cache/artifacts/engine/ios/"

test_pigeon_ios() {
  temp_dir=$(mktemp -d -t pigeon)

  pub run pigeon \
    --input $1 \
    --dart_out $temp_dir/pigeon.dart \
    --objc_header_out $temp_dir/pigeon.h \
    --objc_source_out $temp_dir/pigeon.m

  xcrun clang \
    -arch arm64 \
    -isysroot $(xcrun --sdk iphoneos --show-sdk-path) \
    -F $framework_path \
    -Werror \
    -c $temp_dir/pigeon.m \
    -o $temp_dir/pigeon.o

  dartfmt -w $temp_dir/pigeon.dart
  if [ -e "e2e_tests" ]; then
    dartanalyzer $temp_dir/pigeon.dart --packages ./e2e_tests/test_objc/.packages
  fi
  rm -rf $temp_dir
}

pub run test test/
test_pigeon_ios ./pigeons/message.dart
test_pigeon_ios ./pigeons/host2flutter.dart

# e2e tests are not checked in until some issues can be worked out with e2e.
if [ -e "e2e_tests" ]; then
  DARTLE_H="e2e_tests/test_objc/ios/Runner/dartle.h"
  DARTLE_M="e2e_tests/test_objc/ios/Runner/dartle.m"
  DARTLE_DART="e2e_tests/test_objc/lib/dartle.dart"
  pub run pigeon \
    --input pigeons/message.dart \
    --dart_out $DARTLE_DART \
    --objc_header_out $DARTLE_H \
    --objc_source_out $DARTLE_M
  dartfmt -w $DARTLE_DART
  cd e2e_tests/test_objc

  flutter build ios -t test/e2e_test.dart --simulator
  cd ios
  xcodebuild \
    -workspace Runner.xcworkspace \
    -scheme RunnerTests \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 8' \
    test | xcpretty
fi
