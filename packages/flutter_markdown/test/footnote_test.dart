// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() => defineTests();

void defineTests() {
  group(
    'structure',
    () {
      testWidgets(
        'footnote is detected and handle correctly',
        (WidgetTester tester) async {
          const String data = 'Foo[^a]\n[^a]: Bar';
          await tester.pumpWidget(
            boilerplate(
              const MarkdownBody(
                data: data,
              ),
            ),
          );

          final Iterable<Widget> widgets = tester.allWidgets;
          expectTextStrings(widgets, <String>[
            'Foo1',
            '1.',
            'Bar ↩',
          ]);
        },
      );

      testWidgets(
        'footnote is detected and handle correctly for selectable markdown',
        (WidgetTester tester) async {
          const String data = 'Foo[^a]\n[^a]: Bar';
          await tester.pumpWidget(
            boilerplate(
              const MarkdownBody(
                data: data,
                selectable: true,
              ),
            ),
          );

          final Iterable<Widget> widgets = tester.allWidgets;
          expectTextStrings(widgets, <String>[
            'Foo1',
            '1.',
            'Bar ↩',
          ]);
        },
      );

      testWidgets(
        'ignore footnotes without description',
        (WidgetTester tester) async {
          const String data = 'Foo[^1] Bar[^2]\n[^1]: Bar';
          await tester.pumpWidget(
            boilerplate(
              const MarkdownBody(
                data: data,
              ),
            ),
          );

          final Iterable<Widget> widgets = tester.allWidgets;
          expectTextStrings(widgets, <String>[
            'Foo1 Bar[^2]',
            '1.',
            'Bar ↩',
          ]);
        },
      );
      testWidgets(
        'ignore superscripts and footnotes order',
        (WidgetTester tester) async {
          const String data = '[^2]: Bar \n [^1]: Foo \n Foo[^f] Bar[^b]';
          await tester.pumpWidget(
            boilerplate(
              const MarkdownBody(
                data: data,
              ),
            ),
          );

          final Iterable<Widget> widgets = tester.allWidgets;
          expectTextStrings(widgets, <String>[
            'Foo1 Bar2',
            '1.',
            'Foo ↩',
            '2.',
            'Bar ↩',
          ]);
        },
      );

      testWidgets(
        'handle two digits superscript',
        (WidgetTester tester) async {
          const String data = '''
1[^1] 2[^2] 3[^3] 4[^4] 5[^5] 6[^6] 7[^7] 8[^8] 9[^9] 10[^10]
[^1]:1 
[^2]:2 
[^3]:3
[^4]:4
[^5]:5
[^6]:6
[^7]:7
[^8]:8
[^9]:9
[^10]:10
''';
          await tester.pumpWidget(
            boilerplate(
              const MarkdownBody(
                data: data,
              ),
            ),
          );

          final Iterable<Widget> widgets = tester.allWidgets;
          expectTextStrings(widgets, <String>[
            '11 22 33 44 55 66 77 88 99 1010',
            '1.',
            '1 ↩',
            '2.',
            '2 ↩',
            '3.',
            '3 ↩',
            '4.',
            '4 ↩',
            '5.',
            '5 ↩',
            '6.',
            '6 ↩',
            '7.',
            '7 ↩',
            '8.',
            '8 ↩',
            '9.',
            '9 ↩',
            '10.',
            '10 ↩',
          ]);
        },
      );
    },
  );

  group(
    'superscript textstyle replacing',
    () {
      testWidgets(
        'superscript has correct default fontfeature',
        (WidgetTester tester) async {
          const String data = 'Foo[^a]\n[^a]: Bar';
          await tester.pumpWidget(
            boilerplate(
              const MarkdownBody(
                data: data,
              ),
            ),
          );

          final Iterable<Widget> widgets = tester.allWidgets;
          final Text text =
              widgets.firstWhere((Widget widget) => widget is Text) as Text;

          final TextSpan span = text.textSpan! as TextSpan;
          final List<InlineSpan>? children = span.children;

          expect(children, isNotNull);
          expect(children!.length, 2);
          expect(children[1].style, isNotNull);
          expect(children[1].style!.fontFeatures?.length, 1);
          expect(children[1].style!.fontFeatures?.first.feature, 'sups');
        },
      );

      testWidgets(
        'superscript has correct custom fontfeature',
        (WidgetTester tester) async {
          const String data = 'Foo[^a]\n[^a]: Bar';
          await tester.pumpWidget(
            boilerplate(
              MarkdownBody(
                data: data,
                styleSheet:
                    MarkdownStyleSheet(superscriptFontFeatureTag: 'numr'),
              ),
            ),
          );

          final Iterable<Widget> widgets = tester.allWidgets;
          final Text text =
              widgets.firstWhere((Widget widget) => widget is Text) as Text;

          final TextSpan span = text.textSpan! as TextSpan;
          final List<InlineSpan>? children = span.children;

          expect(children, isNotNull);
          expect(children!.length, 2);
          expect(children[1].style, isNotNull);
          expect(children[1].style!.fontFeatures?.length, 2);
          expect(children[1].style!.fontFeatures?[1].feature, 'numr');
        },
      );

      testWidgets(
        'superscript index has the same font style like text',
        (WidgetTester tester) async {
          const String data = '# Foo[^a]\n[^a]: Bar';
          await tester.pumpWidget(
            boilerplate(
              const MarkdownBody(
                data: data,
              ),
            ),
          );

          final Iterable<Widget> widgets = tester.allWidgets;
          final Text text =
              widgets.firstWhere((Widget widget) => widget is Text) as Text;

          final TextSpan span = text.textSpan! as TextSpan;
          final List<InlineSpan>? children = span.children;

          expect(children![0].style, isNotNull);
          expect(children[1].style!.fontSize, children[0].style!.fontSize);
          expect(children[1].style!.fontFamily, children[0].style!.fontFamily);
          expect(children[1].style!.fontStyle, children[0].style!.fontStyle);
          expect(children[1].style!.fontSize, children[0].style!.fontSize);
        },
      );

      testWidgets(
        'link is correctly copied to new superscript index',
        (WidgetTester tester) async {
          final List<MarkdownLink> linkTapResults = <MarkdownLink>[];
          const String data = 'Foo[^a]\n[^a]: Bar';
          await tester.pumpWidget(
            boilerplate(
              MarkdownBody(
                data: data,
                onTapLink: (String text, String? href, String title) =>
                    linkTapResults.add(MarkdownLink(text, href, title)),
              ),
            ),
          );

          final Iterable<Widget> widgets = tester.allWidgets;
          final Text text =
              widgets.firstWhere((Widget widget) => widget is Text) as Text;

          final TextSpan span = text.textSpan! as TextSpan;

          final List<Type> gestureRecognizerTypes = <Type>[];
          span.visitChildren((InlineSpan inlineSpan) {
            if (inlineSpan is TextSpan) {
              final TapGestureRecognizer? recognizer =
                  inlineSpan.recognizer as TapGestureRecognizer?;
              gestureRecognizerTypes.add(recognizer?.runtimeType ?? Null);
              if (recognizer != null) {
                recognizer.onTap!();
              }
            }
            return true;
          });

          expect(span.children!.length, 2);
          expect(
            gestureRecognizerTypes,
            orderedEquals(<Type>[Null, TapGestureRecognizer]),
          );
          expectLinkTap(linkTapResults[0], const MarkdownLink('1', '#fn-a'));
        },
      );
    },
  );
}
