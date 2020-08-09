// Copyright 2020 Quiverware LLC. Open source contribution. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import '../shared/markdown_demo_widget.dart';
import '../shared/markdown_extensions.dart';

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

class ExtendedEmojiDemo extends StatelessWidget implements MarkdownDemoWidget {
  static const _title = 'Extended Emoji Demo';

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

  final _notExtended = '# Using Emoji Syntax\n';

  final _extended = '# Using Extened Emoji Syntax\n';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: data,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Container(
            margin: EdgeInsets.all(12),
            constraints: BoxConstraints.expand(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MarkdownBody(
                  data: _notExtended + snapshot.data,
                  extensionSet: MarkdownExtensionSet.githubWeb.value,
                ),
                SizedBox(
                  height: 24,
                ),
                MarkdownBody(
                  data: _extended + snapshot.data,
                  extensionSet: md.ExtensionSet([], [ExtendedEmojiSyntax()]),
                ),
              ],
            ),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}

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
