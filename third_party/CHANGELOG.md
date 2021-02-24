# CHANGES

## 0.21.0-nullsafety.0

- Fix sizing when both width and height are null. This is potentially breaking.
- Bump versions to stable nullsafe when possible
- Update README with links to alternative implementations of SVG in Flutter.
- Attempt to report file source/key when errors happen.
- Add missing platforms to example project, update Android embedding.
- Minor fixes for future error handling to respect new Dart rules/expectations.

## 0.20.0-nullsafety.4

- Adds option `warningsAsErrors` that throws errors when detecting unsupported SVG elements.

## 0.20.0-nullsafety.3

- Fix broken image for pub.

## 0.20.0-nullsafety.2

- Fix bug where HTTP headers were not passed along to the HTTP client.

## 0.20.0-nullsafety.1

- Remove unnecessary package:collection dependency

## 0.20.0-nullsafety.0

- Initial release with null safety
- Remove dead code
- Fix up incorrect `catchError` usages

## 0.19.2+1

- Fix a bug where color filters were applied when they should not be.

## 0.19.2

- Allow for opt-in/out of color filter caching behavior, undeprecate color
  filtering on the providers, and allow for a global override.

## 0.19.1

- Fix color filtering when BlendMode.color is used.

## 0.19.0

- Avoid unnecessary cache invalidation of SVGs drawn with color changes by:
  - Deprecate color filter related options on PictureProvider classes.
  - Make ColorFilter a property on SvgPicture
  - Use the ColorFiltered widget for filtered SVGs.
- Fix RTL rendering bug

## 0.18.1

- Bump the path_drawing dependency to 0.4.1+1
- Expose clipBehavior from FittedBox
- Expose SVG ids in `Drawable*` classes.
- Change type of `alignment` to `AlignmentGeometry` on `SvgPicture`.
- Fixed bug in transform parsing

## 0.18.0

- Drop DiagnosticbleMixin usage.
- Bump XML dependency to ^4.1.0 and resolve deprecated API usages.
- Await futures in tests.

## 0.17.4

- Allow `precachePicture` to take `null` for a `BuildContext`.
- Provide a clearer error message when nested `<svg>` elements are used.

## 0.17.3+1

- Fixed regression in v0.17.3 for shape elements with no explicit fill but
  explicit opacity.

## 0.17.3

- Be more permissive about whitespace in transform attributes.
- Stop defaulting color to black when not present, fixing issue with colors
  carried over from `use` elements.

## 0.17.2

- Bumped minimum Flutter version to 1.6.7 to pick up DiagnosticableMixin.
- Allow more variations of whitespace in base64 encoded image data.

## 0.17.1

- Fix for issue with `use` elements refering to groups or other `use` elements
  not correctly applying styles.

## 0.17.0

- Make ColorFiltering apply to whole layer instead of per paint operation.
- **BREAKING** Remove `colorFilter` parameter from `VectorDrawable.draw`.
- Fix color filtering for text.

## 0.16.1

- Support `image` tags in `defs`.
- Make `DrawableRasterImage` implement `DrawableStyleable`.

## 0.16.0

- Move `transform` out of `DrawableStyle` and onto `DrawableStyleable`. Shapes
  already worked this way, and the transform logic was handled in a confusingly
  different way than all the other style attributes.
- Support `<use/>` elements having `id`s.
- Properly apply transforms to referenced use eleemnts.

## 0.15.0

- Respect transformations on `<image/>` tags.
- Be more tolerant of malformed base64 data, similar to browsers (specifically,
  having spaces present in the data). ## 0.14.4
- Apply masks in the correct order when blend modes are involved in shapes.

## 0.14.4

- Support for masks on groups.
- Update example project to Android X.

## 0.14.3

- Support for the `mix-blend-mode` attribute.

## 0.14.2

- Format, open up obtainKey for testing.

## 0.14.1

- Support for HSL colors (thanks to [@christianalfoni](https://github.com/christianalfoni))

## 0.14.0

- Added support for masks (thanks to [@krispypen](https://github.com/krispypen))
- Allow for clearing of the picture cache

## 0.13.1

- Fix case where color filters were incorrectly getting created.

## 0.13.0+2

- Same fix for group opacity/saveLayer as in 0.12.4+2

## 0.13.0+1

- Bump path_drawing dependency, which includes bug fixes in parsing.

## 0.13.0

- Updated SDK constraint to support new error message formats
- Updated error message formats
- Misc. updates for new SDK features

## 0.12.4+2

- Changed version constraint to prevent pulling down from wrong flutter version.
- Fixed group opacity/saveLayer bug.

## 0.12.4+1

- Bump dep on path_drawing which contains bugfixes for parsing.

## 0.12.4

- Fixed `opacity` handling, particularly for groups. Previously, opacities were
  averaged together, which resulted in incorrect compositing (particularly if
  overlapping shapes were drawn within a group). Now, a new layer is created
  with the opacity applied to the whole. This may cause some performance
  degredation, but is more correct.
- Allow font-size to be specified in `px` (with an explicit postfix).
- Add `excludeFromSemantics` property for purely decorative SVGs. The default
  value is false.

## 0.12.3

- Fixed bug with stream completer unregistration.
- Fixed bug with text transforms in new parsing.
- Fixed bug with RGBA parsing for opacity

## 0.12.2

- Fixed bug with AVD parsing from strings.

## 0.12.1

- Support for `display="none"` and `visibility="hidden"`.

## 0.12.0

- **BREAKING** Avoid scaling based on devicePixelRatio. This turned out to be a
  mistake, and caused rendering inconsistencies across devices. It was
  particularly harmful on devices where the ratio was less than 1.0.
- Add `precachePicture` method to allow for pre-caching of SVG assets. Similar
  in functionality to `precacheImage` in the Flutter framework. Also added
  improvements to error handling in the various related routines.

## 0.11.0+1

- Format source code
- Remove unintentionally committed pubspec.lock

## 0.11.0

- Rewrote parsing logic to unpin dart-xml dependency, and bumped Dart XML
  dependency.
- Fix bug where unsupported elements could impact drawing. Unhandled elements
  that have children will now be completely ignored. This is technically a
  breaking change, as previously a child of an unsupported element could have
  been drawn if it was supported. Fixes [#126](https://github.com/dnfield/flutter_svg/issues/126).

## 0.10.4

- Fix bug in transform logic [#122](https://github.com/dnfield/flutter_svg/issues/122)
- Avoid defaulting to the rootBundle, using th DefaultAssetBundle instead when
  resolving pictures [#118](https://github.com/dnfield/flutter_svg/pull/118)

## 0.10.3

- Pin dart-xml to 3.2.5, as 3.3.0 is a breaking change (next release will
  address this).
- Support `px` postfixes on many double literals.

## 0.10.2

- Added a `semanticsLabel` property to `SvgPicture`.
- Updated tests to support async changes in Flutter's `Picture.toImage` method.
  - This is breaking for tests - tests will now require a more recent version of
    Flutter to run. It should not break consumers though.

## 0.10.1

This is technically a breaking release, but it also includes important fixes for
v0.10.0. Rather than splitting the breaking parts out in to v0.11.0 so soon
after the release of v0.10.0, I'm including some more breaking changes here.
This will not normally be done.

- Fix bug that caused `<stop>` elements that weren't self-closing to parse
  improperly.
- Many documentation updates/improvements.
- Added support for gradients that use `xlink:href`
- **BREAKING**: Changed some of the methods on `DrawableDefinitionServer` to
  support gradients better.
- **BREAKING**: Removed the `PaintServer` typedef, since this was only serving
  gradients and we need to have more control there for `xlink:href` support.

## 0.10.0+1

- Fix bug that caused an empty `<defs/>` element prevent rendering.

## 0.10.0

- Rewrite parsing to be more space efficient.
- Refactor parsing to enable more output possibilities.
- Create a dedicated SVG parsing class (SvgParser).
- Updates to text - better support for nested text/tspans.
- Miscellaneous bug fixes.
- Testing improvements.

## 0.9.0+1

- Fix inheritance issues with `text-anchor`.
- Fix a few inconsistencies in text anchor processing/positioning.

## 0.9.0

- **BREAKING** Improvements to text positioning. Thanks to @krispypen!

## 0.8.3

- Implement support for `clipPath` outside of `defs` eleemnts.
- Implement support for `use` in a `clipPath`.
- Recommend `usvg` rather than `svgcleaner` per author's recommendation.

## 0.8.2

- Make `DrawableNoop` implement `DrawableStyleable` to avoid crashing with
  certain unhandled elements.
- Improve error reporting for certain `<style>` element scenarios.

## 0.8.1

- Revert changes made on 0.7.0 to attempt to utilize `width` and `height`. These
  changes did not quite fix what they were intended to fix and caused problems
  they weren't intended to case.

## 0.8.0

- Made parsing `async` to support image loading.
- Added support for `<image>` elements.

## 0.7.0+1

- By default, `SvgPicture.asset` will now cache the asset. We already cached the
  final picture, but the caching included any color filtering provided on the
  image. This is problematic if the color is animated. See
  [dnfield/flutter_svg#33](https://github.com/dnfield/flutter_svg/issues/33)

## 0.7.0

- **BREAKING** Correct erroneous `width` and `height` processing on the root
  element.
  - Previously, `width` and `height` were treated as synonyms for the width and
    height of the `viewBox`. This is not correct, and resulted in meaningful
    rendering errors in some scenarios compared to Chrome. Fixing this makes the
    parser more conformant to the spec, but may make your SVGs look
    significantly different if they specify `width` or `height`. If you want the
    old behavior, you'll have to update your SVGs to not specify `width` and
    `height` (only specify `viewBox`).
- Use `MediaQuery.of(context).devicePixelRatio` if available before defaulting
  to `window.devicePixelRatio` in places that need awareness of
  devicePixelRatios.
- Support for `<use>`, `<symbol>`, and shape/group elements in `<defs>`. There
  are some limitations to this currently,

## 0.6.3

- Consume updated version of path_drawing.
- Fix bug with fill-rule inheritance + example to test.

## 0.6.2

- Consume updated version of path_drawing, which fixes
  [dnfield/flutter_svg#73](https://github.com/dnfield/flutter_svg/issues/73)

## 0.6.1

- Fixed an issue with stroke and fill inheritance (and added test)
- General formatting/analyzer cleanup

## 0.6.0

- **BREAKING** Update Flutter version dependencies/package dependencies
- Print unhandled errors only once, and only in debug mode (000e17f)
- Add ability to specify a `BoxFit` and `Alignment` for SvgPictures (Thanks
  @sroddy!).
- Support `userSpaceOnUse` gradientUnits (@sroddy)
- Miscellaneous bug fixes
- Restructure project to match expectations of Flutter tooling

## 0.5.5

- Create a new class to encapsulate `Paint` and assist with inheriting all
  painting properties.
- Fixes regression introduced in v0.5.2 where some previously working
  inheritance stopped working.
- Support more complex stroke/fill property inheritance.

## 0.5.4

- Consume latest path_drawing (and path_parsing) packages to fix issue(s) with
  smooth curve handling.

## 0.5.3

- Revert `HttpStatus.OK` change - not ready yet for Flutter beta channel

## 0.5.2

- Fix bug(s) in processing stroke and fill opacity when stroke/fill are
  inherited.
- Fix HTTP network headers for network pictures

## 0.5.1

- Consume latest change from path_drawing (fixes exponent validation)

## 0.5.0

- Minimum Flutter version is now 0.5.1 (latest beta as of release)
  - Merge in support for Focal Pointed Radial Gradients
  - Use asset directory references in pubspec.yaml
- Better support for nested `<tspan>` styles
- Support for `text-anchor` attribute
- Fix `<ellipse>` parsing bug (ellipses were drawn at half the expected size)
- Fix `<polyline>` parsing bug (polylines were incorrectly forced to be closed)

## 0.4.1

- Fix bug where widget caused exception in a `FittedBox`

## 0.4.0

- Added `width` and `height` properties to `SvgPicture`
- Remove deprecated code related to `SvgImage`
- Improved reporting of error conditions
  - Unsupported style elements will report an error
  - Unresolvable definitions will report an error
- Fixed `matchesTextDirection`
- Support for `text-anchor`

## 0.3.3

- Fix centering/scaling of canvas when viewBox is not square
- Improved color parsing

## 0.3.2

- Bug fix around caching for tinting/coloring (color was not being properly
  included in cache keys)

## 0.3.1

- Support for tinting/coloring the output
- Documentation updates

## 0.3.0

- This version represents a major rewrite of the widget(s) involved in rendering
  SVG drawings. This is primarily to support caching and better performance in
  rendering.
- New method on DrawableRoot toPicture to create a ui.Picture object from the
  SVG.
- Support for caching of Pictures, similar to how framework caches images. This
  will eventually be configurable, but is not as of this release.

### BREAKING CHANGES

- BREAKING CHANGE: `SvgImage`, `AvdImage`, and `VectorDrawableImage` have been
  deprecated. They relied on methods that are less efficient than those now
  surfaced in `SvgPicture`.
- BREAKING CHANGE: Size is no longer passed to `SvgPicture` - its size is
  determined by parent size.
- BREAKING CHANGE: `clipToViewBox` is now called `allowDrawingOutsideViewBox`.
  It defaults to false. It should not ordinarily be set to true, as it can allow
  unexpected memory usage if your vector graphic tries to draw far outside of
  the viewBox bounds.
- BREAKING CHANGE: `SvgPicture` does not support custom `ErrorWidgetBuilder`s at
  this point in time. However, errors will be properly logged to the console.
  This is a result of improvements in the loading/caching of drawings.

## 0.2.0

- Fix bug(s) in inheritance (better rendering of Ghostscript_Tiger.svg)
- Support for `<clipPath>`s
- Refactoring of how gradients are handled to enable clipPaths
- Refactor of SVG shape -> path logic

## 0.1.4

- Fix bugs in `<radialGradient>` percentage handling.
- Add error widget on error.
- Add ability to specify error/placeholder widgets.
- Minor improvement on flutter logo SVG (add missing gradient).
- Improve docs, unit tests.

## 0.1.3

- Add more unit tests and rendering tests (!).
- Add top level flutter_svg.dart.
- Fix bugs found in transform matrix logic for skewX and skewY.
- Minor improvements in handling inheritance for PathFillType.
- Support gradient spread types (TileModes in Flutter).

## 0.1.2

- Bump to path_drawing 0.2.3 (fix arc defect).
- Handle 'none' in dasharray without throwing exception.
- Better handling of inheritance and 'none' in fill/stroke/dasharray

## 0.1.1

- Handle opacity on groups and inherited/blended opacity.
- Fixes elements that have both opacity and stroke-opacity or fill-opacity.
- Improvements for inheritance.
- Fixes related to unspecified fills on shapes.

## 0.1.0

Bumping minor version due to internal breaking changes and new support. Works on
dev channel as of release (Flutter >= 0.3.6).

- Refactor `DrawableRoot` to support top level style definition.
- Support for dash paths.
- Support for more inherited attributes.
- Initial support for `@style` attributes.
- Support for `rgb()` color attribute/styles.
- Change painting order from stroke first, then fill to fill first, then stroke
  (matches Chrome rendering of `assets/simple/style_attr.svg`).

## 0.0.2

Initial text support.  Relies on flutter 0.3.6.

## 0.0.1

Initial release.  Relies on pre-released master.
