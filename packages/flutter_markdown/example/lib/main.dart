// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

const String _markdownData = """# Markdown Example
Markdown allows you to easily include formatted text, images, and even formatted Dart code in your app.

## Styling
Style text as _italic_, __bold__, ~~strikethrough~~, or `inline code`.

- Use bulleted lists
- To better clarify
- Your points

## Links
You can use [hyperlinks](hyperlink) in markdown

## Images

You can include images:

![Flutter logo](https://raw.githubusercontent.com/dart-lang/site-shared/master/src/_assets/image/flutter/icon/64.png)

## Markdown widget

This is an example of how to create your own Markdown widget:

    Markdown(data: 'Hello _world_!');

## Code blocks
Formatted Dart code looks really pretty too:

```
void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: Markdown(data: markdownData),
    ),
  ));
}
```

Enjoy!
""";

void main() {
  runApp(MaterialApp(
    title: "Markdown Demo",
    home: Scaffold(
      appBar: AppBar(title: const Text('Markdown Demo')),
      body: const Markdown(data: _markdownData),
    ),
  ));
}
