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

## Available Hooks

### pre-commit

The `pre-commit` hook runs automatically when you run `git commit` and performs the following on any staged changes:

1. **Formatting**: It runs `flutter_plugin_tools format --run-on-staged-packages` to verify that all staged files in the targeted packages are correctly formatted.
2. **Static Analysis**: If formatting passes, it runs `flutter_plugin_tools analyze --run-on-staged-packages --dart` to run static analysis on the staged packages.

If either check fails, it aborts the commit. To bypass the hook (for a WIP commit, for example), you can use the `--no-verify` flag:

```bash
git commit -m "WIP" --no-verify
```
