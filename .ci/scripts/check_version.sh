#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
set -e

# For pre-submit, this is currently run in Cirrus; see TODO below.
# For post-submit, ignore platform interface breaking version changes and
# missing version/CHANGELOG detection since PR-level overrides aren't available
# in post-submit.
if [[ $LUCI_PR == "" ]]; then
  ./script/tool_runner.sh version-check --ignore-platform-interface-breaks
else
  # TODO(stuartmorgan): Migrate this check from Cirrus. See
  # https://github.com/flutter/flutter/issues/130076
  :
fi
