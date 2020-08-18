set -e
cd $( dirname "${BASH_SOURCE[0]}" )
source ../../../helper/run_android_helper.sh

readonly BUNDLE="dev.flutter.imitation_game.smiley"
readonly TEST_NAME="smiley"

# TODO(gaaclarke): Get assembleRelease working.  I don't know if the performance
# is any different but assembleRelease requires signing the apk.
./gradlew assembleDebug
launch_apk ./app/build/outputs/apk/debug/app-debug.apk $BUNDLE "MainActivity"
sleep 10
MEMORY_TOTAL=`read_app_total_memory $BUNDLE`
report_results $TEST_NAME "android" "{\"adb_memory_total\":$MEMORY_TOTAL.0}"
