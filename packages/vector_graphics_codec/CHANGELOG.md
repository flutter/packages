## NEXT

* Updates minimum supported SDK version to Flutter 3.38/Dart 3.10.

## 1.1.13

* Works around a subtle Wasm bug in `writeRadialGradient`.

## 1.1.12

* Transfers the package source from https://github.com/dnfield/vector_graphics
  to https://github.com/flutter/packages.

## 1.1.11+1

* Relaxes package:http constraint.

## 1.1.11

* Uses package:http to drop dependency on dart:html.

## 1.1.10+1

* Adds missing save before clip.

## 1.1.10

* Adds missing clip before saveLayer.

## 1.1.9+2

* Fixes case sensitivity on scientific notation parsing.

## 1.1.9+1

* Fixes publication error that did not have latest source code.

## 1.1.9

* Fixes handling of invalid XML `@id` attributes.
* Fixes handling of self-referential `<use/>` elements.
* Adds `--out-dir` option to compiler.
* Tweaks warning message for unhandled eleemnts.

## 1.1.8

* Fixes bugs in transform parsing.

## 1.1.7

* Supports for matching the ambient text direction.

## 1.1.6

* Fixes bug in text position computation when transforms are involved.

## 1.1.5+1

* Removes/update some invalid assertions related to image formats.

## 1.1.5

* Adds support for encoding control points as IEEE 754-2008 half precision
  floating point values.
* Increase minimum SDK to 2.17.0.
* Adds an error builder property to provide a fallback widget on exceptions.

## 1.1.4

* Supports more image formats and malformed MIME types.
* Fixes inheritence for `fill-rule`s.

## 1.1.3

* Further improvements to whitespace handling for text.

## 1.1.2

* Fixes handling and inheritence of `none`.

## 1.1.1

* Multiple text positioning bug fixes.
* Preserve stroke-opacity when specified.

## 1.1.0

* Fixes a number of inheritence related bugs:
  * Inheritence of properties specified on the root element now work.
  * Opacity inheritence is more correct now.
  * Inheritence of `use` elements is more correctly handled.
* Makes `currentColor` non-null on SVG theme, and fix how it is applied.
* Removes the opacity peephole optimizer, which was incorrectly applying
  optimizations in a few cases. A future release may add this back.
* Adds clipBehavior to the widget.
* Fixes patterns when multiple patterns are specified and applied within the
  graphic.

## 1.0.1

* Fixes handling of unspecified fill colors on use/group elements.

## 1.0.0+1

* Fixes issue in pattern decoding.
* Fixes issue in matrix parsing for some combinations of matrices.

## 1.0.0

* Initial stable release.

## 0.0.3

* Pattern support.

## 0.0.2

* Adds support for encoding and decoding inline images.

## 0.0.1

* Adds [VectorGraphicsCodec], [VectorGraphicsCodecListener], and [VectorGraphicsBuffer]
  types used to construct and decode a vector graphics binary asset.

## 0.0.0

* Create repository.
