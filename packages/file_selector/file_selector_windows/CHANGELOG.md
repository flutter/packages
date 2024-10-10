## 0.9.3+3

* Updates Pigeon for non-nullable collection type support.
* Updates minimum supported SDK version to Flutter 3.19/Dart 3.3.

## 0.9.3+2

* Updates to pigeon 21.
* Updates minimum supported SDK version to Flutter 3.16/Dart 3.2.

## 0.9.3+1

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.
* Migrates `styleFrom` usage in examples off of deprecated `primary` and `onPrimary` parameters.

## 0.9.3

* Adds `getSaveLocation` and deprecates `getSavePath`.

## 0.9.2

* Adds `getDirectoryPaths` implementation.

## 0.9.1+8

* Sets a cmake_policy compatibility version to fix build warnings.
* Updates minimum Flutter version to 3.3.

## 0.9.1+7

* Updates to `pigeon` version 9.

## 0.9.1+6

* Clarifies explanation of endorsement in README.
* Aligns Dart and Flutter SDK constraints.

## 0.9.1+5

* Updates links for the merge of flutter/plugins into flutter/packages.
* Updates example code for `use_build_context_synchronously` lint.
* Updates minimum Flutter version to 3.0.

## 0.9.1+4

* Changes XTypeGroup initialization from final to const.

## 0.9.1+3

* Updates imports for `prefer_relative_imports`.
* Updates minimum Flutter version to 2.10.

## 0.9.1+2

* Fixes the problem that the initial directory does not work after completing a file selection.

## 0.9.1+1

* Updates README for endorsement.
* Updates `flutter_test` to be a `dev_dependencies` entry.

## 0.9.1

* Converts the method channel to Pigeon.

## 0.9.0

* **BREAKING CHANGE**: Methods that take `XTypeGroup`s now throw an
  `ArgumentError` if any group is not a wildcard (all filter types null or
  empty), but doesn't include any of the filter types supported by Windows.
* Ignores deprecation warnings for upcoming styleFrom button API changes.

## 0.8.2+2

* Updates references to the obsolete master branch.

## 0.8.2+1

* Removes unnecessary imports.
* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 0.8.2

* Moves source to flutter/plugins, and restructures to allow for unit testing.
* Switches to an internal method channel implementation.

## 0.0.2+1

* Update README

## 0.0.2

* Update SDK constraint to signal compatibility with null safety.

## 0.0.1

* Initial Windows implementation of `file_selector`.
