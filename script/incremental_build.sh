#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/common.sh"

# Set some default actions if run without arguments.
ACTIONS=("$@")
if [[ "${#ACTIONS[@]}" == 0 ]]; then
  ACTIONS=("test" "analyze" "java-test")
fi

BRANCH_NAME="${BRANCH_NAME:-"$(git rev-parse --abbrev-ref HEAD)"}"

if [[ "${BRANCH_NAME}" != "master" ]]; then
  # Sets CHANGED_PACKAGES
  check_changed_packages
fi

if [[ "$CHANGED_PACKAGES" == "" ]]; then
  echo "Running for all packages"
  if [[ grep -q "flutter" "${REPO_DIR}/pubspec.yaml"]]; then
    (cd "$REPO_DIR" && pub global run flutter_plugin_tools "${ACTIONS[@]}" $BUILD_SHARDING)
  else 
    (cd "$REPO_DIR" && dartanalyzer . && pub get && pub run test && pub publish --dry-run)
  fi
else
  echo "Running for ${CHANGED_PACKAGES}"
  if [[ grep -q "flutter" "${REPO_DIR}/pubspec.yaml"]]; then    
    (cd "$REPO_DIR" && pub global run flutter_plugin_tools "${ACTIONS[@]}" --plugins="$CHANGED_PACKAGES" $BUILD_SHARDING)
  else
    (cd "$REPO_DIR" && dartanalyzer . && pub get && pub run test && pub publish --dry-run)
  fi
fi
