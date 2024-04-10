## 0.9.4+1

* Removes a few deprecated API usages.

## 0.9.4

* Updates web code to package `web: ^0.5.0`.
* Updates SDK version to Dart `^3.3.0`. Flutter `^3.16.0`.

## 0.9.3

* Updates minimum supported SDK version to Dart 3.2.

## 0.9.2+1

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 0.9.2

* Adds and propagates `cancel` event on file selection.
* Changes `openFile` to return `null` when no files are selected/selection is canceled,
  as in other platforms.

## 0.9.1

* Adds `getSaveLocation` and deprecates `getSavePath`.
* Updates minimum supported SDK version to Flutter 3.3/Dart 2.18.

## 0.9.0+4

* Clarifies explanation of endorsement in README.
* Aligns Dart and Flutter SDK constraints.

## 0.9.0+3

* Updates links for the merge of flutter/plugins into flutter/packages.
* Updates minimum Flutter version to 3.0.

## 0.9.0+2

* Changes XTypeGroup initialization from final to const.

## 0.9.0+1

* Updates imports for `prefer_relative_imports`.
* Updates minimum Flutter version to 2.10.
* Fixes avoid_redundant_argument_values lint warnings and minor typos.

## 0.9.0

* **BREAKING CHANGE**: Methods that take `XTypeGroup`s now throw an
  `ArgumentError` if any group is not a wildcard (all filter types null or
  empty), but doesn't include any of the filter types supported by web.

## 0.8.1+5

* Minor fixes for new analysis options.

## 0.8.1+4

* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 0.8.1+3

* Minor code cleanup for new analysis rules.
* Removes dependency on `meta`.

## 0.8.1+2

* Add `implements` to pubspec.

# 0.8.1+1

- Updated installation instructions in README.

# 0.8.1

- Return a non-null value from `getSavePath` for consistency with
  API expectations that null indicates canceling.

# 0.8.0

- Migrated to null-safety

# 0.7.0+1

- Add dummy `ios` dir, so flutter sdk can be lower than 1.20

# 0.7.0

- Initial open-source release.
