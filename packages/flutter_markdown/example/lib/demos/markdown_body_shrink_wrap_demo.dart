// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(goderbauer): Restructure the examples to avoid this ignore, https://github.com/flutter/flutter/issues/110208.
// ignore_for_file: avoid_implementing_value_types

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../shared/dropdown_menu.dart' as dropdown;
import '../shared/markdown_demo_widget.dart';

// ignore_for_file: public_member_api_docs

const String _data = '''
**MarkdownBody**
''';

const String _notes = '''
# Shrink wrap demo
---

## Overview

This example demonstrates how `MarkdownBody`'s `shrinkWrap` property works.

- If `shrinkWrap` is `true`, `MarkdownBody` will take the minimum height that
  wraps its content.
- If `shrinkWrap` is `false`, `MarkdownBody` will expand to the maximum allowed
  height.
''';

class MarkdownBodyShrinkWrapDemo extends StatefulWidget
    implements MarkdownDemoWidget {
  const MarkdownBodyShrinkWrapDemo({super.key});

  static const String _title = 'Shrink wrap demo';

  @override
  String get title => MarkdownBodyShrinkWrapDemo._title;

  @override
  String get description => "This example demonstrates how MarkdownBody's "
      'shrinkWrap property works.';

  @override
  Future<String> get data => Future<String>.value(_data);

  @override
  Future<String> get notes => Future<String>.value(_notes);

  @override
  State<MarkdownBodyShrinkWrapDemo> createState() =>
      _MarkdownBodyShrinkWrapDemoState();
}

class _MarkdownBodyShrinkWrapDemoState
    extends State<MarkdownBodyShrinkWrapDemo> {
  bool _shrinkWrap = true;

  final Map<String, bool> _shrinkWrapMenuItems = <String, bool>{
    'true': true,
    'false': false,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        dropdown.DropdownMenu<bool>(
          items: _shrinkWrapMenuItems,
          label: 'Shrink wrap:',
          initialValue: _shrinkWrap,
          onChanged: (bool? value) {
            if (value != _shrinkWrap) {
              setState(() {
                _shrinkWrap = value!;
              });
            }
          },
        ),
        Expanded(
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.5),
                    border: Border.all(
                      color: Colors.red,
                      width: 2,
                    ),
                  ),
                  child: MarkdownBody(
                    data: _data,
                    shrinkWrap: _shrinkWrap,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
