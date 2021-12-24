## 0.6.9

  * Leading spaces in a paragraph and in list items are now ignored according to [GFM #192](https://github.github.com/gfm/#example-192) and [GFM #236](https://github.github.com/gfm/#example-236).

## 0.6.8

  * Added option paddingBuilders

## 0.6.7

 * Fix `unnecessary_import` lint errors.
 * Added option pPadding
 * Added options h1Padding - h6Padding

## 0.6.6

 * Soft line break

## 0.6.5

 * Fix unique Keys for RichText blocks

## 0.6.4

 * Fix merging of spans when first span is not a TextSpan

## 0.6.3

 * Fixed `onTap`, now the changed hyperlinks are reflected even with keeping the same link name unchanged.

## 0.6.2

 * Updated metadata for new source location
 * Style changes to conform to flutter/packages analyzer settings

 ## 0.6.1

 * Added builder option bulletBuilder

## 0.6.0

 * Null safety release
 * Added stylesheet option listBulletPadding
 * Fixed blockquote inline styling
 * Added onTapText handler for selectable text

## 0.6.0-nullsafety.2

 * Dependencies updated for null safety

## 0.6.0-nullsafety.1

 * Fix null safety on web
 * Image test mocks fixed for null safety

## 0.6.0-nullsafety.0

 * Initial null safety migration.

## 0.5.2

 * Added `MarkdownListItemCrossAxisAlignment` to allow for intrinsic height
   measurements of lists.

## 0.5.1

 * Fix user defined builders

## 0.5.0

 * BREAKING CHANGE: `MarkdownTapLinkCallback` now has three parameters, not one, exposing more
   information about a tapped link.
   * Note for upgraders, the old single parameter `href` is now the second parameter to match the specification.
 * Android example upgraded
 * Test coverage updated to match GitHub Flavoured Markdown and CommonMark
 * Handle links with empty descriptions
 * Handle empty rows in tables

## 0.4.4

 * Fix handling of newline character in blockquote
 * Add new example demo
 * Use the start attribute in ordered list to set the first number
 * Revert changes made in PR #235 (which broke newline handling)

## 0.4.3

 * Fix merging of `MarkdownStyleSheets`
 * Fix `MarkdownStyleSheet` textScaleFactor to use default value of 1.0, if not provided, instead using the textScaleFactor of the nearest MediaQuery

## 0.4.2

 * Fix parsing of image caption & alt attributes
 * Fix baseline alignment in lists
 * Support `LineBreakSyntax`

## 0.4.1

 * Downgrade Flutter minimum from 1.17.1 to 1.17.0 for Pub

## 0.4.0

 * Updated for Flutter 1.17
 * Ignore newlines in paragraphs
 * Improve handling of horizontal rules

## 0.3.5

 * Fix hardcoded colors and improve Darktheme
 * Fix text alignment when formatting is involved

## 0.3.4

 * Add support for text paragraphs and blockquotes.

## 0.3.3

 * Add the ability to control the scroll position of the `MarkdownWidget`.

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

 * Support GitHub flavoured Markdown
 * Support strikethrough
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
