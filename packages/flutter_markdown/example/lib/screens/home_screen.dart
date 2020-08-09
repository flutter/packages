// Copyright 2020 Quiverware LLC. Open source contribution. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import '../demos/basic_markdown_demo.dart';
import '../demos/extended_emoji_demo.dart';
import '../demos/minimal_markdown_demo.dart';
import '../demos/original_demo.dart';
import '../demos/subscript_syntax_demo.dart';
import '../demos/wrap_alignment_demo.dart';
import '../screens/demo_card.dart';
import '../shared/markdown_demo_widget.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/homeScreen';

  final _demos = <MarkdownDemoWidget>[
    MinimalMarkdownDemo(),
    BasicMarkdownDemo(),
    WrapAlignmentDemo(),
    SubscriptSyntaxDemo(),
    ExtendedEmojiDemo(),
    OriginalMarkdownDemo(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Markdown Demos'),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.black12,
          child: ListView(
            children: [
              for (var demo in _demos) DemoCard(widget: demo),
            ],
          ),
        ),
      ),
    );
  }
}
