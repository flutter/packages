// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import '../demos/basic_markdown_demo.dart';
import '../demos/centered_header_demo.dart';
import '../demos/custom_bullet_list_demo.dart';
import '../demos/extended_emoji_demo.dart';
import '../demos/markdown_body_shrink_wrap_demo.dart';
import '../demos/minimal_markdown_demo.dart';
import '../demos/original_demo.dart';
import '../demos/subscript_syntax_demo.dart';
import '../demos/wrap_alignment_demo.dart';
import '../screens/demo_card.dart';
import '../shared/markdown_demo_widget.dart';

// ignore_for_file: public_member_api_docs

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  static const String routeName = '/homeScreen';

  final List<MarkdownDemoWidget> _demos = <MarkdownDemoWidget>[
    const MinimalMarkdownDemo(),
    const BasicMarkdownDemo(),
    const WrapAlignmentDemo(),
    const SubscriptSyntaxDemo(),
    const ExtendedEmojiDemo(),
    OriginalMarkdownDemo(),
    const CenteredHeaderDemo(),
    const MarkdownBodyShrinkWrapDemo(),
    const CustomBulletListDemo(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Markdown Demos'),
      ),
      body: SafeArea(
        child: ColoredBox(
          color: Colors.black12,
          child: ListView(
            children: <Widget>[
              for (final MarkdownDemoWidget demo in _demos)
                DemoCard(widget: demo),
            ],
          ),
        ),
      ),
    );
  }
}
