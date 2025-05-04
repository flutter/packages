## 5.8.0

* Updates minimum supported SDK version to Flutter 3.22/Dart 3.4.
* Adds Swift Package Manager compatibility.

## 5.7.8

* Updates Pigeon for non-nullable collection type support.

## 5.7.7

* Fixes "callee requires a non-null parameter" analyzer warning.
* Updates minimum supported SDK version to Flutter 3.19/Dart 3.3.

## 5.7.6

* Upgrades GoogleSignIn iOS SDK to 7.1.

## 5.7.5

* Pins GoogleSignIn to iOS SDK "7.0.0" while preparing the update to 7.1.

## 5.7.4

* Improves type handling in Objective-C code.
* Updates minimum iOS version to 12.0 and minimum Flutter version to 3.16.6.

## 5.7.3

* Adds privacy manifest.

## 5.7.2

* Updates `clearAuthCache` override to match base class declaration.

## 5.7.1

* Changes `pigeon` to a dev dependency.

## 5.7.0

* Adds support for macOS.
* Updates minimum supported SDK version to Flutter 3.16/Dart 3.2.

## 5.6.5

* Upgrades GoogleSignIn iOS SDK to 7.0.

## 5.6.4

* Converts platform communication to Pigeon.

## 5.6.3

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 5.6.2

* Updates functions without a prototype to avoid deprecation warning.

## 5.6.1

* Clarifies explanation of endorsement in README.
* Aligns Dart and Flutter SDK constraints.

## 5.6.0

* Updates minimum Flutter version to 3.3 and iOS 11.

## 5.5.2

* Updates links for the merge of flutter/plugins into flutter/packages.
* Updates minimum Flutter version to 3.0.

## 5.5.1

* Fixes passing `serverClientId` via the channelled `init` call
* Updates minimum Flutter version to 2.10.

## 5.5.0

* Adds override for `GoogleSignInPlatform.initWithParams`.

## 5.4.0

* Adds support for `serverClientId` configuration option.
* Makes `Google-Services.info` file optional.

## 5.3.1

* Suppresses warnings for pre-iOS-13 codepaths.

## 5.3.0

* Supports arm64 iOS simulators by increasing GoogleSignIn dependency to version 6.2.

## 5.2.7

* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 5.2.6

* Switches to an internal method channel, rather than the default.

## 5.2.5

* Splits from `google_sign_in` as a federated implementation.
