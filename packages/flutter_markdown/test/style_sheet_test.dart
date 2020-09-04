// Copyright 2020 Quiverware LLC. Open source contribution. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'utils.dart';

void main() => defineTests();

void defineTests() {
  group('Style Sheet', () {
    testWidgets(
      'equality - Cupertino',
      (WidgetTester tester) async {
        final CupertinoThemeData theme =
            CupertinoThemeData(brightness: Brightness.light);

        final MarkdownStyleSheet style1 =
            MarkdownStyleSheet.fromCupertinoTheme(theme);
        final MarkdownStyleSheet style2 =
            MarkdownStyleSheet.fromCupertinoTheme(theme);
        expect(style1, equals(style2));
        expect(style1.hashCode, equals(style2.hashCode));
      },
    );

    testWidgets(
      'equality - Material',
      (WidgetTester tester) async {
        final ThemeData theme =
            ThemeData.light().copyWith(textTheme: textTheme);

        final MarkdownStyleSheet style1 = MarkdownStyleSheet.fromTheme(theme);
        final MarkdownStyleSheet style2 = MarkdownStyleSheet.fromTheme(theme);
        expect(style1, equals(style2));
        expect(style1.hashCode, equals(style2.hashCode));
      },
    );

    testWidgets(
      'MarkdownStyleSheet.fromCupertinoTheme',
      (WidgetTester tester) async {
        final CupertinoThemeData cTheme = CupertinoThemeData(
          brightness: Brightness.dark,
        );

        final MarkdownStyleSheet style =
            MarkdownStyleSheet.fromCupertinoTheme(cTheme);

        // a
        expect(style.a.color, CupertinoColors.link.darkColor);
        expect(style.a.fontSize, cTheme.textTheme.textStyle.fontSize);

        // p
        expect(style.p, cTheme.textTheme.textStyle);

        // code
        expect(style.code.color, cTheme.textTheme.textStyle.color);
        expect(style.code.fontSize, cTheme.textTheme.textStyle.fontSize * 0.85);
        expect(style.code.fontFamily, 'monospace');
        expect(
            style.code.backgroundColor, CupertinoColors.systemGrey6.darkColor);

        // H1
        expect(style.h1.color, cTheme.textTheme.textStyle.color);
        expect(style.h1.fontSize, cTheme.textTheme.textStyle.fontSize + 10);
        expect(style.h1.fontWeight, FontWeight.w500);

        // H2
        expect(style.h2.color, cTheme.textTheme.textStyle.color);
        expect(style.h2.fontSize, cTheme.textTheme.textStyle.fontSize + 8);
        expect(style.h2.fontWeight, FontWeight.w500);

        // H3
        expect(style.h3.color, cTheme.textTheme.textStyle.color);
        expect(style.h3.fontSize, cTheme.textTheme.textStyle.fontSize + 6);
        expect(style.h3.fontWeight, FontWeight.w500);

        // H4
        expect(style.h4.color, cTheme.textTheme.textStyle.color);
        expect(style.h4.fontSize, cTheme.textTheme.textStyle.fontSize + 4);
        expect(style.h4.fontWeight, FontWeight.w500);

        // H5
        expect(style.h5.color, cTheme.textTheme.textStyle.color);
        expect(style.h5.fontSize, cTheme.textTheme.textStyle.fontSize + 2);
        expect(style.h5.fontWeight, FontWeight.w500);

        // H6
        expect(style.h6.color, cTheme.textTheme.textStyle.color);
        expect(style.h6.fontSize, cTheme.textTheme.textStyle.fontSize);
        expect(style.h6.fontWeight, FontWeight.w500);

        // em
        expect(style.em.color, cTheme.textTheme.textStyle.color);
        expect(style.em.fontSize, cTheme.textTheme.textStyle.fontSize);
        expect(style.em.fontStyle, FontStyle.italic);

        // strong
        expect(style.strong.color, cTheme.textTheme.textStyle.color);
        expect(style.strong.fontSize, cTheme.textTheme.textStyle.fontSize);
        expect(style.strong.fontWeight, FontWeight.bold);

        // del
        expect(style.del.color, cTheme.textTheme.textStyle.color);
        expect(style.del.fontSize, cTheme.textTheme.textStyle.fontSize);
        expect(style.del.decoration, TextDecoration.lineThrough);

        // blockqoute
        expect(style.blockquote, cTheme.textTheme.textStyle);

        // img
        expect(style.img, cTheme.textTheme.textStyle);

        // checkbox
        expect(style.checkbox.color, cTheme.primaryColor);
        expect(style.checkbox.fontSize, cTheme.textTheme.textStyle.fontSize);

        // tableHead
        expect(style.tableHead.color, cTheme.textTheme.textStyle.color);
        expect(style.tableHead.fontSize, cTheme.textTheme.textStyle.fontSize);
        expect(style.tableHead.fontWeight, FontWeight.w600);

        // tableBody
        expect(style.tableBody, cTheme.textTheme.textStyle);
      },
    );

    testWidgets(
      'MarkdownStyleSheet.fromTheme',
      (WidgetTester tester) async {
        final theme = ThemeData.dark().copyWith(
          textTheme: TextTheme(
            bodyText2: TextStyle(fontSize: 12.0),
          ),
        );

        final MarkdownStyleSheet style = MarkdownStyleSheet.fromTheme(theme);

        // a
        expect(style.a.color, Colors.blue);

        // p
        expect(style.p, theme.textTheme.bodyText2);

        // code
        expect(style.code.color, theme.textTheme.bodyText2.color);
        expect(style.code.fontSize, theme.textTheme.bodyText2.fontSize * 0.85);
        expect(style.code.fontFamily, 'monospace');
        expect(style.code.backgroundColor, theme.cardColor);

        // H1
        expect(style.h1, theme.textTheme.headline5);

        // H2
        expect(style.h2, theme.textTheme.headline6);

        // H3
        expect(style.h3, theme.textTheme.subtitle1);

        // H4
        expect(style.h4, theme.textTheme.bodyText1);

        // H5
        expect(style.h5, theme.textTheme.bodyText1);

        // H6
        expect(style.h6, theme.textTheme.bodyText1);

        // em
        expect(style.em.fontStyle, FontStyle.italic);
        expect(style.em.color, theme.textTheme.bodyText2.color);

        // strong
        expect(style.strong.fontWeight, FontWeight.bold);
        expect(style.strong.color, theme.textTheme.bodyText2.color);

        // del
        expect(style.del.decoration, TextDecoration.lineThrough);
        expect(style.del.color, theme.textTheme.bodyText2.color);

        // blockqoute
        expect(style.blockquote, theme.textTheme.bodyText2);

        // img
        expect(style.img, theme.textTheme.bodyText2);

        // checkbox
        expect(style.checkbox.color, theme.primaryColor);
        expect(style.checkbox.fontSize, theme.textTheme.bodyText2.fontSize);

        // tableHead
        expect(style.tableHead.fontWeight, FontWeight.w600);

        // tableBody
        expect(style.tableBody, theme.textTheme.bodyText2);
      },
    );

    testWidgets(
      'merge 2 style sheets',
      (WidgetTester tester) async {
        final ThemeData theme =
            ThemeData.light().copyWith(textTheme: textTheme);
        final MarkdownStyleSheet style1 = MarkdownStyleSheet.fromTheme(theme);
        final MarkdownStyleSheet style2 = MarkdownStyleSheet(
          p: TextStyle(color: Colors.red),
          blockquote: TextStyle(fontSize: 16),
        );

        final MarkdownStyleSheet merged = style1.merge(style2);
        expect(merged.p.color, Colors.red);
        expect(merged.blockquote.fontSize, 16);
        expect(merged.blockquote.color, theme.textTheme.bodyText2.color);
      },
    );

    testWidgets(
      'create based on which theme',
      (WidgetTester tester) async {
        const String data = '[title](url)';
        await tester.pumpWidget(
          boilerplate(
            const Markdown(
              data: data,
              styleSheetTheme: MarkdownStyleSheetBaseTheme.cupertino,
            ),
          ),
        );

        final RichText widget = tester.widget(find.byType(RichText));
        expect(widget.text.style.color, CupertinoColors.link.color);
      },
    );

    testWidgets(
      'apply 2 distinct style sheets',
      (WidgetTester tester) async {
        final ThemeData theme =
            ThemeData.light().copyWith(textTheme: textTheme);

        final MarkdownStyleSheet style1 = MarkdownStyleSheet.fromTheme(theme);
        final MarkdownStyleSheet style2 =
            MarkdownStyleSheet.largeFromTheme(theme);
        expect(style1, isNot(style2));

        await tester.pumpWidget(
          boilerplate(
            Markdown(
              data: '# Test',
              styleSheet: style1,
            ),
          ),
        );

        final RichText text1 = tester.widget(find.byType(RichText));
        await tester.pumpWidget(
          boilerplate(
            Markdown(
              data: '# Test',
              styleSheet: style2,
            ),
          ),
        );
        final RichText text2 = tester.widget(find.byType(RichText));

        expect(text1.text, isNot(text2.text));
      },
    );
  });
}
