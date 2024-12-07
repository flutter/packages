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
