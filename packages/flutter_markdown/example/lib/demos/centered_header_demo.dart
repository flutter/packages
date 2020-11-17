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

""";

const String _notes = """
# Centered Title Demo
---

## Overview
This example demonstrates how to implement a centered headline using a custom builder.

""";

class CenteredHeaderDemo extends StatelessWidget implements MarkdownDemoWidget {
  static const _title = 'Centered Header Demo';

  @override
  String get title => CenteredHeaderDemo._title;

  @override
  String get description =>
      'An example of using a user defined builder to implement a centered headline';

  @override
  Future<String> get data => Future<String>.value(_data);

  @override
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
              'h2': CenteredHeaderBuilder(),
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
