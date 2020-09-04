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
  group('Table', () {
    testWidgets(
      'should show properly',
      (WidgetTester tester) async {
        const String data = '|Header 1|Header 2|\n|-----|-----|\n|Col 1|Col 2|';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final Iterable<Widget> widgets = tester.allWidgets;
        expectTextStrings(
            widgets, <String>['Header 1', 'Header 2', 'Col 1', 'Col 2']);
      },
    );

    testWidgets(
      'work without the outer pipes',
      (WidgetTester tester) async {
        const String data = 'Header 1|Header 2\n-----|-----\nCol 1|Col 2';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final Iterable<Widget> widgets = tester.allWidgets;
        expectTextStrings(
            widgets, <String>['Header 1', 'Header 2', 'Col 1', 'Col 2']);
      },
    );

    testWidgets(
      'should work with alignments',
      (WidgetTester tester) async {
        const String data =
            '|Header 1|Header 2|\n|:----:|----:|\n|Col 1|Col 2|';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final Iterable<DefaultTextStyle> styles =
            tester.widgetList(find.byType(DefaultTextStyle));

        expect(styles.first.textAlign, TextAlign.center);
        expect(styles.last.textAlign, TextAlign.right);
      },
    );

    testWidgets(
      'should work with styling',
      (WidgetTester tester) async {
        const String data = '|Header|\n|----|\n|*italic*|';
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(data: data),
          ),
        );

        final Iterable<Widget> widgets = tester.allWidgets;
        final RichText richText =
            widgets.lastWhere((Widget widget) => widget is RichText);

        expectTextStrings(widgets, <String>['Header', 'italic']);
        expect(richText.text.style.fontStyle, FontStyle.italic);
      },
    );

    testWidgets(
      'should work next to other tables',
      (WidgetTester tester) async {
        const String data = '|first header|\n|----|\n|first col|\n\n'
            '|second header|\n|----|\n|second col|';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final Iterable<Widget> tables = tester.widgetList(find.byType(Table));

        expect(tables.length, 2);
      },
    );

    testWidgets(
      'column width should follow stylesheet',
      (WidgetTester tester) async {
        final ThemeData theme =
            ThemeData.light().copyWith(textTheme: textTheme);

        const String data = '|Header|\n|----|\n|Column|';
        const FixedColumnWidth columnWidth = FixedColumnWidth(100);
        final MarkdownStyleSheet style =
            MarkdownStyleSheet.fromTheme(theme).copyWith(
          tableColumnWidth: columnWidth,
        );

        await tester.pumpWidget(
            boilerplate(MarkdownBody(data: data, styleSheet: style)));

        final Table table = tester.widget(find.byType(Table));

        expect(table.defaultColumnWidth, columnWidth);
      },
    );
  });
}
