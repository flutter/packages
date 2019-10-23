## 0.3.0

 * Supporting GitHub flavoured Markdown
 * Supporting strikethrough
 * Convert TextSpan to use new InlineSpan API

## 0.2.0

* Updated environment sdk constraints to make the package
  Dart 2 compatible.  As a result, usage of this version and higher 
  requires a Dart 2 SDK.

## 0.1.6

* Updated `markdown` dependency.

## 0.1.5

* Add `mockito` as a dev dependency. Eliminate use of `package:http`, which
  is no longer part of Flutter.

## 0.1.4

* Add `li` style to bullets 

## 0.1.3

* Add `path` and `http` as declared dependencies in `pubspec.yaml`

## 0.1.2

* Add support for horizontal rules.
* Fix the `onTap` callback on images nested in hyperlinks

## 0.1.1

* Add support for local file paths in image links. Make sure to set the
  `imageDirectory` property to specify the base directory containing the image
  files.

## 0.1.0

* Roll the dependency on `markdown` to 1.0.0
* Add a test and example for image links
* Fix the `onTap` callback on hyperlinks

## 0.0.9

* First published version
