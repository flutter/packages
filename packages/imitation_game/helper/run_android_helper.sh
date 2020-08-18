report_results() 
{
  local TEST=$1
  local PLATFORM=$2
  local MEASUREMENTS=$3
  curl --header "Content-Type: application/json" \
    --request POST \
    --data "{\"test\":\"$TEST\",\"platform\":\"$PLATFORM\",\"results\":$MEASUREMENTS}" \
    http://localhost:4040
}

launch_apk()
{
  local APK_PATH=$1
  local BUNDLE_NAME=$2
  local ACTIVITY_NAME=$3
  adb install -r $APK_PATH
  adb shell am start -n $BUNDLE_NAME/$BUNDLE_NAME.$ACTIVITY_NAME
}

read_app_total_memory()
{
  local BUNDLE_NAME=$1
  adb shell dumpsys meminfo $BUNDLE_NAME | sed -n 's/.*TOTAL:[ ]*\([0-9]*\).*/\1/p'
}
