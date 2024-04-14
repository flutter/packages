## 0.6.23

* Gracefully handle image dimension parsing failures.

## 0.6.22+1

* Removes `_ambiguate` methods from code.

## 0.6.22

* Introduces a new `MarkdownElementBuilder.isBlockElement()` method to specify if custom element
  is a block.

## 0.6.21+1

* Adds `onSelectionChanged` to the constructors of `Markdown` and `MarkdownBody`.

## 0.6.21

* Fixes support for `WidgetSpan` in `Text.rich` elements inside `MarkdownElementBuilder`.

## 0.6.20+1

* Updates minimum supported SDK version to Flutter 3.19.

## 0.6.20

* Adds `textScaler` to `MarkdownStyleSheet`, and deprecates `textScaleFactor`.
  * Clients using `textScaleFactor: someFactor` should replace it with
    `TextScaler.linear(someFactor)` to preserve behavior.
* Removes use of deprecated Flutter framework `textScaleFactor` methods.
* Updates minimum supported SDK version to Flutter 3.16.

## 0.6.19

* Replaces `RichText` with `Text.rich` so the widget can work with `SelectionArea` when `selectable` is set to false.

## 0.6.18+3

* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.
* Fixes lint warnings.

## 0.6.18+2

* Removes leading whitespace from list items.

## 0.6.18+1

* Fixes a typo in README.

## 0.6.18

* Adds support for `footnote`.

## 0.6.17+4

* Fixes an issue where a code block would overlap its container decoration.

## 0.6.17+3

* Fixes an incorrect note about SDK versions in the 0.6.17+2 CHANGELOG.md entry.

## 0.6.17+2

* Adds pub topics to package metadata.

## 0.6.17+1

* Deletes deprecated splash screen meta-data element.
* Updates README to improve examples of using Markdown.

## 0.6.17

* Introduces a new `MarkdownElementBuilder.visitElementAfterWithContext()` method passing the widget `BuildContext` and
  the parent text's `TextStyle`.

## 0.6.16

* Adds `tableVerticalAlignment` property to allow aligning table cells vertically.

## 0.6.15+1

* Fixes 'The Scrollbar's ScrollController has no ScrollPosition attached' exception when scrolling scrollable code blocks.
* Fixes stale ignore: prefer_const_constructors.
* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.

## 0.6.15

* Fixes unawaited_futures violations.
* Updates minimum Flutter version to 3.3.
* Aligns Dart and Flutter SDK constraints.
* Replace `describeEnum` with the `name` getter.
* Supports custom rendering of tags without children.

## 0.6.14

* Require `markdown: ^7.0.0`

## 0.6.13+1

* Adjusts code to account for nullability change in Flutter SDK.
* Updates the example to specify the import for `DropdownMenu`.

## 0.6.13

* Support changes in the latest `package:markdown`.

## 0.6.12

* Markdown Lists now take into account `fitContent` instead of always expanding to the maximum horizontally ([flutter/flutter#108976](https://github.com/flutter/flutter/issues/108976)).

## 0.6.11

* Deprecates and removes use of `TaskListSyntax` as new markdown package supports checkboxes natively.
  Consider using `OrderedListWithCheckBoxSyntax` or `UnorderedListWithCheckBoxSyntax` as a replacement.
* Changes `_buildCheckbox()` to inspect state of checkbox input element by existence of `'checked'` attribute.

## 0.6.10+6

* Removes print logged when not handling hr for alignment.
* Removes print logged when not handling li for alignment.

## 0.6.10+5

* Fixes lint warnings.

## 0.6.10+4

* Updates text theme parameters to avoid deprecation issues.

## 0.6.10+3

* Fixes shrinkWrap not taken into account with single child ([flutter/flutter#105299](https://github.com/flutter/flutter/issues/105299)).

## 0.6.10+2

* Migrates from `ui.hash*` to `Object.hash*`.

## 0.6.10+1

* Updates Linux example to remove unneeded library dependencies that
  could cause build failures.
* Updates for non-nullable bindings.

## 0.6.10

 * Update `markdown` dependency

## 0.6.9+1

 * Remove build status badge from `README.md`

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
