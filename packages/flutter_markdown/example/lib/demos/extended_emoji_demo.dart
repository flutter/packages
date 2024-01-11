// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import '../shared/markdown_demo_widget.dart';
import '../shared/markdown_extensions.dart';

// ignore_for_file: public_member_api_docs

const String _notes = """
# Extended Emoji Demo
---

## Overview

This simple example demonstrates how to subclass an existing inline syntax
parser to extend, enhance, or modify its behavior. This example shows how to
subclass the EmojiSyntax inline syntax parser to support alternative names for
the thumbs up and thumbs down emoji characters. The emoji character map used by
EmojiSyntax has the keys "+1" and "-1" associated with the thumbs up and thumbs
down emoji characters, respectively. The ExtendedEmojiSyntax subclass extends
the EmojiSyntax class by overriding the onMatch method to intercept the call
from the parser. ExtendedEmojiSyntax either handles the matched tag or passes
the match along to its parent for processing.

```
class ExtendedEmojiSyntax extends md.EmojiSyntax {
  static const alternateTags = <String, String>{
    'thumbsup': '👍',
    'thumbsdown': '👎',
  };

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    var emoji = alternateTags[match[1]];
    if (emoji != null) {
      parser.addNode(md.Text(emoji));
      return true;
    }
    return super.onMatch(parser, match);
  }
}
```
""";

// TODO(goderbauer): Restructure the examples to avoid this ignore, https://github.com/flutter/flutter/issues/110208.
// ignore: avoid_implementing_value_types
class ExtendedEmojiDemo extends StatelessWidget implements MarkdownDemoWidget {
  const ExtendedEmojiDemo({super.key});

  static const String _title = 'Extended Emoji Demo';

  @override
  String get title => ExtendedEmojiDemo._title;

  @override
  String get description => 'Demonstrates how to extend an existing inline'
      ' syntax parser by intercepting the parser onMatch routine.';

  @override
  Future<String> get data =>
      Future<String>.value('Simple test :smiley: :thumbsup:!');

  @override
  Future<String> get notes => Future<String>.value(_notes);

  static const String _notExtended = '# Using Emoji Syntax\n';

  static const String _extended = '# Using Extened Emoji Syntax\n';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: data,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Container(
            margin: const EdgeInsets.all(12),
            constraints: const BoxConstraints.expand(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                MarkdownBody(
                  data: _notExtended + snapshot.data!,
                  extensionSet: MarkdownExtensionSet.githubWeb.value,
                ),
                const SizedBox(
                  height: 24,
                ),
                MarkdownBody(
                  data: _extended + snapshot.data!,
                  extensionSet: md.ExtensionSet(<md.BlockSyntax>[],
                      <md.InlineSyntax>[ExtendedEmojiSyntax()]),
                ),
              ],
            ),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}

class ExtendedEmojiSyntax extends md.EmojiSyntax {
  static const Map<String, String> alternateTags = <String, String>{
    'thumbsup': '👍',
    'thumbsdown': '👎',
  };

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final String? emoji = alternateTags[match[1]!];
    if (emoji != null) {
      parser.addNode(md.Text(emoji));
      return true;
    }
    return super.onMatch(parser, match);
  }
}
