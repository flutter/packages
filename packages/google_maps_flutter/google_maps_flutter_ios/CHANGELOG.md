## 2.3.5

* Updates minimum required plugin_platform_interface version to 2.1.7.

## 2.3.4

* Fixes new lint warnings.

## 2.3.3

* Adds support for version 8 of the Google Maps SDK in apps targeting iOS 14+.
* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.

## 2.3.2

* Fixes an issue where the onDragEnd callback for marker is not called.

## 2.3.1

* Adds pub topics to package metadata.

## 2.3.0

* Adds implementation for `cloudMapId` parameter to support cloud-based maps styling.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.
* Fixes unawaited_futures violations.

## 2.2.3

* Removes obsolete null checks on non-nullable values.
* Updates minimum supported SDK version to Flutter 3.3/Dart 2.18.

## 2.2.2

* Sets an upper bound on the `GoogleMaps` SDK version that can be used, to
  avoid future breakage.

## 2.2.1

* Clarifies explanation of endorsement in README.
* Aligns Dart and Flutter SDK constraints.

## 2.2.0

* Updates minimum Flutter version to 3.3 and iOS 11.

## 2.1.14

* Updates links for the merge of flutter/plugins into flutter/packages.

## 2.1.13

* Updates code for stricter lint checks.
* Updates code for new analysis options.
* Re-enable XCUITests: testUserInterface.
* Remove unnecessary `RunnerUITests` target from Podfile of the example app.

## 2.1.12

* Updates imports for `prefer_relative_imports`.
* Updates minimum Flutter version to 2.10.
* Fixes violations of new analysis option use_named_constants.
* Fixes avoid_redundant_argument_values lint warnings and minor typos.

## 2.1.11

* Precaches Google Maps services initialization and syncing.

## 2.1.10

* Splits iOS implementation out of `google_maps_flutter` as a federated
  implementation.
