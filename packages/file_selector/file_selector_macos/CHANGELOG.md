## NEXT

* Updates minimum supported SDK version to Flutter 3.22/Dart 3.4.

## 0.9.4+2

* Updates Pigeon for non-nullable collection type support.

## 0.9.4+1

* Adds privacy manifest.
* Updates minimum supported SDK version to Flutter 3.19/Dart 3.3.

## 0.9.4

* Adds Swift Package Manager compatibility.
* Updates minimum supported SDK version to Flutter 3.13/Dart 3.1.

## 0.9.3+3

* Fixes handling of unknown file extensions on macOS 11+.

## 0.9.3+2

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.
* Migrates `styleFrom` usage in examples off of deprecated `primary` and `onPrimary` parameters.

## 0.9.3+1

* Updates to the latest version of `pigeon`.

## 0.9.3

* Adds `getSaveLocation` and deprecates `getSavePath`.
* Updates minimum supported macOS version to 10.14.

## 0.9.2

* Adds support for MIME types on macOS 11+.

## 0.9.1+1

* Updates references to the deprecated `macUTIs`.

## 0.9.1

* Adds `getDirectoryPaths` implementation.

## 0.9.0+8

* Updates pigeon for null value handling fixes.
* Updates minimum Flutter version to 3.3.

## 0.9.0+7

* Updates to `pigeon` version 9.

## 0.9.0+6

* Clarifies explanation of endorsement in README.
* Aligns Dart and Flutter SDK constraints.

## 0.9.0+5

* Updates links for the merge of flutter/plugins into flutter/packages.
* Updates example code for `use_build_context_synchronously` lint.
* Updates minimum Flutter version to 3.0.

## 0.9.0+4

* Converts platform channel to Pigeon.

## 0.9.0+3

* Changes XTypeGroup initialization from final to const.

## 0.9.0+2

* Updates imports for `prefer_relative_imports`.
* Updates minimum Flutter version to 2.10.

## 0.9.0+1

* Updates README for endorsement.
* Updates `flutter_test` to be a `dev_dependencies` entry.

## 0.9.0

* **BREAKING CHANGE**: Methods that take `XTypeGroup`s now throw an
  `ArgumentError` if any group is not a wildcard (all filter types null or
  empty), but doesn't include any of the filter types supported by macOS.
* Ignores deprecation warnings for upcoming styleFrom button API changes.

## 0.8.2+2

* Updates references to the obsolete master branch.

## 0.8.2+1

* Removes unnecessary imports.
* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 0.8.2

* Moves source to flutter/plugins.
* Adds native unit tests.
* Converts native implementation to Swift.
* Switches to an internal method channel implementation.

## 0.0.4+1

* Update README

## 0.0.4

* Treat empty filter lists the same as null.

## 0.0.3

* Fix README

## 0.0.2

* Update SDK constraint to signal compatibility with null safety.

## 0.0.1

* Initial macOS implementation of `file_selector`.
