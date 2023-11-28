// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class IconGeneratorPage extends StatefulWidget {
  const IconGeneratorPage({super.key});

  static int defaultIconCodePoint = int.parse('0xf03f');

  @override
  State<IconGeneratorPage> createState() => _IconGeneratorPageState();
}

class _IconGeneratorPageState extends State<IconGeneratorPage> {
  int iconCodePoint = IconGeneratorPage.defaultIconCodePoint;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          onSubmitted: (String value) {
            final int codePointAsInt =
                int.tryParse(value) ?? IconGeneratorPage.defaultIconCodePoint;
            setState(() {
              iconCodePoint = codePointAsInt;
            });
          },
        ),
        const SizedBox(height: 24.0),
        Icon(generateIcon(iconCodePoint)),
      ],
    );
  }

  // Unless '--no-tree-shake-icons' is passed to the flutter build command,
  // the presence of this method will trigger an exception due to the use of
  // non-constant invocations of [IconData].
  IconData generateIcon(int materialIconCodePoint) => IconData(
        materialIconCodePoint,
        fontFamily: 'MaterialIcons',
      );
}
