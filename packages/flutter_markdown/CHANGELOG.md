## 0.3.2

 * Uplift `package:markdown` dependency version to enable deleting HTML unescape URI workaround
 * Explictly state that Flutter 1.10.7 is the minimum supported Flutter version in the library `pubspec.yaml`.

## 0.3.1

 * Expose `tableColumnWidth`
 * Add `MarkdownStyleSheet.fromCupertinoTheme`
 * Fix `MarkdownStyleSheet.blockquote`
 * Flutter for web support
 * Add physic and shrinkWrap to Markdown widget
 * Add MarkdownBody.fitContent
 * Support select text to copy
 * Fix list bullet alignment
 * HTML unescape URIs (temporary workaround for [dart-lang/markdown #272](https://github.com/dart-lang/markdown/issues/272))
 * Rebuilt `example/android` and `example/ios` directories

**Note:** this version has an implicit minimum supported version of Flutter 1.10.7.
See [flutter/flutter_markdown issue #156](https://github.com/flutter/flutter_markdown/issues/156) for more detail.

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
