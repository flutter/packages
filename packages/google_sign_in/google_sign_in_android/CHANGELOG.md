## NEXT

* Updates minimum supported SDK version to Flutter 3.27/Dart 3.6.

## 6.2.1

* Removes obsolete code related to supporting SDK <21.

## 6.2.0

* Adds a sign-in field to allow clients to explicitly specify an account name.

## 6.1.36

* Updates compileSdk 34 to flutter.compileSdkVersion.

## 6.1.35

* Removes the dependency on the Guava library.

## 6.1.34

* Removes unnecessary native code.

## 6.1.33

* Updates Pigeon for non-nullable collection type support.

## 6.1.32

* Updates Java compatibility version to 11.
* Updates minimum supported SDK version to Flutter 3.24/Dart 3.5.

## 6.1.31

* Bumps `com.google.guava:guava` from `32.0.1` to `33.3.1`.

## 6.1.30

* Temporarily downgrades Guava from version 33.3.0 to 32.0.1 to fix an R8 related error.

## 6.1.29

* Updates Guava to version 33.3.0.

## 6.1.28

* Updates lint checks to ignore NewerVersionAvailable.

## 6.1.27

* Updates AGP version to 8.5.0.

## 6.1.26

* Removes additional references to the v1 Android embedding.

## 6.1.25

* Updates Guava to version 33.2.1.

## 6.1.24

* Updates minimum supported SDK version to Flutter 3.22/Dart 3.4.
* Removes support for apps using the v1 Android embedding.

## 6.1.23

* Updates minSdkVersion to 19.
* Updates minimum supported SDK version to Flutter 3.16/Dart 3.2.

## 6.1.22

* Updates minimum supported SDK version to Flutter 3.13/Dart 3.1.
* Updates compileSdk version to 34.
* Updates play-services-auth version to 21.0.0.

## 6.1.21

* Updates `clearAuthCache` override to match base class declaration.
* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.

## 6.1.20

* Updates play-services-auth version to 20.7.0.

## 6.1.19

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 6.1.18

* Updates play-services-auth version to 20.6.0.

## 6.1.17

* Converts method channels to Pigeon.

## 6.1.16

* Updates Guava to version 32.0.1.

## 6.1.15

* Updates minimum supported SDK version to Flutter 3.3/Dart 2.18.
* Updates Guava to version 32.0.0.

## 6.1.14

* Fixes compatibility with AGP versions older than 4.2.

## 6.1.13

* Adds `targetCompatibilty` matching `sourceCompatibility` for older toolchains.

## 6.1.12

* Adds a namespace for compatibility with AGP 8.0.

## 6.1.11

* Fixes Java warnings.

## 6.1.10

* Sets an explicit Java compatibility version.

## 6.1.9

* Updates play-services-auth version to 20.5.0.

## 6.1.8

* Clarifies explanation of endorsement in README.
* Aligns Dart and Flutter SDK constraints.
* Updates compileSdkVersion to 33.

## 6.1.7

* Updates links for the merge of flutter/plugins into flutter/packages.

## 6.1.6

* Minor implementation cleanup
* Updates minimum Flutter version to 3.0.

## 6.1.5

* Updates play-services-auth version to 20.4.1.

## 6.1.4

* Rolls Guava to version 31.1.

## 6.1.3

* Updates play-services-auth version to 20.4.0.

## 6.1.2

* Fixes passing `serverClientId` via the channelled `init` call

## 6.1.1

* Corrects typos in plugin error logs and removes not actionable warnings.
* Updates minimum Flutter version to 2.10.
* Updates play-services-auth version to 20.3.0.

## 6.1.0

* Adds override for `GoogleSignIn.initWithParams` to handle new `forceCodeForRefreshToken` parameter.

## 6.0.1

* Updates gradle version to 7.2.1 on Android.

## 6.0.0

* Deprecates `clientId` and adds support for `serverClientId` instead.
  Historically `clientId` was interpreted as `serverClientId`, but only on Android. On
  other platforms it was interpreted as the OAuth `clientId` of the app. For backwards-compatibility
  `clientId` will still be used as a server client ID if `serverClientId` is not provided.
* **BREAKING CHANGES**:
  * Adds `serverClientId` parameter to `IDelegate.init` (Java).

## 5.2.8

* Suppresses `deprecation` warnings (for using Android V1 embedding).

## 5.2.7

* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 5.2.6

* Switches to an internal method channel, rather than the default.

## 5.2.5

* Splits from `google_sign_in` as a federated implementation.
