// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() => defineTests();

void defineTests() {
  group('Unordered List', () {
    testWidgets(
      'simple 3 item list',
      (WidgetTester tester) async {
        const String data = '- Item 1\n- Item 2\n- Item 3';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final Iterable<Widget> widgets = tester.allWidgets;
        expectTextStrings(widgets, <String>[
          '•',
          'Item 1',
          '•',
          'Item 2',
          '•',
          'Item 3',
        ]);
      },
    );

    testWidgets(
      'empty list item',
      (WidgetTester tester) async {
        const String data = '- \n- Item 2\n- Item 3';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final Iterable<Widget> widgets = tester.allWidgets;
        expectTextStrings(widgets, <String>[
          '•',
          '•',
          'Item 2',
          '•',
          'Item 3',
        ]);
      },
    );

    testWidgets(
        // Example 236 from the GitHub Flavored Markdown specification.
        'leading space are ignored', (WidgetTester tester) async {
      const String data = ' -    one\n\n        two';
      await tester.pumpWidget(
        boilerplate(
          const MarkdownBody(data: data),
        ),
      );

      final Iterable<Widget> widgets = tester.allWidgets;
      expectTextStrings(widgets, <String>[
        '•',
        'one',
        'two',
      ]);
    });

    testWidgets(
      'leading spaces are ignored (non-paragraph test case)',
      (WidgetTester tester) async {
        const String data = '- one\n-  two\n-   three';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final Iterable<Widget> widgets = tester.allWidgets;
        expectTextStrings(widgets, <String>[
          '•',
          'one',
          '•',
          'two',
          '•',
          'three',
        ]);
      },
    );

    testWidgets('custom bullet builder', (WidgetTester tester) async {
      const String data =
          '* Item 1\n   * Item 2\n      * Item 3\n   * Item 4\n* Item 5';
      Widget builder(MarkdownBulletParameters parameters) => Text(
            '${parameters.index} ${parameters.style == BulletStyle.orderedList ? 'ordered' : 'unordered'} ${parameters.nestLevel}',
          );

      await tester.pumpWidget(
        boilerplate(
          Markdown(data: data, bulletBuilder: builder),
        ),
      );

      final Iterable<Widget> widgets = tester.allWidgets;

      expectTextStrings(widgets, <String>[
        '0 unordered 0',
        'Item 1',
        '0 unordered 1',
        'Item 2',
        '0 unordered 2',
        'Item 3',
        '1 unordered 1',
        'Item 4',
        '1 unordered 0',
        'Item 5',
      ]);
    });
  });

  group('Ordered List', () {
    testWidgets(
      '2 distinct ordered lists with separate index values',
      (WidgetTester tester) async {
        const String data = '1. Item 1\n1. Item 2\n2. Item 3\n\n\n'
            '10. Item 10\n13. Item 11';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final Iterable<Widget> widgets = tester.allWidgets;
        expectTextStrings(widgets, <String>[
          '1.',
          'Item 1',
          '2.',
          'Item 2',
          '3.',
          'Item 3',
          '4.',
          'Item 10',
          '5.',
          'Item 11'
        ]);
      },
    );

    testWidgets('leading space are ignored', (WidgetTester tester) async {
      const String data = ' 1.    one\n\n       two';
      await tester.pumpWidget(
        boilerplate(
          const MarkdownBody(data: data),
        ),
      );

      final Iterable<Widget> widgets = tester.allWidgets;
      expectTextStrings(widgets, <String>['1.', 'one', 'two']);
    });

    testWidgets('custom bullet builder', (WidgetTester tester) async {
      const String data =
          '1. Item 1\n   1. Item 2\n      1. Item 3\n   1. Item 4\n1. Item 5';
      Widget builder(MarkdownBulletParameters parameters) => Text(
            '${parameters.index} ${parameters.style == BulletStyle.orderedList ? 'ordered' : 'unordered'} ${parameters.nestLevel}',
          );

      await tester.pumpWidget(
        boilerplate(
          Markdown(data: data, bulletBuilder: builder),
        ),
      );

      final Iterable<Widget> widgets = tester.allWidgets;

      expectTextStrings(widgets, <String>[
        '0 ordered 0',
        'Item 1',
        '0 ordered 1',
        'Item 2',
        '0 ordered 2',
        'Item 3',
        '1 ordered 1',
        'Item 4',
        '1 ordered 0',
        'Item 5',
      ]);
    });
  });

  group('Task List', () {
    testWidgets(
      'simple 2 item task list',
      (WidgetTester tester) async {
        const String data = '- [x] Item 1\n- [ ] Item 2';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final Iterable<Widget> widgets = tester.allWidgets;

        expectTextStrings(widgets, <String>[
          String.fromCharCode(Icons.check_box.codePoint),
          'Item 1',
          String.fromCharCode(Icons.check_box_outline_blank.codePoint),
          'Item 2',
        ]);
      },
    );

    testWidgets('custom bullet builder', (WidgetTester tester) async {
      const String data = '* Item 1\n* Item 2\n1) Item 3\n2) Item 4';
      Widget builder(MarkdownBulletParameters parameters) => Text(
          '${parameters.index} ${parameters.style == BulletStyle.orderedList ? 'ordered' : 'unordered'}');

      await tester.pumpWidget(
        boilerplate(
          Markdown(data: data, bulletBuilder: builder),
        ),
      );

      final Iterable<Widget> widgets = tester.allWidgets;

      expectTextStrings(widgets, <String>[
        '0 unordered',
        'Item 1',
        '1 unordered',
        'Item 2',
        '0 ordered',
        'Item 3',
        '1 ordered',
        'Item 4',
      ]);
    });

    testWidgets(
      'custom checkbox builder',
      (WidgetTester tester) async {
        const String data = '- [x] Item 1\n- [ ] Item 2';
        Widget builder(bool checked) => Text('$checked');

        await tester.pumpWidget(
          boilerplate(
            Markdown(data: data, checkboxBuilder: builder),
          ),
        );

        final Iterable<Widget> widgets = tester.allWidgets;

        expectTextStrings(widgets, <String>[
          'true',
          'Item 1',
          'false',
          'Item 2',
        ]);
      },
    );
  });

  group('fitContent', () {
    testWidgets(
      'uses maximum width when false',
      (WidgetTester tester) async {
        const String data = '- Foo\n- Bar';

        await tester.pumpWidget(
          boilerplate(
            const Column(
              children: <Widget>[
                MarkdownBody(fitContent: false, data: data),
              ],
            ),
          ),
        );

        final double screenWidth =
            find.byType(Column).evaluate().first.size!.width;
        final double markdownBodyWidth =
            find.byType(MarkdownBody).evaluate().single.size!.width;

        expect(markdownBodyWidth, equals(screenWidth));
      },
    );

    testWidgets(
      'uses minimum width when true',
      (WidgetTester tester) async {
        const String data = '- Foo\n- Bar';

        await tester.pumpWidget(
          boilerplate(
            const Column(
              children: <Widget>[
                MarkdownBody(data: data),
              ],
            ),
          ),
        );

        final double screenWidth =
            find.byType(Column).evaluate().first.size!.width;
        final double markdownBodyWidth =
            find.byType(MarkdownBody).evaluate().single.size!.width;

        expect(markdownBodyWidth, lessThan(screenWidth));
      },
    );
  });
}
