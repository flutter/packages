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

```
This is an H1
=============

This is an H2
-------------
```

Atx-style

```
# This is an H1

## This is an H2

###### This is an H6
```

Select the valid headers:

- [x] `# hello`
- [ ] `#hello`

## Links

[Google's Homepage][Google]

```
[inline-style](https://www.google.com)

[reference-style][Google]
```

## Images

![Flutter logo](/dart-lang/site-shared/master/src/_assets/image/flutter/icon/64.png)

## Tables

|Syntax                                 |Result                               |
|---------------------------------------|-------------------------------------|
|`*italic 1*`                           |*italic 1*                           |
|`_italic 2_`                           | _italic 2_                          |
|`**bold 1**`                           |**bold 1**                           |
|`__bold 2__`                           |__bold 2__                           |
|`This is a ~~strikethrough~~`          |This is a ~~strikethrough~~          |
|`***italic bold 1***`                  |***italic bold 1***                  |
|`___italic bold 2___`                  |___italic bold 2___                  |
|`***~~italic bold strikethrough 1~~***`|***~~italic bold strikethrough 1~~***|
|`~~***italic bold strikethrough 2***~~`|~~***italic bold strikethrough 2***~~|

## Styling
Style text as _italic_, __bold__, ~~strikethrough~~, or `inline code`.

- Use bulleted lists
- To better clarify
- Your points

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

## Markdown widget

This is an example of how to create your own Markdown widget:

    Markdown(data: 'Hello _world_!');

Enjoy!

[Google]: https://www.google.com/
""";

void main() {
  runApp(
    MaterialApp(
      title: "Markdown Demo",
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Markdown Demo'),
        ),
        body: SafeArea(
          child: Markdown(
            data: _markdownData,
            imageDirectory: 'https://raw.githubusercontent.com',
          ),
        ),
      ),
    ),
  );
}
