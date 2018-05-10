# CHANGES

## 0.1.0

Bumping minor version due to internal breaking changes and new support. Works on dev channel as of release (Flutter >= 0.3.6).

- Refactor `DrawableRoot` to support top level style definition.
- Support for dash paths.
- Support for more inherited attributes.
- Initial support for `@style` attributes.
- Support for `rgb()` color attribute/styles.
- Change painting order from stroke first, then fill to fill first, then stroke (matches Chrome rendering of `assets/simple/style_attr.svg`).

## 0.0.2

Initial text support.  Relies on flutter 0.3.6

## 0.0.1

Initial release.  Relies on pre-released master
