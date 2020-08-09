// Copyright 2020 Quiverware LLC. Open source contribution. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import '../shared/markdown_demo_widget.dart';

const String _data = """
## Centered Title

###### ※ ※ ※

_* How to implement it see main.dart#L129 in example._
""";

const String _notes = """
# Centered Title Demo
---

> Provide information on the Centered Header builder
""";

/// More information about the centered header builder is needed. The
/// CenteredHeaderBuilder code that was added to the change in pull request
/// #241 https://github.com/flutter/flutter_markdown/pull/241 doesn't
/// appear to work. The changes to the example app to demo the feature are
/// preserved here to be investigated further and potentially fixed.
/// TODO(nobuhito): As the author of this change can you please review and fix?
class CenteredHeaderDemo extends StatelessWidget implements MarkdownDemoWidget {
  static const _title = 'Centered Header Demo';

  @override
  String get title => CenteredHeaderDemo._title;

  @override
  // TODO(nobuhito): please provide a brief description of the demo example.
  String get description =>
      'Provide a description of the Centered Header builder';

  @override
  Future<String> get data => Future<String>.value(_data);

  @override
  // TODO(nobuhito): please provide a implementation notes for the demo example.
  Future<String> get notes => Future<String>.value(_notes);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: data,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Markdown(
            data: snapshot.data,
            builders: {
              'h6': CenteredHeaderBuilder(),
            },
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}

class CenteredHeaderBuilder extends MarkdownElementBuilder {
  @override
  Widget visitText(md.Text text, TextStyle preferredStyle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(text.text, style: preferredStyle),
      ],
    );
  }
}
