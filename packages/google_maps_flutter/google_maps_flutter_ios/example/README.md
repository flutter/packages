# Platform Implementation Test Apps

These are test app for manual testing and automated integration testing
of this platform implementation. They are not intended to demonstrate actual
use of this package, since the intent is that plugin clients use the
app-facing package.

Unless you are making changes to this implementation package, these examples
are very unlikely to be relevant.

## Structure

This package contains multiple exmaples, which are used to test different
versions of the Google Maps iOS SDK. Because the plugin's dependency
is unpinned, CocoaPods will pick the newest version that supports the
minimum targetted OS version of the application using the plugin. In
order to ensure that the plugin continues to compile against all
SDK versions that could resolve, there are multiple largely identical
examples, each with a different minimum target iOS version.

In order to avoid wasting CI resources, the majority of the testing
is done with the lowest supported version. The assumption (based on
experience so far) is that the changes in the SDK are unlikely to
break functionality at runtime, and that it's primarily a
compile-time issue. However, we can add testing to newer versions
(e.g., to test functionality that only exists in newer versions
of the SDK) as needed.

## Updating Examples

* When a new major of the SDK comes out that raises the minimum
  iOS deployment version, a new example with that minimum target
  should be added to ensure that the plugin compiles with that
  version of the SDK.
* When the minimum supported version of Flutter (on `stable`)
  reaches the point where the oldest example is for an SDK
  that can no longer be resolved to, that example should be
  removed, and all of its testing (Dart integration tests,
  native unit tests, native UI tests) should be folded into
  the next-oldest version.
