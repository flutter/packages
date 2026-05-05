#!/bin/bash
# .agents/hooks/dart_format.sh

if [ ! -t 0 ]; then
  cat > /dev/null
fi

# Optimization: Only run if there are staged or modified .dart files
if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  MODIFIED_DART=$(git status --porcelain | grep -E '\.dart$')
  if [ -z "$MODIFIED_DART" ]; then
    echo "{}"
    exit 0
  fi
fi

# Run Formatting (quietly)
dart format . > /dev/null 2>&1

echo "{}"
