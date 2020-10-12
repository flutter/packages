// Copyright 2020 Quiverware LLC. Open source contribution. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() => defineTests();

void defineTests() {
  group('Hard Line Breaks', () {
    testWidgets(
      // Example 654 from GFM.
      'two spaces at end of line',
      (WidgetTester tester) async {
        const String data = 'foo  \nbar';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final richTextFinder = find.byType(RichText);
        expect(richTextFinder, findsOneWidget);

        final richText = richTextFinder.evaluate().first.widget as RichText;
        final text = richText.text.toPlainText();
        expect(text, 'foo\nbar');
      },
    );

    testWidgets(
      // Example 655 from GFM.
      'backslash at end of line',
      (WidgetTester tester) async {
        const String data = 'foo\\\nbar';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final richTextFinder = find.byType(RichText);
        expect(richTextFinder, findsOneWidget);

        final richText = richTextFinder.evaluate().first.widget as RichText;
        final text = richText.text.toPlainText();
        expect(text, 'foo\nbar');
      },
    );

    testWidgets(
      // Example 656 from GFM.
      'more than two spaces at end of line',
      (WidgetTester tester) async {
        const String data = 'foo       \nbar';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final richTextFinder = find.byType(RichText);
        expect(richTextFinder, findsOneWidget);

        final richText = richTextFinder.evaluate().first.widget as RichText;
        final text = richText.text.toPlainText();
        expect(text, 'foo\nbar');
      },
    );

    testWidgets(
      // Example 657 from GFM.
      'leading spaces at beginning of next line are ignored',
      (WidgetTester tester) async {
        const String data = 'foo  \n     bar';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final richTextFinder = find.byType(RichText);
        expect(richTextFinder, findsOneWidget);

        final richText = richTextFinder.evaluate().first.widget as RichText;
        final text = richText.text.toPlainText();
        expect(text, 'foo\nbar');
      },
      // TODO(mjordan56): Remove skip once the issue #322 in the markdown package
      // is fixed and released. https://github.com/dart-lang/markdown/issues/322
      skip: true,
    );

    testWidgets(
      // Example 658 from GFM.
      'leading spaces at beginning of next line are ignored',
      (WidgetTester tester) async {
        const String data = 'foo\\\n     bar';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final richTextFinder = find.byType(RichText);
        expect(richTextFinder, findsOneWidget);

        final richText = richTextFinder.evaluate().first.widget as RichText;
        final text = richText.text.toPlainText();
        expect(text, 'foo\nbar');
      },
      // TODO(mjordan56): Remove skip once the issue #322 in the markdown package
      // is fixed and released. https://github.com/dart-lang/markdown/issues/322
      skip: true,
    );

    testWidgets(
      // Example 659 from GFM.
      'two spaces line break inside emphasis',
      (WidgetTester tester) async {
        const String data = '*foo  \nbar*';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final richTextFinder = find.byType(RichText);
        expect(richTextFinder, findsOneWidget);

        final richText = richTextFinder.evaluate().first.widget as RichText;
        final text = richText.text.toPlainText();
        expect(text, 'foo\nbar');

        // There should be three spans of text.
        final textSpan = richText.text as TextSpan;
        expect(textSpan, isNotNull);
        expect(textSpan.children.length == 3, isTrue);

        // First text span has italic style with normal weight.
        final firstSpan = textSpan.children[0];
        expectTextSpanStyle(firstSpan, FontStyle.italic, FontWeight.normal);

        // Second span is just the newline character with no font style or weight.

        // Third text span has italic style with normal weight.
        final thirdSpan = textSpan.children[2];
        expectTextSpanStyle(thirdSpan, FontStyle.italic, FontWeight.normal);
      },
    );

    testWidgets(
      // Example 660 from GFM.
      'backslash line break inside emphasis',
      (WidgetTester tester) async {
        const String data = '*foo\\\nbar*';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final richTextFinder = find.byType(RichText);
        expect(richTextFinder, findsOneWidget);

        final richText = richTextFinder.evaluate().first.widget as RichText;
        final text = richText.text.toPlainText();
        expect(text, 'foo\nbar');

        // There should be three spans of text.
        final textSpan = richText.text as TextSpan;
        expect(textSpan, isNotNull);
        expect(textSpan.children.length == 3, isTrue);

        // First text span has italic style with normal weight.
        final firstSpan = textSpan.children[0];
        expectTextSpanStyle(firstSpan, FontStyle.italic, FontWeight.normal);

        // Second span is just the newline character with no font style or weight.

        // Third text span has italic style with normal weight.
        final thirdSpan = textSpan.children[2];
        expectTextSpanStyle(thirdSpan, FontStyle.italic, FontWeight.normal);
      },
    );

    testWidgets(
      // Example 661 from GFM.
      'two space line break does not occur in code span',
      (WidgetTester tester) async {
        const String data = '`code  \nspan`';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final richTextFinder = find.byType(RichText);
        expect(richTextFinder, findsOneWidget);

        final richText = richTextFinder.evaluate().first.widget as RichText;
        final text = richText.text.toPlainText();
        expect(text, 'code   span');

        final textSpan = richText.text as TextSpan;
        expect(textSpan, isNotNull);
        expect(textSpan.style, isNotNull);
        expect(textSpan.style.fontFamily == 'monospace', isTrue);
      },
    );

    testWidgets(
      // Example 662 from GFM.
      'backslash line break does not occur in code span',
      (WidgetTester tester) async {
        const String data = '`code\\\nspan`';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final richTextFinder = find.byType(RichText);
        expect(richTextFinder, findsOneWidget);

        final richText = richTextFinder.evaluate().first.widget as RichText;
        final text = richText.text.toPlainText();
        expect(text, 'code\\ span');

        final textSpan = richText.text as TextSpan;
        expect(textSpan, isNotNull);
        expect(textSpan.style, isNotNull);
        expect(textSpan.style.fontFamily == 'monospace', isTrue);
      },
    );

    testWidgets(
      // Example 665 from GFM.
      'backslash at end of paragraph is ignored',
      (WidgetTester tester) async {
        const String data = 'foo\\';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final richTextFinder = find.byType(RichText);
        expect(richTextFinder, findsOneWidget);

        final richText = richTextFinder.evaluate().first.widget as RichText;
        final text = richText.text.toPlainText();
        expect(text, 'foo\\');
      },
    );

    testWidgets(
      // Example 666 from GFM.
      'two spaces at end of paragraph is ignored',
      (WidgetTester tester) async {
        const String data = 'foo  ';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final richTextFinder = find.byType(RichText);
        expect(richTextFinder, findsOneWidget);

        final richText = richTextFinder.evaluate().first.widget as RichText;
        final text = richText.text.toPlainText();
        expect(text, 'foo');
      },
    );

    testWidgets(
      // Example 667 from GFM.
      'backslash at end of header is ignored',
      (WidgetTester tester) async {
        const String data = '### foo\\';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final richTextFinder = find.byType(RichText);
        expect(richTextFinder, findsOneWidget);

        final richText = richTextFinder.evaluate().first.widget as RichText;
        final text = richText.text.toPlainText();
        expect(text, 'foo\\');
      },
    );

    testWidgets(
      // Example 668 from GFM.
      'two spaces at end of header is ignored',
      (WidgetTester tester) async {
        const String data = '### foo  ';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final richTextFinder = find.byType(RichText);
        expect(richTextFinder, findsOneWidget);

        final richText = richTextFinder.evaluate().first.widget as RichText;
        final text = richText.text.toPlainText();
        expect(text, 'foo');
      },
    );
  });

  group('Soft Line Breaks', () {
    testWidgets(
      // Example 669 from GFM.
      'lines of text in paragraph',
      (WidgetTester tester) async {
        const String data = 'foo\nbaz';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final richTextFinder = find.byType(RichText);
        expect(richTextFinder, findsOneWidget);

        final richText = richTextFinder.evaluate().first.widget as RichText;
        final text = richText.text.toPlainText();
        expect(text, 'foo baz');
      },
    );

    testWidgets(
      // Example 670 from GFM.
      'spaces at beginning and end of lines of text in paragraph are removed',
      (WidgetTester tester) async {
        const String data = 'foo \n baz';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final richTextFinder = find.byType(RichText);
        expect(richTextFinder, findsOneWidget);

        final richText = richTextFinder.evaluate().first.widget as RichText;
        final text = richText.text.toPlainText();
        expect(text, 'foo baz');
      },
    );
  });
}
