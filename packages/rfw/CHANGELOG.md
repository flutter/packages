## 1.0.25
* Adds support for wildget builders.

## 1.0.24

* Adds `InkResponse` material widget.
* Adds `Material` material widget.
* Adds the `child` to `Opacity` core widget.
* Implements more `InkWell` parameters.

## 1.0.23

* Replaces usage of deprecated Flutter APIs.

## 1.0.22

* Adds more testing to restore coverage to 100%.
* Format documentation.

## 1.0.21

* Adds support for subscribing to the root of a `DynamicContent` object.

## 1.0.20

* Adds `OverflowBox` material widget.
* Updates `ButtonBar` material widget implementation.

## 1.0.19

* Add `DropdownButton` and `ClipRRect` widgets to rfw widget library.

## 1.0.18

* Exposes `WidgetLibrary`s registered in `Runtime`.
* Exposes widgets map in `LocalWidgetLibrary`.

## 1.0.17

* Adds support for tracking source locations of `BlobNode`s and
  finding `BlobNode`s from the widget tree (`BlobNode.source` and
  `Runtime.blobNodeFor` respectively).

## 1.0.16

* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.
* Fixes lint warnings.

## 1.0.15

* Updates README.md to point to the CONTRIBUTING.md file.
* Introduces CONTRIBUTING.md, and adds more information about golden testing.

## 1.0.14

* Adds pub topics to package metadata.

## 1.0.13

* Block comments in RFW's text format. (`/*...*/`)

## 1.0.12

* Improves web compatibility.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.
* Adds more testing to restore coverage to 100%.
* Removes some dead code.

## 1.0.11

* Adds more documentation in the README.md file!
* Adds automated verification of the sample code in the README.

## 1.0.10

* Fixes stale ignore: `prefer_const_constructors`.
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
