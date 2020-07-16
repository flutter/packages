# Flutter Markdown
[![pub package](https://img.shields.io/pub/v/flutter_markdown.svg)](https://pub.dartlang.org/packages/flutter_markdown) 
[![Build Status](https://travis-ci.org/flutter/flutter_markdown.svg?branch=master)](https://travis-ci.org/flutter/flutter_markdown)


A markdown renderer for Flutter. It supports the
[original format](https://daringfireball.net/projects/markdown/), but no inline
html.

## Getting Started

Using the Markdown widget is simple, just pass in the source markdown as a
string:

    Markdown(data: markdownSource);

If you do not want the padding or scrolling behavior, use the MarkdownBody
instead:

    MarkdownBody(data: markdownSource);

By default, Markdown uses the formatting from the current material design theme,
but it's possible to create your own custom styling. Use the MarkdownStyle class
to pass in your own style. If you don't want to use Markdown outside of material
design, use the MarkdownRaw class.

## Emoji Support

Emoji glyphs can be included in the formatted text displayed by the Markdown widget by either inserting the emoji glyph directly or using the inline emoji tag syntax in the source Markdown document.

Markdown documents using UTF-8 encoding can insert emojis, symbols, and other Unicode characters directly in the source document. Emoji glyphs inserted directly in the Markdown source data are treated as text and preserved in the formatted output of the Markdown widget. For example, in the following Markdown widget constructor, a text string with a smiley face emoji is passed in as the source Markdown data.

```
Markdown(
    controller: controller,
    selectable: true,
    data: 'Insert emoji here😀 ',
)
```

The resulting Markdown widget will contain a single line of text with the emoji preserved in the formatted text output.

The second method for including emoji glyphs is to provide the Markdown widget with a syntax extension for inline emoji tags. The Markdown package includes a syntax extension for emojis, EmojiSyntax. The default extension set used by the Markdown widget is the GitHub flavored extension set. This pre-defined extension set approximates the GitHub supported Markdown tags, providing syntax handlers for fenced code blocks, tables, auto-links, and strike-through. To include the inline emoji tag syntax while maintaining the default GitHub flavored Markdown behavior, define an extension set that combines EmojiSyntax with ExtensionSet.gitHubFlavored.

```
import 'package:markdown/markdown.dart' as md;

Markdown(
    controller: controller,
    selectable: true,
    data: 'Insert emoji :smiley: here',
    extensionSet: md.ExtensionSet(
        [md.gitHubFlavored.blockSyntaxes],
        [md.EmojiSyntax(), ...md.gitHubFlavored.inlineSyntaxes]),
)
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
