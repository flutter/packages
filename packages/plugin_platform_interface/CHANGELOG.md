## NEXT

* Updates minimum supported SDK version to Flutter 3.22/Dart 3.4.

## 2.1.8

* Fixes new lint warnings.

## 2.1.7

* Changes `MockPlatformInterfaceMixin` to a `mixin class` for better
  compatibility with projects that have a minumum Dart SDK version of 3.0.
* Updates minimum supported SDK version to Dart 3.0.

## 2.1.6

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 2.1.5

* Updates README to improve example and discuss `base`.
* Updates minimum Flutter version to 3.3.

## 2.1.4

* Updates links for the merge of flutter/plugins into flutter/packages.
* Updates minimum supported Dart version.

## 2.1.3

* Minor fixes for new analysis options.
* Adds additional tests for `PlatformInterface` and `MockPlatformInterfaceMixin`.
* Modifies `PlatformInterface` to use an expando for detecting if a customer
  tries to implement PlatformInterface using `implements` rather than `extends`.
  This ensures that `verify` will continue to work as advertized after
  https://github.com/dart-lang/language/issues/2020 is implemented.

## 2.1.2

* Updates README to demonstrate `verify` rather than `verifyToken`, and to note
  that the test mixin applies to fakes as well as mocks.
* Adds an additional test for `verifyToken`.

## 2.1.1

* Fixes `verify` to work with fake objects, not just mocks.

## 2.1.0

* Introduce `verify`, which prevents use of `const Object()` as instance token.
* Add a comment indicating that `verifyToken` will be deprecated in a future release.

## 2.0.2

* Update package description.

## 2.0.1

* Fix `federated flutter plugins` link in the README.md.

## 2.0.0

* Migrate to null safety.

## 1.0.3

* Fix homepage in `pubspec.yaml`.

## 1.0.2

* Make the pedantic dev_dependency explicit.

## 1.0.1

* Fixed a bug that made all platform interfaces appear as mocks in release builds (https://github.com/flutter/flutter/issues/46941).

## 1.0.0 - Initial release.

* Provides `PlatformInterface` with common mechanism for enforcing that a platform interface
  is not implemented with `implements`.
* Provides test only `MockPlatformInterface` to enable using Mockito to mock platform interfaces.
