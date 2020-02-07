# exit when any command fails
set -e

pub run test test/

# cd build
# make
# ./dartle --input ../dartles/simple.dartle --dart_out dartle.dart --objc_header_out dartle.h --objc_source_out dartle.m
# cd ..
# cp build/dartle.h tests/test_objc/ios/Runner/
# cp build/dartle.m tests/test_objc/ios/Runner/
# cp build/dartle.dart tests/test_objc/lib/

# e2e tests are disabled while I work to fix iOS e2e.
# DARTLE_H="e2e_tests/test_objc/ios/Runner/dartle.h"
# DARTLE_M="e2e_tests/test_objc/ios/Runner/dartle.m"
# DARTLE_DART="e2e_tests/test_objc/lib/dartle.dart"
# pub run pigeon \
#   --input pigeons/message.dart \
#   --dart_out $DARTLE_DART \
#   --objc_header_out $DARTLE_H \
#   --objc_source_out $DARTLE_M
# dartfmt -w $DARTLE_DART
# cd e2e_tests/test_objc

#############################################
# Uncomment to just launch the app.
#############################################
# open -a Simulator
# flutter run
# exit

# flutter build ios -t test/e2e_test.dart --simulator
# cd ios
# xcodebuild \
#   -workspace Runner.xcworkspace \
#   -scheme RunnerTests \
#   -sdk iphonesimulator \
#   -destination 'platform=iOS Simulator,name=iPhone 8' \
#   test | xcpretty
