## NEXT

* Updates minimum supported SDK version to Flutter 3.38/Dart 3.10.
* Updates README to reflect currently supported OS versions for the latest
  versions of the endorsed platform implementations.
  * Applications built with older versions of Flutter will continue to
    use compatible versions of the platform implementations.

## 6.3.2

* Updates README to indicate that Andoid SDK <21 is no longer supported.
* Updates minimum supported SDK version to Flutter 3.27/Dart 3.6.
* Ensures that `launch` with `forceSafariVC: false`, `forceWebView: true` and a non-web scheme throws a `PlatformException`.

## 6.3.1

* Removes incorrect SMS instructions from README.
* Updates minimum supported SDK version to Flutter 3.19/Dart 3.3.

## 6.3.0

* Adds `BrowserConfiguration` parameter, to configure in-app browser views, such as Android Custom Tabs or SFSafariViewController.
* Adds `showTitle` to `BrowserConfiguration`, to allow showing webpage titles in in-app browser views.
* Updates minimum supported SDK version to Flutter 3.16/Dart 3.2.

## 6.2.6

* Updates minimum iOS implementation version to include a privacy manifest.

## 6.2.5

* Removes use of deprecated `renderView` API.

## 6.2.4

* Updates support matrix in README to indicate that iOS 11 is no longer supported.
* Clients on versions of Flutter that still support iOS 11 can continue to use this
  package with iOS 11, but will not receive any further updates to the iOS implementation.
* Fixes a grammar error in the comments of `launchUrl` method.

## 6.2.3

* Updates minimum required plugin_platform_interface version to 2.1.7.

## 6.2.2

* Adds a link about web limitations to the `url_launcher_web` package in the
  `url_launcher` `README.md` and `launchUrl` method.

## 6.2.1

* Fixes incorrect types in `supportsLaunchMode` and
  `supportsCloseForLaunchMode`.

## 6.2.0

_Retracted due to incorrect types in new APIs._

* Adds `supportsLaunchMode` for checking whether the current platform supports a
  given launch mode, to allow clients that will only work with specific modes
  to avoid fallback to a different mode.
* Adds `supportsCloseForLaunchMode` to allow checking programatically if a
  launched URL will be able to be closed. Previously the documented behvaior was
  that it worked only with the `inAppWebView` launch mode, but this is no longer
  true on all platforms with the addition of `inAppBrowserView`.
* Updates the documention for `launchUrl` to clarify that clients should not
  rely on any specific behavior of the `platformDefault` launch mode. Changes
  to the handling of `platformDefault`, such as Android's recent change from
  `inAppWebView` to the new `inAppBrowserView`, are not considered breaking.
* Updates minimum supported SDK version to Flutter 3.13.

## 6.1.14

* Updates documentation to mention support for Android Custom Tabs.

## 6.1.13

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 6.1.12

* Removes the use of `canLaunchUrl` in `Link`, to avoid issues on platforms where `canLaunchUrl` is unreliable or requires permissions.
* Updates minimum supported macOS version to 10.14.
* Fixes stale ignore: prefer_const_constructors.
* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.

## 6.1.11

* Fixes some url_launcher docs that were missing the null operator (?).
* Updates minimum Flutter version to 3.3.
* Aligns Dart and Flutter SDK constraints.

## 6.1.10

* Updates links for the merge of flutter/plugins into flutter/packages.

## 6.1.9

* Updates minimum Flutter version to 3.0.
* Updates iOS minimum version in README.

## 6.1.8

* Updates code for stricter lint checks.

## 6.1.7

* Updates code for new analysis options.

## 6.1.6

* Updates imports for `prefer_relative_imports`.
* Updates minimum Flutter version to 2.10.
* Fixes avoid_redundant_argument_values lint warnings and minor typos.

## 6.1.5

* Migrates `README.md` examples to the [`code-excerpt` system](https://github.com/flutter/flutter/wiki/Contributing-to-Plugins-and-Packages#readme-code).

## 6.1.4

* Adopts new platform interface method for launching URLs.
* Ignores unnecessary import warnings in preparation for [upcoming Flutter changes](https://github.com/flutter/flutter/pull/105648).

## 6.1.3

* Updates README section about query permissions to better reflect changes to
  `canLaunchUrl` recommendations.

## 6.1.2

* Minor fixes for new analysis options.

## 6.1.1

* Removes unnecessary imports.
* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 6.1.0

* Introduces new `launchUrl` and `canLaunchUrl` APIs; `launch` and `canLaunch`
  are now deprecated. These new APIs:
  * replaces the `String` URL argument with a `Uri`, to prevent common issues
    with providing invalid URL strings.
  * replaces `forceSafariVC` and `forceWebView` with `LaunchMode`, which makes
    the API platform-neutral, and standardizes the default behavior between
    Android and iOS.
  * moves web view configuration options into a new `WebViewConfiguration`
    object. The default behavior for JavaScript and DOM storage is now enabled
    rather than disabled.
* Also deprecates `closeWebView` in favor of `closeInAppWebView` to clarify
  that it is specific to the in-app web view launch option.
* Adds OS version support information to README.
* Reorganizes and clarifies README.

## 6.0.20

* Fixes a typo in `default_package` registration for Windows, macOS, and Linux.

## 6.0.19

* Updates README:
  * Adds description for `file` scheme usage.
  * Updates `Uri` class link to SDK documentation.

## 6.0.18

* Removes dependency on `meta`.

## 6.0.17

* Updates code for new analysis options.

## 6.0.16

* Moves Android and iOS implementations to federated packages.

## 6.0.15

* Updates README:
  * Improves organization.
  * Clarifies how `canLaunch` should be used.
* Updates example application to demonstrate intended use of `canLaunch`.

## 6.0.14

* Updates readme to indicate that sending SMS messages on Android 11 requires to add a query to AndroidManifest.xml.
* Fixes integration tests.
* Updates example app Android compileSdkVersion to 31.

## 6.0.13

* Fixes extracting browser headers when they are null error.

## 6.0.12

* Fixes an error where 'launch' method of url_launcher would cause an error if the provided URL was not valid by RFC 3986.

## 6.0.11

* Updates minimum Flutter SDK to 2.5 and iOS deployment target to 9.0.
* Updates Android lint settings.

## 6.0.10

* Removes references to the Android v1 embedding.

## 6.0.9

* Silences warnings that may occur during build when using a very
  recent version of Flutter relating to null safety.

## 6.0.8

* Adds API level 30 required package visibility configuration to the example's AndroidManifest.xml and README.
* Fixes test button check for iOS 15.

## 6.0.7

* Updates the README to describe a workaround to the `Uri` query
  encoding bug.

## 6.0.6

* Requires `url_launcher_platform_interface` 2.0.3. This fixes an issue
  where 6.0.5 could fail to compile in some projects due to internal
  changes in that version that were not compatible with earlier versions
  of `url_launcher_platform_interface`.

## 6.0.5

* Adds iOS unit and UI integration test targets.
* Adds a `Link` widget to the example app.

## 6.0.4

* Migrates maven repository from jcenter to mavenCentral.

## 6.0.3

* Updates README notes about URL schemes on iOS.

## 6.0.2

* Updates platform_plugin_interface version requirement.

## 6.0.1

* Updates result to `True` on iOS when the url was loaded successfully.
* Adds a README note about required applications.

## 6.0.0

* Migrates to null safety.
* Fixes outdated links across a number of markdown files ([#3276](https://github.com/flutter/plugins/pull/3276)).
* Updates the example app: remove the deprecated `RaisedButton` and `FlatButton` widgets.
* Correct statement in description about which platforms url_launcher supports.

## 5.7.13

* Updates Flutter SDK constraint.

## 5.7.12

* Updates code sample in `README.md`.

## 5.7.11

* Updates integration test examples to use `testWidgets` instead of `test`.

## 5.7.10

* Updates Dart SDK constraint in example.

## 5.7.9

* Check in windows/ directory for example/.

## 5.7.8

* Fixes a situation where an app would crash if the url_launcher’s `launch` method can’t find an app to open the provided url. It will now throw a clear Dart PlatformException.

## 5.7.7

* Introduces the Link widget with an implementation for native platforms.

## 5.7.6

* Suppress deprecation warning on the `shouldOverrideUrlLoading` method on Android of the `FlutterWebChromeClient` class.

## 5.7.5

* Improves documentation of the `headers` parameter.

## 5.7.4

* Updates android compileSdkVersion to 29.

## 5.7.3

* Check in linux/ directory for example/.

## 5.7.2

* Adds API documentation explaining the [canLaunch] method returns `false` if package visibility (Android API 30) is not managed correctly.

## 5.7.1

* Keeps handling deprecated Android v1 classes for backward compatibility.

## 5.7.0

* Handles WebView multi-window support.

## 5.6.0

* Supports Windows by default.

## 5.5.3

* Suppress deprecation warning on the `shouldOverrideUrlLoading` method on Android.

## 5.5.2

* Depend explicitly on the `platform_interface` package that adds the `webOnlyWindowName` parameter.

## 5.5.1

* Adds webOnlyWindowName parameter to launch().

## 5.5.0

* Supports Linux by default.

## 5.4.11

* Adds documentation in README suggesting how to properly encode urls with special characters.

## 5.4.10

* Post-v2 Android embedding cleanups.

## 5.4.9

* Updates README.

## 5.4.8

* Initialize `previousAutomaticSystemUiAdjustment` in launch method.

## 5.4.7

* Updates lower bound of dart dependency to 2.1.0.

## 5.4.6

* Adds `web` to the example app.

## 5.4.5

* Removes Android dependencies fallback.
* Requires Flutter SDK 1.12.13+hotfix.5 or greater.
* Fixes CocoaPods podspec lint warnings.

## 5.4.4

* Replaces deprecated `getFlutterEngine` call on Android.

## 5.4.3

* Fixes the launchUniversalLinkIos method.

## 5.4.2

* Makes the pedantic dev_dependency explicit.

## 5.4.1

* Updates unit tests to work with the PlatformInterface from package `plugin_platform_interface`.

## 5.4.0

* Supports macOS by default.

## 5.3.0

* Supports web by default.
* Uses the new plugins pubspec schema.

## 5.2.7

* Minor unit test changes and added a lint for public DartDocs.

## 5.2.6

*  Removes AndroidX warnings.

## 5.2.5

* Include lifecycle dependency as a compileOnly one on Android to resolve
  potential version conflicts with other transitive libraries.

## 5.2.4

* Uses `package:url_launcher_platform_interface` to get the platform-specific implementation.

## 5.2.3

* Android: Use android.arch.lifecycle instead of androidx.lifecycle:lifecycle in `build.gradle` to support apps that has not been migrated to AndroidX.

## 5.2.2

* Re-land embedder v2 support with correct Flutter SDK constraints.

## 5.2.1

* Reverts the migration since the Flutter dependency was too low.

## 5.2.0

* Migrates the plugin to use the V2 Android engine embedding. This shouldn't
  affect existing functionality. Plugin authors who use the V2 embedding can now
  instantiate the plugin and expect that it correctly responds to app lifecycle
  changes.

## 5.1.7

* Define clang module for iOS.

## 5.1.6

* Fixes bug where androidx app won't build with this plugin by enabling androidx and jetifier in the android `gradle.properties`.

## 5.1.5

* Updates homepage url after moving to federated directory.

## 5.1.4

* Updates and migrates iOS example project.

## 5.1.3

* Always launch url from the top most UIViewController in iOS.

## 5.1.2

* Updates AGP and gradle.
* Split plugin and WebViewActivity class files.

## 5.1.1

* Suppress a handled deprecation warning on iOS.

## 5.1.0

* Adds `headers` field to enable headers in the Android implementation.

## 5.0.5

* Adds `enableDomStorage` field to `launch` to enable DOM storage in Android WebView.

## 5.0.4

* Updates Dart code to conform to current Dart formatter.

## 5.0.3

* Adds missing template type parameter to `invokeMethod` calls.
* Bumps minimum Flutter version to 1.5.0.
* Replaces invokeMethod with invokeMapMethod wherever necessary.

## 5.0.2

* Fixes `closeWebView` failure on iOS.

## 5.0.1

* Logs a more detailed warning at build time about the previous AndroidX
  migration.

## 5.0.0

* **BREAKING CHANGE:** Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

  This was originally incorrectly pushed in the `4.2.0` update.

## 4.2.0+3

* **Reverts the breaking 4.2.0 update**. 4.2.0 was known to be breaking and
  should have incremented the major version number instead of the minor. This
  revert is in and of itself breaking for anyone that has already migrated
  however. Anyone who has already migrated their app to AndroidX should
  immediately update to `5.0.0` instead. That's the correctly versioned new push
  of `4.2.0`.

## 4.2.0+2

* Updates `launch` to use async and await, fixed the incorrect return value by `launch` method.

## 4.2.0+1

* Refactors the Java and Objective-C code. Replaced instance variables with properties in Objective-C.

## 4.2.0

* **BAD**. This was a breaking change that was incorrectly published on a minor
  version upgrade, should never have happened. Reverted by 4.2.0+3.

* **BREAKING CHANGE:** Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

## 4.1.0+1

* This is just a version bump to republish as 4.1.0 was published with some dirty local state.

## 4.1.0

* Adds `universalLinksOnly` setting.
* Updates `launch` to return `Future<bool>`.

## 4.0.3

* Fixes launch url fail for Android: `launch` now assert activity not null and using activity to startActivity.
* Fixes `WebViewActivity has leaked IntentReceiver` for Android.

## 4.0.2

* Adds `closeWebView` function to programmatically close the current WebView.

## 4.0.1

* Adds enableJavaScript field to `launch` to enable javascript in Android WebView.

## 4.0.0

* **Breaking change** Now requires a minimum Flutter version of 0.5.6.
* Updates to statusBarBrightness field so that the logic runs on the Flutter side.
* **Breaking change** statusBarBrightness no longer has a default value.

## 3.0.3

* Adds statusBarBrightness field to `launch` to set iOS status bar brightness.

## 3.0.2

* Updates Gradle tooling to match Android Studio 3.1.2.

## 3.0.1

* Fixes a crash during Safari view controller dismiss.

## 3.0.0

* **BREAKING CHANGE:** Set SDK constraints to match the Flutter beta release.

## 2.0.2

* Fixes Dart 2 issue: `launch` now returns `Future<void>` instead of
  `Future<Null>`.

## 2.0.1

* Simplifies and upgrades Android project template to Android SDK 27.
* Updates package description.

## 2.0.0

* **BREAKING CHANGE:** Upgrades to Gradle 4.1 and Android Studio Gradle plugin
  3.0.1. Older Flutter projects need to upgrade their Gradle setup as well in
  order to use this version of the plugin. Instructions can be found
  [here](https://github.com/flutter/flutter/wiki/Updating-Flutter-projects-to-Gradle-4.1-and-Android-Studio-Gradle-plugin-3.0.1).

## 1.0.3

* Adds FLT prefix to iOS types.

## 1.0.2

* Fixes handling of URLs in Android WebView.

## 1.0.1

* Supports option to launch default browser in iOS.
* Parse incoming url and decide on what to open based on scheme.
* Supports WebView on Android.

## 1.0.0

* iOS plugin presents a Safari view controller instead of switching to the Safari app.

## 0.4.2+5

* Aligns author name with rest of repo.

## 0.4.2+2, 0.4.2+3, 0.4.2+4

* Updates README.

## 0.4.2+1

* Updates README.

## 0.4.2

* Changes to README.md.

## 0.4.1

* Upgrades Android SDK Build Tools to 25.0.3.

## 0.4.0

* Upgrades to new plugin registration.

## 0.3.6

* Fixes workaround for failing dynamic check in Xcode 7/sdk version 9.

## 0.3.5

* Workaround for failing dynamic check in Xcode 7/sdk version 9.

## 0.3.4

* Adds test.

## 0.3.3

* Changes to buildToolsVersion.

## 0.3.2

* Changes to README.md.

## 0.3.1

* Changes to README.md.

## 0.3.0

* Adds `canLaunch` method.

## 0.2.0

* Changes `launch` to a top-level method instead of a static method in a class.

## 0.1.1

* Changes to README.md.

## 0.1.0

* Initial Open Source release.
