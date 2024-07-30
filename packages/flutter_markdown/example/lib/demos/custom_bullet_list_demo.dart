// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(goderbauer): Restructure the examples to avoid this ignore, https://github.com/flutter/flutter/issues/110208.
// ignore_for_file: avoid_implementing_value_types

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../shared/markdown_demo_widget.dart';

// ignore_for_file: public_member_api_docs

const String _markdownData = '''
# Custom Ordered List Demo

## Unordered List

- first
- second
   - first
      - first
      - second
   - first
      - second

## Ordered List

1. first
2. second
   1. first
      1. first
      2. second
   1. first
      1. second
''';

const String _notes = '''
# Custom Bullet List Demo
---

## Overview

This is the custom bullet list demo. This demo shows how to customize the bullet list style.
This demo example is being preserved for reference purposes.
''';

class CustomBulletListDemo extends StatelessWidget
    implements MarkdownDemoWidget {
  const CustomBulletListDemo({super.key});

  static const String _title = 'Custom Bullet List Demo';

  @override
  String get title => CustomBulletListDemo._title;

  @override
  String get description => 'Shows how to customize the bullet list style.';

  @override
  Future<String> get data => Future<String>.value(_markdownData);

  @override
  Future<String> get notes => Future<String>.value(_notes);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Markdown(
          data: _markdownData,
          bulletBuilder: (MarkdownBulletParameters parameters) => FittedBox(
            fit: BoxFit.scaleDown,
            child: switch (parameters.style) {
              BulletStyle.unorderedList => const Text('・'),
              BulletStyle.orderedList =>
                Text('${parameters.nestLevel}-${parameters.index + 1}.'),
            },
          ),
        ),
      ),
    );
  }
}
