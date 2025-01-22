## 6.3.14

* Bumps androidx.annotation:annotation from 1.9.0 to 1.9.1.

## 6.3.13

* Bumps androidx.annotation:annotation from 1.8.2 to 1.9.0.

## 6.3.12

* Updates Java compatibility version to 11.

## 6.3.11

* Updates Pigeon for non-nullable collection type support.

## 6.3.10

* Removes dependency on org.jetbrains.kotlin:kotlin-bom.
* Updates minimum supported SDK version to Flutter 3.24/Dart 3.5.

## 6.3.9

* Bumps androidx.annotation:annotation from 1.8.1 to 1.8.2.

## 6.3.8

* Bumps androidx.browser:browser from 1.5.0 to 1.8.0.

## 6.3.7

* Bumps androidx.annotation:annotation from 1.8.0 to 1.8.1.

## 6.3.6

* Updates lint checks to ignore NewerVersionAvailable.

## 6.3.5

* Bumps androidx.core:core from 1.10.1 to 1.13.1.

## 6.3.4

* Updates Android Gradle Plugin to 8.5.1.

## 6.3.3

* Updates minimum supported SDK version to Flutter 3.22/Dart 3.4.
* Removes support for apps using the v1 Android embedding.

## 6.3.2

* Bumps androidx.annotation:annotation from 1.7.1 to 1.8.0.

## 6.3.1

* Updates minSdkVersion to 19.
* Updates minimum supported SDK version to Flutter 3.16/Dart 3.2.

## 6.3.0

* Adds support for `BrowserConfiguration`.
* Implements `showTitle` functionality for Android Custom Tabs.
* Updates compileSdk version to 34.

## 6.2.3

* Bumps androidx.annotation:annotation from 1.7.0 to 1.7.1.

## 6.2.2

* Updates minimum required plugin_platform_interface version to 2.1.7.

## 6.2.1

* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.
* Fixes lint warnings.

## 6.2.0

* Adds support for `inAppBrowserView` as a separate launch mode option from
  `inAppWebView` mode. `inAppBrowserView` is the preferred in-app mode for most uses,
  but does not support `closeInAppWebView`.
* Implements `supportsMode` and `supportsCloseForMode`.

## 6.1.1

* Updates annotations lib to 1.7.0.

## 6.1.0

* Adds support for Android Custom Tabs.

## 6.0.39

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 6.0.38

* Updates android implementation to support api 34 broadcast receiver requirements.

## 6.0.37

* Sets android.defaults.buildfeatures.buildconfig to true for compatibility with AGP 8.0+.

## 6.0.36

* Bumps androidx.annotation:annotation from 1.2.0 to 1.6.0.
* Adds a dependency on kotlin-bom to align versions of Kotlin transitive dependencies.

## 6.0.35

* Converts method channels to Pigeon.

## 6.0.34

* Reverts ContextCompat usage that caused flutter/flutter#127014

## 6.0.33

* Explicitly sets if reciever for close should be exported.

## 6.0.32

* Updates gradle, AGP and fixes some lint errors.

## 6.0.31

* Fixes compatibility with AGP versions older than 4.2.

## 6.0.30

* Adds `targetCompatibilty` matching `sourceCompatibility` for older toolchains.

## 6.0.29

* Adds a namespace for compatibility with AGP 8.0.

## 6.0.28

* Sets an explicit Java compatibility version.

## 6.0.27

* Fixes Java warnings.
* Updates minimum Flutter version to 3.3.

## 6.0.26

* Bump RoboElectric dependency to 4.4.1 to support AndroidX.

## 6.0.25

* Clarifies explanation of endorsement in README.
* Aligns Dart and Flutter SDK constraints.

## 6.0.24

* Updates links for the merge of flutter/plugins into flutter/packages.
* Updates minimum Flutter version to 3.0.

## 6.0.23

* Updates code for stricter lint checks.

## 6.0.22

* Updates code for new analysis options.

## 6.0.21

* Updates androidx.annotation to 1.2.0.

## 6.0.20

* Updates android gradle plugin to 4.2.0.

## 6.0.19

* Revert gradle back to 3.4.2.

## 6.0.18

* Updates gradle to 7.2.2.
* Updates minimum Flutter version to 2.10.

## 6.0.17

* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 6.0.16

* Adds fallback querying for `canLaunch` with web URLs, to avoid false negatives
  when there is a custom scheme handler.

## 6.0.15

* Switches to an in-package method channel implementation.

## 6.0.14

* Updates code for new analysis options.
* Removes dependency on `meta`.

## 6.0.13

* Splits from `shared_preferences` as a federated implementation.
