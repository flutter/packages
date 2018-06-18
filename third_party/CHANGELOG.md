# CHANGES

## 0.4.0

- Added `width` and `height` properties to `SvgPicture`
- Remove deprecated code related to `SvgImage`
- Improved reporting of error conditions
  - Unsupported style elements will report an error
  - Unresolvable definitions will report an error
- Fixed `matchesTextDirection`

## 0.3.3

- Fix centering/scaling of canvas when viewBox is not square
- Improved color parsing

## 0.3.2

- Bug fix around caching for tinting/coloring (color was not being properly included in cache keys)

## 0.3.1

- Support for tinting/coloring the output
- Documentation updates

## 0.3.0

- This version represents a major rewrite of the widget(s) involved in rendering
  SVG drawings. This is primarily to support caching and better performance in rendering.
- New method on DrawableRoot toPicture to create a ui.Picture object from the SVG.
- Support for caching of Pictures, similar to how framework caches images. This will
  eventually be configurable, but is not as of this release.

### BREAKING CHANGES

- BREAKING CHANGE: `SvgImage`, `AvdImage`, and `VectorDrawableImage` have been
  deprecated. They relied on methods that are less efficient than those
  now surfaced in `SvgPicture`.
- BREAKING CHANGE: Size is no longer passed to `SvgPicture` - its size is
  determined by parent size.
- BREAKING CHANGE: `clipToViewBox` is now called `allowDrawingOutsideViewBox`.
  It defaults to false. It should not ordinarily be set to true, as it can allow
  unexpected memory usage if your vector graphic tries to draw far outside of
  the viewBox bounds.
- BREAKING CHANGE: `SvgPicture` does not support custom `ErrorWidgetBuilder`s at
  this point in time.  However, errors will be properly logged to the console.
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

Bumping minor version due to internal breaking changes and new support. Works on dev channel as of release (Flutter >= 0.3.6).

- Refactor `DrawableRoot` to support top level style definition.
- Support for dash paths.
- Support for more inherited attributes.
- Initial support for `@style` attributes.
- Support for `rgb()` color attribute/styles.
- Change painting order from stroke first, then fill to fill first, then stroke (matches Chrome rendering of `assets/simple/style_attr.svg`).

## 0.0.2

Initial text support.  Relies on flutter 0.3.6.

## 0.0.1

Initial release.  Relies on pre-released master.
