# Agent Guide for the Flutter Packages Repository

This document provides guidance for AI agents to effectively contribute to the `flutter/packages` repository.

## Guiding Principles for Contributions

- **Format All Code**: Every code change must be formatted using the repository's tools.
- **Pass All Tests**: All changes must pass linting, analysis, and relevant tests.
- **Update CHANGELOGs**: Any user-facing change or bug fix in a package requires an update to its `CHANGELOG.md` and `pubspec.yaml` version.
- **Follow Conventions**: Adhere to the repository's specific conventions, such as federated plugin structure and code generation steps.

## Agent Environment Setup

To ensure a consistent and functional environment, configure your VM with the following setup. This provides the necessary Flutter SDK and dependencies for building and testing packages.

```bash
curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.32.8-stable.tar.xz | tar -xJ -C $HOME
export FLUTTER_HOME=$HOME/flutter
export PATH=$FLUTTER_HOME/bin:$PATH
flutter --disable-analytics
flutter precache --force
# Sanity check the configuration.
flutter doctor --verbose
```

## Repository Overview

This is a monorepo containing many Flutter packages.
- First-party packages developed entirely by the Flutter team are in `packages/`.
- Packages that were originally developed by a third party, but are now maintained by the Flutter team are in `third_party/packages/`.
- The repository tooling is in `script/tool/`.

Many packages are part of **federated plugins**. A federated plugin has a main package (e.g., `path_provider`) that defines the API used by plugin clients, a platform interface package (e.g., `path_provider_platform_interface`) that defines the interface that each platform implementation must implement, and one or more platform implementation packages (e.g., `path_provider_android`, `path_provider_ios`) that implement that platform interface. When working on a federated plugin, you may need to modify multiple packages.

For more details, see the main `README.md` and `CONTRIBUTING.md`.

## Core Tooling and Workflows

The primary tool for this repository is `flutter_plugin_tools.dart`.

### Initial Setup

First, initialize the tooling:
```bash
cd $REPO_ROOT/script/tool # $REPO_ROOT is the repository root
dart pub get
```

### Identifying Target Packages

Most tool commands take a `--packages` argument. You must correctly identify all packages affected by your changes. You can derive this from git diff.

For example, to find changed files against the main branch of the upstream remote (assuming the upstream remote is named `origin`):

```bash
git diff --name-only origin/main...HEAD
```

Then, for each file path, find its enclosing package. A package is a directory containing a `pubspec.yaml` file. The directory name is usually the package name. Ignore `pubspec.yaml` files within `example/` directories when determining the package for a file.

#### Targeting All Packages

Running a tool command without a `--packages` argument will run the command on all packages. For example, a dependency can be updated for all packages in the repository:

```bash
dart run $REPO_ROOT/script/tool/bin/flutter_plugin_tools.dart update-dependency --pub-package <dependency_name>
```

### Common Commands

- **Formatting**: Always format your changes.

  ```bash
  dart run $REPO_ROOT/script/tool/bin/flutter_plugin_tools.dart format --packages <changed_packages>
  ```
- **Testing**: All changes must pass analysis and tests:

  ```bash
  # Run static analysis
  dart run $REPO_ROOT/script/tool/bin/flutter_plugin_tools.dart analyze --packages <changed_packages>
  # Run Dart unit tests
  dart run $REPO_ROOT/script/tool/bin/flutter_plugin_tools.dart dart-test --packages <changed_packages>
  ```

  The tool can also run native and integration tests, but these may require a more complete environment than is available.
- **Validation**: Run these checks to ensure that changes follow team guidelines:
  ```bash
  dart run $REPO_ROOT/script/tool/bin/flutter_plugin_tools.dart publish-check --packages <changed_packages>
  dart run $REPO_ROOT/script/tool/bin/flutter_plugin_tools.dart readme-check --packages <changed_packages>
  dart run $REPO_ROOT/script/tool/bin/flutter_plugin_tools.dart version-check --packages <changed_packages>
  dart run $REPO_ROOT/script/tool/bin/flutter_plugin_tools.dart license-check
  dart run $REPO_ROOT/script/tool/bin/flutter_plugin_tools.dart repo-package-info-check
  ```

### Specialized Workflows

- **Federated Plugin Development**: If you change multiple packages in a federated plugin that depend on each other, use `make-deps-path-based` to make their pubspec.yaml files use `path:` dependencies. This allows you to test them together locally.
  ```bash
  dart run $REPO_ROOT/script/tool/bin/flutter_plugin_tools.dart make-deps-path-based --target-dependencies=<changed_plugin_packages>
  ```

  The CI system will run tests with path-based dependencies automatically, so this is not required for PRs, but can be useful for local testing.
- **Updating Dependencies**: To update a dependency across multiple packages:
  ```bash
  dart run $REPO_ROOT/script/tool/bin/flutter_plugin_tools.dart update-dependency --pub-package <dependency_name> --packages <packages_to_update>
  ```
- **Updating README Code Samples**: If you change example code that is included in a README.md:
  ```bash
  dart run $REPO_ROOT/script/tool/bin/flutter_plugin_tools.dart update-excerpts --packages <changed_packages>
  ```

## Code Generators

Some packages use code generators, and changes to those packages require running the relevant code generators.

- **Pigeon**: If you change a file in a `pigeons/` directory, you must run the Pigeon generator:
  ```bash
  # Run from the package's directory
  dart run pigeon --input pigeons/<changed_file>.dart
  ```
- **Mockito**: If you change code in a package that uses `mockito` for tests (check `dev_dependencies` in `pubspec.yaml`), you must run its mock generator:
  ```bash
  # Run from the package's directory
  dart run build_runner build -d
  ```

## Code Style

All code must adhere to the repository's style guides. The `format` command handles most of this, but be aware of the specific style guides for each language, as detailed in [CONTRIBUTING.md](./CONTRIBUTING.md#style):
- **Dart**: Flutter style, formatted with `dart format`.
- **C++**: Google style, formatted with `clang-format`.
- **Java**: Google style, formatted with `google-java-format`.
- **Kotlin**: Android Kotlin style, formatted with `ktfmt`.
- **Objective-C**: Google style, formatted with `clang-format`.
- **Swift**: Google style, formatted with `swift-format`.

## Version and CHANGELOG updates

Any PR that changes non-test code in a package should update its version in pubspec.yaml and add a corresponding entry in CHANGELOG.md.

**This process can be automated**. The `update-release-info` command is the preferred way to handle this. It determines changed packages, bumps versions, and updates changelogs automatically.
```bash
dart run $REPO_ROOT/script/tool/bin/flutter_plugin_tools.dart update-release-info \
  --version=minimal \
  --base-branch=origin/main \
  --changelog="A description of the changes."
```

- `--version=minimal`: Bumps patch for bug fixes, and skips unchanged packages. This is usually the best option unless a new feature is being added.
  - When making public API changes, use `--version=minor` instead.
- `--base-branch=origin/main`: Diffs against the `main` branch to find changed packages.

If you update manually, follow semantic versioning and the repository's CHANGELOG format.
