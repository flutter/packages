// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import '../shared/markdown_demo_widget.dart';

// ignore_for_file: public_member_api_docs

const String _data = '''
## Centered Title

###### ※ ※ ※

''';

const String _notes = '''
# Centered Title Demo
---

## Overview
This example demonstrates how to implement a centered headline using a custom builder.

''';

// TODO(goderbauer): Restructure the examples to avoid this ignore, https://github.com/flutter/flutter/issues/110208.
// ignore: avoid_implementing_value_types
class CenteredHeaderDemo extends StatelessWidget implements MarkdownDemoWidget {
  const CenteredHeaderDemo({super.key});

  static const String _title = 'Centered Header Demo';

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
    return FutureBuilder<String>(
      future: data,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Markdown(
            data: snapshot.data!,
            builders: <String, MarkdownElementBuilder>{
              'h2': CenteredHeaderBuilder(),
              'h6': CenteredHeaderBuilder(),
            },
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}

class CenteredHeaderBuilder extends MarkdownElementBuilder {
  @override
  Widget visitText(md.Text text, TextStyle? preferredStyle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(text.text, style: preferredStyle),
      ],
    );
  }
}
