## 2.14.9

* Adds `PlatformCap` for `PlatformPolyline.startCap` and `endCap`.

## 2.14.8

* Updates Java compatibility version to 11.
* Updates minimum supported SDK version to Flutter 3.24/Dart 3.5.

## 2.14.7

* Adds `PlatformPatternItem` pigeon class to convert `PlatformPolyline.pattern`.

## 2.14.6

* Converts 'PlatformCameraUpdate' to pigeon.

## 2.14.5

* Converts `JointType` to enum.

## 2.14.4

* Converts 'PlatformTileOverlay' to pigeon.

## 2.14.3

* Converts `PlatformPolygon` and `PlatformPolyline` to pigeon.

## 2.14.2

* Bumps `com.android.tools.build:gradle` from 7.3.1 to 8.5.1.

## 2.14.1

* Converts `PlatformCircle` and `PlatformMarker` to pigeon.

## 2.14.0

* Updates map configuration and platform view creation parameters to use Pigeon.

## 2.13.0

* Adds support for heatmap layers.

## 2.12.2

* Updates the example app to use TLHC mode, per current package guidance.

## 2.12.1

* Updates lint checks to ignore NewerVersionAvailable.

## 2.12.0

* Converts Java->Dart calls to Pigeon.

## 2.11.1

* Fixes handling of Circle updates.

## 2.11.0

* Converts additional platform calls to Pigeon.

## 2.10.0

* Converts some platform calls to Pigeon.

## 2.9.1

* Converts inspector interface platform calls to Pigeon.

## 2.9.0

* Adds support for BitmapDescriptor classes `AssetMapBitmap` and `BytesMapBitmap`.

## 2.8.1

* Updates minimum supported SDK version to Flutter 3.22/Dart 3.4.
* Removes support for apps using the v1 Android embedding.

## 2.8.0

* Adds support for marker clustering.

## 2.7.0

* Adds support for `MapConfiguration.style`.
* Adds support for `getStyleError`.
* Updates minimum supported SDK version to Flutter 3.13/Dart 3.1.
* Updates compileSdk version to 34.

## 2.6.2

* Updates minimum required plugin_platform_interface version to 2.1.7.

## 2.6.1

* Fixes new lint warnings.

## 2.6.0

* Fixes missing updates in TLHC mode.
* Switched default display mode to TLHC mode.
* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.

## 2.5.3

* Updates `com.google.android.gms:play-services-maps` to 18.2.0.

## 2.5.2

* Updates annotations lib to 1.7.0.

## 2.5.1

* Adds pub topics to package metadata.

## 2.5.0

* Adds implementation for `cloudMapId` parameter to support cloud-based map styling.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 2.4.16

* Removes old empty override methods.
* Fixes unawaited_futures violations.

## 2.4.15

* Removes obsolete null checks on non-nullable values.
* Updates minimum supported SDK version to Flutter 3.3/Dart 2.18.

## 2.4.14

* Updates gradle, AGP and fixes some lint errors.

## 2.4.13

* Fixes compatibility with AGP versions older than 4.2.

## 2.4.12

* Fixes Java warnings.

## 2.4.11

* Adds a namespace for compatibility with AGP 8.0.

## 2.4.10

* Bump RoboElectric dependency to 4.4.1 to support AndroidX.

## 2.4.9

* Clarifies explanation of endorsement in README.
* Aligns Dart and Flutter SDK constraints.

## 2.4.8

* Fixes compilation warnings.

## 2.4.7

* Updates annotation dependency.
* Updates compileSdkVersion to 33.

## 2.4.6

* Updates links for the merge of flutter/plugins into flutter/packages.

## 2.4.5

* Fixes Initial padding not working when map has not been created yet.

## 2.4.4

* Fixes Points losing precision when converting to LatLng.
* Updates minimum Flutter version to 3.0.

## 2.4.3

* Updates code for stricter lint checks.

## 2.4.2

* Updates code for stricter lint checks.

## 2.4.1

* Update `androidx.test.espresso:espresso-core` to 3.5.1.

## 2.4.0

* Adds the ability to request a specific map renderer.
* Updates code for new analysis options.

## 2.3.3

* Update android gradle plugin to 7.3.1.

## 2.3.2

* Update `com.google.android.gms:play-services-maps` to 18.1.0.

## 2.3.1

* Updates imports for `prefer_relative_imports`.

## 2.3.0

* Switches the default for `useAndroidViewSurface` to true, and adds
  information about the current mode behaviors to the README.
* Updates minimum Flutter version to 2.10.

## 2.2.0

* Updates `useAndroidViewSurface` to require Hybrid Composition, making the
  selection work again in Flutter 3.0+. Earlier versions of Flutter are
  no longer supported.
* Fixes violations of new analysis option use_named_constants.
* Fixes avoid_redundant_argument_values lint warnings and minor typos.

## 2.1.10

* Splits Android implementation out of `google_maps_flutter` as a federated
  implementation.
