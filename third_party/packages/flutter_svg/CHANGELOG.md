## NEXT

* Updates minimum supported SDK version to Flutter 3.38/Dart 3.10.

## 2.3.0

* Adds an `imageBuilder` property to `SvgPicture` for wrapping the loaded SVG
  widget.

## 2.2.4

* Updates README with example to scale SVG without losing quality.
* Updates minimum supported SDK version to Flutter 3.35/Dart 3.9.

## 2.2.3

* Replaces use of deprecated Color.value.
* Updates minimum supported SDK version to Flutter 3.32/Dart 3.8.

## 2.2.2

* Fixes typo of `allowDrawingOutsideViewBox` in doc comments.

## 2.2.1

* Fixes message buffer access in SvgAssetLoader.
* Updates minimum supported SDK version to Flutter 3.29/Dart 3.7.

## 2.2.0

* Exposes `renderingStrategy` in `SvgPicture` constructors.
* Updates minimum supported SDK version to Flutter 3.27/Dart 3.6.

## 2.1.0

* Exposes `colorMapper` in `SvgPicture` constructors.

## 2.0.17

* Implements errorBuilder callback.

## 2.0.16

* Adopts code excerpts for README.

## 2.0.15

* Fixes `SvgNetworkLoader` not closing internally created http clients.

## 2.0.14

* Makes the package WASM compatible.

## 2.0.13

* Relaxes the dependency constraints on vector_graphics, vector_graphics_codec,
  and vector_graphics_compiler.

## 2.0.12

* Adds `missing_code_block_language_in_doc_comment` lint.

## 2.0.11

* Transfers the package source from https://github.com/dnfield/flutter_svg
  to https://github.com/flutter/packages.

## 2.0.10+1

* Relaxes http dependency.

## 2.0.10

* Uses package:http for network requests, and allow injection of the client.
* Bumps vector_graphics dependency.

## 2.0.9

* Adds back `SvgPicture(theme:)` parameter with a deprecation. Although this
  parameter was inherently broken, removing it would require a major semver
  bump, which would cause consumers to miss out on important fixes.

## 2.0.8

* Adds back `DefaultSvgTheme`.
* Bumps vector_graphics to 1.1.9+1.
* Adds debugFillProperties.
* Fixes bug for cache keys.

## 2.0.7

* Fixes broken `matchTextDirection`.

## 2.0.6

* Fixes test-only issues with latest Flutter stable (3.10).
* Roll vector_graphics to higher minimum version.

## 2.0.5

* Allows malformed UTF-8 in loaders.
* Makes the cache respect the SvgTheme and ColorMapper, if present.

## 2.0.4

* Newer version of vector_graphics.
* Caching bug fix.
* Reintroduce clipBehavior.

## 2.0.3

* Require newer version of vector_graphics.
* Fixes bug in cache that incorrectly fired assert.

## 2.0.2

* Require newer version of vector_graphics with multiple fixes around
  inheritence, patterns, and currentColor handling.

## 2.0.1

* Disable Isolate parsing in debug mode.
* Fixes internal Color representation leakage from `package:vector_graphics_compiler`.

## 2.0.0+1

* Fixes bug in asset loading from packages.

## 2.0.0

* Uses parsing backend from `vector_graphics_compiler`.
  * Out of order defs now supported.
  * Patterns supported.
  * Many optimizations added.
  * **REGRESSION**: Lost support for `dx` and `dy` on `text`. See
    https://github.com/dnfield/vector_graphics/issues/44 if this is important to
    you.
* Parse SVG data in background isolate by default.
* Uses widgets/rendering strategy from `vector_graphics`.
* Much less caching.
* More tests work without special handling - most of parsing is now sync,
  and the loaders know how to avoid using `compute` in tests. For SVGs that
  contain images, `vg.waitForPendingDecodes` is available.

**DEPRECATIONS**

* The `VectorDrawable` classes have gone away.
* The `AvdPicture` and related classes/parser have gone away.
* The `PictureCache` and `PictureStream` classes have gone away.
* The `PicturePovider` class exists only for access to a no-op cache.
* Several static members on `SvgPicture` and the `svg` utility class have gone
  away.
* The `color` and `colorBlendMode` properties have been removed. Instead, use
  the `colorFilter` property.

## 1.1.6

* Fixes transforms on image tags, clipPaths.
* Avoid painting zero-width strokes.

## 1.1.5

* More permissive about color strings.

## 1.1.4

* Handle default image width/height properly.

## 1.1.3

* Handle `pt` values.

## 1.1.2

* Updates path parsing/drawing dependencies to fix arc parsing bug.

## 1.1.1+1

* Fixes regression introduced in 1.1.1.
* Updates fix for fill/stroke inheritence when currentColor is specified in the
  SVG but not in the theme.

## 1.1.1

* Fixes a bug introduced in 1.1.0 related to fill/stroke inheritence.
* Explicit dev_dependency on flutter_lints.
* Avoid deprecated API from Flutter.

## 1.1.0

* Respect stroke* properties when a paint definition is used for a stroke.
* Respect stroke* properties from groups with no `@stroke` property.
* Bumps package versions.

## 1.0.3+1

* Fixes bugs in picture disposal.

## 1.0.3

* Uses `longestLine` rather than `minIntrinsicWidth` to place text.
* Avoid unnecessary painting when a picture doesn't actually change in
  [RenderPicture].

## 1.0.2

* Avoid cache invalidation when `currentColor` or font based units are not used.
* Supports `rem` units.

## 1.0.1

* Fixes bug with incorrect fills in some cases of `<use>` elements.
* Analysis cleanup of Dart code.
* Fixes bug where self-closing `<g>` tags could alter rendering.
* Fixes bug where an invalid `@stroke-dasharray` could cause an infinite loop.
* Fixes bugs related to nested `<g>` elements in `<defs>`.
* Removes unnecessary `sync*` related code.

## 1.0.0

* New widget/RenderObject implementation to avoid rebuilds/paints when
  near or overlapping an animating widget. Also should improve raster
  cacheability.
* Correctly list web as a supported platform.
* Supports for em/ex units.
* Stable 1.0.0 release.

## 0.23.0+1

* Missing commit that reduced breakages introduced in 0.23.0.

## 0.23.0

* Supports for currentColor.
* Some API breaks around PictureProvider to support currentColor.
* Supports for `xml:space`.
* Supports for `text-decoration`.
* Supports for `font-style`.

## 0.22.1

* Pick up performance improvements in path_parsing 0.2.1.
* Performance improvements in XML parsing of SVGs.

## 0.22.0

* Expose `PictureCache` on `PictureProvider`, and deprecate
  `PictureProvider.cacheCount` and `PictureProvider.clearCache`. This is
  intended to allow users to set a maximum cache size, which was previously
  impossible.

## 0.21.0+1

* Fixes alignment/sizing issues introduced in 0.21.0.

## 0.21.0

* Stable nullsafe release.

## 0.21.0-nullsafety.1

* Fixes bug introduced when width and height are both null on the widget.
* Uses more efficient method for XML attribute parsing.

## 0.21.0-nullsafety.0

* Fixes sizing when both width and height are null. This is potentially breaking.
* Bumps versions to stable nullsafe when possible.
* Updates README with links to alternative implementations of SVG in Flutter.
* Attempt to report file source/key when errors happen.
* Adds missing platforms to example project, update Android embedding.
* Minor fixes for future error handling to respect new Dart rules/expectations.

## 0.20.0-nullsafety.4

* Adds option `warningsAsErrors` that throws errors when detecting unsupported
  SVG elements.

## 0.20.0-nullsafety.3

* Fixes broken image for pub.

## 0.20.0-nullsafety.2

* Fixes bug where HTTP headers were not passed along to the HTTP client.

## 0.20.0-nullsafety.1

* Removes unnecessary package:collection dependency.

## 0.20.0-nullsafety.0

* Initial release with null safety.
* Removes dead code.
* Fixes up incorrect `catchError` usages.

## 0.19.2+1

* Fixes a bug where color filters were applied when they should not be.

## 0.19.2

* Allows for opt-in/out of color filter caching behavior, undeprecate color
  filtering on the providers, and allow for a global override.

## 0.19.1

* Fixes color filtering when BlendMode.color is used.

## 0.19.0

* Avoid unnecessary cache invalidation of SVGs drawn with color changes by:
  * Deprecates color filter related options on PictureProvider classes.
  * Makes ColorFilter a property on SvgPicture.
  * Uses the ColorFiltered widget for filtered SVGs.
* Fixes RTL rendering bug.

## 0.18.1

* Bumps the path_drawing dependency to 0.4.1+1.
* Expose clipBehavior from FittedBox.
* Expose SVG ids in `Drawable*` classes.
* Changes type of `alignment` to `AlignmentGeometry` on `SvgPicture`.
* Fixes bug in transform parsing.

## 0.18.0

* Drop DiagnosticbleMixin usage.
* Bumps XML dependency to ^4.1.0 and resolve deprecated API usages.
* Await futures in tests.

## 0.17.4

* Allows `precachePicture` to take `null` for a `BuildContext`.
* Provide a clearer error message when nested `<svg>` elements are used.

## 0.17.3+1

* Fixes regression in v0.17.3 for shape elements with no explicit fill but
  explicit opacity.

## 0.17.3

* Be more permissive about whitespace in transform attributes.
* Stop defaulting color to black when not present, fixing issue with colors
  carried over from `use` elements.

## 0.17.2

* Bumps minimum Flutter version to 1.6.7 to pick up DiagnosticableMixin.
* Allows more variations of whitespace in base64 encoded image data.

## 0.17.1

* Fixes for issue with `use` elements refering to groups or other `use` elements
  not correctly applying styles.

## 0.17.0

* Makes ColorFiltering apply to whole layer instead of per paint operation.
* **BREAKING** Removes `colorFilter` parameter from `VectorDrawable.draw`.
* Fixes color filtering for text.

## 0.16.1

* Supports `image` tags in `defs`.
* Makes `DrawableRasterImage` implement `DrawableStyleable`.

## 0.16.0

* Moves `transform` out of `DrawableStyle` and onto `DrawableStyleable`. Shapes
  already worked this way, and the transform logic was handled in a confusingly
  different way than all the other style attributes.
* Supports `<use/>` elements having `id`s.
* Properly apply transforms to referenced use eleemnts.

## 0.15.0

* Respect transformations on `<image/>` tags.
* Be more tolerant of malformed base64 data, similar to browsers (specifically,
  having spaces present in the data). ## 0.14.4.
* Apply masks in the correct order when blend modes are involved in shapes.

## 0.14.4

* Supports for masks on groups.
* Updates example project to Android X.

## 0.14.3

* Supports for the `mix-blend-mode` attribute.

## 0.14.2

* Format, open up obtainKey for testing.

## 0.14.1

* Supports for HSL colors (thanks to [@christianalfoni](https://github.com/christianalfoni)).

## 0.14.0

* Adds support for masks (thanks to [@krispypen](https://github.com/krispypen)).
* Allows for clearing of the picture cache.

## 0.13.1

* Fixes case where color filters were incorrectly getting created.

## 0.13.0+2

* Same fix for group opacity/saveLayer as in 0.12.4+2.

## 0.13.0+1

* Bumps path_drawing dependency, which includes bug fixes in parsing.

## 0.13.0

* Updates SDK constraint to support new error message formats.
* Updates error message formats.
* Misc. updates for new SDK features.

## 0.12.4+2

* Changes version constraint to prevent pulling down from wrong flutter version.
* Fixes group opacity/saveLayer bug.

## 0.12.4+1

* Bumps dep on path_drawing which contains bugfixes for parsing.

## 0.12.4

* Fixes `opacity` handling, particularly for groups. Previously, opacities were
  averaged together, which resulted in incorrect compositing (particularly if
  overlapping shapes were drawn within a group). Now, a new layer is created
  with the opacity applied to the whole. This may cause some performance
  degredation, but is more correct.
* Allows font-size to be specified in `px` (with an explicit postfix).
* Adds `excludeFromSemantics` property for purely decorative SVGs. The default
  value is false.

## 0.12.3

* Fixes bug with stream completer unregistration.
* Fixes bug with text transforms in new parsing.
* Fixes bug with RGBA parsing for opacity.

## 0.12.2

* Fixes bug with AVD parsing from strings.

## 0.12.1

* Supports for `display="none"` and `visibility="hidden"`.

## 0.12.0

* **BREAKING** Avoid scaling based on devicePixelRatio. This turned out to be a
  mistake, and caused rendering inconsistencies across devices. It was
  particularly harmful on devices where the ratio was less than 1.0.
* Adds `precachePicture` method to allow for pre-caching of SVG assets. Similar
  in functionality to `precacheImage` in the Flutter framework. Also added
  improvements to error handling in the various related routines.

## 0.11.0+1

* Format source code.
* Removes unintentionally committed pubspec.lock.

## 0.11.0

* Rewrites parsing logic to unpin dart-xml dependency, and bumped Dart XML
  dependency.
* Fixes bug where unsupported elements could impact drawing. Unhandled elements
  that have children will now be completely ignored. This is technically a
  breaking change, as previously a child of an unsupported element could have
  been drawn if it was supported. Fixes [#126](https://github.com/dnfield/flutter_svg/issues/126).

## 0.10.4

* Fixes bug in transform logic [#122](https://github.com/dnfield/flutter_svg/issues/122).
* Avoid defaulting to the rootBundle, using th DefaultAssetBundle instead when
  resolving pictures [#118](https://github.com/dnfield/flutter_svg/pull/118).

## 0.10.3

* Pins dart-xml to 3.2.5, as 3.3.0 is a breaking change (next release will
  address this).
* Supports `px` postfixes on many double literals.

## 0.10.2

* Adds a `semanticsLabel` property to `SvgPicture`.
* Updates tests to support async changes in Flutter's `Picture.toImage` method.
  * This is breaking for tests - tests will now require a more recent version of
    Flutter to run. It should not break consumers though.

## 0.10.1

This is technically a breaking release, but it also includes important fixes for
v0.10.0. Rather than splitting the breaking parts out in to v0.11.0 so soon
after the release of v0.10.0, I'm including some more breaking changes here.
This will not normally be done.

* Fixes bug that caused `<stop>` elements that weren't self-closing to parse
  improperly.
* Many documentation updates/improvements.
* Adds support for gradients that use `xlink:href`.
* **BREAKING**: Changes some of the methods on `DrawableDefinitionServer` to
  support gradients better.
* **BREAKING**: Removes the `PaintServer` typedef, since this was only serving
  gradients and we need to have more control there for `xlink:href` support.

## 0.10.0+1

* Fixes bug that caused an empty `<defs/>` element prevent rendering.

## 0.10.0

* Rewrites parsing to be more space efficient.
* Refactors parsing to enable more output possibilities.
* Create a dedicated SVG parsing class (SvgParser).
* Updates to text - better support for nested text/tspans.
* Miscellaneous bug fixes.
* Testing improvements.

## 0.9.0+1

* Fixes inheritance issues with `text-anchor`.
* Fixes a few inconsistencies in text anchor processing/positioning.

## 0.9.0

* **BREAKING** Improvements to text positioning. Thanks to @krispypen!

## 0.8.3

* Implements support for `clipPath` outside of `defs` eleemnts.
* Implements support for `use` in a `clipPath`.
* Recommend `usvg` rather than `svgcleaner` per author's recommendation.

## 0.8.2

* Makes `DrawableNoop` implement `DrawableStyleable` to avoid crashing with
  certain unhandled elements.
* Improves error reporting for certain `<style>` element scenarios.

## 0.8.1

* Reverts changes made on 0.7.0 to attempt to utilize `width` and `height`. These
  changes did not quite fix what they were intended to fix and caused problems
  they weren't intended to case.

## 0.8.0

* Makes parsing `async` to support image loading.
* Adds support for `<image>` elements.

## 0.7.0+1

* By default, `SvgPicture.asset` will now cache the asset. We already cached the
  final picture, but the caching included any color filtering provided on the
  image. This is problematic if the color is animated. See
  [dnfield/flutter_svg#33](https://github.com/dnfield/flutter_svg/issues/33).

## 0.7.0

* **BREAKING** Correct erroneous `width` and `height` processing on the root
  element.
  * Previously, `width` and `height` were treated as synonyms for the width and
    height of the `viewBox`. This is not correct, and resulted in meaningful
    rendering errors in some scenarios compared to Chrome. Fixing this makes the
    parser more conformant to the spec, but may make your SVGs look
    significantly different if they specify `width` or `height`. If you want the
    old behavior, you'll have to update your SVGs to not specify `width` and
    `height` (only specify `viewBox`).
* Uses `MediaQuery.of(context).devicePixelRatio` if available before defaulting
  to `window.devicePixelRatio` in places that need awareness of
  devicePixelRatios.
* Supports for `<use>`, `<symbol>`, and shape/group elements in `<defs>`. There
  are some limitations to this currently,.

## 0.6.3

* Consume updated version of path_drawing.
* Fixes bug with fill-rule inheritance + example to test.

## 0.6.2

* Consume updated version of path_drawing, which fixes
  [dnfield/flutter_svg#73](https://github.com/dnfield/flutter_svg/issues/73).

## 0.6.1

* Fixes an issue with stroke and fill inheritance (and added test).
* General formatting/analyzer cleanup.

## 0.6.0

* **BREAKING** Update Flutter version dependencies/package dependencies.
* Print unhandled errors only once, and only in debug mode (000e17f).
* Adds ability to specify a `BoxFit` and `Alignment` for SvgPictures (Thanks
  @sroddy!).
* Supports `userSpaceOnUse` gradientUnits (@sroddy).
* Miscellaneous bug fixes.
* Restructure project to match expectations of Flutter tooling.

## 0.5.5

* Create a new class to encapsulate `Paint` and assist with inheriting all
  painting properties.
* Fixes regression introduced in v0.5.2 where some previously working
  inheritance stopped working.
* Supports more complex stroke/fill property inheritance.

## 0.5.4

* Consume latest path_drawing (and path_parsing) packages to fix issue(s) with
  smooth curve handling.

## 0.5.3

* Reverts `HttpStatus.OK` change - not ready yet for Flutter beta channel.

## 0.5.2

* Fixes bug(s) in processing stroke and fill opacity when stroke/fill are
  inherited.
* Fixes HTTP network headers for network pictures.

## 0.5.1

* Consume latest change from path_drawing (fixes exponent validation).

## 0.5.0

* Minimum Flutter version is now 0.5.1 (latest beta as of release).
  * Merge in support for Focal Pointed Radial Gradients.
  * Uses asset directory references in pubspec.yaml.
* Better support for nested `<tspan>` styles.
* Supports for `text-anchor` attribute.
* Fixes `<ellipse>` parsing bug (ellipses were drawn at half the expected size).
* Fixes `<polyline>` parsing bug (polylines were incorrectly forced to be closed).

## 0.4.1

* Fixes bug where widget caused exception in a `FittedBox`.

## 0.4.0

* Adds `width` and `height` properties to `SvgPicture`.
* Removes deprecated code related to `SvgImage`.
* Improves reporting of error conditions.
  * Unsupported style elements will report an error.
  * Unresolvable definitions will report an error.
* Fixes `matchesTextDirection`.
* Supports for `text-anchor`.

## 0.3.3

* Fixes centering/scaling of canvas when viewBox is not square.
* Improves color parsing.

## 0.3.2

* Bug fix around caching for tinting/coloring (color was not being properly
  included in cache keys).

## 0.3.1

* Supports for tinting/coloring the output.
* Documentation updates.

## 0.3.0

* This version represents a major rewrite of the widget(s) involved in rendering
  SVG drawings. This is primarily to support caching and better performance in
  rendering.
* New method on DrawableRoot toPicture to create a ui.Picture object from the
  SVG.
* Supports for caching of Pictures, similar to how framework caches images. This
  will eventually be configurable, but is not as of this release.

**BREAKING CHANGES**:
  * `SvgImage`, `AvdImage`, and `VectorDrawableImage` have been
    deprecated. They relied on methods that are less efficient than those now
    surfaced in `SvgPicture`.
  * Size is no longer passed to `SvgPicture` - its size is
    determined by parent size.
  * `clipToViewBox` is now called `allowDrawingOutsideViewBox`
    It defaults to false. It should not ordinarily be set to true, as it can allow
    unexpected memory usage if your vector graphic tries to draw far outside of
    the viewBox bounds.
  * `SvgPicture` does not support custom `ErrorWidgetBuilder`s at
    this point in time. However, errors will be properly logged to the console
    This is a result of improvements in the loading/caching of drawings.

## 0.2.0

* Fixes bug(s) in inheritance (better rendering of Ghostscript_Tiger.svg).
* Supports for `<clipPath>`s.
* Refactors of how gradients are handled to enable clipPaths.
* Refactors of SVG shape -> path logic.

## 0.1.4

* Fixes bugs in `<radialGradient>` percentage handling.
* Adds error widget on error.
* Adds ability to specify error/placeholder widgets.
* Minor improvement on flutter logo SVG (add missing gradient).
* Improves docs, unit tests.

## 0.1.3

* Adds more unit tests and rendering tests (!).
* Adds top level flutter_svg.dart.
* Fixes bugs found in transform matrix logic for skewX and skewY.
* Minor improvements in handling inheritance for PathFillType.
* Supports gradient spread types (TileModes in Flutter).

## 0.1.2

* Bumps to path_drawing 0.2.3 (fix arc defect).
* Handle 'none' in dasharray without throwing exception.
* Better handling of inheritance and 'none' in fill/stroke/dasharray.

## 0.1.1

* Handle opacity on groups and inherited/blended opacity.
* Fixes elements that have both opacity and stroke-opacity or fill-opacity.
* Improvements for inheritance.
* Fixes related to unspecified fills on shapes.

## 0.1.0

* Bumping minor version due to internal breaking changes and new support. Works
  on dev channel as of release (Flutter >= 0.3.6).
* Refactors `DrawableRoot` to support top level style definition.
* Supports for dash paths.
* Supports for more inherited attributes.
* Initial support for `@style` attributes.
* Supports for `rgb()` color attribute/styles.
* Changes painting order from stroke first, then fill to fill first, then stroke
  (matches Chrome rendering of `assets/simple/style_attr.svg`).

## 0.0.2

* Initial text support.  Relies on flutter 0.3.6.

## 0.0.1

* Initial release.  Relies on pre-released master.
