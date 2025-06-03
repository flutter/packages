## NEXT

* Updates minimum supported SDK version to Flutter 3.27/Dart 3.6.

## 0.1.2

* Added a callback to the widget for testing to make unit tests more deterministic.

## 0.1.1

* Adds `AdSenseCodeParameters` configuration object for `adSense.initialize`.
* Adds a 100ms delay to `adBreak` and `showAdFn`, so Flutter tapevents have time
  to settle before an H5 Ad takes over the screen.

## 0.1.0

* Adds H5 Games Ads API as `h5` library.

## 0.0.2

* **Breaking changes**: Reshuffles API exports:
  * Makes `adSense.initialize` async.
  * Removes the `adUnit` method, and instead exports the `AdUnitWidget` directly.
  * Renames `experimental/google_adsense` to `experimental/ad_unit_widget.dart`.
  * Removes the `AdStatus` and `AdUnitParams` exports.
  * Removes the "stub" files, so this package is now web-only and must be used
    through a conditional import.
* Tweaks several documentation pages to remove references to internal APIs.
* Splits tests to reflect the new code structure.

## 0.0.1

* Initial release.
