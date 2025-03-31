## 2.15.0

* Adds support for animating the camera with a duration.

## 2.14.0

* Adds support for ground overlay.
* Updates minimum supported SDK version to Flutter 3.22/Dart 3.4.

## 2.13.2

* Updates most objects passed from Dart to native to use typed data.

## 2.13.1

* Updates Pigeon for non-nullable collection type support.

## 2.13.0

* Updates map configuration and platform view creation parameters to use Pigeon.
* Updates minimum supported SDK version to Flutter 3.19/Dart 3.3.

## 2.12.0

* Adds support for marker clustering.

## 2.11.0

* Adds support for heatmap layers.

## 2.10.0

* Converts Obj-C->Dart calls to Pigeon.

## 2.9.0

* Converts additional platform calls to Pigeon.

## 2.8.2

* Converts inspector interface platform calls to Pigeon.

## 2.8.1

* Improves Objective-C type handling.

## 2.8.0

* Adds compatibility with SDK version 9.x for apps targetting iOS 15+.

## 2.7.0

* Adds support for BitmapDescriptor classes `AssetMapBitmap` and `BytesMapBitmap`.

## 2.6.1

* Adds support for patterns in polylines.

## 2.6.0

* Updates the minimum allowed verison of the Google Maps SDK to 8.4, for privacy
  manifest support.
    * This means that applications using this package can no longer support
      iOS 13 or 14, as the versions of the Google Maps SDK that support those
      versions do not have privacy manifests, so cannot be used in published
      applications once the new App Store enforcement of manifests takes effect.
* Includes the Google Maps SDK's [GoogleMapsPrivacy bundle](https://developers.google.com/maps/documentation/ios-sdk/config#add-apple-privacy-manifest-file)
  manifest entries direct in the plugin, so that package clients do not need to
  manually add that privacy bundle to the application build.

## 2.5.2

* Fixes the tile overlay not correctly displaying on physical ios devices.

## 2.5.1

* Makes the tile overlay callback invoke the platform channel on the platform thread.

## 2.5.0

* Adds support for `MapConfiguration.style`.
* Adds support for `getStyleError`.

## 2.4.2

* Fixes a bug in "takeSnapshot" function that incorrectly returns a blank image on iOS 17.

## 2.4.1

* Restores the workaround to exclude arm64 simulator builds, as it is still necessary for applications targeting iOS 12.

## 2.4.0

* Adds support for arm64 simulators.
* Updates minimum supported SDK version to Flutter 3.16.6.
* Removes support for iOS 11.

## 2.3.6

* Adds privacy manifest.

## 2.3.5

* Updates minimum required plugin_platform_interface version to 2.1.7.

## 2.3.4

* Fixes new lint warnings.

## 2.3.3

* Adds support for version 8 of the Google Maps SDK in apps targeting iOS 14+.
* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.

## 2.3.2

* Fixes an issue where the onDragEnd callback for marker is not called.

## 2.3.1

* Adds pub topics to package metadata.

## 2.3.0

* Adds implementation for `cloudMapId` parameter to support cloud-based maps styling.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.
* Fixes unawaited_futures violations.

## 2.2.3

* Removes obsolete null checks on non-nullable values.
* Updates minimum supported SDK version to Flutter 3.3/Dart 2.18.

## 2.2.2

* Sets an upper bound on the `GoogleMaps` SDK version that can be used, to
  avoid future breakage.

## 2.2.1

* Clarifies explanation of endorsement in README.
* Aligns Dart and Flutter SDK constraints.

## 2.2.0

* Updates minimum Flutter version to 3.3 and iOS 11.

## 2.1.14

* Updates links for the merge of flutter/plugins into flutter/packages.

## 2.1.13

* Updates code for stricter lint checks.
* Updates code for new analysis options.
* Re-enable XCUITests: testUserInterface.
* Remove unnecessary `RunnerUITests` target from Podfile of the example app.

## 2.1.12

* Updates imports for `prefer_relative_imports`.
* Updates minimum Flutter version to 2.10.
* Fixes violations of new analysis option use_named_constants.
* Fixes avoid_redundant_argument_values lint warnings and minor typos.

## 2.1.11

* Precaches Google Maps services initialization and syncing.

## 2.1.10

* Splits iOS implementation out of `google_maps_flutter` as a federated
  implementation.
