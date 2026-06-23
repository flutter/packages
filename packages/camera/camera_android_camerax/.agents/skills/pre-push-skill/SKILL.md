---
name: "pre-push-skill"
description: "Executes the required pre-push steps for the flutter/packages repository. Call this tool immediately whenever the user asks to push, asks if we/you are ready to push, or wants to validate their local changes can become a pull request."
---

# Pre-Push Skill Checks to Verify

## 1. Initial Clean Working Tree Check

The first step is ensuring that all changes are committed
and there are no tracked files with lingering non committed state.
Command to run:

```bash
git status --porcelain
```

If this command outputs anything,
then there are uncommitted git changes.
The code is not ready to push.

## 2. Check for Changed Files

You must verify that there are actually changed files to test.
Command to run:

```bash
git diff --name-only main...HEAD | grep '^packages/camera/camera_android_camerax'
```

If this command outputs nothing,
then no relevant files were modified in this branch.
There is no code to push,
and you can skip all remaining validation steps.

## 3. Check Merge Conflicts

Ensure the current branch is up to date with the main branch
and has no merge conflicts.
You can verify this by checking if the upstream `main` branch
is an ancestor of your current `HEAD`.
Command to run:

```bash
git fetch origin main
git merge-base --is-ancestor origin/main HEAD
```

If this command fails (exits with a non-zero code),
the branch is behind `origin/main`.
The code is NOT ready to push.
The developer must pull the latest changes from `main`
and resolve any merge conflicts before proceeding.

## 4. Unit Tests

Tests ensure that your changes do not break existing functionality
and that new features work as expected.
All unit tests must pass before code can be merged.
Command to run:

```bash
dart run script/tool/bin/flutter_plugin_tools.dart \
  dart-test --packages camera_android_camerax
```

If this command fails, the code is likely not ready to push.
The tests might have been failing prior to any changes being made,
so prompt the user to review all found errors
and fix the newly introduced failures before pushing any code.

## 5. Publish Check (Version and CHANGELOG updates)

Any pull request that changes non-test code
must increment the package version in `pubspec.yaml`
and add a corresponding entry describing the change in `CHANGELOG.md`.
Command to run:

```bash
dart run script/tool/bin/flutter_plugin_tools.dart \
  publish-check --pacakges camera_android_camerax
```

If this command fails, the code WAS NOT ready to push.
The required version bump and changelog entry must be made
and committed before code can be pushed.

## 6. License Headers

All source files in this repository must include
the standard copyright and license header.
Command to run:

```bash
dart run script/tool/bin/flutter_plugin_tools.dart license-check --packages camera_android_camerax
```

If this command fails, the code WAS NOT ready to push.
Those license errors must be fixed and committed before code is pushed.


## 6. Non-mechanical Steps

Before declaring the task complete,
verify the requirements for creating a pull request
in the flutter/packages repository are met:

**What you MUST verify automatically:**
- **Documentation:** Check if the modified or newly added public APIs
  include Dart doc comments (`///`). If not, the code IS NOT ready to
  be pushed.
- **Tests:** Virtually all changes required a test.
  See [Test Documentation](https://github.com/flutter/flutter/blob/master/docs/ecosystem/testing/Plugin-Tests.md).
  Evaluate the change against that testing rubric.
  Based on the rubric, if the change requires a test,
  give the user a quote from the testing documentation
  on what type of test is required for their changes.
  Beyond the rubric, if you think the change does not meet
  the documented quality bar, tell the user
  and only push if they approve the test coverage.

# Take Action
First, explicitly state the final verdict to the user
at the very beginning of your response using a large heading:

- If ANY step failed: Start your response with a clear
  "# NO, you are not ready to push."
  followed by a summary of what failed and what needs to be fixed.
- If ALL steps passed: Start your response with a clear
  "# YES, you are ready to push!"

Then, provide the developer with a brief summary
of what you verified automatically.
For example, in the case of failure,
if unit tests are failing, point to the exact tests and the exact errors.
For example, in the case of success, if all tests passed,
communicate that the code is ready to push
because unit tests passed, the licenses look good,
and all required publishing steps have been completed.

If the code is ready to push,
provide them with the command to create the PR:

```bash
gh pr create -t "TITLE" -b "BODY"
```

where

- TITLE is the title of the PR that starts with the package name in brackets
  (for example, `[camera_android] Fix crash`
  or `[camera_android, camera_android_camerax] Fix crash`
  if both `camera_android` and `camera_android_camerax` were modified).
- BODY is the PR description that should contain a link
  to at least one issue that is being fixed.
