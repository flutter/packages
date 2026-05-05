#!/bin/bash
# .agents/hooks/dart_analyze.sh

LOGFILE="/tmp/jetski_hooks.log"
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PROJECT_ROOT=$(cd "$SCRIPT_DIR/../.." && pwd)

echo "[$(date)] dart_analyze.sh started in $PWD" >> "$LOGFILE"
echo "[$(date)] Project root: $PROJECT_ROOT" >> "$LOGFILE"

cd "$PROJECT_ROOT" || exit 1

if [ ! -t 0 ]; then
  cat > /dev/null
fi

# Run Analysis and capture output
echo "[$(date)] Running dart analyze" >> "$LOGFILE"
ANALYSIS_OUTPUT=$(dart analyze --fatal-infos 2>&1)
EXIT_CODE=$?

# If exit code is 0 (no issues), allow the agent to stop
if [ $EXIT_CODE -eq 0 ]; then
  echo "[$(date)] Analysis passed" >> "$LOGFILE"
  echo '{"decision": "stop"}'
  exit 0
fi

# If there are issues, tell Jetski to CONTINUE and provide the reason
echo "[$(date)] Analysis failed with code $EXIT_CODE" >> "$LOGFILE"
REASON="Analyzer issues found. Please fix these before finishing:\n\n$ANALYSIS_OUTPUT"

# Use python3 to safely JSON-escape the multi-line string
python3 -c "import json, sys; print(json.dumps({'decision': 'continue', 'reason': sys.argv[1]}))" "$REASON"
