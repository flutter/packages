// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'utils.dart';

void main() => defineTests();

void defineTests() {
  group('Text Scale Factor', () {
    testWidgets(
      'should use style textScaleFactor in RichText',
      (WidgetTester tester) async {
        const String data = 'Hello';
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              styleSheet: MarkdownStyleSheet(textScaleFactor: 2.0),
              data: data,
            ),
          ),
        );

        final RichText richText = tester.widget(find.byType(RichText));
        expect(richText.textScaleFactor, 2.0); // ignore: deprecated_member_use
      },
    );

    testWidgets(
      'should use MediaQuery textScaleFactor in RichText',
      (WidgetTester tester) async {
        const String data = 'Hello';
        await tester.pumpWidget(
          boilerplate(
            const MediaQuery(
              // ignore: deprecated_member_use
              data: MediaQueryData(textScaleFactor: 2.0),
              child: MarkdownBody(
                data: data,
              ),
            ),
          ),
        );

        final RichText richText = tester.widget(find.byType(RichText));
        expect(richText.textScaleFactor, 2.0); // ignore: deprecated_member_use
      },
    );

    testWidgets(
      'should use MediaQuery textScaleFactor in SelectableText.rich',
      (WidgetTester tester) async {
        const String data = 'Hello';
        await tester.pumpWidget(
          boilerplate(
            const MediaQuery(
              // ignore: deprecated_member_use
              data: MediaQueryData(textScaleFactor: 2.0),
              child: MarkdownBody(
                data: data,
                selectable: true,
              ),
            ),
          ),
        );

        final SelectableText selectableText =
            tester.widget(find.byType(SelectableText));
        // ignore: deprecated_member_use
        expect(selectableText.textScaleFactor, 2.0);
      },
    );
  });
}
