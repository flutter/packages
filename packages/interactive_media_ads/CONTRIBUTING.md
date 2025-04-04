# Contributing to `interactive_media_ads`

Please start by taking a look at the general guide to contributing to the `flutter/packages` repo:
https://github.com/flutter/packages/blob/main/CONTRIBUTING.md

## Package Structure

The structure of this plugin is similar to a [federated plugin](https://docs.flutter.dev/packages-and-plugins/developing-packages#federated-plugins),
except the code for each package (platform interface, platform implementations, and app-facing
interface) are maintained in this single plugin. The sections below will provide an overview of how
this plugin implements each portion.

If you are familiar with [changing federated plugin](https://github.com/flutter/flutter/blob/master/docs/ecosystem/contributing/README.md#changing-federated-plugins)
in the `flutter/packages` repo, the process is similar except that all changes are made in this
plugin. Therefore, it is not necessary to run the script that makes dependencies path based.

### Quick Overview

This plugin uses the native [IMA SDKs] for Android and iOS. The API for the SDK of both platforms
are relatively similar, so this plugin attempts to maintain an interface that is similar to the
native SDKs.

The app-facing interface uses delegation to interact with the underlying platform implementations.
Therefore, the platform interface is similar to the app-facing interface with the differences being
explained in the sections below. Many app-facing interface classes will contain a `platform` field
that is used to forward handling to the platform implementation:

```dart
// App-facing class used by apps
class AdsLoader {
  AdsLoader.fromPlatform(this.platform);
  
  final PlatformAdsLoader platform;
  
  Future<void> requestAds(AdsRequest request) {
    return platform.requestAds(request);
  }
}

// Platform interface class implemented by each platform
abstract base class PlatformAdsLoader {
  Future<void> requestAds(AdsRequest request);
}
```

The `platform` variable should also be used to provide access to platform specific methods or
platform specific creation parameters:

```dart
final AdsLoader loader = AdsLoader();
(loader.platform as AndroidAdsLoader).callAndroidSpecificMethod();
```

The other classes/enums included in the app-facing interface are typically exported from the
platform interface. A data class being a good example of a class that is exported.

### Platform Interface

Code location: `lib/src/platform_interface/`.

This declares an interface that each platform must implement to be supported by the app-facing
interface.

The design of the platform interface should prioritize:
* Minimizing the chances of needing a breaking change when adding a new feature.
* Allowing platform implementations to easily add platform specific features.
* Being straight-forward to write unit tests.

Each platform creates a subclass of the central [InteractiveMediaAdsPlatform](lib/src/platform_interface/interactive_media_ads_platform.dart)
class. A platform implementation is set by setting `InteractiveMediaAdsPlatform.instance` to an
instance of a platform implementation of `InteractiveMediaAdsPlatform`.

### Platform Interface Class Types

Below are some of the types of classes in the interface.

#### Delegate Platform Class

These are classes where the app-facing interface needs to delegate handling to the platform
implementation. These classes are typically prefixed with `Platform`.

If the corresponding app-facing class can be instantiated by the app (e.g. [AdsLoader]),
the `InteractiveMediaAdsPlatform.instance` field should be used in a factory to instantiate the
correct platform implementation. See [PlatformAdsLoader] as an example. This class should should
also take a creation params class as the only constructor parameter. 

If the corresponding app-facing class can't be instantiated by the app (e.g. `AdsManager`), the
class should only have a single protected constructor. See [PlatformAdsManager].

If the corresponding app-facing class needs to be a `Widget` (e.g. [AdDisplayContainer]), this
should follow the same pattern as being instantiable by the app except it should contain a single
method: `Widget build(BuildContext)`. See [PlatformAdDisplayContainer].

**Note**

Every method should contain no more than one parameter. This allows the platform interface and
platform implementations to add new features without requiring a breaking change.

#### Data Classes

These classes contain only fields and no methods. Each data class should be made `@immutable`.

### Platform Implementations

Code location:
* Android: `lib/src/android/`
* iOS: `lib/src/ios/`

The platform implementations create a subclass of `InteractiveMediaAdsPlatform` and implement the 
platform classes that are returned by this.

#### SDK Wrappers

The platform implementations use Dart wrappers of their native SDKs. The SDKs are wrapped using
using the `pigeon` package. However, the code that handles generating the wrappers for iOS is still
in the process of review, so this plugin must use a git dependency in the pubspec.

The wrappers for the SDK of each platform can be updated and modified by changing the pigeon files:

* Android: `pigeons/interactive_media_ads_android.dart`
* iOS: `pigeons/interactive_media_ads_ios.dart`

The generated files are located:
* Android:
  * `lib/src/android/interactive_media_ads.g.dart`
  * `android/src/main/kotlin/dev/flutter/packages/interactive_media_ads/InteractiveMediaAdsLibrary.g.kt`
* iOS
  * `lib/src/ios/interactive_media_ads.g.dart`
  *  `ios/interactive_media_ads/Sources/interactive_media_ads/InteractiveMediaAdsLibrary.g.swift`

To update a wrapper for a platform, follow the steps:

##### 1. Ensure the project has been built at least once

* Android: Run `flutter build apk --debug` in `example/`.
* iOS: Run `flutter build ios --simulator` in `example/`

##### 2. Make changes to the respective pigeon file that matches the native SDK

* Android:
    - [Android SDK]
    - Pigeon file to update: `pigeons/interactive_media_ads_android.dart`
* iOS:
    - [iOS SDK]
    - Pigeon file to update: `pigeons/interactive_media_ads_ios.dart`

Once the file is updated, [run pigeon] to update generated code with the changes.

##### 3. Update the generated APIs in native code

Running the `flutter build` step from step 1 again should provide build errors and indicate what
needs to be done. Alternatively, it can be easier to update native code with the platform's specific
IDE:

* Android: Open `example/android/` in a separate Android Studio project.
* iOS: Open `example/ios/` in Xcode.

##### 4. Write API tests

Assuming a non-static method or constructor was added to the native wrapper, a native test will need
to be added.

* Android native tests location: `android/src/test/kotlin/dev/flutter/packages/interactive_media_ads/`
* iOS native tests location `example/ios/RunnerTests/`

#### Dart Unit Testing

Tests for the platform implementations use [mockito] to generate mock objects of the native Dart
wrappers. To generate the mock objects in `test/`, [run mockito].

### App-facing Interface

Code location: `lib/src/`

The app-facing interface shares the same structure as the platform interface and uses delegation
to forward handling to the platform implementation. Note a few differences from the platform
interface:

* Constructors and methods can contain more than one parameter.
* Platform classes can be instantiated with a platform implementation or creation params of
  the corresponding platform interface class. See `AdsLoader.fromPlatform` and
  `AdsLoader.fromPlatformCreationParams`.

## Recommended Process for Adding a New Feature

### 1. Create a new feature request issue in the `flutter/flutter` repo.

See https://github.com/flutter/flutter/issues/new?assignees=&labels=&projects=&template=3_feature_request.yml

### 2. In that issue add the specific native classes/methods that this feature requires for each platform:

* [Android SDK]
* [iOS SDK]

Add a note if this feature only exist for a single platform. 

### 3. Add a design where the feature can be added to the platform interface and app-facing interface.

If this is only supported on a single platform, add where it can be added in the platform 
implementation.

### 4. Work can be started on the feature request or you can wait for feedback from a Flutter contributor.

[IMA SDKs]: https://developers.google.com/interactive-media-ads
[AdsLoader]: lib/src/ads_loader.dart
[AdDisplayContainer]: lib/src/ad_display_container.dart
[PlatformAdsLoader]: lib/src/platform_interface/platform_ads_loader.dart
[PlatformAdsManager]: lib/src/platform_interface/platform_ads_manager.dart
[PlatformAdDisplayContainer]: lib/src/platform_interface/platform_ad_display_container.dart
[Android SDK]: https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/package-summary
[iOS SDK]: https://developers.google.com/interactive-media-ads/docs/sdks/ios/client-side/reference/Classes
[mockito]: https://pub.dev/packages/mockito
[run pigeon]: https://github.com/flutter/flutter/blob/master/docs/ecosystem/contributing/README.md#pigeon
[run mockito]: https://github.com/flutter/flutter/blob/master/docs/ecosystem/contributing/README.md#mockito
