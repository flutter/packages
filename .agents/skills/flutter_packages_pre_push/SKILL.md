---
name: "flutter_packages_pre_push"
description: "A comprehensive pre-push checklist and validation script for developers and AI agents contributing to the flutter/packages repository. Directly answers the question: 'Am I ready to push?'"
---

# Pre-Push Skill: `flutter/packages`

This skill provides a fully automated pre-push validation script and a mental checklist. It directly answers the question: **"Am I ready to push?"**

AI Agents: Run the bash script below before completing any pull request or commit task. If it outputs `🛑 NO. You are not ready to push`, you must fix the errors before concluding your task.

Human Developers: You can save the bash script below as `.git/hooks/pre-push` to enforce these rules locally, or simply run it manually before opening a PR!

## Automated Validation Script

Run this script from the root of the repository. It identifies exactly which packages you modified and runs the repository's native `flutter_plugin_tools` on them. It does NOT stop on the first error, so you get a complete list of everything needed to be ready!

```bash
#!/bin/bash

# Ensure we are at the repository root
REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

echo "📦 1. Checking for uncommitted changes..."
if [[ -n $(git status --porcelain) ]]; then
  echo "❌ You have uncommitted changes in your working directory!"
  echo "Please commit or stash your changes before running this script,"
  echo "so we can safely pull the latest changes from main."
  exit 1
else
  echo "✅ Working directory is clean."
fi

echo "========================================="
echo "🔄 2. Pulling latest changes from main..."
git fetch origin main 2>/dev/null || true
if ! git merge origin/main --no-edit; then
  echo "❌ Merge conflict detected!"
  echo "Please resolve the merge conflicts, commit the result, and run this script again."
  exit 1
else
  echo "✅ Successfully pulled latest changes (no conflicts)."
fi

# Ensure the repository tool dependencies are fetched
dart pub get -C "$REPO_ROOT/script/tool" > /dev/null

echo "========================================="
echo "🔍 3. Identifying changed packages..."
# Diff against main. Adjust origin/main to upstream/main if needed.
CHANGED_FILES=$(git diff --name-only origin/main...HEAD || git diff --name-only origin/main)

# Find unique packages containing pubspec.yaml
PACKAGES=""
for file in $CHANGED_FILES; do
  dir=$(dirname "$file")
  while [ "$dir" != "." ] && [ "$dir" != "/" ]; do
    if [ -f "$dir/pubspec.yaml" ]; then
      # Ignore example directories as per repository guidelines
      if [[ ! "$dir" == *"example"* ]]; then
        PACKAGE_NAME=$(basename "$dir")
        PACKAGES="$PACKAGES,$PACKAGE_NAME"
      fi
      break
    fi
    dir=$(dirname "$dir")
  done
done

# Clean up trailing/leading commas and deduplicate
PACKAGES=$(echo "$PACKAGES" | tr ',' '\n' | sort -u | paste -sd, - | sed 's/^,//')

if [ -z "$PACKAGES" ]; then
  echo "✅ No package changes detected. Continuing."
  exit 0
fi

echo "📦 Changed packages detected: $PACKAGES"
READY=true

echo "========================================="
echo "🧹 4. Running auto-formatters..."
echo "Note: This runs dart format, clang-format, ktfmt, etc."
if ! dart run script/tool/bin/flutter_plugin_tools.dart format --packages="$PACKAGES"; then
  echo "❌ Formatter found issues."
  READY=false
else
  echo "✅ Format complete."
fi

echo "========================================="
echo "🔍 5. Running static analysis..."
echo "Note: This runs dart analyze --fatal-infos internally."
if ! dart run script/tool/bin/flutter_plugin_tools.dart analyze --packages="$PACKAGES"; then
  echo "❌ Analysis failed."
  READY=false
else
  echo "✅ Analysis passed."
fi

echo "========================================="
echo "🧪 6. Running unit tests..."
if ! dart run script/tool/bin/flutter_plugin_tools.dart dart-test --packages="$PACKAGES"; then
  echo "❌ Tests failed."
  READY=false
else
  echo "✅ Tests passed."
fi

echo "========================================="
echo "📝 7. Validating package structure..."
if ! dart run script/tool/bin/flutter_plugin_tools.dart validate --packages="$PACKAGES"; then
  echo "❌ Structure validation failed."
  READY=false
else
  echo "✅ Structure validation passed."
fi

echo "========================================="
echo "🏷️ 8. Checking versions and CHANGELOGs..."
if ! dart run script/tool/bin/flutter_plugin_tools.dart publish-check --packages="$PACKAGES"; then
  echo "❌ Version and Changelog validation failed."
  READY=false
else
  echo "✅ Version and Changelog validation passed."
fi

echo "========================================="
echo "⚖️ 9. Checking license headers..."
if ! dart run script/tool/bin/flutter_plugin_tools.dart license-check; then
  echo "❌ License check failed."
  READY=false
else
  echo "✅ License check passed."
fi

echo "========================================="
echo "📦 10. Checking for new uncommitted changes..."
if [[ -n $(git status --porcelain) ]]; then
  echo "❌ You have uncommitted changes in your working directory!"
  echo "   (Did the auto-formatter modify files in step 4?)"
  READY=false
else
  echo "✅ Working directory is still clean."
fi

echo "========================================="
if [ "$READY" = "true" ]; then
  echo "🚀 YES! You are ready to push!"
  echo ""
  echo "🛑 MANUAL PRE-REVIEW CHECKLIST 🛑"
  echo "Please verify the following PR requirements before submitting:"
  echo "- [ ] I read the Contributor Guide and AI contribution guidelines."
  echo "- [ ] I signed the CLA."
  echo "- [ ] PR Title starts with the package name in brackets, e.g. [${PACKAGES%%,*}]"
  echo "- [ ] Linked to at least one issue (or noted it's a new feature)."
  echo "- [ ] Updated any relevant doc comments (///)."
  echo "- [ ] Added new tests for the change made (Critical for PR acceptance!)."
  exit 0
else
  echo "🛑 NO. You are not ready to push. Please fix the errors above."
  echo ""
  echo "💡 TIP: If you failed step 8 (publish-check), run:"
  echo "  dart run script/tool/bin/flutter_plugin_tools.dart update-release-info \\"
  echo "    --version=minimal --base-branch=origin/main --changelog=\"<description>\""
  echo ""
  echo "💡 TIP: If you failed step 10, run 'git commit' to commit the formatter's changes!"
  exit 1
fi
```

## How to use this skill (For Agents)
1. Whenever a user asks you to implement a fix, feature, or refactor in `flutter/packages`, make your edits.
2. Before you announce that the work is finished, **you MUST run the script above**.
3. If step 1 (`format`) modifies files, step 7 will fail! You must commit the formatter's modifications so the working tree is clean.
4. If step 2 (`analyze`) fails, you must read the analyzer errors and fix them in the source code.
5. If step 5 (`publish-check`) fails because of missing `CHANGELOG.md` or `pubspec.yaml` version bumps, use the `update-release-info` command (shown in the TIP) to automatically generate them.
6. If the script says `🛑 NO. You are not ready to push`, fix all issues and run the script again. Do not finish the task until you see `🚀 YES! You are ready to push!`.
7. Once you are ready, review the "Manual Pre-Review Checklist". If you did not add tests or write doc comments, proactively ask the user if they would like you to do so!
