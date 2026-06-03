# Platform Implementation Test App

This is a test app for manual testing and automated integration testing
of this platform implementation. It is not intended to demonstrate actual use of
this package, since the intent is that plugin clients use the app-facing
package.

Unless you are making changes to this implementation package, this example is
very unlikely to be relevant.

## Example Structure

This directory contains two example apps:
- latest/ uses an unpinned SDK load, so it will use the latest SDK version.
  This follows the standard recommendation in the package's README.
- 3-64 pins the SDK to 3.64. This is used for integration tests of the
  heatmap support, since heatmaps were removed from the SDK in 3.65.
