## 0.0.2

* **Breaking changes**: Reshuffles API exports:
  * Renames `experimental/google_adsense` to `experimental/adsense`.
  * Removes `AdStatus` and `AdUnitParams` from `experimental/google_adsense`.
  * Moves `AdSense` and its `adSense` singleton to the root export.
  * Removes the `adUnit` method from `AdSense`, which is now provided through
    an extension from `experimental/adsense`.
* Tweaks several documentation pages to remove references to internal APIs.
* Splits tests to reflect the new code structure.

## 0.0.1

* Initial release.
