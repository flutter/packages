## Welcome

For an introduction to contributing to Flutter, see [our contributor
guide](https://github.com/flutter/flutter/blob/master/CONTRIBUTING.md).

Additional resources specific to the packages repository:
- [Setting up the Packages development
  environment](https://github.com/flutter/flutter/blob/master/docs/ecosystem/contributing/Setting-up-the-Packages-development-environment.md),
  which covers the setup process for this repository.
- [Packages repository structure](https://github.com/flutter/flutter/blob/master/docs/ecosystem/Plugins-and-Packages-repository-structure.md),
  to get an overview of how this repository is laid out.
- [Contributing to Plugins and Packages](https://github.com/flutter/flutter/blob/master/docs/ecosystem/contributing/README.md),
  for more information about how to make PRs for this repository, especially when
  changing federated plugins.
- [Plugin tests](https://github.com/flutter/flutter/blob/master/docs/ecosystem/testing/Plugin-Tests.md),
  which explains the different kinds of tests used for plugins, where to find them, and how to run them.
  As explained in the Flutter guide,
  [**PRs need tests**](https://github.com/flutter/flutter/blob/master/docs/contributing/Tree-hygiene.md#tests), so
  this is critical to read before submitting a plugin PR.

### Code review processes and automation

PRs will automatically be assigned to
[code owners](https://github.com/flutter/packages/blob/main/CODEOWNERS)
for review.
If a code owner is creating a PR, they should explicitly pick another
[Flutter team member](https://github.com/flutter/flutter/blob/master/docs/contributing/Contributor-access.md)
as a code reviewer.

### Style

Flutter packages and plugins follow Google style—or Flutter style for Dart—for the languages they
use, and use auto-formatters:
- [Dart](https://github.com/flutter/flutter/blob/master/docs/contributing/Style-guide-for-Flutter-repo.md) formatted
  with `dart format`
- [C++](https://google.github.io/styleguide/cppguide.html) formatted with `clang-format`
  - **Note**: The Linux plugins generally follow idiomatic GObject-based C
    style. See [the engine style
    notes](https://github.com/flutter/engine/blob/main/CONTRIBUTING.md#style)
    for more details, and exceptions.
- [Java](https://google.github.io/styleguide/javaguide.html) formatted with
  `google-java-format`
- [Kotlin](https://developer.android.com/kotlin/style-guide) formatted with
  `ktfmt`
- [Objective-C](https://google.github.io/styleguide/objcguide.html) formatted with
  `clang-format`
- [Swift](https://google.github.io/swift/) formatted with `swift-format`

### Releasing

If you are a team member landing a PR, or just want to know what the release
process is for package changes, see [the release
documentation](https://github.com/flutter/flutter/blob/master/docs/ecosystem/release/README.md).
