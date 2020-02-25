// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

const String _markdownData = """
# Markdown Example
Markdown allows you to easily include formatted text, images, and even formatted Dart code in your app.

## Titles

Setext-style


This is an H1
=============

This is an H2
-------------


Atx-style


# This is an H1

## This is an H2

###### This is an H6


## List

- Use bulleted lists
- To better clarify
- Your points

1. This list
2. Contains several numbered items
3. to demonstrate

""";

void main() {
  runApp(
    MaterialApp(
      title: "Markdown Text Alignment Demo",
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Markdown Text Alignment Demo'),
        ),
        body: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            return Markdown(
              data: _markdownData,
              styleSheet:
                  MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                textAlign: WrapAlignment.center,
                unorderedListAlign: WrapAlignment.center,
                orderedListAlign: WrapAlignment.center,
                h1Align: WrapAlignment.center,
                h2Align: WrapAlignment.center,
                h6Align: WrapAlignment.center,
              ),
            );
          }),
        ),
      ),
    ),
  );
}
