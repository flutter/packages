// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(goderbauer): Restructure the examples to avoid this ignore, https://github.com/flutter/flutter/issues/110208.
// ignore_for_file: avoid_implementing_value_types

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import '../shared/markdown_demo_widget.dart';

// ignore_for_file: public_member_api_docs

// Markdown source data showing the use of subscript tags.
const String _data = '''
## Subscript Syntax

NaOH + Al_2O_3 = NaAlO_2 + H_2O

C_4H_10 = C_2H_6 + C_2H_4
''';

const String _notes = """
# Subscript Syntax Demo
---

## Overview

This is an example of how to create an inline syntax parser with an
associated element builder. This example defines an inline syntax parser that
matches instances of an underscore character "**_**" followed by a integer
numerical value. When the parser finds a match for this syntax sequence,
a '**sub**' element is inserted into the abstract syntac tree. The supplied
builder for the '**sub**' element, SubscriptBuilder, is then called to create
an appropriate RichText widget for the formatted output.

## Usage

To support a new custom inline Markdown tag, an inline syntax object needs to be
defined for the Markdown parser and an element builder which is deligated the
task of building the appropriate Flutter widgets for the resulting Markdown
output. Instances of these objects need to be provided to the Markdown widget.

```
  Markdown(
    data: _data,
    builders: {
      'sub': SubscriptBuilder(),
    },
    extensionSet: md.ExtensionSet([], [SubscriptSyntax()]),
  );
```

### Inline Syntax Class

```
class SubscriptSyntax extends md.InlineSyntax {
  static final _pattern = r'_([0-9]+)';

  SubscriptSyntax() : super(_pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text('sub', match[1]));
    return true;
  }
```

### Markdown Element Builder

```
class SubscriptBuilder extends MarkdownElementBuilder {
  static const List<String> _subscripts = [
    '₀', '₁', '₂', '₃', '₄', '₅', '₆', '₇', '₈', '₉'
  ];

  @override
  Widget visitElementAfter(md.Element element, TextStyle preferredStyle) {
    String textContent = element.textContent;
    String text = '';
    for (int i = 0; i < textContent.length; i++) {
      text += _subscripts[int.parse(textContent[i])];
    }
    return SelectableText.rich(TextSpan(text: text));
  }
}
```
""";

/// The subscript syntax demo provides an example of creating an inline syntax
/// object which defines the syntax for the Markdown inline parser and an
/// accompanying Markdown element builder object to handle subscript tags.
class SubscriptSyntaxDemo extends StatelessWidget
    implements MarkdownDemoWidget {
  const SubscriptSyntaxDemo({super.key});

  static const String _title = 'Subscript Syntax Demo';

  @override
  String get title => SubscriptSyntaxDemo._title;

  @override
  String get description => 'An example of how to create a custom inline '
      'syntax parser and element builder for numerical subscripts.';

  @override
  Future<String> get data => Future<String>.value(_data);

  @override
  Future<String> get notes => Future<String>.value(_notes);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: data,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Markdown(
            data: snapshot.data!,
            builders: <String, MarkdownElementBuilder>{
              'sub': SubscriptBuilder(),
            },
            extensionSet: md.ExtensionSet(
                <md.BlockSyntax>[], <md.InlineSyntax>[SubscriptSyntax()]),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}

class SubscriptBuilder extends MarkdownElementBuilder {
  static const List<String> _subscripts = <String>[
    '₀',
    '₁',
    '₂',
    '₃',
    '₄',
    '₅',
    '₆',
    '₇',
    '₈',
    '₉'
  ];

  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    // We don't currently have a way to control the vertical alignment of text spans.
    // See https://github.com/flutter/flutter/issues/10906#issuecomment-385723664
    final String textContent = element.textContent;
    String text = '';
    for (int i = 0; i < textContent.length; i++) {
      text += _subscripts[int.parse(textContent[i])];
    }
    return SelectableText.rich(TextSpan(text: text));
  }
}

class SubscriptSyntax extends md.InlineSyntax {
  SubscriptSyntax() : super(_pattern);

  static const String _pattern = r'_([0-9]+)';

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text('sub', match[1]!));
    return true;
  }
}
