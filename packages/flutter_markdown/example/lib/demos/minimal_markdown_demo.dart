// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(goderbauer): Restructure the examples to avoid this ignore, https://github.com/flutter/flutter/issues/110208.
// ignore_for_file: avoid_implementing_value_types

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../shared/markdown_demo_widget.dart';

// ignore_for_file: public_member_api_docs

const String _data = '''
# Minimal Markdown Test
---
This is a simple Markdown test. Provide a text string with Markdown tags
to the Markdown widget and it will display the formatted output in a scrollable
widget.

## Section 1
Maecenas eget **arcu egestas**, mollis ex vitae, posuere magna. Nunc eget
 aliquam tortor. Vestibulum porta sodales efficitur. Mauris interdum turpis
 eget est condimentum, vitae porttitor diam ornare.

### Subsection A
Sed et massa finibus, blandit massa vel, vulputate velit. Vestibulum vitae
venenatis libero. ***Curabitur sem lectus, feugiat eu justo in, eleifend
accumsan ante.*** Sed a fermentum elit. Curabitur sodales metus id mi ornare,
in ullamcorper magna congue.
''';

const String _notes = """
# Minimal Markdown Demo
---

## Overview

The simplest use case that illustrates how to make use of the
flutter_markdown package is to include a Markdown widget in a widget tree
and supply it with a character string of text containing Markdown formatting
syntax. Here is a simple Flutter app that creates a Markdown widget that
formats and displays the text in the string _markdownData. The resulting
Flutter app demonstrates the use of headers, rules, and emphasis text from
plain text Markdown syntax.

## Usage

The code sample below demonstrates a simple Flutter app with a Markdown widget.

```
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

const String _markdownData = \"""
# Minimal Markdown Test
---
This is a simple Markdown test. Provide a text string with Markdown tags
to the Markdown widget and it will display the formatted output in a
scrollable widget.

## Section 1
Maecenas eget **arcu egestas**, mollis ex vitae, posuere magna. Nunc eget
aliquam tortor. Vestibulum porta sodales efficitur. Mauris interdum turpis
eget est condimentum, vitae porttitor diam ornare.

### Subsection A
Sed et massa finibus, blandit massa vel, vulputate velit. Vestibulum vitae
venenatis libero. **__Curabitur sem lectus, feugiat eu justo in, eleifend
accumsan ante.__** Sed a fermentum elit. Curabitur sodales metus id mi
ornare, in ullamcorper magna congue.
\""";

void main() {
  runApp(
    MaterialApp(
      title: "Markdown Demo",
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Simple Markdown Demo'),
        ),
        body: SafeArea(
          child: Markdown(
            data: _markdownData,
          ),
        ),
      ),
    ),
  );
}
```
""";

class MinimalMarkdownDemo extends StatelessWidget
    implements MarkdownDemoWidget {
  const MinimalMarkdownDemo({super.key});

  static const String _title = 'Minimal Markdown Demo';

  @override
  String get title => MinimalMarkdownDemo._title;

  @override
  String get description => 'A minimal example of how to use the Markdown '
      'widget in a Flutter app.';

  @override
  Future<String> get data => Future<String>.value(_data);

  @override
  Future<String> get notes => Future<String>.value(_notes);

  @override
  Widget build(BuildContext context) {
    return const Markdown(
      data: _data,
    );
  }
}
