// Copyright 2020 Quiverware LLC. Open source contribution. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
          '10.',
          'Item 10',
          '11.',
          'Item 11'
        ]);
      },
    );
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

    testWidgets(
      'custom checkbox builder',
      (WidgetTester tester) async {
        const String data = '- [x] Item 1\n- [ ] Item 2';
        final MarkdownCheckboxBuilder builder =
            (bool checked) => Text('$checked');

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
}
