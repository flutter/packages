// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
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
            '|Header 1|Header 2|Header 3|\n|:----|:----:|----:|\n|Col 1|Col 2|Col 3|';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final Iterable<DefaultTextStyle> styles =
            tester.widgetList(find.byType(DefaultTextStyle));

        expect(styles.first.textAlign, TextAlign.left);
        expect(styles.elementAt(1).textAlign, TextAlign.center);
        expect(styles.last.textAlign, TextAlign.right);

        final Iterable<Wrap> wraps = tester.widgetList(find.byType(Wrap));

        expect(wraps.first.alignment, WrapAlignment.start);
        expect(wraps.elementAt(1).alignment, WrapAlignment.center);
        expect(wraps.last.alignment, WrapAlignment.end);

        final Iterable<Text> texts = tester.widgetList(find.byType(Text));

        expect(texts.first.textAlign, TextAlign.left);
        expect(texts.elementAt(1).textAlign, TextAlign.center);
        expect(texts.last.textAlign, TextAlign.right);
      },
    );

    testWidgets(
      'should work with styling',
      (WidgetTester tester) async {
        const String data = '|Header|\n|----|\n|*italic*|';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final Iterable<Widget> widgets = tester.allWidgets;
        final Text text =
            widgets.lastWhere((Widget widget) => widget is Text) as Text;

        expectTextStrings(widgets, <String>['Header', 'italic']);
        expect(text.textSpan!.style!.fontStyle, FontStyle.italic);
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

    testWidgets(
      'table cell vertical alignment should default to middle',
      (WidgetTester tester) async {
        final ThemeData theme =
            ThemeData.light().copyWith(textTheme: textTheme);

        const String data = '|Header|\n|----|\n|Column|';
        final MarkdownStyleSheet style = MarkdownStyleSheet.fromTheme(theme);
        await tester.pumpWidget(
            boilerplate(MarkdownBody(data: data, styleSheet: style)));

        final Table table = tester.widget(find.byType(Table));

        expect(
            table.defaultVerticalAlignment, TableCellVerticalAlignment.middle);
      },
    );

    testWidgets(
      'table cell vertical alignment should follow stylesheet',
      (WidgetTester tester) async {
        final ThemeData theme =
            ThemeData.light().copyWith(textTheme: textTheme);

        const String data = '|Header|\n|----|\n|Column|';
        const TableCellVerticalAlignment tableCellVerticalAlignment =
            TableCellVerticalAlignment.top;
        final MarkdownStyleSheet style = MarkdownStyleSheet.fromTheme(theme)
            .copyWith(tableVerticalAlignment: tableCellVerticalAlignment);

        await tester.pumpWidget(
            boilerplate(MarkdownBody(data: data, styleSheet: style)));

        final Table table = tester.widget(find.byType(Table));

        expect(table.defaultVerticalAlignment, tableCellVerticalAlignment);
      },
    );

    testWidgets(
      'table cell vertical alignment should follow stylesheet for different values',
      (WidgetTester tester) async {
        final ThemeData theme =
            ThemeData.light().copyWith(textTheme: textTheme);

        const String data = '|Header|\n|----|\n|Column|';
        const TableCellVerticalAlignment tableCellVerticalAlignment =
            TableCellVerticalAlignment.bottom;
        final MarkdownStyleSheet style = MarkdownStyleSheet.fromTheme(theme)
            .copyWith(tableVerticalAlignment: tableCellVerticalAlignment);

        await tester.pumpWidget(
            boilerplate(MarkdownBody(data: data, styleSheet: style)));

        final Table table = tester.widget(find.byType(Table));

        expect(table.defaultVerticalAlignment, tableCellVerticalAlignment);
      },
    );

    testWidgets(
      'table scrollbar thumbVisibility should follow stylesheet',
      (WidgetTester tester) async {
        final ThemeData theme =
            ThemeData.light().copyWith(textTheme: textTheme);

        const String data = '|Header|\n|----|\n|Column|';
        const bool tableScrollbarThumbVisibility = true;
        final MarkdownStyleSheet style = MarkdownStyleSheet.fromTheme(theme)
            .copyWith(
                tableColumnWidth: const FixedColumnWidth(100),
                tableScrollbarThumbVisibility: tableScrollbarThumbVisibility);

        await tester.pumpWidget(
            boilerplate(MarkdownBody(data: data, styleSheet: style)));

        final Scrollbar scrollbar = tester.widget(find.byType(Scrollbar));

        expect(scrollbar.thumbVisibility, tableScrollbarThumbVisibility);
      },
    );

    testWidgets(
      'table scrollbar thumbVisibility should follow stylesheet',
      (WidgetTester tester) async {
        final ThemeData theme =
            ThemeData.light().copyWith(textTheme: textTheme);

        const String data = '|Header|\n|----|\n|Column|';
        const bool tableScrollbarThumbVisibility = false;
        final MarkdownStyleSheet style = MarkdownStyleSheet.fromTheme(theme)
            .copyWith(
                tableColumnWidth: const FixedColumnWidth(100),
                tableScrollbarThumbVisibility: tableScrollbarThumbVisibility);

        await tester.pumpWidget(
            boilerplate(MarkdownBody(data: data, styleSheet: style)));

        final Scrollbar scrollbar = tester.widget(find.byType(Scrollbar));

        expect(scrollbar.thumbVisibility, tableScrollbarThumbVisibility);
      },
    );

    testWidgets(
      'table with last row of empty table cells',
      (WidgetTester tester) async {
        final ThemeData theme =
            ThemeData.light().copyWith(textTheme: textTheme);

        const String data = '|Header 1|Header 2|\n|----|----|\n| | |';
        const FixedColumnWidth columnWidth = FixedColumnWidth(100);
        final MarkdownStyleSheet style =
            MarkdownStyleSheet.fromTheme(theme).copyWith(
          tableColumnWidth: columnWidth,
        );

        await tester.pumpWidget(
            boilerplate(MarkdownBody(data: data, styleSheet: style)));

        final Table table = tester.widget(find.byType(Table));

        expectTableSize(2, 2);

        expect(find.byType(Text), findsNWidgets(4));
        final List<String?> cellText = find
            .byType(Text)
            .evaluate()
            .map((Element e) => e.widget)
            .cast<Text>()
            .map((Text text) => text.textSpan!)
            .cast<TextSpan>()
            .map((TextSpan e) => e.text)
            .toList();
        expect(cellText[0], 'Header 1');
        expect(cellText[1], 'Header 2');
        expect(cellText[2], '');
        expect(cellText[3], '');

        expect(table.defaultColumnWidth, columnWidth);
      },
    );

    testWidgets(
      'table with an empty row an last row has an empty table cell',
      (WidgetTester tester) async {
        final ThemeData theme =
            ThemeData.light().copyWith(textTheme: textTheme);

        const String data =
            '|Header 1|Header 2|\n|----|----|\n| | |\n| bar | |';
        const FixedColumnWidth columnWidth = FixedColumnWidth(100);
        final MarkdownStyleSheet style =
            MarkdownStyleSheet.fromTheme(theme).copyWith(
          tableColumnWidth: columnWidth,
        );

        await tester.pumpWidget(
            boilerplate(MarkdownBody(data: data, styleSheet: style)));

        final Table table = tester.widget(find.byType(Table));

        expectTableSize(3, 2);

        expect(find.byType(RichText), findsNWidgets(6));
        final List<String?> cellText = find
            .byType(Text)
            .evaluate()
            .map((Element e) => e.widget)
            .cast<Text>()
            .map((Text richText) => richText.textSpan!)
            .cast<TextSpan>()
            .map((TextSpan e) => e.text)
            .toList();
        expect(cellText[0], 'Header 1');
        expect(cellText[1], 'Header 2');
        expect(cellText[2], '');
        expect(cellText[3], '');
        expect(cellText[4], 'bar');
        expect(cellText[5], '');

        expect(table.defaultColumnWidth, columnWidth);
      },
    );

    group('GFM Examples', () {
      testWidgets(
        // Example 198 from GFM.
        'simple table',
        (WidgetTester tester) async {
          final ThemeData theme =
              ThemeData.light().copyWith(textTheme: textTheme);

          const String data = '| foo | bar |\n| --- | --- |\n| baz | bim |';
          const FixedColumnWidth columnWidth = FixedColumnWidth(100);
          final MarkdownStyleSheet style =
              MarkdownStyleSheet.fromTheme(theme).copyWith(
            tableColumnWidth: columnWidth,
          );

          await tester.pumpWidget(
              boilerplate(MarkdownBody(data: data, styleSheet: style)));

          final Table table = tester.widget(find.byType(Table));

          expectTableSize(2, 2);

          expect(find.byType(Text), findsNWidgets(4));
          final List<String?> cellText = find
              .byType(Text)
              .evaluate()
              .map((Element e) => e.widget)
              .cast<Text>()
              .map((Text text) => text.textSpan!)
              .cast<TextSpan>()
              .map((TextSpan e) => e.text)
              .toList();
          expect(cellText[0], 'foo');
          expect(cellText[1], 'bar');
          expect(cellText[2], 'baz');
          expect(cellText[3], 'bim');
          expect(table.defaultColumnWidth, columnWidth);
        },
      );

      testWidgets(
        // Example 199 from GFM.
        'input table cell data does not need to match column length',
        (WidgetTester tester) async {
          final ThemeData theme =
              ThemeData.light().copyWith(textTheme: textTheme);

          const String data = '| abc | defghi |\n:-: | -----------:\nbar | baz';
          const FixedColumnWidth columnWidth = FixedColumnWidth(100);
          final MarkdownStyleSheet style =
              MarkdownStyleSheet.fromTheme(theme).copyWith(
            tableColumnWidth: columnWidth,
          );

          await tester.pumpWidget(
              boilerplate(MarkdownBody(data: data, styleSheet: style)));

          final Table table = tester.widget(find.byType(Table));

          expectTableSize(2, 2);

          expect(find.byType(Text), findsNWidgets(4));
          final List<String?> cellText = find
              .byType(Text)
              .evaluate()
              .map((Element e) => e.widget)
              .cast<Text>()
              .map((Text text) => text.textSpan!)
              .cast<TextSpan>()
              .map((TextSpan e) => e.text)
              .toList();
          expect(cellText[0], 'abc');
          expect(cellText[1], 'defghi');
          expect(cellText[2], 'bar');
          expect(cellText[3], 'baz');
          expect(table.defaultColumnWidth, columnWidth);
        },
      );

      testWidgets(
        // Example 200 from GFM.
        'include a pipe in table cell data by escaping the pipe',
        (WidgetTester tester) async {
          final ThemeData theme =
              ThemeData.light().copyWith(textTheme: textTheme);

          const String data =
              '| f\\|oo  |\n| ------ |\n| b \\| az |\n| b **\\|** im |';
          const FixedColumnWidth columnWidth = FixedColumnWidth(100);
          final MarkdownStyleSheet style =
              MarkdownStyleSheet.fromTheme(theme).copyWith(
            tableColumnWidth: columnWidth,
          );

          await tester.pumpWidget(
              boilerplate(MarkdownBody(data: data, styleSheet: style)));

          final Table table = tester.widget(find.byType(Table));

          expectTableSize(1, 3);

          expect(find.byType(Text), findsNWidgets(4));
          final List<String?> cellText = find
              .byType(Text)
              .evaluate()
              .map((Element e) => e.widget)
              .cast<Text>()
              .map((Text text) => text.textSpan!)
              .cast<TextSpan>()
              .map((TextSpan e) => e.text)
              .toList();
          expect(cellText[0], 'f|oo');
          expect(cellText[1], 'defghi');
          expect(cellText[2], 'b | az');
          expect(cellText[3], 'b | im');
          expect(table.defaultColumnWidth, columnWidth);
        },
        // TODO(mjordan56): Remove skip once the issue #340 in the markdown package
        // is fixed and released. https://github.com/dart-lang/markdown/issues/340
        // This test will need adjusting once issue #340 is fixed.
        skip: true,
      );

      testWidgets(
        // Example 201 from GFM.
        'table definition is complete at beginning of new block',
        (WidgetTester tester) async {
          final ThemeData theme =
              ThemeData.light().copyWith(textTheme: textTheme);

          const String data =
              '| abc | def |\n| --- | --- |\n| bar | baz |\n> bar';
          const FixedColumnWidth columnWidth = FixedColumnWidth(100);
          final MarkdownStyleSheet style =
              MarkdownStyleSheet.fromTheme(theme).copyWith(
            tableColumnWidth: columnWidth,
          );

          await tester.pumpWidget(
              boilerplate(MarkdownBody(data: data, styleSheet: style)));

          final Table table = tester.widget(find.byType(Table));

          expectTableSize(2, 2);

          expect(find.byType(Text), findsNWidgets(5));
          final List<String?> text = find
              .byType(Text)
              .evaluate()
              .map((Element e) => e.widget)
              .cast<Text>()
              .map((Text text) => text.textSpan!)
              .cast<TextSpan>()
              .map((TextSpan e) => e.text)
              .toList();
          expect(text[0], 'abc');
          expect(text[1], 'def');
          expect(text[2], 'bar');
          expect(text[3], 'baz');
          expect(table.defaultColumnWidth, columnWidth);

          // Blockquote
          expect(find.byType(DecoratedBox), findsOneWidget);
          expect(text[4], 'bar');
        },
      );

      testWidgets(
        // Example 202 from GFM.
        'table definition is complete at first empty line',
        (WidgetTester tester) async {
          final ThemeData theme =
              ThemeData.light().copyWith(textTheme: textTheme);

          const String data =
              '| abc | def |\n| --- | --- |\n| bar | baz |\nbar\n\nbar';
          const FixedColumnWidth columnWidth = FixedColumnWidth(100);
          final MarkdownStyleSheet style =
              MarkdownStyleSheet.fromTheme(theme).copyWith(
            tableColumnWidth: columnWidth,
          );

          await tester.pumpWidget(
              boilerplate(MarkdownBody(data: data, styleSheet: style)));

          final Table table = tester.widget(find.byType(Table));

          expectTableSize(3, 2);

          expect(find.byType(Text), findsNWidgets(7));
          final List<String?> text = find
              .byType(Text)
              .evaluate()
              .map((Element e) => e.widget)
              .cast<Text>()
              .map((Text text) => text.textSpan!)
              .cast<TextSpan>()
              .map((TextSpan e) => e.text)
              .toList();
          expect(text, <String>['abc', 'def', 'bar', 'baz', 'bar', '', 'bar']);
          expect(table.defaultColumnWidth, columnWidth);
        },
      );

      testWidgets(
        // Example 203 from GFM.
        'table header row must match the delimiter row in number of cells',
        (WidgetTester tester) async {
          final ThemeData theme =
              ThemeData.light().copyWith(textTheme: textTheme);

          const String data = '| abc | def |\n| --- |\n| bar |';
          const FixedColumnWidth columnWidth = FixedColumnWidth(100);
          final MarkdownStyleSheet style =
              MarkdownStyleSheet.fromTheme(theme).copyWith(
            tableColumnWidth: columnWidth,
          );

          await tester.pumpWidget(
              boilerplate(MarkdownBody(data: data, styleSheet: style)));

          expect(find.byType(Table), findsNothing);
          final List<String?> text = find
              .byType(Text)
              .evaluate()
              .map((Element e) => e.widget)
              .cast<Text>()
              .map((Text text) => text.textSpan!)
              .cast<TextSpan>()
              .map((TextSpan e) => e.text)
              .toList();
          expect(text[0], '| abc | def | | --- | | bar |');
        },
      );

      testWidgets(
        // Example 204 from GFM.
        'remainder of table cells may vary, excess cells are ignored',
        (WidgetTester tester) async {
          final ThemeData theme =
              ThemeData.light().copyWith(textTheme: textTheme);

          const String data =
              '| abc | def |\n| --- | --- |\n| bar |\n| bar | baz | boo |';
          const FixedColumnWidth columnWidth = FixedColumnWidth(100);
          final MarkdownStyleSheet style =
              MarkdownStyleSheet.fromTheme(theme).copyWith(
            tableColumnWidth: columnWidth,
          );

          await tester.pumpWidget(
              boilerplate(MarkdownBody(data: data, styleSheet: style)));

          final Table table = tester.widget(find.byType(Table));

          expectTableSize(3, 2);

          expect(find.byType(Text), findsNWidgets(6));
          final List<String?> cellText = find
              .byType(Text)
              .evaluate()
              .map((Element e) => e.widget)
              .cast<Text>()
              .map((Text text) => text.textSpan!)
              .cast<TextSpan>()
              .map((TextSpan e) => e.text)
              .toList();
          expect(cellText, <String>['abc', 'def', 'bar', '', 'bar', 'baz']);
          expect(table.defaultColumnWidth, columnWidth);
        },
      );

      testWidgets(
        // Example 205 from GFM.
        'no table body is created when no rows are defined',
        (WidgetTester tester) async {
          final ThemeData theme =
              ThemeData.light().copyWith(textTheme: textTheme);

          const String data = '| abc | def |\n| --- | --- |';
          const FixedColumnWidth columnWidth = FixedColumnWidth(100);
          final MarkdownStyleSheet style =
              MarkdownStyleSheet.fromTheme(theme).copyWith(
            tableColumnWidth: columnWidth,
          );

          await tester.pumpWidget(
              boilerplate(MarkdownBody(data: data, styleSheet: style)));

          final Table table = tester.widget(find.byType(Table));

          expectTableSize(1, 2);

          expect(find.byType(Text), findsNWidgets(2));
          final List<String?> cellText = find
              .byType(Text)
              .evaluate()
              .map((Element e) => e.widget)
              .cast<Text>()
              .map((Text text) => text.textSpan!)
              .cast<TextSpan>()
              .map((TextSpan e) => e.text)
              .toList();
          expect(cellText[0], 'abc');
          expect(cellText[1], 'def');
          expect(table.defaultColumnWidth, columnWidth);
        },
      );
    });
  });
}
