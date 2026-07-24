#!/bin/bash
# Simulates a successful adherence to cross_skill_rubric.json

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_ROOT="$(cd "$SCRIPT_DIR/../../" && pwd)"

# Modify a safe file inside the package.
echo "<!-- dummy eval modification -->" >> "$PACKAGE_ROOT/README.md"
