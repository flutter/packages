## NEXT

* Updates minimum supported SDK version to Flutter 3.27/Dart 3.6.

## 2.3.2

* Replaces deprecated RouteInformation API usage.

## 2.3.1

* Updates minimum required plugin_platform_interface version to 2.1.7.

## 2.3.0
* Adds `InAppBrowserConfiguration` parameter to `LaunchOptions`, to configure in-app browser views, such as Android Custom Tabs or `SFSafariViewController`.
* Adds `showTitle` parameter to `InAppBrowserConfiguration` in order to control web-page title visibility.

## 2.2.1

* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.
* Fixes new lint warnings.

## 2.2.0

* Adds a new `inAppBrowserView` launch mode, to distinguish in-app browser
  views (such as Android Custom Tabs or SFSafariViewController) from simple
  web views.
* Adds `supportsMode` and `supportsCloseForMode` to query platform support for
  launching and closing with various modes.

## 2.1.5

* Updates documentation to mention support for Android Custom Tabs.

## 2.1.4

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 2.1.3

* Updates minimum Flutter version to 3.3.
* Aligns Dart and Flutter SDK constraints.
* Removes deprecated API calls.

## 2.1.2

* Updates links for the merge of flutter/plugins into flutter/packages.
* Updates minimum Flutter version to 3.0.

## 2.1.1

* Updates imports for `prefer_relative_imports`.
* Updates minimum Flutter version to 2.10.

## 2.1.0

* Adds a new `launchUrl` method corresponding to the new app-facing interface.

## 2.0.5

* Updates code for new analysis options.
* Update to use the `verify` method introduced in platform_plugin_interface 2.1.0.

## 2.0.4

* Silenced warnings that may occur during build when using a very
  recent version of Flutter relating to null safety.

## 2.0.3

* Migrate `pushRouteNameToFramework` to use ChannelBuffers API.

## 2.0.2

* Update platform_plugin_interface version requirement.

## 2.0.1

* Fix SDK range.

## 2.0.0

* Migrate to null safety.

## 1.0.10

* Update Flutter SDK constraint.

## 1.0.9

* Laid the groundwork for introducing a Link widget.

## 1.0.8

* Added webOnlyWindowName parameter

## 1.0.7

* Update lower bound of dart dependency to 2.1.0.

## 1.0.6

* Make the pedantic dev_dependency explicit.

## 1.0.5

* Make the `PlatformInterface` `_token` non `const` (as `const` `Object`s are not unique).

## 1.0.4

* Use the common PlatformInterface code from plugin_platform_interface.
* [TEST ONLY BREAKING CHANGE] remove UrlLauncherPlatform.isMock, we're not increasing the major version
  as doing so for platform interfaces has bad implications, given that this is only going to break
  test code, and that the plugin is young and shouldn't have third-party users we've decided to land
  this as a patch bump.

## 1.0.3

* Minor DartDoc changes and add a lint for missing DartDocs.

## 1.0.2

* Use package URI in test directory to import code from lib.

## 1.0.1

* Enforce that UrlLauncherPlatform isn't implemented with `implements`.

## 1.0.0

* Initial release.
