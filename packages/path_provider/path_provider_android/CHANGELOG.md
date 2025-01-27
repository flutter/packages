## 2.2.15

* Removes unnecessary native code.

## 2.2.14

* Updates annotations lib to 1.9.1.

## 2.2.13

* Updates annotations lib to 1.9.0.

## 2.2.12

* Updates Pigeon for non-nullable collection type support.

## 2.2.11

* Updates Java compatibility version to 11.
* Updates minimum supported SDK version to Flutter 3.24/Dart 3.5.

## 2.2.10

* Updates annotations lib to 1.8.2.

## 2.2.9

* Updates annotations lib to 1.8.1.

## 2.2.8

* Updates lint checks to ignore NewerVersionAvailable.

## 2.2.7

* Updates AGP version to 8.5.0.

## 2.2.6

* Updates annotations lib to 1.8.0.

## 2.2.5

* Updates minimum supported SDK version to Flutter 3.22/Dart 3.4.
* Removes support for apps using the v1 Android embedding.

## 2.2.4

* Updates minSdkVersion version to 19.
* Updates minimum supported SDK version to Flutter 3.16/Dart 3.2.

## 2.2.3

* Updates minimum supported SDK version to Flutter 3.13/Dart 3.1.
* Updates compileSdk version to 34.

## 2.2.2

* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.
* Updates annotations lib to 1.7.1.

## 2.2.1

* Updates annotations lib to 1.7.0.

## 2.2.0

* Adds implementation of `getDownloadsDirectory()`.

## 2.1.1

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 2.1.0

* Adds getApplicationCachePath() for storing app-specific cache files.
* Updates minimum supported SDK version to Flutter 3.3/Dart 2.18.

## 2.0.27

* Fixes compatibility with AGP versions older than 4.2.

## 2.0.26

* Adds a namespace for compatibility with AGP 8.0.

## 2.0.25

* Fixes Java warnings.

## 2.0.24

* Clarifies explanation of endorsement in README.
* Aligns Dart and Flutter SDK constraints.
* Updates compileSdkVersion to 33.

## 2.0.23

* Updates links for the merge of flutter/plugins into flutter/packages.
* Updates minimum Flutter version to 3.0.

## 2.0.22

* Removes unused Guava dependency.

## 2.0.21

* Updates code for `no_leading_underscores_for_local_identifiers` lint.
* Updates minimum Flutter version to 2.10.
* Upgrades `androidx.annotation` version to 1.5.0.
* Upgrades Android Gradle plugin version to 7.3.1.

## 2.0.20

* Reverts changes in versions 2.0.18 and 2.0.19.

## 2.0.19

* Bumps kotlin to 1.7.10

## 2.0.18

* Bumps `androidx.annotation:annotation` version to 1.4.0.
* Bumps gradle version to 7.2.2.

## 2.0.17

* Lower minimim version back to 2.8.1.

## 2.0.16

* Fixes bug with `getExternalStoragePaths(null)`.

## 2.0.15

* Switches the medium from MethodChannels to Pigeon.

## 2.0.14

* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 2.0.13

* Fixes typing build warning.

## 2.0.12

* Returns to using a different platform channel name, undoing the revert in
  2.0.11, but updates the minimum Flutter version to 2.8 to avoid the issue
  that caused the revert.

## 2.0.11

* Temporarily reverts the platform channel name change from 2.0.10 in order to
  restore compatibility with Flutter versions earlier than 2.8.

## 2.0.10

* Switches to a package-internal implementation of the platform interface.

## 2.0.9

* Updates Android compileSdkVersion to 31.

## 2.0.8

* Updates example app Android compileSdkVersion to 31.
* Fixes typing build warning.

## 2.0.7

* Fixes link in README.

## 2.0.6

* Split from `path_provider` as a federated implementation.
