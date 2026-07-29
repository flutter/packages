# Git Hooks

This directory contains Git hooks for the `flutter/packages` repository.

## Installation

To install the Git hooks, run the following commands from the root of the repository:

```bash
# Fetch dependencies for the githooks package
dart pub get -C script/githooks

# Run the installation script
dart script/githooks/bin/install_hooks.dart
```

To uninstall ALL of the Git hooks in this directory, run:

```bash
git config --unset core.hooksPath
```

To uninstall certain hooks TEMPORARILY pass `--no-verify` to the related
action, e.g. `git commit --no-verify` to bypass the pre-commit hook.

To only use specific Git hooks in this directory long-term, create a
script in your local .git/hooks directory that runs the desired hook.
For example, create `.git/hooks/pre-commit` with:

```dart
#!/usr/bin/env bash
exec dart script/githooks/bin/main.dart pre-commit "$@"
```

And make it executable:

```bash
chmod +x .git/hooks/pre-commit
git config --unset core.hooksPath
```

## Available Hooks

### pre-commit

The `pre-commit` hook runs automatically when you run `git commit` and performs the following checks on any staged changes:

1. **Formatting**: It runs `dart run script/tool/bin/flutter_plugin_tools.dart format --run-on-staged-packages` to verify that all staged files in the targeted packages are correctly formatted.
2. **Static Analysis**: If formatting passes, it runs `dart run script/tool/bin/flutter_plugin_tools.dart analyze --run-on-staged-packages --dart` to run static analysis on the staged packages.

If either check fails, it aborts the commit. To bypass the hook (for a WIP commit, for example), you can use the `--no-verify` flag:

```bash
git commit -m "WIP" --no-verify
```
