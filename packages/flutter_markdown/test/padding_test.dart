// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'utils.dart';

void main() => defineTests();

void defineTests() {
  group('Padding builders', () {
    testWidgets(
      'use paddingBuilders for p',
      (WidgetTester tester) async {
        const double paddingX = 10.0;

        await tester.pumpWidget(
          boilerplate(
            Markdown(
                data: '**line 1**\n\n# H1\n![alt](/assets/images/logo.png)',
                paddingBuilders: <String, MarkdownPaddingBuilder>{
                  'p': CustomPaddingBuilder(paddingX * 1),
                  'strong': CustomPaddingBuilder(paddingX * 2),
                  'h1': CustomPaddingBuilder(paddingX * 3),
                  'img': CustomPaddingBuilder(paddingX * 4),
                }),
          ),
        );

        final List<Padding> paddings =
            tester.widgetList<Padding>(find.byType(Padding)).toList();

        expect(paddings.length, 4);
        expect(
          paddings[0].padding.along(Axis.horizontal) == paddingX * 1 * 2,
          true,
        );
        expect(
          paddings[1].padding.along(Axis.horizontal) == paddingX * 3 * 2,
          true,
        );
        expect(
          paddings[2].padding.along(Axis.horizontal) == paddingX * 1 * 2,
          true,
        );
        expect(
          paddings[3].padding.along(Axis.horizontal) == paddingX * 4 * 2,
          true,
        );
        imageCache.clear();
      },
    );
  });
}

class CustomPaddingBuilder extends MarkdownPaddingBuilder {
  CustomPaddingBuilder(this.paddingX);

  double paddingX;

  @override
  EdgeInsets getPadding() {
    return EdgeInsets.symmetric(horizontal: paddingX);
  }
}
