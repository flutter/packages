// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'utils.dart';

void main() => defineTests();

void defineTests() {
  group('MarkdownBody shrinkWrap test', () {
    testWidgets(
      'Given a MarkdownBody with shrinkWrap=true '
      'Then it wraps its content',
      (WidgetTester tester) async {
        await tester.pumpWidget(boilerplate(
          const Stack(
            children: <Widget>[
              Text('shrinkWrap=true'),
              Align(
                alignment: Alignment.bottomCenter,
                child: MarkdownBody(
                  data: 'This is a [link](https://flutter.dev/)',
                ),
              ),
            ],
          ),
        ));

        final Rect stackRect = tester.getRect(find.byType(Stack));
        final Rect textRect = tester.getRect(find.text('shrinkWrap=true'));
        final Rect markdownBodyRect = tester.getRect(find.byType(MarkdownBody));

        // The Text should be on the top of the Stack
        expect(textRect.top, equals(stackRect.top));
        expect(textRect.bottom, lessThan(stackRect.bottom));
        // The MarkdownBody should be on the bottom of the Stack
        expect(markdownBodyRect.top, greaterThan(stackRect.top));
        expect(markdownBodyRect.bottom, equals(stackRect.bottom));
      },
    );
    testWidgets(
      'Given a MarkdownBody with shrinkWrap=false '
      'Then it expands to the maximum allowed height',
      (WidgetTester tester) async {
        await tester.pumpWidget(boilerplate(
          const Stack(
            children: <Widget>[
              Text('shrinkWrap=false test'),
              Align(
                alignment: Alignment.bottomCenter,
                child: MarkdownBody(
                  data: 'This is a [link](https://flutter.dev/)',
                  shrinkWrap: false,
                ),
              ),
            ],
          ),
        ));

        final Rect stackRect = tester.getRect(find.byType(Stack));
        final Rect textRect =
            tester.getRect(find.text('shrinkWrap=false test'));
        final Rect markdownBodyRect = tester.getRect(find.byType(MarkdownBody));

        // The Text should be on the top of the Stack
        expect(textRect.top, equals(stackRect.top));
        expect(textRect.bottom, lessThan(stackRect.bottom));
        // The MarkdownBody should take all Stack's height
        expect(markdownBodyRect.top, equals(stackRect.top));
        expect(markdownBodyRect.bottom, equals(stackRect.bottom));
      },
    );
  });
}
