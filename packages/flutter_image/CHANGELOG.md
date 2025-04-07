## 4.1.12

* Updates README to indicate that this package will be discontinued.
* Updates minimum supported SDK version to Flutter 3.22/Dart 3.4.

## 4.1.11

* Replaces deprecated loadBuffer API usage.

## 4.1.10

* Fixes image asset link to use image within package.
* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.
* Updates README to improve example of using `NetworkImageWithRetry`.

## 4.1.9

* Adds an example app.

## 4.1.8

* Adds pub topics to package metadata.
## 4.1.7

* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.
* Migrates deprecated `ImageProvider.load` to `ImageProvider.loadBuffer`.

## 4.1.6

* Fixes unawaited_futures violations.
* Updates minimum supported SDK version to Flutter 3.3/Dart 2.18.
* Aligns Dart and Flutter SDK constraints.

## 4.1.5

* Removes use of `runtimeType.toString()`.

## 4.1.4

* Ignores lint warnings from new changes in Flutter master.
* Suppresses more deprecation warnings for changes to Flutter master.
* Removes duplicate test from test script.
* Fixes lint warnings.

## 4.1.3

* Suppresses deprecation warnings.

## 4.1.2

* Migrates from `ui.hash*` to `Object.hash*`.

## 4.1.1

* Updates package description.
* Updates for non-nullable bindings.

## 4.1.0

- Added custom header support.

## 4.0.1

- Moved source to flutter/packages

## 4.0.0

- Migrates to null safety
- **Breaking change**: `NetworkImageWithRetry.load` now throws a `FetchFailure` if the fetched image data is zero bytes.

## 3.0.0

* **Breaking change**. Updates for Flutter 1.10.15.

## 2.0.1

- Update Flutter SDK version constraint.

## 2.0.0

* **Breaking change**. Updates for Flutter 1.5.9.

## 1.0.0

* **Breaking change**. SDK constraints to support Flutter beta versions and Dart 2 only.

## 0.0.3

- Moved `flutter_test` to dev_dependencies in `pubspec.yaml`, and fixed issues
flagged by the analyzer.

## 0.0.2

- Add `NetworkImageWithRetry`, an `ImageProvider` with a retry mechanism.

## 0.0.1

- Contains no useful code.
