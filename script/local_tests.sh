#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
TEST_SCRIPT_NAME="run_tests.sh"

source "$SCRIPT_DIR/common.sh"

check_changed_packages

for PACKAGE in $CHANGED_PACKAGE_LIST; do
  PACKAGE_PATH=./packages/$PACKAGE
  TEST_SCRIPT=$PACKAGE_PATH/$TEST_SCRIPT_NAME
  if [ -e $TEST_SCRIPT ]; then
    pushd $PWD
    cd $PACKAGE_PATH
    ls
    ./$TEST_SCRIPT_NAME
    popd
  fi
done
