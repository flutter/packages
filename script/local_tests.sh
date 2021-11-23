#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# TODO(stuartmorgan): Replace this script with flutter_plugin_tools
# functionality, to eliminate the need to have a (less functional) bash copy of
# checked_changed_packages in this repository.
set -e

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly REPO_DIR="$(dirname "$SCRIPT_DIR")"
readonly LEGACY_TEST_SCRIPT_NAME="run_tests.sh"
readonly TEST_DART_PROGRAM_NAME="run_tests"

function check_changed_packages() {
  # Try get a merge base for the branch and calculate affected packages.
  # We need this check because some CIs can do a single branch clones with a limited history of commits.
  local packages
  local branch_base_sha="$(git merge-base --fork-point FETCH_HEAD HEAD || git merge-base FETCH_HEAD HEAD)"
  if [[ "$?" == 0 ]]; then
    echo "Checking for changed packages from $branch_base_sha"
    IFS=$'\n' packages=( $(git diff --name-only "$branch_base_sha" HEAD | grep -o "packages/[^/]*" | sed -e "s/packages\///g" | sort | uniq) )
  else
    error "Cannot find a merge base for the current branch to run an incremental build..."
    error "Please rebase your branch onto the latest master!"
    return 1
  fi

  # Filter out any packages that don't have a pubspec.yaml: they have probably
  # been deleted in this PR.
  CHANGED_PACKAGES=""
  CHANGED_PACKAGE_LIST=()
  for package in "${packages[@]}"; do
    if [[ -f "$REPO_DIR/packages/$package/pubspec.yaml" ]]; then
      CHANGED_PACKAGES="${CHANGED_PACKAGES},$package"
      CHANGED_PACKAGE_LIST=("${CHANGED_PACKAGE_LIST[@]}" "$package")
    fi
  done

  if [[ "${#CHANGED_PACKAGE_LIST[@]}" == 0 ]]; then
    echo "No changes detected in packages."
  else
    echo "Detected changes in the following ${#CHANGED_PACKAGE_LIST[@]} package(s):"
    for package in "${CHANGED_PACKAGE_LIST[@]}"; do
      echo "$package"
    done
    echo ""
  fi
  return 0
}

check_changed_packages

for PACKAGE in "${CHANGED_PACKAGE_LIST[@]}"; do
  echo ""
  echo "===================="
  echo $PACKAGE
  echo "===================="
  PACKAGE_PATH=./packages/$PACKAGE

  # Run the new script if it's present.
  TEST_SCRIPT=$PACKAGE_PATH/bin/$TEST_DART_PROGRAM_NAME.dart
  if [ -e $TEST_SCRIPT ]; then
    pushd $PWD
    cd $PACKAGE_PATH
    dart run ":$TEST_DART_PROGRAM_NAME"
    popd
  fi

  # Run the legacy script if it's present, unless on Windows.
  LEGACY_TEST_SCRIPT=$PACKAGE_PATH/$LEGACY_TEST_SCRIPT_NAME
  if [ -e $LEGACY_TEST_SCRIPT ]; then
    echo "$LEGACY_TEST_SCRIPT is deprecated. Please convert to $TEST_DART_PROGRAM_NAME.dart."
    echo ""
    if [[ "$OSTYPE" == "msys" ]]; then
      echo "$LEGACY_TEST_SCRIPT is not supported for Windows. Skipping."
    else
      pushd $PWD
      cd $PACKAGE_PATH
      ls
      ./$LEGACY_TEST_SCRIPT_NAME
      popd
    fi
  fi
done
