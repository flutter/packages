## 1.1.5

* Updates to Pigeon 13.

## 1.1.4

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.
* Fixes stale ignore: prefer_const_constructors.
* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.

## 1.1.3

* Migrates internal implementation to Pigeon.
* Updates minimum supported SDK version to Flutter 3.3/Dart 2.18.

## 1.1.2

* Internal refactoring for maintainability.

## 1.1.1

* Clarifies explanation of endorsement in README.
* Aligns Dart and Flutter SDK constraints.

## 1.1.0

* Updates minimum Flutter version to 3.3 and iOS 11.

## 1.0.13

* Updates links for the merge of flutter/plugins into flutter/packages.
* Updates minimum Flutter version to 3.0.

## 1.0.12

* Adds compatibility with `intl` 0.18.0.

## 1.0.11

* Fixes issue where failed authentication was failing silently

## 1.0.10

* Updates imports for `prefer_relative_imports`.
* Updates minimum Flutter version to 2.10.

## 1.0.9

* Fixes avoid_redundant_argument_values lint warnings and minor typos.

## 1.0.8

* Updates `local_auth_platform_interface` constraint to the correct minimum
  version.

## 1.0.7

* Updates references to the obsolete master branch.

## 1.0.6

* Suppresses warnings for pre-iOS-11 codepaths.

## 1.0.5

* Removes unnecessary imports.
* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 1.0.4

* Fixes `deviceSupportsBiometrics` to return true when biometric hardware
  is available but not enrolled.

## 1.0.3

* Adopts `Object.hash`.

## 1.0.2

* Adds support `localizedFallbackTitle` in authenticateWithBiometrics on iOS.

## 1.0.1

* BREAKING CHANGE: Changes `stopAuthentication` to always return false instead of throwing an error.

## 1.0.0

* Initial release from migration to federated architecture.
