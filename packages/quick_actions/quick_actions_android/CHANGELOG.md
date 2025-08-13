## 1.0.22

* Updates kotlin version to 2.2.0 to enable gradle 8.11 support.

## 1.0.21

* Removes obsolete code related to supporting SDK <21.

## 1.0.20

* Updates compileSdk 34 to flutter.compileSdkVersion.

## 1.0.19

* Updates `pigeon` dependency to version 24.

## 1.0.18

* Updates Java compatibility version to 11.
* Updates minimum supported SDK version to Flutter 3.24/Dart 3.5.

## 1.0.17

* Updates README to include more specific context on how to use launcher activities, including
  a full explanation for https://github.com/flutter/flutter/issues/152883.

## 1.0.16

* Updates README to include guidance on using the plugin with a launcher activity.

## 1.0.15

* Updates lint checks to ignore NewerVersionAvailable.

## 1.0.14

* Updates AGP version to 8.4.1.

## 1.0.13

* Updates minimum supported SDK version to Flutter 3.22/Dart 3.4.
* Removes support for apps using the v1 Android embedding.

## 1.0.12

* Switches from using `ShortcutManager` to `ShortcutManagerCompat`.

## 1.0.11

* Updates minSdkVersion to 19.
* Updates minimum supported SDK version to Flutter 3.16/Dart 3.2.
* Updates compileSdk version to 34.

## 1.0.10

* Updates minimum required plugin_platform_interface version to 2.1.7.
* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.

## 1.0.9

* Changes method channels to pigeon.

## 1.0.8

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 1.0.7

* Adjusts SDK checks for better testability.

## 1.0.6

* Removes obsolete null checks on non-nullable values.
* Updates minimum supported SDK version to Flutter 3.3/Dart 2.18.

## 1.0.5

* Fixes Java warnings.

## 1.0.4

* Fixes compatibility with AGP versions older than 4.2.

## 1.0.3

* Adds a namespace for compatibility with AGP 8.0.

## 1.0.2

* Clarifies explanation of endorsement in README.
* Aligns Dart and Flutter SDK constraints.
* Updates compileSdkVersion to 33.

## 1.0.1

* Updates links for the merge of flutter/plugins into flutter/packages.
* Updates minimum Flutter version to 3.0.

## 1.0.0

* Updates version to 1.0 to reflect current status.
* Updates minimum Flutter version to 2.10.
* Updates mockito-core to 4.6.1.
* Removes deprecated FieldSetter from QuickActionsTest.

## 0.6.2

* Updates gradle version to 7.2.1.

## 0.6.1

* Allows Android to trigger quick actions without restarting the app.

## 0.6.0+11

* Updates references to the obsolete master branch.

## 0.6.0+10

* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 0.6.0+9

* Switches to a package-internal implementation of the platform interface.
