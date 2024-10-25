## 1.1.12

* Transfers the package source from https://github.com/dnfield/vector_graphics
  to https://github.com/flutter/packages.

## 1.1.11+1

* Relax package:http constraint.

## 1.1.11

* Use package:http to drop dependency on dart:html.

## 1.1.10+1

* Add missing save before clip.

## 1.1.10

* Add missing clip before saveLayer.

## 1.1.9+2

* Fix case sensitivity on scientific notation parsing.

## 1.1.9+1

* Fix publication error that did not have latest source code.

## 1.1.9

* Fix handling of invalid XML `@id` attributes.
* Fix handling of self-referential `<use/>` elements.
* Add `--out-dir` option to compiler.
* Tweak warning message for unhandled eleemnts.

## 1.1.8

* Fix bugs in transform parsing.

## 1.1.7

* Support for matching the ambient text direction.

## 1.1.6

* Fix bug in text position computation when transforms are involved.

## 1.1.5+1

* Remove/update some invalid assertions related to image formats.

## 1.1.5

* Add support for encoding control points as IEEE 754-2008 half precision
  floating point values.
* Increase minimum SDK to 2.17.0.
* Added an error builder property to provide a fallback widget on exceptions.

## 1.1.4

* Support more image formats and malformed MIME types.
* Fix inheritence for `fill-rule`s.

## 1.1.3

* Further improvements to whitespace handling for text.

## 1.1.2

* Fix handling and inheritence of `none`.

## 1.1.1

* Multiple text positioning bug fixes.
* Preserve stroke-opacity when specified.

## 1.1.0

* Fix a number of inheritence related bugs:
  * Inheritence of properties specified on the root element now work.
  * Opacity inheritence is more correct now.
  * Inheritence of `use` elements is more correctly handled.
* Make `currentColor` non-null on SVG theme, and fix how it is applied.
* Remove the opacity peephole optimizer, which was incorrectly applying
  optimizations in a few cases. A future release may add this back.
* Add clipBehavior to the widget.
* Fix patterns when multiple patterns are specified and applied within the
  graphic.

## 1.0.1

* Fix handling of unspecified fill colors on use/group elements.

## 1.0.0+1

* Fix issue in pattern decoding.
* Fix issue in matrix parsing for some combinations of matrices.

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
