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
  group('Style Sheet', () {
    testWidgets(
      'equality - Cupertino',
      (WidgetTester tester) async {
        const CupertinoThemeData theme =
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
        const CupertinoThemeData cTheme = CupertinoThemeData(
          brightness: Brightness.dark,
        );

        final MarkdownStyleSheet style =
            MarkdownStyleSheet.fromCupertinoTheme(cTheme);

        // a
        expect(style.a!.color, CupertinoColors.link.darkColor);
        expect(style.a!.fontSize, cTheme.textTheme.textStyle.fontSize);

        // p
        expect(style.p, cTheme.textTheme.textStyle);

        // code
        expect(style.code!.color, cTheme.textTheme.textStyle.color);
        expect(
            style.code!.fontSize, cTheme.textTheme.textStyle.fontSize! * 0.85);
        expect(style.code!.fontFamily, 'monospace');

        // H1
        expect(style.h1!.color, cTheme.textTheme.textStyle.color);
        expect(style.h1!.fontSize, cTheme.textTheme.textStyle.fontSize! + 10);
        expect(style.h1!.fontWeight, FontWeight.w500);

        // H2
        expect(style.h2!.color, cTheme.textTheme.textStyle.color);
        expect(style.h2!.fontSize, cTheme.textTheme.textStyle.fontSize! + 8);
        expect(style.h2!.fontWeight, FontWeight.w500);

        // H3
        expect(style.h3!.color, cTheme.textTheme.textStyle.color);
        expect(style.h3!.fontSize, cTheme.textTheme.textStyle.fontSize! + 6);
        expect(style.h3!.fontWeight, FontWeight.w500);

        // H4
        expect(style.h4!.color, cTheme.textTheme.textStyle.color);
        expect(style.h4!.fontSize, cTheme.textTheme.textStyle.fontSize! + 4);
        expect(style.h4!.fontWeight, FontWeight.w500);

        // H5
        expect(style.h5!.color, cTheme.textTheme.textStyle.color);
        expect(style.h5!.fontSize, cTheme.textTheme.textStyle.fontSize! + 2);
        expect(style.h5!.fontWeight, FontWeight.w500);

        // H6
        expect(style.h6!.color, cTheme.textTheme.textStyle.color);
        expect(style.h6!.fontSize, cTheme.textTheme.textStyle.fontSize);
        expect(style.h6!.fontWeight, FontWeight.w500);

        // em
        expect(style.em!.color, cTheme.textTheme.textStyle.color);
        expect(style.em!.fontSize, cTheme.textTheme.textStyle.fontSize);
        expect(style.em!.fontStyle, FontStyle.italic);

        // strong
        expect(style.strong!.color, cTheme.textTheme.textStyle.color);
        expect(style.strong!.fontSize, cTheme.textTheme.textStyle.fontSize);
        expect(style.strong!.fontWeight, FontWeight.bold);

        // del
        expect(style.del!.color, cTheme.textTheme.textStyle.color);
        expect(style.del!.fontSize, cTheme.textTheme.textStyle.fontSize);
        expect(style.del!.decoration, TextDecoration.lineThrough);

        // blockqoute
        expect(style.blockquote, cTheme.textTheme.textStyle);

        // img
        expect(style.img, cTheme.textTheme.textStyle);

        // checkbox
        expect(style.checkbox!.color, cTheme.primaryColor);
        expect(style.checkbox!.fontSize, cTheme.textTheme.textStyle.fontSize);

        // tableHead
        expect(style.tableHead!.color, cTheme.textTheme.textStyle.color);
        expect(style.tableHead!.fontSize, cTheme.textTheme.textStyle.fontSize);
        expect(style.tableHead!.fontWeight, FontWeight.w600);

        // tableBody
        expect(style.tableBody, cTheme.textTheme.textStyle);
      },
    );

    testWidgets(
      'MarkdownStyleSheet.fromTheme',
      (WidgetTester tester) async {
        final ThemeData theme = ThemeData.dark().copyWith(
          textTheme: const TextTheme(
            bodyMedium: TextStyle(fontSize: 12.0),
          ),
        );

        final MarkdownStyleSheet style = MarkdownStyleSheet.fromTheme(theme);

        // a
        expect(style.a!.color, Colors.blue);

        // p
        expect(style.p, theme.textTheme.bodyMedium);

        // code
        expect(style.code!.color, theme.textTheme.bodyMedium!.color);
        expect(
            style.code!.fontSize, theme.textTheme.bodyMedium!.fontSize! * 0.85);
        expect(style.code!.fontFamily, 'monospace');
        expect(style.code!.backgroundColor, theme.cardTheme.color);

        // H1
        expect(style.h1, theme.textTheme.headlineSmall);

        // H2
        expect(style.h2, theme.textTheme.titleLarge);

        // H3
        expect(style.h3, theme.textTheme.titleMedium);

        // H4
        expect(style.h4, theme.textTheme.bodyLarge);

        // H5
        expect(style.h5, theme.textTheme.bodyLarge);

        // H6
        expect(style.h6, theme.textTheme.bodyLarge);

        // em
        expect(style.em!.fontStyle, FontStyle.italic);
        expect(style.em!.color, theme.textTheme.bodyMedium!.color);

        // strong
        expect(style.strong!.fontWeight, FontWeight.bold);
        expect(style.strong!.color, theme.textTheme.bodyMedium!.color);

        // del
        expect(style.del!.decoration, TextDecoration.lineThrough);
        expect(style.del!.color, theme.textTheme.bodyMedium!.color);

        // blockqoute
        expect(style.blockquote, theme.textTheme.bodyMedium);

        // img
        expect(style.img, theme.textTheme.bodyMedium);

        // checkbox
        expect(style.checkbox!.color, theme.primaryColor);
        expect(style.checkbox!.fontSize, theme.textTheme.bodyMedium!.fontSize);

        // tableHead
        expect(style.tableHead!.fontWeight, FontWeight.w600);

        // tableBody
        expect(style.tableBody, theme.textTheme.bodyMedium);
      },
    );

    testWidgets(
      'merge 2 style sheets',
      (WidgetTester tester) async {
        final ThemeData theme =
            ThemeData.light().copyWith(textTheme: textTheme);
        final MarkdownStyleSheet style1 = MarkdownStyleSheet.fromTheme(theme);
        final MarkdownStyleSheet style2 = MarkdownStyleSheet(
          p: const TextStyle(color: Colors.red),
          blockquote: const TextStyle(fontSize: 16),
        );

        final MarkdownStyleSheet merged = style1.merge(style2);
        expect(merged.p!.color, Colors.red);
        expect(merged.blockquote!.fontSize, 16);
        expect(merged.blockquote!.color, theme.textTheme.bodyMedium!.color);
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

        final Text widget = tester.widget(find.byType(Text));
        expect(widget.textSpan!.style!.color, CupertinoColors.link.color);
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

    testWidgets(
      'use stylesheet option listBulletPadding',
      (WidgetTester tester) async {
        const double paddingX = 20.0;
        final MarkdownStyleSheet style = MarkdownStyleSheet(
            listBulletPadding:
                const EdgeInsets.symmetric(horizontal: paddingX));

        await tester.pumpWidget(
          boilerplate(
            Markdown(
              data: '1. Bullet\n 2. Bullet\n * Bullet',
              styleSheet: style,
            ),
          ),
        );

        final List<Padding> paddings =
            tester.widgetList<Padding>(find.byType(Padding)).toList();

        expect(paddings.length, 3);
        expect(
          paddings.every(
            (Padding p) => p.padding.along(Axis.horizontal) == paddingX * 2,
          ),
          true,
        );
      },
    );

    testWidgets(
      'check widgets for use stylesheet option h1Padding',
      (WidgetTester tester) async {
        const String data = '# Header';
        const double paddingX = 20.0;
        final MarkdownStyleSheet style = MarkdownStyleSheet(
          h1Padding: const EdgeInsets.symmetric(horizontal: paddingX),
        );

        await tester.pumpWidget(boilerplate(MarkdownBody(
          data: data,
          styleSheet: style,
        )));

        final Iterable<Widget> widgets = selfAndDescendantWidgetsOf(
          find.byType(MarkdownBody),
          tester,
        );
        expectWidgetTypes(widgets, <Type>[
          MarkdownBody,
          Column,
          Padding,
          Wrap,
          Text,
          RichText,
        ]);
        expectTextStrings(widgets, <String>['Header']);
      },
    );

    testWidgets(
      'use stylesheet option pPadding',
      (WidgetTester tester) async {
        const double paddingX = 20.0;
        final MarkdownStyleSheet style = MarkdownStyleSheet(
          pPadding: const EdgeInsets.symmetric(horizontal: paddingX),
        );

        await tester.pumpWidget(
          boilerplate(
            Markdown(
              data: 'Test line 1\n\nTest line 2\n\nTest line 3\n# H1',
              styleSheet: style,
            ),
          ),
        );

        final List<Padding> paddings =
            tester.widgetList<Padding>(find.byType(Padding)).toList();

        expect(paddings.length, 3);
        expect(
          paddings.every(
            (Padding p) => p.padding.along(Axis.horizontal) == paddingX * 2,
          ),
          true,
        );
      },
    );

    testWidgets(
      'use stylesheet option h1Padding-h6Padding',
      (WidgetTester tester) async {
        const double paddingX = 20.0;
        final MarkdownStyleSheet style = MarkdownStyleSheet(
          h1Padding: const EdgeInsets.symmetric(horizontal: paddingX),
          h2Padding: const EdgeInsets.symmetric(horizontal: paddingX),
          h3Padding: const EdgeInsets.symmetric(horizontal: paddingX),
          h4Padding: const EdgeInsets.symmetric(horizontal: paddingX),
          h5Padding: const EdgeInsets.symmetric(horizontal: paddingX),
          h6Padding: const EdgeInsets.symmetric(horizontal: paddingX),
        );

        await tester.pumpWidget(
          boilerplate(
            Markdown(
              data:
                  'Test\n\n# H1\n## H2\n### H3\n#### H4\n##### H5\n###### H6\n',
              styleSheet: style,
            ),
          ),
        );

        final List<Padding> paddings =
            tester.widgetList<Padding>(find.byType(Padding)).toList();

        expect(paddings.length, 6);
        expect(
          paddings.every(
            (Padding p) => p.padding.along(Axis.horizontal) == paddingX * 2,
          ),
          true,
        );
      },
    );

    testWidgets(
      'deprecated textScaleFactor is converted to linear scaler',
      (WidgetTester tester) async {
        const double scaleFactor = 2.0;
        final MarkdownStyleSheet style = MarkdownStyleSheet(
          textScaleFactor: scaleFactor,
        );

        expect(style.textScaler, const TextScaler.linear(scaleFactor));
        expect(style.textScaleFactor, scaleFactor);
      },
    );

    testWidgets(
      'deprecated textScaleFactor is null when a scaler is provided',
      (WidgetTester tester) async {
        const TextScaler scaler = TextScaler.linear(2.0);
        final MarkdownStyleSheet style = MarkdownStyleSheet(
          textScaler: scaler,
        );

        expect(style.textScaler, scaler);
        expect(style.textScaleFactor, null);
      },
    );

    testWidgets(
      'copyWith textScaler overwrites both textScaler and textScaleFactor',
      (WidgetTester tester) async {
        final MarkdownStyleSheet original = MarkdownStyleSheet(
          textScaleFactor: 2.0,
        );

        const TextScaler newScaler = TextScaler.linear(3.0);
        final MarkdownStyleSheet copy = original.copyWith(
          textScaler: newScaler,
        );

        expect(copy.textScaler, newScaler);
        expect(copy.textScaleFactor, null);
      },
    );

    testWidgets(
      'copyWith textScaleFactor overwrites both textScaler and textScaleFactor',
      (WidgetTester tester) async {
        final MarkdownStyleSheet original = MarkdownStyleSheet(
          textScaleFactor: 2.0,
        );

        const double newScaleFactor = 3.0;
        final MarkdownStyleSheet copy = original.copyWith(
          textScaleFactor: newScaleFactor,
        );

        expect(copy.textScaler, const TextScaler.linear(newScaleFactor));
        expect(copy.textScaleFactor, newScaleFactor);
      },
    );
  });
}
