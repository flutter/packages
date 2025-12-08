## 0.3.0+8

* Removes internal native library Dart proxy.

## 0.3.0+7

* Bumps kotlin_version to 2.2.21.

## 0.3.0+6

* Bumps com.android.tools.build:gradle from 8.12.1 to 8.13.1.

## 0.3.0+5

* Updates to Pigeon 26.

## 0.3.0+4

* Sets a maximum version on the `GoogleInteractiveMediaAds` dependency to avoid
  breaking iOS 13-14 support.

## 0.3.0+3

* Bumps `com.google.ads.interactivemedia.v3:interactivemedia` from 3.37.0 to 3.38.0.

## 0.3.0+2

* Updates minimum supported version to iOS 13.
* Updates minimum supported SDK version to Flutter 3.35/Dart 3.9.

## 0.3.0+1

* Updates Java compatibility version to 17 and minimum supported SDK version to Flutter 3.35/Dart 3.9.

## 0.3.0

* Bumps `com.google.ads.interactivemedia.v3:interactivemedia` from 3.36.0 to 3.37.0.
* **Breaking Change** Adds app desugaring as a requirement for Android apps. Apps without desugaring
  enabled won't build with the current or future IMA versions. To enable app desugaring, see
  `README.md`.
* **Breaking Change** Updates `AdsRequest.adTagUrl` to return `null` when an ad tag is not set.

## 0.2.8+1

* Resolves Gradle 9 deprecations.

## 0.2.8

* Adds support for accessing data for an ad. See `AdEvent.ad`.

## 0.2.7

* Adds support to retrieve content time offsets at which ad breaks are scheduled. See
  `AdsManager.adCuePoints`

## 0.2.6+7

* Updates Android `PlatformAdDisplayContainer` implementation to support preloading ads.

## 0.2.6+6

* Bumps com.android.tools.build:gradle to 8.12.1 and kotlin_version to 2.2.10.

## 0.2.6+5

* Fixes Android `IllegalStateException` from `MediaPlayer` by releasing resources on
  `VideoAdPlayer.release`.
* Fixes `_startAdProgressTracking` error caused by race condition.

## 0.2.6+4

* Adds internal wrappers for iOS native `IMAAd` and `IMAUniversalAdID`.
* Updates internal wrapper for iOS native `IMAAdEvent`.
* Updates internal wrapper for Android native `AdEvent`.
* Updates minimum supported SDK version to Flutter 3.29/Dart 3.7.

## 0.2.6+3

* Updates `README` with information about enabling desugaring on Android.

## 0.2.6+2

* Updates kotlin version to 2.2.0 to enable gradle 8.11 support.

## 0.2.6+1

* Fixes passing ads response to Android native `AdsRequest`.

## 0.2.6

* Adds support to configure ad requests. See `AdsRequest`.

## 0.2.5+1

* Adds remaining methods for internal wrapper of the Android native `AdsRequest`.
* Adds remaining methods for internal wrapper of the iOS native `IMAAdsRequest`.

## 0.2.5

* Adds support to set general SDK settings. See `ImaSettings` and `AdsLoader.settings`.

## 0.2.4+2

* Bumps gradle from 8.9.0 to 8.11.1.

## 0.2.4+1

* Adds internal wrapper for Android native `ImaSdkSettings`.
* Adds internal wrapper for iOS native `IMASettings`.

## 0.2.4

* Adds support for companion ads. See `CompanionAdSlot` and `AdDisplayContainer(companionAds)`.

## 0.2.3+12

* Fixes appending request agent to ad tags that contain a query.

## 0.2.3+11

* Updates pigeon generated code to fix `ImplicitSamInstance` and `SyntheticAccessor` Kotlin lint
  warnings.

## 0.2.3+10

* Fixes `AdEventType`s not triggering on iOS in release mode.

## 0.2.3+9

* Bumps gradle from 8.0.0 to 8.9.0.

## 0.2.3+8

* Updates compileSdk 34 to flutter.compileSdkVersion.

## 0.2.3+7

* Bumps gradle-plugin to 2.1.10.

## 0.2.3+6

* Adds internal wrapper for iOS native `IMAAdPodInfo`.

## 0.2.3+5

* Bumps gradle-plugin to 2.1.0.

## 0.2.3+4

* Adds remaining methods for internal wrapper of the iOS native `IMAAdDisplayContainer`.

## 0.2.3+3

* Adds internal wrapper for Android native `CompanionAdSlot` and `CompanionAdSlot.ClickListener`.

## 0.2.3+2

* Bumps `com.google.ads.interactivemedia.v3:interactivemedia` from 3.35.1 to 3.36.0.

## 0.2.3+1

* Bumps androidx.annotation:annotation from 1.8.2 to 1.9.1.

## 0.2.3

* Adds parameters to control the rendering of ads. See `AdsManager.init`.

## 0.2.2+15

* Adds remaining methods for internal wrapper of the Android native `BaseManager`.

## 0.2.2+14

* Adds internal wrapper for iOS native `IMACompanionAdSlot` and `IMACompanionDelegate`.

## 0.2.2+13

* Adds internal wrapper for Android native `Ad`.

## 0.2.2+12

* Adds internal wrapper for iOS native `IMACompanionAd`.

## 0.2.2+11

* Adds internal wrapper for Android native `UniversalAdId`.

## 0.2.2+10

* Fixes bug where Android would show the last frame of the previous Ad before playing the current
  one.

## 0.2.2+9

* Adds internal wrapper for Android native `CompanionAd`.

## 0.2.2+8

* Adds remaining methods for internal wrapper of the iOS native `IMAAdsRenderingSettings`.

## 0.2.2+7

* Updates Java compatibility version to 11.
* Updates minimum supported SDK version to Flutter 3.24/Dart 3.5.

## 0.2.2+6

* Bumps Android dependency `com.google.ads.interactivemedia.v3:interactivemedia` from `3.50.0` to
  `3.35.1`.

## 0.2.2+5

* Changes the example app to initialize the `AdsLoader` in `onContainerAdded`.

## 0.2.2+4

* Adds internal wrapper for Android native `AdProgressInfo`.

## 0.2.2+3

* Adds internal wrapper for iOS native `IMAFriendlyObstruction`.

## 0.2.2+2

* Adds internal wrapper for Android native `AdsRenderingSettings`.

## 0.2.2+1

* Bumps Android dependency `com.google.ads.interactivemedia.v3:interactivemedia` from `3.34.0` to
  `3.35.0`.

## 0.2.2

* Adds support for mid-roll ads. See `AdsRequest.contentProgressProvider`.

## 0.2.1

* Adds internal wrapper for Android native `ContentProgressProvider`.

## 0.2.0

* Adds support for pausing and resuming Ad playback. See `AdsManager.pause` and `AdsManager.resume`.
* Adds support to skip an Ad. See `AdsManager.skip` and `AdsManager.discardAdBreak`.
* **Breaking Change** To keep platform consistency, Android no longer continues playing an Ad 
  whenever it returns from an Ad click. Call `AdsManager.resume` to resume Ad playback.

## 0.1.2+6

* Fixes bug where the ad would play when the app returned to foreground during content playback.

## 0.1.2+5

* Adds internal wrapper for remaining methods of the Android native `AdsManager`.

## 0.1.2+4

* Bumps androidx.annotation:annotation from 1.8.1 to 1.8.2.

## 0.1.2+3

* Adds a contribution guide. See `CONTRIBUTING.md`.

## 0.1.2+2

* Removes dependency on org.jetbrains.kotlin:kotlin-bom.
* Updates minimum supported SDK version to Flutter 3.24/Dart 3.5.

## 0.1.2+1

* Updates README to clarify supported features and link to issues tracker.

## 0.1.2

* Adds support for all `AdEventType`s and ad data. See `AdEvent.adData`.
* Updates minimum supported SDK version to Flutter 3.19/Dart 3.3.

## 0.1.1+1

* Fixes a typo in the formatting of the CHANGELOG.

## 0.1.1

* Adds iOS implementation.
* Adds support for setting the layout direction of the `AdDisplayContainer`.

## 0.1.0+2

* Bumps androidx.annotation:annotation from 1.7.1 to 1.8.1.

## 0.1.0+1

* Updates lint checks to ignore NewerVersionAvailable.

## 0.1.0

* Bumps `com.google.ads.interactivemedia.v3:interactivemedia` from 3.33.0 to 3.34.0.
* **Breaking Change** Updates Android `minSdk` from 19 to 21.

## 0.0.2+1

* Updates `README` with a usage section and fix app-facing interface documentation.

## 0.0.2

* Adds Android implementation.

## 0.0.1+3

* Fixes the pub badge source.

## 0.0.1+2

* Bumps Android's androidx.annotation:annotation dependency from 1.5.0 to 1.8.0.

## 0.0.1+1

* Adds Swift Package Manager support.

## 0.0.1

* Adds platform interface for Android and iOS.
