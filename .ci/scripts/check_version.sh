#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
set -e

# For pre-submit, check for missing or breaking changes that don't have a
# corresponding override label.
# For post-submit, ignore platform interface breaking version changes and
# missing version/CHANGELOG detection since PR-level overrides aren't available
# in post-submit.
if [[ $LUCI_PR == "" ]]; then
  .ci/scripts/tool_runner.sh version-check --ignore-platform-interface-breaks
else
  .ci/scripts/tool_runner.sh version-check --check-for-missing-changes --pr-labels="$PR_OVERRIDE_LABELS"
fi
