# CHANGELOG

## 1.1.1

- Multiple text positioning bug fixes.
- Preserve stroke-opacity when specified.

## 1.1.0

- Fix a number of inheritence related bugs:
  - Inheritence of properties specified on the root element now work.
  - Opacity inheritence is more correct now.
  - Inheritence of `use` elements is more correctly handled.
- Make `currentColor` non-null on SVG theme, and fix how it is applied.
- Remove the opacity peephole optimizer, which was incorrectly applying
  optimizations in a few cases. A future release may add this back.
- Add clipBehavior to the widget.
- Fix patterns when multiple patterns are specified and applied within the
  graphic.

## 1.0.1

- Fix handling of unspecified fill colors on use/group elements.

## 1.0.0+1

- Fix issue in pattern decoding.
- Fix issue in matrix parsing for some combinations of matrices.

## 1.0.0

* Initial stable release.

## 0.0.3

* Pattern support.

## 0.0.2

* Add support for encoding and decoding inline images.

## 0.0.1

* Add [VectorGraphicsCodec], [VectorGraphicsCodecListener], and [VectorGraphicsBuffer]
  types used to construct and decode a vector graphics binary asset.

## 0.0.0

* Create repository.
