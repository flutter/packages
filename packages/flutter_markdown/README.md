# Flutter Markdown
[![pub package](https://img.shields.io/pub/v/flutter_markdown.svg)](https://pub.dartlang.org/packages/flutter_markdown)


A markdown renderer for Flutter. It supports the
[original format](https://daringfireball.net/projects/markdown/), but no inline
HTML.

## Overview

The [`flutter_markdown`](https://pub.dev/packages/flutter_markdown) package
renders Markdown, a lightweight markup language, into a Flutter widget
containing a rich text representation.

`flutter_markdown` is built on top of the Dart
[`markdown`](https://pub.dev/packages/markdown) package, which parses
the Markdown into an abstract syntax tree (AST). The nodes of the AST are an
HTML representation of the Markdown data.

## Flutter Isn't an HTML Renderer

While this approach to creating a rich text representation of Markdown source
text in Flutter works well, Flutter isn't an HTML renderer like a web browser.
Markdown was developed by John Gruber in 2004 to allow users to turn readable,
plain text content into rich text HTML. This close association with HTML allows
for the injection of HTML into the Markdown source data. Markdown parsers
generally ignore hand-tuned HTML and pass it through to be included in the
generated HTML. This *trick* has allowed users to perform some customization
or tweaking of the HTML output. A common HTML tweak is to insert HTML line-break
elements **\<br />** in Markdown source to force additional line breaks not
supported by the Markdown syntax. This HTML *trick* doesn't apply to Flutter. The
`flutter_markdown` package doesn't support inline HTML.

## Markdown Specifications and `flutter_markdown` Compliance

There are three seminal documents regarding Markdown syntax; the
[original Markdown syntax documentation](https://daringfireball.net/projects/markdown/syntax)
specified by John Gruber, the
[CommonMark specification](https://spec.commonmark.org/0.29/), and the
[GitHub Flavored Markdown specification](https://github.github.com/gfm/).

The CommonMark specification brings order to and clarifies the Markdown syntax
cases left ambiguous or unclear in the Gruber document. GitHub Flavored
Markdown (GFM) is a strict superset of CommonMark used by GitHub.

The `markdown` package, and in extension, the `flutter_markdown` package, supports
four levels of Markdown syntax; basic, CommonMark, GitHub Flavored, and GitHub
Web. Basic, CommonMark, and GitHub Flavored adhere to the three Markdown
documents, respectively. GitHub Web adds header ID and emoji support. The
`flutter_markdown` package defaults to GitHub Flavored Markdown.

## Getting Started

Using the Markdown widget is simple, just pass in the source markdown as a
string:

<?code-excerpt "example/lib/readme_excerpts.dart (CreateMarkdown)"?>
```dart
const Markdown(data: markdownSource);
```

If you do not want the padding or scrolling behavior, use the MarkdownBody
instead:

<?code-excerpt "example/lib/readme_excerpts.dart (CreateMarkdownBody)"?>
```dart
const MarkdownBody(data: markdownSource);
```

By default, Markdown uses the formatting from the current material design theme,
but it's possible to create your own custom styling. Use the MarkdownStyle class
to pass in your own style. If you don't want to use Markdown outside of material
design, use the MarkdownRaw class.

## Selection

By default, Markdown is not selectable. A caller may use the following ways to
customize the selection behavior of Markdown:

* Set `selectable` to true, and use `onTapText` and `onSelectionChanged` to
  handle tapping and selecting events.
* Set `selectable` to false, and wrap Markdown with [`SelectionArea`](https://api.flutter.dev/flutter/material/SelectionArea-class.html) or [`SelectionRegion`](https://api.flutter.dev/flutter/widgets/SelectableRegion-class.html).

## Emoji Support

Emoji glyphs can be included in the formatted text displayed by the Markdown
widget by either inserting the emoji glyph directly or using the inline emoji
tag syntax in the source Markdown document.

Markdown documents using UTF-8 encoding can insert emojis, symbols, and other
Unicode characters directly in the source document. Emoji glyphs inserted
directly in the Markdown source data are treated as text and preserved in the
formatted output of the Markdown widget. For example, in the following Markdown
widget constructor, a text string with a smiley face emoji is passed in as the
source Markdown data.

<?code-excerpt "example/lib/readme_excerpts.dart (CreateMarkdownWithEmoji)"?>
```dart
Markdown(
  controller: controller,
  selectable: true,
  data: 'Insert emoji here😀 ',
);
```

The resulting Markdown widget will contain a single line of text with the
emoji preserved in the formatted text output.

The second method for including emoji glyphs is to provide the Markdown
widget with a syntax extension for inline emoji tags. The Markdown
package includes a syntax extension for emojis, EmojiSyntax. The default
extension set used by the Markdown widget is the GitHub flavored extension
set. This pre-defined extension set approximates the GitHub supported
Markdown tags, providing syntax handlers for fenced code blocks, tables,
auto-links, and strike-through. To include the inline emoji tag syntax
while maintaining the default GitHub flavored Markdown behavior, define
an extension set that combines EmojiSyntax with ExtensionSet.gitHubFlavored.

<?code-excerpt "example/lib/readme_excerpts.dart (CreateMarkdownWithEmojiExtension)"?>
```dart
import 'package:markdown/markdown.dart' as md;
// ···
  Markdown(
    controller: controller,
    selectable: true,
    data: 'Insert emoji :smiley: here',
    extensionSet: md.ExtensionSet(
      md.ExtensionSet.gitHubFlavored.blockSyntaxes,
      <md.InlineSyntax>[
        md.EmojiSyntax(),
        ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes
      ],
    ),
  );
```

## Image Support

The `Img` tag only supports the following image locations:

* From the network: Use a URL prefixed by either `http://` or `https://`.

* From local files on the device: Use an absolute path to the file, for example by
  concatenating the file name with the path returned by a known storage location,
  such as those provided by the [`path_provider`](https://pub.dartlang.org/packages/path_provider)
  plugin.

* From image locations referring to bundled assets: Use an asset name prefixed by `resource:`.
  like `resource:assets/image.png`.

## Verifying Markdown Behavior

Verifying Markdown behavior in other applications can often be useful to track
down or identify unexpected output from the `flutter_markdown` package. Two
valuable resources are the
[Dart Markdown Live Editor](https://dart-lang.github.io/markdown/) and the
[Markdown Live Preview](https://markdownlivepreview.com/). These two resources
are dynamic, online Markdown viewers.

## Markdown Resources

Here are some additional Markdown syntax resources:

- [Markdown Guide](https://www.markdownguide.org/)
- [CommonMark Markdown Reference](https://commonmark.org/help/)
- [GitHub Guides - Mastering Markdown](https://guides.github.com/features/mastering-markdown/#GitHub-flavored-markdown)
  - [Download PDF cheatsheet version](https://guides.github.com/pdfs/markdown-cheatsheet-online.pdf)
