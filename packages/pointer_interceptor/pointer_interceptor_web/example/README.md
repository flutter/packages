# Platform Implementation Test App

This is a test app for manual testing and automated integration testing
of this platform implementation. It is not intended to demonstrate actual use of
this package, since the intent is that plugin clients use the app-facing
package.

Unless you are making changes to this implementation package, this example is
very unlikely to be relevant.

## Getting Started

`flutter run -d chrome` to run the sample. You can tweak some code in the `lib/main.dart`, but be careful, changes there can break integration tests!

## Running tests

You may use the [Flutter Plugin Tools](https://github.com/flutter/packages/blob/main/script/tool/README.md)
to run the integration tests of this package.

See [How to Run Dart Integration Tests](https://github.com/flutter/packages/blob/main/script/tool/README.md#run-dart-integration-tests)
for the latest documentation.

### Web-specific options

Use the following options to build and drive the integration examples on the web:

* `--web` as platform
* `--packages pointer_interceptor_web` as package
* `--run-chromedriver` to start a `chromedriver` session from `drive-examples`.

### Chromedriver

**Make sure that you have `chromedriver` in your `$PATH`.**

You may download the appropriate version of `chromedriver` for your OS and
Chrome version from the
[Chrome for Testing availability](https://googlechromelabs.github.io/chrome-for-testing/)
website.
