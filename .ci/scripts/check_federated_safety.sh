#!/bin/bash
# Copyright 2013 The Flutter Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
set -e

if [[ $LUCI_PR == "" ]]; then
  echo "This check is only run in presubmit"
else
  .ci/scripts/tool_runner.sh federation-safety-check
fi
