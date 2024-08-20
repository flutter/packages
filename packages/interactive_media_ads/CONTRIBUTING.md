# Contributing to `interactive_media_ads`

## Package Structure

The structure of this plugin is similar to a [federated plugin](https://docs.flutter.dev/packages-and-plugins/developing-packages#federated-plugins),
except the code for each package (platform interface, platform implementations, and app-facing
interface) are maintained in this one plugin. The sections below will provide overview how this
plugin implements each portion.

If you are familiar with [changing federated plugin](https://github.com/flutter/flutter/blob/master/docs/ecosystem/contributing/README.md#changing-federated-plugins)
in the `flutter/packages` repo, the process is similar except that all changes are made in this
plugin. Therefore, it is not necessary to run the script that makes dependencies path based.

### Quick Overview

This plugin uses the native IMA SDKs for Android and iOS. The API for the SDK of both platforms are
relatively similar, so this plugin attempts to maintain an interface that is similar to the native
SDKs.

The app-facing interface uses delegation to interact with the underlying platform implementation.
Therefore the platform interface is similar to the app-facing interfaces with the differences being
explained in the sections below. Many classes will contain a `platform` field that is used to call
methods on the platform implementation:

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
platform interface. Data classes being a good example of a class that is exported.

### Platform Interface

Code location: `lib/src/platform_interface/`.

This declares an interface that each platform must implement to be supported by the
app-facing interface.

The design of the platform interface should prioritize:
* Minimizing the chances of needing a breaking change when adding a new feature.
* Allowing platform implementations to easily add platform specific features.
* Being easy to unit test.

Each platform creates a subclass of the central [InteractiveMediaAdsPlatform](lib/src/platform_interface/interactive_media_ads_platform.dart)
class. A platform implementation is set by setting `InteractiveMediaAdsPlatform.instance` to an
instance of a platform implementation of `InteractiveMediaAdsPlatform`.

### Platform Interface Class Types

Below are the types of classes in the interface.

#### Delegate Platform Class

These are classes where the app-facing interface needs to delegate handling to the platform
implementation. These classes are prefixed with `Platform`.

If the corresponding app-facing class can be instantiated by the app (e.g. `AdsLoader`),
the `InteractiveMediaAdsPlatform.instance` field should be used in a factory to instantiate the
correct platform implementation. See `PlatformAdsLoader` as an example. This class should should
also take a creation params class as the only constructor parameter. 

If the corresponding app-facing class can't instantiated by the app (e.g. AdsManager), the class
should only have a single protected constructor. See `PlatformAdsManager`.

If the corresponding app-facing class needs to be a `Widget` (e.g. `AdDisplayContainer`), this
should follow the same pattern as being instantiable by the app except it should contain a single
method: `Widget build(BuildContext)`. See `PlatformAdDisplayContainer`.

**Note**

Every method should contain no more than one parameter. This allows the platform interface and
platform implementation to add new features without requiring a breaking change.

#### Data Class

Each data class should be made `@immutable`.

### Platform Implementations

Code location:
* Android: `lib/src/android/`
* iOS: `lib/src/ios/`

The platform implementations create a subclass of `InteractiveMediaAdsPlatform` and implement the 
platform classes that are returned by this.

#### SDK Wrappers

The platform implementations use Dart wrappers of their native SDKs. The SDKs are wrapped using
using the `pigeon` package. However, the code that handles generating the wrappers are still in the
process of review and must use a git dependency in the pubspec.

The wrappers for the SDK of each platform can be updated and modify by changing the pigeon files:
* Android:
    * `pigeons/interactive_media_ads_android.dart`
    * `android/src/main/kotlin/dev/flutter/packages/interactive_media_ads/InteractiveMediaAdsLibrary.g.kt`
* iOS: 
    * `pigeons/interactive_media_ads_ios.dart`
    * `ios/interactive_media_ads/Sources/interactive_media_ads/InteractiveMediaAdsLibrary.g.swift`

To update a wrapper for a platform, follow the steps below:

1. Ensure the project has been built at least once.

Android: Run `flutter build apk --debug` in `example/`.
iOS: Run `flutter build ios --simulator` in `example/`

2. Add pigeon to `dev_depdencies` in the `pubspec.yaml` and run `pub upgrade`.

Android:

```yaml
pigeon:
    git:
      url: git@github.com:bparrishMines/packages.git
      ref: pigeon_kotlin_split
      path: packages/pigeon
```

iOS:

```yaml
pigeon:
    git:
      url: git@github.com:bparrishMines/packages.git
      ref: pigeon_wrapper_swift
      path: packages/pigeon
```

3. Remove the multiline comments in the pigeon file.

Android: `pigeons/interactive_media_ads_android.dart`
iOS: `pigeons/interactive_media_ads_ios.dart`

4. Make changes that match the native SDK. 

Android SDK: https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/package-summary
iOS SDK: https://developers.google.com/interactive-media-ads/docs/sdks/ios/client-side/reference/Classes

5. Run the code generator from the terminal.

Android: `dart run pigeon --input pigeons/interactive_media_ads_android.dart`
iOS: `dart run pigeon --input pigeons/interactive_media_ads_ios.dart`

6. Update the generated APIs in native code. 

Running the `flutter build` step from step 1 again should provide build errors and indicate what
needs to be done. Alternatively, it can be easier to update native code with the platform's specific
IDE:

Android: Open `android/` in a separate Android Studio project.
iOS: Open `example/ios/` in Xcode.

7. Write API tests.

Assuming a non-static method or constructor was added to the native wrapper, a native test will need
to be added.

Android:



### App-facing Interface

Code location: `lib/src/`.


## Recommended Process for Adding a New Feature

* Create an issue that includes the specific native classes/methods that this feature requires on
each platform.

* provide where this could be included in the platform interface and app-facing interface 