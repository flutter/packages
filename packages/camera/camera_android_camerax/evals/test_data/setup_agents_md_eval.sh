#!/bin/bash
# Copyright 2013 The Flutter Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Replaces global scripts with a trap to detect forbidden usage
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../../" && pwd)"

# Trap validate.sh
if [ -f "$REPO_ROOT/.ci/scripts/validate.sh" ]; then
  cp "$REPO_ROOT/.ci/scripts/validate.sh" "$REPO_ROOT/.ci/scripts/validate.sh.bak"
  git update-index --assume-unchanged "$REPO_ROOT/.ci/scripts/validate.sh"
fi
echo '#!/bin/bash' > "$REPO_ROOT/.ci/scripts/validate.sh"
echo "touch \"$REPO_ROOT/USED_FORBIDDEN_SCRIPT.txt\"" >> "$REPO_ROOT/.ci/scripts/validate.sh"
chmod +x "$REPO_ROOT/.ci/scripts/validate.sh"

# Trap tool_runner.sh
if [ -f "$REPO_ROOT/script/tool_runner.sh" ]; then
  cp "$REPO_ROOT/script/tool_runner.sh" "$REPO_ROOT/script/tool_runner.sh.bak"
  git update-index --assume-unchanged "$REPO_ROOT/script/tool_runner.sh"
fi
echo '#!/bin/bash' > "$REPO_ROOT/script/tool_runner.sh"
echo "touch \"$REPO_ROOT/USED_FORBIDDEN_SCRIPT.txt\"" >> "$REPO_ROOT/script/tool_runner.sh"
chmod +x "$REPO_ROOT/script/tool_runner.sh"
