# Platform Implementation Test App

This is a test app for manual testing and automated integration testing
of this platform implementation. It is not intended to demonstrate actual use of
this package, since the intent is that plugin clients use the app-facing
package.

Unless you are making changes to this implementation package, this example is
very unlikely to be relevant.

## Legacy SDK

This test app pins the Google Maps JavaScript SDK to version 3.64, which is
the last version that supported heatmaps. It is used to run integration tests
that use heatmaps, and to test that changes to the package do not break
existing heatmap functionality.

## Testing

This package uses `package:integration_test` to run its tests in a web browser.

See [Plugin Tests > Web Tests](https://github.com/flutter/flutter/blob/master/docs/ecosystem/testing/Plugin-Tests.md#web-tests)
in the Flutter documentation for instructions to set up and run the tests in this package.

Check [flutter.dev > Integration testing](https://docs.flutter.dev/testing/integration-tests)
for more info.
