set -e
cd $( dirname "${BASH_SOURCE[0]}" )
source ../../../helper/run_android_helper.sh

readonly BUNDLE="dev.flutter.imitation_game.smiley"
readonly TEST_NAME="smiley"

./gradlew assembleRelease
launch_apk ./app/build/outputs/apk/release/app-release.apk $BUNDLE "MainActivity"
sleep 10
MEMORY_TOTAL=`read_app_total_memory $BUNDLE`
report_results $TEST_NAME "android" "{\"adb_memory_total\":$MEMORY_TOTAL.0}"
