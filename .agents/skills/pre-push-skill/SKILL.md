---
name: "pre-push-skill"
description: "Executes the required pre-push steps for the flutter/packages repository. Call this tool immediately whenever the user asks to push, requests a code review before committing, or wants to validate their local changes can become a pull request. Do NOT use this tool if the user is working in flutter/flutter or flutter/engine."
---

# Pre-Push Skill

This skill provides a fully automated pre-push validation script
and a mental checklist for developers attempting to push code changes
to any of the packages in the flutter/packages repository.
It directly answers the question: **"Am I ready to push?"**

Follow the steps below before pushing any current code changes upstream
via `git push` to a package or finishing your task.
If any step fails, continue with the following steps
to provide a comprehensive list of required fixes for the user.

## 1. Initial Clean Working Tree Check

Because the tooling natively relies on `git diff`
to determine which packages have changed,
it **completely ignores uncommitted changes**.
You must ensure the working tree is clean before running any checks.
Command to run:

```bash
git status --porcelain
```

If this command outputs anything, the code WAS NOT ready to push.
The developer must commit or stash their changes
before you can proceed with the remaining validation steps.
Do not continue if there are uncommitted changes.

## 2. Check for Changed Packages

Because `--run-on-changed-packages` defaults to checking the entire repository
if zero packages have changed, you must verify
that there are actually package changes to test.
Command to run:

```bash
git diff --name-only main...HEAD | grep '^packages/'
```

If this command outputs nothing, then no packages were modified in this branch.
You can skip all remaining validation steps
and proceed directly to the Final Review.
If it outputs file paths, continue to the next step.

## 3. Format Code

Consistent code style is required for all pull requests.
The repository uses auto-formatters (like `dart format`, `clang-format`)
to enforce this. Command to run:

```bash
dart run script/tool/bin/flutter_plugin_tools.dart \
  format --run-on-changed-packages
```

If this command modifies any files, the code WAS NOT ready to push.
Those changes must be committed before the developer can push.

## 4. Static Analysis

Static analysis catches potential bugs, type errors,
and style violations without needing to run the code.
All code must pass the analyzer without any warnings or errors.
Command to run:

```bash
dart run script/tool/bin/flutter_plugin_tools.dart \
  analyze --run-on-changed-packages
```

If this command fails, the code WAS NOT ready to push.
Those analyzer errors must be fixed and committed before the developer can push.

## 5. Unit Tests

Tests ensure that your changes do not break existing functionality
and that new features work as expected.
All unit tests must pass before code can be merged.
Command to run:

```bash
dart run script/tool/bin/flutter_plugin_tools.dart \
  dart-test --run-on-changed-packages
```

If this command fails, the code WAS NOT ready to push.
Those test errors must be fixed and committed before the developer can push.

## 6. Publish Check (Version and CHANGELOG updates)

Any pull request that changes non-test code
must increment the package version in `pubspec.yaml`
and add a corresponding entry describing the change in `CHANGELOG.md`.
Command to run:

```bash
dart run script/tool/bin/flutter_plugin_tools.dart \
  publish-check --run-on-changed-packages
```

If this command fails, the code WAS NOT ready to push.
The required version bump and changelog entry must be made
and committed before the developer can push.
This can be done automatically by running:

```bash
dart run script/tool/bin/flutter_plugin_tools.dart update-release-info \
  --version=minimal --base-branch=main \
  --changelog="<description of your changes>"
```

## 7. License Headers

All source files in this repository must include
the standard copyright and license header.
Command to run:

```bash
dart run script/tool/bin/flutter_plugin_tools.dart license-check
```

If this command fails, the code WAS NOT ready to push.
Those license errors must be fixed and committed before the developer can push.

## 8. Final Clean Working Tree Check

Before pushing, ensure that all your fixes, formatting changes,
and version bumps are committed. Command to run:

```bash
git status --porcelain
```

If this command outputs anything, the code WAS NOT ready to push.
The changes must be cleaned up before the developer can push.

---

## Final Review

Before declaring the task complete,
verify the final requirements for creating a pull request
in the flutter/packages repository.

**What you MUST verify automatically:**
- **Documentation:** Check if the modified or newly added public APIs
  include Dart doc comments (`///`). If any are missing, proactively fix them
  or ask the user if they'd like you to add them.
- **Tests:** Check if any test files were added or modified
  alongside the source code changes. If not, proactively ask the user
  if they'd like you to generate tests (Critical for PR acceptance!).

**What you MUST NOT hold against the developer:**
Do NOT penalize or block the developer for administrative checklist items
that are unverifiable by an agent
(e.g., signing the CLA, reading the Contributor Guide).

**Action to take:**
First, explicitly state the final verdict to the user
at the very beginning of your response using a large heading:

- If ANY step failed: Start your response with a clear
  "# NO, you are not ready to push."
  followed by a summary of what failed and what needs to be fixed.
- If ALL steps passed: Start your response with a clear
  "# YES, you are ready to push!"

Then, provide the developer with a brief summary
of what you verified automatically.
If the code is ready to push, provide them with this short checklist
of items they will need to handle when opening their pull request:

- Ensure the PR title starts with the package name in brackets
  (e.g., `[camera_android] Fix crash`).
- Ensure the PR description links to at least one issue that is being fixed.
- Ensure they have signed the CLA.
- Ensure the branch is up to date with the main branch
  and has no merge conflicts.
