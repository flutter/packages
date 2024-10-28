## NEXT

* Updates minimum supported SDK version to Flutter 3.19/Dart 3.3.

## 2.9.0

* Adds clustering support.

## 2.8.0

* Adds support for heatmap layers.

## 2.7.1

* Updates the example app to use TLHC mode, per current package guidance.

## 2.7.0

* Adds support for BitmapDescriptor classes `AssetMapBitmap` and `BytesMapBitmap`.
* Updates minimum supported SDK version to Flutter 3.22/Dart 3.4.

## 2.6.1

* Updates the minimum version of the iOS implementation package to a version
  with privacy manifest support.
* Updates README and example app to reflect that the minimum supported version
  is now iOS 14. Removal of support for iOS 12 and 13 was necessary due to the
  upcoming App Store privary manifest requirements.

## 2.6.0

* Adds `style` to the GoogleMap widget constructor. This allows setting the map
  style during creation, avoiding the possibility of the default style being
  displayed briefly.
* Deprecates `GoogleMapController.setMapStyle` in favor of setting the style via
  the new widget `style` parameter.
* Updates minimum supported SDK version to Flutter 3.19.

## 2.5.3

* Updates support matrix in README to indicate that iOS 11 is no longer supported.
* Clients on versions of Flutter that still support iOS 11 can continue to
  use this package with iOS 11, but will not receive any further
  updates to the iOS implementation.

## 2.5.2

* Updates minimum required plugin_platform_interface version to 2.1.7.

## 2.5.1

* Fixes new lint warnings.

## 2.5.0

* Adds implementation for `cloudMapId` parameter to support cloud-based maps styling.

## 2.4.1

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 2.4.0

* Adds options for gesture handling and tilt controls on web.

## 2.3.1

* Fixes a regression from 2.2.8 that could cause incorrect handling of a
  rapid series of map object updates.
* Fixes stale ignore: prefer_const_constructors.
* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.

## 2.3.0

* Endorses [`google_maps_flutter_web`](https://pub.dev/packages/google_maps_flutter_web)
  as the web implementation of this plugin.

## 2.2.8

* Fixes unawaited_futures violations.

## 2.2.7

* Removes obsolete null checks on non-nullable values.
* Updates minimum supported SDK version to Flutter 3.3/Dart 2.18.

## 2.2.6

* Aligns Dart and Flutter SDK constraints.
* Updates README.md to specify not to use GoogleMaps widget within an unbounded widget.

## 2.2.5

* Updates iOS minimum version in README.

## 2.2.4

* Updates links for the merge of flutter/plugins into flutter/packages.
* Updates minimum Flutter version to 3.0.

## 2.2.3

* Fixes a minor syntax error in `README.md`.

## 2.2.2

* Modified `README.md` to fix minor syntax issues and added Code Excerpt to `README.md`.
* Updates code for new analysis options.
* Updates code for `no_leading_underscores_for_local_identifiers` lint.

## 2.2.1

* Updates imports for `prefer_relative_imports`.

## 2.2.0

* Deprecates `AndroidGoogleMapsFlutter.useAndroidViewSurface` in favor of
  [setting the flag directly in the Android implementation](https://pub.dev/packages/google_maps_flutter_android#display-mode).
* Updates minimum Flutter version to 2.10.

## 2.1.12

* Fixes violations of new analysis option use_named_constants.

## 2.1.11

* Fixes avoid_redundant_argument_values lint warnings and minor typos.
* Moves Android and iOS implementations to federated packages.

## 2.1.10

* Avoids map shift when scrolling on iOS.

## 2.1.9

* Updates integration tests to use the new inspector interface.
* Removes obsolete test-only method for accessing a map controller's method channel.
* Ignores unnecessary import warnings in preparation for [upcoming Flutter changes](https://github.com/flutter/flutter/pull/106316).

## 2.1.8

* Switches to new platform interface versions of `buildView` and
  `updateOptions`.
* Ignores unnecessary import warnings in preparation for [upcoming Flutter changes](https://github.com/flutter/flutter/pull/104231).

## 2.1.7

* Objective-C code cleanup.

## 2.1.6

* Fixes issue in Flutter v3.0.0 where some updates to the map don't take effect on Android.
* Fixes iOS native unit tests on M1 devices.
* Minor fixes for new analysis options.

## 2.1.5

* Removes unnecessary imports.
* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 2.1.4

* Updates Android Google maps sdk version to `18.0.2`.
* Adds OS version support information to README.

## 2.1.3

* Fixes iOS crash on `EXC_BAD_ACCESS KERN_PROTECTION_FAILURE` if the map frame changes long after creation.

## 2.1.2

* Removes dependencies from `pubspec.yaml` that are only needed in `example/pubspec.yaml`
* Updates Android compileSdkVersion to 31.
* Internal code cleanup for stricter analysis options.

## 2.1.1

* Suppresses unchecked cast warning.

## 2.1.0

* Add iOS unit and UI integration test targets.
* Provide access to Hybrid Composition on Android through the `GoogleMap` widget.

## 2.0.11

* Add additional marker drag events.

## 2.0.10

* Update minimum Flutter SDK to 2.5 and iOS deployment target to 9.0.

## 2.0.9

* Fix Android `NullPointerException` caused by the `GoogleMapController` being disposed before `GoogleMap` was ready.

## 2.0.8

* Mark iOS arm64 simulators as unsupported.

## 2.0.7

* Add iOS unit and UI integration test targets.
* Exclude arm64 simulators in example app.
* Remove references to the Android V1 embedding.

## 2.0.6

* Migrate maven repo from jcenter to mavenCentral.

## 2.0.5

* Google Maps requires at least Android SDK 20.

## 2.0.4

* Unpin iOS GoogleMaps pod dependency version.

## 2.0.3

* Fix incorrect typecast in TileOverlay example.
* Fix english wording in instructions.

## 2.0.2

* Update flutter\_plugin\_android\_lifecycle dependency to 2.0.1 to fix an R8 issue
  on some versions.

## 2.0.1

* Update platform\_plugin\_interface version requirement.

## 2.0.0

* Migrate to null-safety
* BREAKING CHANGE: Passing an unknown map object ID (e.g., MarkerId) to a
  method, it will throw an `UnknownMapObjectIDError`. Previously it would
  either silently do nothing, or throw an error trying to call a function on
  `null`, depneding on the method.

## 1.2.0

* Support custom tiles.

## 1.1.1

* Fix in example app to properly place polyline at initial camera position.

## 1.1.0

* Add support for holes in Polygons.

## 1.0.10

* Update the example app: remove the deprecated `RaisedButton` and `FlatButton` widgets.

## 1.0.9

* Fix outdated links across a number of markdown files ([#3276](https://github.com/flutter/plugins/pull/3276))

## 1.0.8

* Update Flutter SDK constraint.

## 1.0.7

* Android: Handle deprecation & unchecked warning as error.

## 1.0.6

* Update Dart SDK constraint in example.
* Remove unused `test` dependency in the example app.

## 1.0.5

Overhaul lifecycle management in GoogleMapsPlugin.

GoogleMapController is now uniformly driven by implementing `DefaultLifecycleObserver`. That observer is registered to a lifecycle from one of three sources:

1. For v2 plugin registration, `GoogleMapsPlugin` obtains the lifecycle via `ActivityAware` methods.
2. For v1 plugin registration, if the activity implements `LifecycleOwner`, it's lifecycle is used directly.
3. For v1 plugin registration, if the activity does not implement `LifecycleOwner`, a proxy lifecycle is created and driven via `ActivityLifecycleCallbacks`.

## 1.0.4

* Cleanup of Android code:
* A few minor formatting changes and additions of `@Nullable` annotations.
* Removed pass-through of `activityHashCode` to `GoogleMapController`.
* Replaced custom lifecycle state ints with `androidx.lifecycle.Lifecycle.State` enum.
* Fixed a bug where the Lifecycle object was being leaked `onDetachFromActivity`, by nulling out the field.
* Moved GoogleMapListener to its own file. Declaring multiple top level classes in the same file is discouraged.

## 1.0.3

* Update android compileSdkVersion to 29.

## 1.0.2

* Remove `io.flutter.embedded_views_preview` requirement from readme.

## 1.0.1

* Fix headline in the readme.

## 1.0.0 - Out of developer preview  🎉.

* Bump the minimal Flutter SDK to 1.22 where platform views are out of developer preview and performing better on iOS. Flutter 1.22 no longer requires adding the `io.flutter.embedded_views_preview` to `Info.plist` in iOS.

## 0.5.33

* Keep handling deprecated Android v1 classes for backward compatibility.

## 0.5.32

* Fix typo in google_maps_flutter/example/map_ui.dart.

## 0.5.31

* Geodesic Polyline support for iOS

## 0.5.30

* Add a `dispose` method to the controller to let the native side know that we're done with said controller.
* Call `controller.dispose()` from the `dispose` method of the `GoogleMap` widget.

## 0.5.29+1

* (ios) Pin dependency on GoogleMaps pod to `< 3.10`, to address https://github.com/flutter/flutter/issues/63447

## 0.5.29

* Pass a constant `_web_only_mapCreationId` to `platform.buildView`, so web can return a cached widget DOM when flutter attempts to repaint there.
* Modify some examples slightly so they're more web-friendly.

## 0.5.28+2

* Move test introduced in #2449 to its right location.

## 0.5.28+1

* Android: Make sure map view only calls onDestroy once.
* Android: Fix a memory leak regression caused in `0.5.26+4`.

## 0.5.28

* Android: Add liteModeEnabled option.

## 0.5.27+3

* iOS: Update the gesture recognizer blocking policy to "WaitUntilTouchesEnded", which fixes the camera idle callback not triggered issue.
* Update the min flutter version to 1.16.3.
* Skip `testTakeSnapshot` test on Android.

## 0.5.27+2

* Update lower bound of dart dependency to 2.1.0.

## 0.5.27+1

* Remove endorsement of `web` platform, it's not ready yet.

## 0.5.27

* Migrate the core plugin to use `google_maps_flutter_platform_interface` APIs.

## 0.5.26+4

* Android: Fix map view crash when "exit app" while using `FragmentActivity`.
* Android: Remove listeners from `GoogleMap` when disposing.

## 0.5.26+3

* iOS: observe the bounds update for the `GMSMapView` to reset the camera setting.
* Update UI related e2e tests to wait for camera update on the platform thread.

## 0.5.26+2

* Fix UIKit availability warnings and CocoaPods podspec lint warnings.

## 0.5.26+1

* Removes an erroneously added method from the GoogleMapController.h header file.

## 0.5.26

* Adds support for toggling zoom controls (Android only)

## 0.5.25+3

* Rename 'Page' in the example app to avoid type conflict with the Flutter Framework.

## 0.5.25+2

* Avoid unnecessary map elements updates by ignoring not platform related attributes (eg. onTap)

## 0.5.25+1

* Add takeSnapshot that takes a snapshot of the map.

## 0.5.25

* Add an optional param `mipmaps` for `BitmapDescriptor.fromAssetImage`.

## 0.5.24+1

* Make the pedantic dev_dependency explicit.

## 0.5.24

* Exposed `getZoomLevel` in `GoogleMapController`.

## 0.5.23+1

* Move core plugin to its own subdirectory, to prepare for federation.

## 0.5.23

* Add methods to programmatically control markers info windows.

## 0.5.22+3

* Fix polygon and circle stroke width according to device density

## 0.5.22+2

* Update README: Add steps to enable Google Map SDK in the Google Developer Console.

## 0.5.22+1

* Fix for toggling traffic layer on Android not working

## 0.5.22

* Support Android v2 embedding.
* Bump the min flutter version to `1.12.13+hotfix.5`.
* Fixes some e2e tests on Android.

## 0.5.21+17

* Fix Swift example in README.md.

## 0.5.21+16

* Fixed typo in LatLng's documentation.

## 0.5.21+15

* Remove the deprecated `author:` field from pubspec.yaml
* Migrate the plugin to the pubspec platforms manifest.
* Require Flutter SDK 1.10.0 or greater.

## 0.5.21+14

* Adds support for toggling 3D buildings.

## 0.5.21+13

* Add documentation.

## 0.5.21+12

* Update driver tests in the example app to e2e tests.

## 0.5.21+11

* Define clang module for iOS, fix analyzer warnings.

## 0.5.21+10

* Cast error.code to unsigned long to avoid using NSInteger as %ld format warnings.

## 0.5.21+9

* Remove AndroidX warnings.

## 0.5.21+8

* Add NS*ASSUME_NONNULL*\* macro to reduce iOS compiler warnings.

## 0.5.21+7

* Create a clone of cached elements in GoogleMap (Polyline, Polygon, etc.) to detect modifications
  if these objects are mutated instead of modified by copy.

## 0.5.21+6

* Override a default method to work around flutter/flutter#40126.

## 0.5.21+5

* Update and migrate iOS example project.

## 0.5.21+4

* Support projection methods to translate between screen and latlng coordinates.

## 0.5.21+3

* Fix `myLocationButton` bug in `google_maps_flutter` iOS.

## 0.5.21+2

* Fix more `prefer_const_constructors` analyzer warnings in example app.

## 0.5.21+1

* Fix `prefer_const_constructors` analyzer warnings in example app.

## 0.5.21

* Don't recreate map elements if they didn't change since last widget build.

## 0.5.20+6

* Adds support for toggling the traffic layer

## 0.5.20+5

* Allow (de-)serialization of CameraPosition

## 0.5.20+4

* Marker drag event

## 0.5.20+3

* Update Android play-services-maps to 17.0.0

## 0.5.20+2

* Android: Fix polyline width in building phase.

## 0.5.20+1

* Android: Unregister ActivityLifecycleCallbacks on activity destroy (fixes a memory leak).

## 0.5.20

* Add map toolbar support

## 0.5.19+2

* Fix polygons for iOS

## 0.5.19+1

* Fix polyline width according to device density

## 0.5.19

* Adds support for toggling Indoor View on or off.

* Allow BitmapDescriptor scaling override

## 0.5.18

* Fixed build issue on iOS.

## 0.5.17

* Add support for Padding.

## 0.5.16+1

* Update Dart code to conform to current Dart formatter.

## 0.5.16

* Add support for custom map styling.

## 0.5.15+1

* Add missing template type parameter to `invokeMethod` calls.
* Bump minimum Flutter version to 1.5.0.
* Replace invokeMethod with invokeMapMethod wherever necessary.

## 0.5.15

* Add support for Polygons.

## 0.5.14+1

* Example app update(comment out usage of the ImageStreamListener API which has a breaking change
  that's not yet on master). See: https://github.com/flutter/flutter/issues/33438

## 0.5.14

* Adds onLongPress callback for GoogleMap.

## 0.5.13

* Add support for Circle overlays.

## 0.5.12

* Prevent calling null callbacks and callbacks on removed objects.

## 0.5.11+1

* Android: Fix an issue where myLocationButtonEnabled setting was not propagated when set to false onMapLoad.

## 0.5.11

* Add myLocationButtonEnabled option.

## 0.5.10

* Support Color's alpha channel when converting to UIColor on iOS.

## 0.5.9

* BitmapDescriptor#fromBytes accounts for screen scale on ios.

## 0.5.8

* Remove some unused variables and rename method

## 0.5.7

* Add a BitmapDescriptor that is aware of scale.

## 0.5.6

* Add support for Polylines on GoogleMap.

## 0.5.5

* Enable iOS accessibility.

## 0.5.4

* Add method getVisibleRegion for get the latlng bounds of the visible map area.

## 0.5.3

* Added support setting marker icons from bytes.

## 0.5.2

* Added onTap for callback for GoogleMap.

## 0.5.1

* Update Android gradle version.
* Added infrastructure to write integration tests.

## 0.5.0

* Add a key parameter to the GoogleMap widget.

## 0.4.0

* Change events are call backs on GoogleMap widget.
* GoogleMapController no longer handles change events.
* trackCameraPosition is inferred from GoogleMap.onCameraMove being set.

## 0.3.0+3

* Update Android play-services-maps to 16.1.0

## 0.3.0+2

* Address an issue on iOS where icons were not loading.
* Add apache http library required false for Android.

## 0.3.0+1

* Add NSNull Checks for markers controller in iOS.
* Also address an issue where initial markers are set before initialization.

## 0.3.0

* **Breaking change**. Changed the Marker API to be
  widget based, it was controller based. Also changed the
  example app to account for the same.

## 0.2.0+6

* Updated the sample app in README.md.

## 0.2.0+5

* Skip the Gradle Android permissions lint for MyLocation (https://github.com/flutter/flutter/issues/28339)
* Suppress unchecked cast warning for the PlatformViewFactory creation parameters.

## 0.2.0+4

* Fixed a crash when the plugin is registered by a background FlutterView.

## 0.2.0+3

* Fixed a memory leak on Android - the map was not properly disposed.

## 0.2.0+2

* Log a more detailed warning at build time about the previous AndroidX
  migration.

## 0.2.0+1

* Fixed a bug which the camera is not positioned correctly at map initialization(temporary workaround)(https://github.com/flutter/flutter/issues/27550).

## 0.2.0

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

## 0.1.0

* Move the map options from the GoogleMapOptions class to GoogleMap widget parameters.

## 0.0.3+3

* Relax Flutter version requirement to 0.11.9.

## 0.0.3+2

* Update README to recommend using the package from pub.

## 0.0.3+1

* Bug fix: custom marker images were not working on iOS as we were not keeping
  a reference to the plugin registrar so couldn't fetch assets.

## 0.0.3

* Don't export `dart:async`.
* Update the minimal required Flutter SDK version to one that supports embedding platform views.

## 0.0.2

* Initial developers preview release.
