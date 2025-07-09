## NEXT

* Updates minimum supported SDK version to Flutter 3.27/Dart 3.6.

## 2.4.3

* Fixes issue where non-JSON formatted strings cause parsing errors.

## 2.4.2

* Fixes `getStringList` returning immutable list.
* Updates minimum supported SDK version to Flutter 3.22/Dart 3.4.

## 2.4.1

* Adds support for `web: ^1.0.0`.

## 2.4.0

* Adds `SharedPreferencesAsyncWeb` API.

## 2.3.0

* Updates web code to package `web: ^0.5.0`.
* Updates SDK version to Dart `^3.3.0`. Flutter `^3.19.0`.

## 2.2.2

* Updates minimum supported SDK version to Dart 3.2.

## 2.2.1

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 2.2.0

* Adds `clearWithParameters` and `getAllWithParameters` methods.
* Updates minimum supported SDK version to Flutter 3.3/Dart 2.18.

## 2.1.0

* Adds `getAllWithPrefix` and `clearWithPrefix` methods.

## 2.0.6

* Clarifies explanation of endorsement in README.
* Aligns Dart and Flutter SDK constraints.

## 2.0.5

* Updates links for the merge of flutter/plugins into flutter/packages.
* Updates minimum Flutter version to 3.0.

## 2.0.4

* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 2.0.3

* Fixes newly enabled analyzer options.
* Removes dependency on `meta`.

## 2.0.2

* Add `implements` to pubspec.

## 2.0.1

* Updated installation instructions in README.
* Move tests to `example` directory, so they run as integration_tests with `flutter drive`.

## 2.0.0

* Migrate to null-safety.

## 0.1.2+8

* Update Flutter SDK constraint.

## 0.1.2+7

* Removed Android folder from `shared_preferences_web`.

## 0.1.2+6

* Update lower bound of dart dependency to 2.1.0.

## 0.1.2+5

* Declare API stability and compatibility with `1.0.0` (more details at: https://github.com/flutter/flutter/wiki/Package-migration-to-1.0.0).

## 0.1.2+4

* Make the pedantic dev_dependency explicit.

## 0.1.2+3

* Bump gradle version to avoid bugs with android projects

# 0.1.2+2

* Remove unused onMethodCall method.

# 0.1.2+1

* Add an android/ folder with no-op implementation to workaround https://github.com/flutter/flutter/issues/46898.

# 0.1.2

* Bump lower constraint on Flutter version.
* Add stub podspec file.

# 0.1.1

* Adds a `shared_preferences_macos` package.

# 0.1.0+1

- Remove the deprecated `author:` field from pubspec.yaml
- Require Flutter SDK 1.10.0 or greater.

# 0.1.0

- Initial release.
