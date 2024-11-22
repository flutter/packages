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
