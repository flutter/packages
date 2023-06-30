## 1.0.10

* Fixes stale ignore: prefer_const_constructors.
* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.
* Changes package internals to avoid explicit `as Uint8List` downcast.

## 1.0.9

* Updates minimum supported SDK version to Flutter 3.3/Dart 2.18.
* Aligns Dart and Flutter SDK constraints.
* Fixes a typo in the API documentation that broke the formatting.

## 1.0.8

* Removes use of `runtimeType.toString()`.
* Updates code to fix strict-cast violations.

## 1.0.7

* Updates README.

## 1.0.6

* Temporarily lowers test coverage minimum to fix flutter roll.
* Disables golden testing due to https://github.com/flutter/flutter/issues/106205.
* Fixes lint warnings.

## 1.0.5

* Fixes URL in document.

## 1.0.4

* Migrates from `ui.hash*` to `Object.hash*`.

## 1.0.3

* Transitions internal testing from a command line lcov tool to a
  Dart tool. No effect on consumers.
* Removes unsupported platforms from the wasm example.
* Updates for non-nullable bindings.

## 1.0.2

* Mentions FractionallySizedBox in documentation.

## 1.0.1

* Improves documentation.
* Provides constants for the file signatures.
* Minor efficiency improvements.
* Fixes `unnecessary_import` lint errors.
* Adds one more core widget, FractionallySizedBox.

## 1.0.0

* Initial release.
