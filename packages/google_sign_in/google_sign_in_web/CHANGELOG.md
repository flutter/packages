## 0.12.4+3

* Fixes callback types for `TokenClientConfig`.

## 0.12.4+2

* Adds support for `web: ^1.0.0`.

## 0.12.4+1

* Fixes README.md typo.

## 0.12.4

* Updates dependencies to `web: ^0.5.0` and `google_identity_services_web: ^0.3.1`.

## 0.12.3+3

* Updates SDK version to Dart `^3.3.0`. Flutter `^3.19.0`.
* Prepares update to package `web: ^0.5.0`.

## 0.12.3+2

* Fixes new lint warnings.

## 0.12.3+1

* Updates `FlexHtmlElementView` (the widget backing `renderButton`) to not
  rely on web engine knowledge (a platform view CSS selector) to operate.

## 0.12.3

* Migrates to `package:web`.
* Updates minimum supported SDK version to Flutter 3.16.0/Dart 3.2.0.

## 0.12.2+1

* Re-publishes `0.12.2` with a small fix to the CodeClient initialization.

## 0.12.2 (withdrawn)

* Adds server auth code retrieval to google_sign_in_web.
* Adds `web_only` library to access web-only methods more easily.

## 0.12.1

* Enables FedCM on browsers that support this authentication mechanism.
* Uses the expiration timestamps of Credential and Token responses to improve
  the accuracy of `isSignedIn` and `canAccessScopes` methods.
* Deprecates `signIn()` method.
  * Users should migrate to `renderButton` and `silentSignIn`, as described in
    the README.

## 0.12.0+5

* Migrates to `dart:ui_web` APIs.
* Updates minimum supported SDK version to Flutter 3.13.0/Dart 3.1.0.

## 0.12.0+4

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 0.12.0+3

* Fixes null cast error on accounts without picture or name details.

## 0.12.0+2

* Adds compatibility with `http` 1.0.

## 0.12.0+1

* Fixes unawaited_futures violations.

## 0.12.0

* Authentication:
  * Adds web-only `renderButton` method and its configuration object, as a new
    authentication mechanism.
  * Prepares a `userDataEvents` Stream, so the Google Sign In Button can propagate
    authentication changes to the core plugin.
  * **Breaking Change:** `signInSilently` now returns an authenticated (but not authorized) user.
* Authorization:
  * Implements the new `canAccessScopes` method.
  * Ensures that the `requestScopes` call doesn't trigger user selection when the
    current user is known (similar to what `signIn` does).
* Updates minimum Flutter version to 3.3.

## 0.11.0+2

* Clarifies explanation of endorsement in README.
* Aligns Dart and Flutter SDK constraints.

## 0.11.0+1

* Updates links for the merge of flutter/plugins into flutter/packages.

## 0.11.0

* **Breaking Change:** Migrates JS-interop to `package:google_identity_services_web`
  * Uses the new Google Identity Authentication and Authorization JS SDKs. [Docs](https://developers.google.com/identity).
    * Added "Migrating to v0.11" section to the `README.md`.
* Updates minimum Flutter version to 3.0.

## 0.10.2+1

* Updates code for `no_leading_underscores_for_local_identifiers` lint.
* Updates minimum Flutter version to 2.10.
* Renames generated folder to js_interop.

## 0.10.2

* Migrates to new platform-interface `initWithParams` method.
* Throws when unsupported `serverClientId` option is provided.

## 0.10.1+3

* Updates references to the obsolete master branch.

## 0.10.1+2

* Minor fixes for new analysis options.

## 0.10.1+1

* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 0.10.1

* Updates minimum Flutter version to 2.8.
* Passes `plugin_name` to Google Sign-In's `init` method so new applications can
  continue using this plugin after April 30th 2022. Issue [#88084](https://github.com/flutter/flutter/issues/88084).

## 0.10.0+5

* Internal code cleanup for stricter analysis options.

## 0.10.0+4

* Removes dependency on `meta`.

## 0.10.0+3

* Updated URL to the `google_sign_in` package in README.

## 0.10.0+2

* Add `implements` to pubspec.

## 0.10.0+1

* Updated installation instructions in README.

## 0.10.0

* Migrate to null-safety.

## 0.9.2+1

* Update Flutter SDK constraint.

## 0.9.2

* Throw PlatformExceptions from where the GMaps SDK may throw exceptions: `init()` and `signIn()`.
* Add two new JS-interop types to be able to unwrap JS errors in release mode.
* Align the fields of the thrown PlatformExceptions with the mobile version.
* Migrate tests to run with `flutter drive`

## 0.9.1+2

* Update package:e2e reference to use the local version in the flutter/plugins
  repository.

## 0.9.1+1

* Remove Android folder from `google_sign_in_web`.

## 0.9.1

* Ensure the web code returns `null` when the user is not signed in, instead of a `null-object` User. Fixes [issue 52338](https://github.com/flutter/flutter/issues/52338).

## 0.9.0

* Add support for methods introduced in `google_sign_in_platform_interface` 1.1.0.

## 0.8.4

* Remove all `fakeConstructor$` from the generated facade. JS interop classes do not support non-external constructors.

## 0.8.3+2

* Make the pedantic dev_dependency explicit.

## 0.8.3+1

* Updated documentation with more instructions about Google Sign In web setup.

## 0.8.3

* Fix initialization error that causes https://github.com/flutter/flutter/issues/48527
* Throw a PlatformException when there's an initialization problem (like wrong server-side config).
* Throw a StateError when checking .initialized before calling .init()
* Update setup instructions in the README.

## 0.8.2+1

* Add a non-op Android implementation to avoid a flaky Gradle issue.

## 0.8.2

* Require Flutter SDK 1.12.13+hotfix.4 or greater.

## 0.8.1+2

* Remove the deprecated `author:` field from pubspec.yaml
* Require Flutter SDK 1.10.0 or greater.

## 0.8.1+1

* Add missing documentation.

## 0.8.1

* Add podspec to enable compilation on iOS.

## 0.8.0

* Flutter for web initial release
