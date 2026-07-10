# Flutter Plugin Tools

This is a set of utilities used in this repository, both for CI and for
local development.

## Getting Started

There are two ways to use this tool. You can either run it locally from the
`flutter/packages` repository, or you can install it globally using
`dart pub global activate`.

If you are developing in `flutter/packages`, you should **always** use the local
method, as only the checked in version is expected to work correctly with the
current state of the repository.

If you are developing in `flutter/core-packages` or another repository using
this tool, and don't have `flutter/packages` cloned locally (or don't keep it
up to date), you can use the global method.

For simplicity, the setup instructions below assume you set up an `fpt` alias to
your preferred method (e.g., in `~/.bashrc` or `~/.zshrc`), and all examples
in this README use that alias. If you choose not to create an alias, or use
a different name for your alias, adjust the examples accordingly.

**Note:** Regardless of which setup method you use, many commands require the
Flutter-bundled version of Dart to be the first `dart` in the path.

### Local Method

Set up the local package to be runnable:

```sh
dart pub get -C "/path/to/flutter/packages/"script/tool
```

Add an alias (recommended):

```sh
alias fpt='dart run "/path/to/flutter/packages/"script/tool/bin/flutter_plugin_tools.dart'
```

### Global Method

Activate the tool globally:

```sh
dart pub global activate flutter_plugin_tools
```

Add an alias (recommended):

```sh
alias fpt='dart pub global run flutter_plugin_tools'
```

## Commands

Run with `--help` for a full list of commands and arguments, but the
following shows a number of common commands being run for a specific package.

Most commands take a `--packages` argument to control which package(s) the
command is targetting. An package name can be any of:
- The name of a package (e.g., `path_provider_android`).
- The name of a federated plugin (e.g., `path_provider`), in which case all
  packages that make up that plugin will be targetted.
- A combination federated_plugin_name/package_name (e.g.,
  `path_provider/path_provider` for the app-facing package).

An alternative to `--packages` is the `--current-package` flag, which causes
the script to target the current working directory's package (or enclosing
package; it can be used from anywhere within a package).

### Format Code

```sh
fpt format --packages package_name
```

The `flutter/packages` repository uses clang version `15.0.0` . Newer versions of clang may format code differently.

### Run Static Analysis

To analyze only Dart code:

```sh
fpt analyze --packages package_name
```

To include native code, include the relevant platform flag(s). For example:

```sh
# Analyze Dart and Android Java/Kotlin code:
fpt analyze --android --packages package_name
# Analyze Dart and iOS+macOS Objective-C/Swift code:
fpt analyze --ios --macos --packages package_name
```

Dart analysis can be excluded with `--no-dart`.

### Run General Validation

To check that changes follow team standards and best practices, run:

```sh
fpt validate --check-for-missing-changes --packages package_name
```

If you are making changes that fall under a CHANGELOG and/or version change
exemption you can omit the `--check-for-missing-changes` flag to skip those
checks.

### Run Dart Unit Tests

```sh
fpt test --packages package_name
```

### Run Dart Integration Tests

```sh
fpt build-examples --apk --packages package_name
fpt drive-examples --android --packages package_name
```

Replace `--apk`/`--android` with the platform you want to test against
(omit it to get a list of valid options).

### Run Native Tests

`native-test` takes one or more platform flags to run tests for. By default it
runs both unit tests and (on platforms that support it) integration tests, but
`--no-unit` or `--no-integration` can be used to run just one type.

Examples:

```sh
# Run just unit tests for iOS and Android:
fpt native-test --ios --android --no-integration --packages package_name
# Run all tests for macOS:
fpt native-test --macos --packages package_name
# Run all tests for Windows:
fpt native-test --windows --packages package_name
```

### Update README.md from Example Sources

```sh
# Update all .md files for all packages:
fpt update-excerpts

# Update the .md files only for one package:
fpt update-excerpts --packages package_name
```

_See also: https://github.com/flutter/flutter/blob/master/docs/ecosystem/contributing/README.md#readme-code_

### Update CHANGELOG and Version

`update-release-info` will automatically update the version and `CHANGELOG.md`
following standard repository style and practice. It can be used for
single-package updates to handle the details of getting the `CHANGELOG.md`
format correct, but is especially useful for bulk updates across multiple packages.

For instance, if you add a new analysis option that requires production
code changes across many packages:

```sh
fpt update-release-info \
  --version=minimal \
  --base-branch=upstream/main \
  --changelog="Fixes violations of new analysis option some_new_option."
```

The `minimal` option for `--version` will skip unchanged packages, and treat
each changed package as either `bugfix` or `next` depending on the files that
have changed in that package, so it is often the best choice for a bulk change.

For cases where you know the change type, `minor` or `bugfix` will make the
corresponding version bump, or `next` will update only `CHANGELOG.md` without
changing the version.

If you have a standard repository setup, `--base-branch=upstream/main` will
usually give the behavior you want, finding all packages changed relative to
the branch point from `upstream/main`. For more complex use cases where you want
a different diff point, you can pass a different `--base-branch`, or use
`--base-sha` to pick the exact diff point.

### Update a dependency

`update-dependency` will update a pub dependency to a new version.

For instance, to updated to version 3.0.0 of `some_package` in every package
that depends on it:

```sh
fpt update-dependency --pub-package=some_package --version=3.0.0
```

If a `--version` is not provided, the latest version from pub will be used.

Currently this only updates the dependency itself in pubspec.yaml, but in the
future this will also update any generated code for packages that use code
generation (e.g., regenerating mocks when updating `mockito`).

### Publish a Release

**Releases are automated for `flutter/packages`.**

The manual procedure described here is _deprecated_, and should only be used when
the automated process fails. Please read
[Releasing a Plugin or Package](https://github.com/flutter/flutter/blob/master/docs/ecosystem/release/README.md)
before using `publish`.

```sh
cd <path_to_repo>
git checkout <commit_hash_to_publish>
fpt publish --packages <package>
```

By default the tool tries to push tags to the `upstream` remote, but some
additional settings can be configured. Run `fpt publish --help` for more
usage information.

The tool wraps `pub publish` for pushing the package to pub, and then will
automatically use git to try to create and push tags. It has some additional
safety checking around `pub publish` too. By default `pub publish` publishes
_everything_, including untracked or uncommitted files in version control.
`publish` will first check the status of the local
directory and refuse to publish if there are any mismatched files with version
control present.

## Configuration

The `.repo_tool_config.yaml` file at the root of the repository contains
configuration for this tool, to support using the same script in multiple
repositories.

The following sections are supported:

- `repo_name` (**required**): The name of the repository
  (e.g., `flutter/packages`).
- `min_flutter` or `min_dart`: The minimum SDK version
  that packages in the repository are allowed to support.
- `allowed_dependencies`, containing one or both of:
  - `pinned`: A list of package names that are allowed as `pubspec.yaml`
    dependencies as long as they are pinned to an exact version.
  - `unpinned`: A list of package names that are allowed as `pubspec.yaml`
    dependencies without a specific version constraint (or with a broad
    constraint).
- `package_labels`: A map from a package name to the label to use for that
  package's issue link query. This is only needed for packages that use a
  label other than `p: <package_name>`.
