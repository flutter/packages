## NEXT

* Updates minimum supported SDK version to Flutter 3.22/Dart 3.4.

## 3.16.3

* Fixes re-registering existing channels while removing Javascript channels.

## 3.16.2

* Updates README to remove contributor-focused documentation.

## 3.16.1

* Adds `missing_code_block_language_in_doc_comment` lint.

## 3.16.0

* Supports NTLM for authentication.

## 3.15.0

* Adds macOS support.

## 3.14.0

* Adds Swift Package Manager compatibility.

## 3.13.1

* Fixes `JSON.stringify()` cannot serialize cyclic structures.

## 3.13.0

* Adds `decidePolicyForNavigationResponse` to internal WKNavigationDelegate to support the
  `PlatformNavigationDelegate.onHttpError` callback.

## 3.12.0

* Adds support for `setOnScrollPositionChange` method to the `WebKitWebViewController`.

## 3.11.0

* Adds support to show JavaScript dialog. See `PlatformWebViewController.setOnJavaScriptAlertDialog`, `PlatformWebViewController.setOnJavaScriptConfirmDialog` and `PlatformWebViewController.setOnJavaScriptTextInputDialog`.

## 3.10.3

* Adds a check that throws an `ArgumentError` when `WebKitWebViewController.addJavaScriptChannel`
  receives a `JavaScriptChannelParams` with a name that is not unique.
* Updates minimum iOS version to 12.0 and minimum Flutter version to 3.16.6.

## 3.10.2

* Adds privacy manifest.

## 3.10.1

* Fixes new lint warnings.

## 3.10.0

* Adds support for `PlatformNavigationDelegate.setOnHttpAuthRequest`.
* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.

## 3.9.4

* Updates to Pigeon 13.

## 3.9.3

* Fixes `use_build_context_synchronously` lint violations in the example app.

## 3.9.2

* Fixes error caused by calling `WKWebViewConfiguration.limitsNavigationsToAppBoundDomains` on
  versions below 14.

## 3.9.1

* Fixes bug where `WebkitWebViewController.getUserAgent` was incorrectly returning an empty String.

## 3.9.0

* Adds support for `PlatformWebViewController.getUserAgent`.

## 3.8.0

* Adds support to register a callback to receive JavaScript console messages. See `WebKitWebViewController.setOnConsoleMessage`.

## 3.7.4

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 3.7.3

* Fixes bug where the `PlatformWebViewWidget` was rebuilt unnecessarily.

## 3.7.2

* Fixes bug where `PlatformWebViewWidget` doesn't rebuild when the controller changes.

## 3.7.1

* Updates pigeon version to `10.1.4`.

## 3.7.0

* Adds support for `WebResouceError.url`.

## 3.6.3

* Introduces `NSError.toString` for better diagnostics.

## 3.6.2

* Fixes unawaited_futures violations.

## 3.6.1

* Fixes bug where a native `NSURL` could be removed from an `InstanceManager` if it is equal to an
  already present `NSURL`.
* Fixes compile-time error from using `WKWebView.inspectable` on unsupported Xcode versions.

## 3.6.0

* Adds support to enable debugging of web contents on the latest versions of WebKit. See
  `WebKitWebViewController.setInspectable`.

## 3.5.0

* Adds support to limit navigation to pages within the app’s domain. See
  `WebKitWebViewControllerCreationParams.limitsNavigationsToAppBoundDomains`.

## 3.4.4

* Removes obsolete null checks on non-nullable values.

## 3.4.3

* Replace `describeEnum` with the `name` getter.

## 3.4.2

* Fixes an exception caused by the `onUrlChange` callback passing a null `NSUrl`.

## 3.4.1

* Fixes internal type conversion error.
* Adds internal unknown enum values to handle api updates.

## 3.4.0

* Adds support for `PlatformWebViewController.setOnPlatformPermissionRequest`.

## 3.3.0

* Adds support for `PlatformNavigationDelegate.onUrlChange`.

## 3.2.4

* Updates pigeon to fix warnings with clang 15.
* Updates minimum Flutter version to 3.3.
* Fixes common typos in tests and documentation.

## 3.2.3

* Updates to `pigeon` version 7.

## 3.2.2

* Changes Objective-C to use relative imports.

## 3.2.1

* Clarifies explanation of endorsement in README.
* Aligns Dart and Flutter SDK constraints.

## 3.2.0

* Updates minimum Flutter version to 3.3 and iOS 11.

## 3.1.1

* Updates links for the merge of flutter/plugins into flutter/packages.

## 3.1.0

* Adds support to access native `WKWebView`.

## 3.0.5

* Renames Pigeon output files.

## 3.0.4

* Fixes bug that prevented the web view from being garbage collected.

## 3.0.3

* Updates example code for `use_build_context_synchronously` lint.

## 3.0.2

* Updates code for stricter lint checks.

## 3.0.1

* Adds support for retrieving navigation type with internal class.
* Updates README with details on contributing.
* Updates pigeon dev dependency to `4.2.13`.

## 3.0.0

* **BREAKING CHANGE** Updates platform implementation to `2.0.0` release of
  `webview_flutter_platform_interface`. See
  [webview_flutter](https://pub.dev/packages/webview_flutter/versions/4.0.0) for updated usage.
* Updates code for `no_leading_underscores_for_local_identifiers` lint.

## 2.9.5

* Updates imports for `prefer_relative_imports`.

## 2.9.4

* Fixes avoid_redundant_argument_values lint warnings and minor typos.
* Fixes typo in an internal method name, from `setCookieForInsances` to `setCookieForInstances`.

## 2.9.3

* Updates `webview_flutter_platform_interface` constraint to the correct minimum
  version.

## 2.9.2

* Fixes crash when an Objective-C object in `FWFInstanceManager` is released, but the dealloc
  callback is no longer available.

## 2.9.1

* Fixes regression where the behavior for the `UIScrollView` insets were removed.

## 2.9.0

* Ignores unnecessary import warnings in preparation for [upcoming Flutter changes](https://github.com/flutter/flutter/pull/106316).
* Replaces platform implementation with WebKit API built with pigeon.

## 2.8.1

* Ignores unnecessary import warnings in preparation for [upcoming Flutter changes](https://github.com/flutter/flutter/pull/104231).

## 2.8.0

* Raises minimum Dart version to 2.17 and Flutter version to 3.0.0.

## 2.7.5

* Minor fixes for new analysis options.

## 2.7.4

* Removes unnecessary imports.
* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 2.7.3

* Removes two occurrences of the compiler warning: "'RequiresUserActionForMediaPlayback' is deprecated: first deprecated in ios 10.0".

## 2.7.2

* Fixes an integration test race condition.
* Migrates deprecated `Scaffold.showSnackBar` to `ScaffoldMessenger` in example app.

## 2.7.1

* Fixes header import for cookie manager to be relative only.

## 2.7.0

* Adds implementation of the `loadFlutterAsset` method from the platform interface.

## 2.6.0

* Implements new cookie manager for setting cookies and providing initial cookies.

## 2.5.0

* Adds an option to set the background color of the webview.
* Migrates from `analysis_options_legacy.yaml` to `analysis_options.yaml`.
* Integration test fixes.
* Updates to webview_flutter_platform_interface version 1.5.2.

## 2.4.0

* Implemented new `loadFile` and `loadHtmlString` methods from the platform interface.

## 2.3.0

* Implemented new `loadRequest` method from platform interface.

## 2.2.0

* Implemented new `runJavascript` and `runJavascriptReturningResult` methods in platform interface.

## 2.1.0

* Add `zoomEnabled` functionality.

## 2.0.14

* Update example App so navigation menu loads immediatly but only becomes available when `WebViewController` is available (same behavior as example App in webview_flutter package).

## 2.0.13

* Extract WKWebView implementation from `webview_flutter`.
