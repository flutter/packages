# CHANGES

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
  https://github.com/dnfield/flutter_svg/issues/33

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
- Fix bug with fill-rule inheritence + example to test.

## 0.6.2

- Consume updated version of path_drawing, which fixes
  https://github.com/dnfield/flutter_svg/issues/73

## 0.6.1

- Fixed an issue with stroke and fill inheritence (and added test)
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
  inheritence stopped working.
- Support more complex stroke/fill property inheritence.

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

- Fix bug(s) in inheritence (better rendering of Ghostscript_Tiger.svg)
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
- Minor improvements in handling inheritence for PathFillType.
- Support gradient spread types (TileModes in Flutter).

## 0.1.2

- Bump to path_drawing 0.2.3 (fix arc defect).
- Handle 'none' in dasharray without throwing exception.
- Better handling of inheritence and 'none' in fill/stroke/dasharray

## 0.1.1

- Handle opacity on groups and inherited/blended opacity.
- Fixes elements that have both opacity and stroke-opacity or fill-opacity.
- Improvements for inheritence.
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
