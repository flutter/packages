#!/bin/bash
# Copyright 2013 The Flutter Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# .agents/hooks/dart_format.sh

LOGFILE="/tmp/jetski_hooks.log"
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PROJECT_ROOT=$(cd "$SCRIPT_DIR/../.." && pwd)

echo "[$(date)] dart_format.sh started in $PWD" >> "$LOGFILE"
echo "[$(date)] Project root: $PROJECT_ROOT" >> "$LOGFILE"

cd "$PROJECT_ROOT" || exit 1

if [ ! -t 0 ]; then
  cat > /dev/null
fi

# Optimization: Only run if there are modified .dart files
if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  MODIFIED_DART=$(git status --porcelain | grep -E '\.dart$')
  if [ -z "$MODIFIED_DART" ]; then
    echo "[$(date)] No modified dart files, exiting" >> "$LOGFILE"
    echo "{}"
    exit 0
  fi
fi

# Explicitly write changes and hide output in Jetski
echo "[$(date)] Running dart format" >> "$LOGFILE"
dart format --output=write . >> "$LOGFILE" 2>&1

echo "[$(date)] dart_format.sh finished" >> "$LOGFILE"
echo "{}"
