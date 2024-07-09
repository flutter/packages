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

**Make sure that you have `chromedriver` running in port `4444`.**

`flutter drive --target integration_test/widget_test.dart --driver test_driver/integration_test.dart --show-web-server-device -d web-server --web-renderer=canvaskit`

The command above will run the integration tests for this package.

Read more on: [flutter.dev > Docs > Testing & debugging > Integration testing](https://docs.flutter.dev/testing/integration-tests).
