# Git Hooks

This directory contains Git hooks for the `flutter/packages` repository.

## Installation

### Option 1: Install All Hooks (Recommended)

To install all Git hooks, run the following commands from the root of the repository:

```bash
# Fetch dependencies for the githooks package
dart pub get -C script/githooks

# Run the installation script
dart script/githooks/bin/install_hooks.dart
```

### Option 2: Install Specific Hooks

To only use specific Git hooks in this directory long-term, create a script in your local `.git/hooks` directory that runs the desired hook.

For example, to install only the `pre-commit` hook, create `.git/hooks/pre-commit` with:

```bash
#!/usr/bin/env bash
exec dart script/githooks/bin/main.dart pre-commit "$@"
```

Then, make it executable and ensure Git uses your local `.git/hooks` directory:

```bash
chmod +x .git/hooks/pre-commit
git config --unset core.hooksPath
```

## Uninstallation

### Uninstall All Hooks

If you installed all hooks using Option 1, you can uninstall them by running:

```bash
git config --unset core.hooksPath
```

### Uninstall Specific Hooks

If you manually added a specific Git hook (Option 2), you can uninstall it by deleting the script from your `.git/hooks` directory:

```bash
rm .git/hooks/pre-commit
```

### Bypass Hooks Temporarily

To skip running hooks for a single action, pass the `--no-verify` flag. For example, to bypass the pre-commit hook during a commit:

```bash
git commit --no-verify
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
