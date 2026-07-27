#!/bin/bash
# Replaces global scripts with a trap to detect forbidden usage
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../../" && pwd)"

# Trap validate.sh
echo '#!/bin/bash' > "$REPO_ROOT/.ci/scripts/validate.sh"
echo 'touch "$REPO_ROOT/USED_FORBIDDEN_SCRIPT.txt"' >> "$REPO_ROOT/.ci/scripts/validate.sh"
chmod +x "$REPO_ROOT/.ci/scripts/validate.sh"

# Trap tool_runner.sh
echo '#!/bin/bash' > "$REPO_ROOT/script/tool_runner.sh"
echo 'touch "$REPO_ROOT/USED_FORBIDDEN_SCRIPT.txt"' >> "$REPO_ROOT/script/tool_runner.sh"
chmod +x "$REPO_ROOT/script/tool_runner.sh"
