#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# TODO(stuartmorgan): Replace this script either with flutter_plugin_tools
# functionality, or something pigeon-specific, to eliminate the need to have a
# bash copy of checked_changed_packages in this repository.
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
TEST_SCRIPT_NAME="run_tests.sh"

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
