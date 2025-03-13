// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'utils.dart';

// The emphasis and strong emphasis section of the GitHub Flavored Markdown
// specification (https://github.github.com/gfm/#emphasis-and-strong-emphasis)
// is extensive covering over 130 example cases. The tests in this file cover
// all of the GFM tests; example 360 through 490.

void main() => defineTests();

void defineTests() {
  group(
    'Emphasis',
    () {
      group(
        'Rule 1',
        () {
          // Rule 1 tests check the single '*' can open emphasis.
          testWidgets(
            // Example 360 from GFM.
            'italic text using asterisk tags',
            (WidgetTester tester) async {
              const String data = '*foo bar*';
              await tester.pumpWidget(
                boilerplate(
                  const MarkdownBody(data: data),
                ),
              );

              final Finder textFinder = find.byType(Text);
              expect(textFinder, findsOneWidget);

              final Text textWidget =
                  textFinder.evaluate().first.widget as Text;
              final String text = textWidget.textSpan!.toPlainText();
              expect(text, 'foo bar');

              expectTextSpanStyle(
                textWidget.textSpan! as TextSpan,
                FontStyle.italic,
                FontWeight.normal,
              );
            },
          );

          testWidgets(
            // Example 361 from GFM.
            'invalid left-flanking delimiter run because * is followed by whitespace',
            (WidgetTester tester) async {
              const String data = 'a * foo bar*';
              await tester.pumpWidget(
                boilerplate(
                  const MarkdownBody(data: data),
                ),
              );

              final Finder textFinder = find.byType(Text);
              expect(textFinder, findsOneWidget);

              // Expect text to be unchanged from original data string.
              final Text textWidget =
                  textFinder.evaluate().first.widget as Text;
              final String text = textWidget.textSpan!.toPlainText();
              expect(text, data);

              expectTextSpanStyle(
                textWidget.textSpan! as TextSpan,
                null,
                FontWeight.normal,
              );
            },
          );

          testWidgets(
            // Example 362 from GFM.
            'invalid left-flanking delimiter run because * preceded by alphanumeric followed by punctuation',
            (WidgetTester tester) async {
              const String data = 'a*"foo bar"*';
              await tester.pumpWidget(
                boilerplate(
                  const MarkdownBody(data: data),
                ),
              );

              final Finder textFinder = find.byType(Text);
              expect(textFinder, findsOneWidget);

              // Expect text to be unchanged from original data string.
              final Text textWidget =
                  textFinder.evaluate().first.widget as Text;
              final String text = textWidget.textSpan!.toPlainText();
              expect(text, data);

              expectTextSpanStyle(
                textWidget.textSpan! as TextSpan,
                null,
                FontWeight.normal,
              );
            },
          );

          // NOTE: Example 363 is not included. The test is "Unicode nonbreaking
          // spaces count as whitespace, too: '* a *' The Markdown parse sees
          // this as a unordered list item." https://github.github.com/gfm/#example-363

          testWidgets(
            // Example 364 from GFM.
            'intraword emphasis with * is permitted alpha characters',
            (WidgetTester tester) async {
              const String data = 'foo*bar*';
              await tester.pumpWidget(
                boilerplate(
                  const MarkdownBody(data: data),
                ),
              );

              final Finder textFinder = find.byType(Text);
              expect(textFinder, findsOneWidget);

              final Text textWidget =
                  textFinder.evaluate().first.widget as Text;
              expect(textWidget, isNotNull);
              final String text = textWidget.textSpan!.toPlainText();
              expect(text, 'foobar');

              // There should be two spans of text.
              final TextSpan textSpan = textWidget.textSpan! as TextSpan;
              expect(textSpan, isNotNull);
              expect(textSpan.children!.length == 2, isTrue);

              // First text span is normal text with no emphasis.
              final InlineSpan firstSpan = textSpan.children![0];
              expectTextSpanStyle(
                firstSpan as TextSpan,
                null,
                FontWeight.normal,
              );

              // Second span has italic style with normal weight.
              final InlineSpan secondSpan = textSpan.children![1];
              expectTextSpanStyle(
                secondSpan as TextSpan,
                FontStyle.italic,
                FontWeight.normal,
              );
            },
          );

          testWidgets(
            // Example 365 from GFM.
            'intraword emphasis with * is permitted numeric characters',
            (WidgetTester tester) async {
              const String data = '5*6*78';
              await tester.pumpWidget(
                boilerplate(
                  const MarkdownBody(data: data),
                ),
              );

              final Finder textFinder = find.byType(Text);
              expect(textFinder, findsOneWidget);

              final Text textWidget =
                  textFinder.evaluate().first.widget as Text;
              expect(textWidget, isNotNull);
              final String text = textWidget.textSpan!.toPlainText();
              expect(text, '5678');

              // There should be three spans of text.
              final TextSpan textSpan = textWidget.textSpan! as TextSpan;
              expect(textSpan, isNotNull);
              expect(textSpan.children!.length == 3, isTrue);

              // First text span is normal text with no emphasis.
              final InlineSpan firstSpan = textSpan.children![0];
              expectTextSpanStyle(
                firstSpan as TextSpan,
                null,
                FontWeight.normal,
              );

              // Second span has italic style with normal weight.
              final InlineSpan secondSpan = textSpan.children![1];
              expectTextSpanStyle(
                secondSpan as TextSpan,
                FontStyle.italic,
                FontWeight.normal,
              );

              // Third text span is normal text with no emphasis.
              final InlineSpan thirdSpan = textSpan.children![2];
              expectTextSpanStyle(
                thirdSpan as TextSpan,
                null,
                FontWeight.normal,
              );
            },
          );
        },
      );

      group('Rule 2', () {
        testWidgets(
          // Example 366 from GFM.
          'italic text using underscore tags',
          (WidgetTester tester) async {
            const String data = '_foo bar_';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo bar');

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 367 from GFM.
          'invalid left-flanking delimiter run because _ is followed by whitespace',
          (WidgetTester tester) async {
            const String data = '_ foo bar_';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, data);

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 368 from GFM.
          'invalid left-flanking delimiter run because _ preceded by alphanumeric followed by punctuation',
          (WidgetTester tester) async {
            const String data = 'a_"foo bar"_';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, data);

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 369 from GFM.
          'emphasis with _ is not allowed inside words alpha characters',
          (WidgetTester tester) async {
            const String data = 'foo_bar_';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, data);

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 370 from GFM.
          'emphasis with _ is not allowed inside words numeric characters',
          (WidgetTester tester) async {
            const String data = '5_6_78';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, data);

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 371 from GFM.
          'emphasis with _ is not allowed inside words unicode characters',
          (WidgetTester tester) async {
            const String data = 'пристаням_стремятся_';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, data);

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 372 from GFM.
          'invalid first delimiter right-flanking followed by second delimiter left-flanking',
          (WidgetTester tester) async {
            const String data = 'aa_"bb"_cc';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, data);

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 373 from GFM.
          'valid open delimiter left- and right-flanking preceded by punctuation',
          (WidgetTester tester) async {
            const String data = 'foo-_(bar)_';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo-(bar)');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span is normal text with no emphasis.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              null,
              FontWeight.normal,
            );

            // Second span has italic style with normal weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );
          },
        );
      });

      group('Rule 3', () {
        testWidgets(
          // Example 374 from GFM.
          'invalid emphasis - closing delimiter does not match opening delimiter',
          (WidgetTester tester) async {
            const String data = '_foo*';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, data);

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 375 from GFM.
          'invalid emphasis - closing * is preceded by whitespace',
          (WidgetTester tester) async {
            const String data = '*foo bar *';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, data);

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 376 from GFM.
          'invalid emphasis - closing * is preceded by newline',
          (WidgetTester tester) async {
            const String data = '*foo bar\n*';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, '*foo bar *');

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 377 from GFM.
          'invalid emphasis - second * is preceded by punctuation followed by alphanumeric',
          (WidgetTester tester) async {
            const String data = '*(*foo)';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, data);

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 378 from GFM.
          'nested * emphasis',
          (WidgetTester tester) async {
            const String data = '*(*foo*)*';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, '(foo)');

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 379 from GFM.
          'intraword emphasis with * is allowed',
          (WidgetTester tester) async {
            const String data = '*foo*bar';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foobar');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span has italic style with normal weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );

            // Second span is normal text with no emphasis.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );
      });

      group('Rule 4', () {
        testWidgets(
          // Example 380 from GFM.
          'invalid emphasis because closing _ is preceded by whitespace',
          (WidgetTester tester) async {
            const String data = '_foo bar _';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, data);

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 381 from GFM.
          'invalid emphasis because second _ is preceded by punctuation and followed by an alphanumeric',
          (WidgetTester tester) async {
            const String data = '_(_foo)';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, data);

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 382 from GFM.
          'nested _ emphasis',
          (WidgetTester tester) async {
            const String data = '_(_foo_)_';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, '(foo)');

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 383 from GFM.
          'intraword emphasis with _ is disallowed - alpha characters',
          (WidgetTester tester) async {
            const String data = '_foo_bar';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, data);

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 384 from GFM.
          'intraword emphasis with _ is disallowed - unicode characters',
          (WidgetTester tester) async {
            const String data = '_пристаням_стремятся';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, data);

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 385 from GFM.
          'intraword emphasis with _ is disallowed - nested emphasis tags',
          (WidgetTester tester) async {
            const String data = '_foo_bar_baz_';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo_bar_baz');

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 386 from GFM.
          'valid emphasis closing delimiter is both left- and right-flanking followed by punctuation',
          (WidgetTester tester) async {
            const String data = '_(bar)_.';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, '(bar).');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span has italic style with normal weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );

            // Second span is normal text with no emphasis.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );
      });

      group('Rule 5', () {
        testWidgets(
          // Example 387 from GFM.
          'strong emphasis using ** emphasis tags',
          (WidgetTester tester) async {
            const String data = '**foo bar**';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo bar');

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.bold,
            );
          },
        );

        testWidgets(
          // Example 388 from GFM.
          'invalid strong emphasis - opening delimiter followed by whitespace',
          (WidgetTester tester) async {
            const String data = '** foo bar**';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, data);

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 389 from GFM.
          'invalid strong emphasis - opening ** is preceded by an alphanumeric and followed by punctuation',
          (WidgetTester tester) async {
            const String data = 'a**"foo"**';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, data);

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 390 from GFM.
          'intraword strong emphasis with ** is permitted',
          (WidgetTester tester) async {
            const String data = 'foo**bar**';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foobar');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span is normal text with no emphasis.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              null,
              FontWeight.normal,
            );

            // Second span has bold weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              null,
              FontWeight.bold,
            );
          },
        );
      });

      group('Rule 6', () {
        testWidgets(
          // Example 391 from GFM.
          'strong emphasis using __ emphasis tags',
          (WidgetTester tester) async {
            const String data = '__foo bar__';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo bar');

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.bold,
            );
          },
        );

        testWidgets(
          // Example 392 from GFM.
          'invalid strong emphasis - opening delimiter followed by whitespace',
          (WidgetTester tester) async {
            const String data = '__ foo bar__';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, data);

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 393 from GFM.
          'invalid strong emphasis - opening delimiter followed by newline',
          (WidgetTester tester) async {
            const String data = '__\nfoo bar__';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, '__ foo bar__');

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 394 from GFM.
          'invalid strong emphasis - opening __ is preceded by an alphanumeric and followed by punctuation',
          (WidgetTester tester) async {
            const String data = 'a__"foo"__';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, data);

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 395 from GFM.
          'intraword strong emphasis is forbidden with __ - alpha characters',
          (WidgetTester tester) async {
            const String data = 'foo__bar__';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, data);

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 396 from GFM.
          'intraword strong emphasis is forbidden with __ - numeric characters',
          (WidgetTester tester) async {
            const String data = '5__6__78';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, data);

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 397 from GFM.
          'intraword strong emphasis is forbidden with __ - unicode characters',
          (WidgetTester tester) async {
            const String data = 'пристаням__стремятся__';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, data);

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 398 from GFM.
          'intraword strong emphasis is forbidden with __ - nested strong emphasis',
          (WidgetTester tester) async {
            const String data = '__foo, __bar__, baz__';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo, bar, baz');

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.bold,
            );
          },
        );

        testWidgets(
          // Example 399 from GFM.
          'valid strong emphasis because opening delimiter is both left- and right-flanking preceded by punctuation',
          (WidgetTester tester) async {
            const String data = 'foo-__(bar)__';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo-(bar)');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span is normal text with no emphasis.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              null,
              FontWeight.normal,
            );

            // Second span has bold weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              null,
              FontWeight.bold,
            );
          },
        );
      });

      group('Rule 7', () {
        testWidgets(
          // Example 400 from GFM.
          'invalid strong emphasis - closing delimiter is preceded by whitespace',
          (WidgetTester tester) async {
            const String data = '**foo bar **';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, data);

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 401 from GFM.
          'invalid strong emphasis - second ** is preceded by punctuation and followed by an alphanumeric',
          (WidgetTester tester) async {
            const String data = '**(**foo)';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, data);

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 402 from GFM.
          'emphasis with nested strong emphasis',
          (WidgetTester tester) async {
            const String data = '*(**foo**)*';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, '(foo)');

            // There should be three spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 3, isTrue);

            // First text span has italic style with normal weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );

            // Second span has italic style with bold weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              FontStyle.italic,
              FontWeight.bold,
            );

            // Third text span has italic style with normal weight.
            final InlineSpan thirdSpan = textSpan.children![2];
            expectTextSpanStyle(
              thirdSpan as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 403 from GFM.
          'strong emphasis with multiple nested emphasis',
          (WidgetTester tester) async {
            const String data =
                '**Gomphocarpus (*Gomphocarpus physocarpus*, syn. *Asclepias physocarpa*)**';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text,
                'Gomphocarpus (Gomphocarpus physocarpus, syn. Asclepias physocarpa)');

            // There should be five spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 5, isTrue);

            // First text span has bold weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              null,
              FontWeight.bold,
            );

            // Second span has both italic style with bold weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              FontStyle.italic,
              FontWeight.bold,
            );

            // Third text span has bold weight.
            final InlineSpan thirdSpan = textSpan.children![2];
            expectTextSpanStyle(
              thirdSpan as TextSpan,
              null,
              FontWeight.bold,
            );

            // Fourth text span has both italic style with bold weight.
            final InlineSpan fourthSpan = textSpan.children![3];
            expectTextSpanStyle(
              fourthSpan as TextSpan,
              FontStyle.italic,
              FontWeight.bold,
            );

            // Fifth text span has bold weight.
            final InlineSpan fifthSpan = textSpan.children![4];
            expectTextSpanStyle(
              fifthSpan as TextSpan,
              null,
              FontWeight.bold,
            );
          },
        );

        testWidgets(
          // Example 404 from GFM.
          'strong emphasis with nested emphasis',
          (WidgetTester tester) async {
            const String data = '**foo "*bar*" foo**';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo "bar" foo');

            // There should be three spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 3, isTrue);

            // First text span has bold weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              null,
              FontWeight.bold,
            );

            // Second span has both italic style with bold weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              FontStyle.italic,
              FontWeight.bold,
            );

            // Third text span has bold weight.
            final InlineSpan thirdSpan = textSpan.children![2];
            expectTextSpanStyle(
              thirdSpan as TextSpan,
              null,
              FontWeight.bold,
            );
          },
        );

        testWidgets(
          // Example 405 from GFM.
          'intraword strong emphasis',
          (WidgetTester tester) async {
            const String data = '**foo**bar';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foobar');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span is normal text with strong emphasis.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              null,
              FontWeight.bold,
            );

            // Second span is normal text with no emphasis.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );
      });

      group('Rule 8', () {
        testWidgets(
          // Example 406 from GFM.
          'invalid strong emphasis - closing delimiter is preceded by whitespace',
          (WidgetTester tester) async {
            const String data = '__foo bar __';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, data);

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 407 from GFM.
          'invalid strong emphasis - second __ is preceded by punctuation followed by alphanumeric',
          (WidgetTester tester) async {
            const String data = '__(__foo)';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, data);

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 408 from GFM.
          'strong emphasis nested in emphasis',
          (WidgetTester tester) async {
            const String data = '_(__foo__)_';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, '(foo)');

            // There should be three spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 3, isTrue);

            // First text span has italic style with normal weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );

            // Second span has italic style with bold weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              FontStyle.italic,
              FontWeight.bold,
            );

            // Third text span has italic style with normal weight.
            final InlineSpan thirdSpan = textSpan.children![2];
            expectTextSpanStyle(
              thirdSpan as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 409 from GFM.
          'intraword strong emphasis is forbidden with __ - alpha characters',
          (WidgetTester tester) async {
            const String data = '__foo__bar';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, data);

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 410 from GFM.
          'intraword strong emphasis is forbidden with __ - unicode characters',
          (WidgetTester tester) async {
            const String data = '__пристаням__стремятся';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, data);

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 411 from GFM.
          'intraword nested strong emphasis is forbidden with __',
          (WidgetTester tester) async {
            const String data = '__foo__bar__baz__';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo__bar__baz');

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.bold,
            );
          },
        );

        testWidgets(
          // Example 412 from GFM.
          'strong emphasis because closing delimiter is both left- and right-flanking is followed by punctuation',
          (WidgetTester tester) async {
            const String data = '__(bar)__.';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, '(bar).');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span is normal text with strong emphasis.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              null,
              FontWeight.bold,
            );

            // Second span has italic style with normal weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );
      });

      group('Rule 9', () {
        testWidgets(
          // Example 413 from GFM.
          'nonempty sequence emphasis span - text followed by link',
          (WidgetTester tester) async {
            const String data = '*foo [bar](/url)*';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo bar');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span is plain text and has italic style with normal weight.
            final TextSpan firstSpan = textSpan.children![0] as TextSpan;
            expect(firstSpan.recognizer, isNull);
            expectTextSpanStyle(
              firstSpan,
              FontStyle.italic,
              FontWeight.normal,
            );

            // Second span has italic style with normal weight.
            final TextSpan secondSpan = textSpan.children![1] as TextSpan;
            expect(secondSpan.recognizer, isNotNull);
            expect(secondSpan.recognizer is GestureRecognizer, isTrue);
            expectTextSpanStyle(
              secondSpan,
              FontStyle.italic,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 414 from GFM.
          'nonempty sequence emphasis span - two lines of text',
          (WidgetTester tester) async {
            const String data = '*foo\nbar*';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo bar');

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 415 from GFM.
          'strong emphasis nested inside emphasis - _ delimiter',
          (WidgetTester tester) async {
            const String data = '_foo __bar__ baz_';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo bar baz');

            // There should be three spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 3, isTrue);

            // First text span has italic style with normal weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );

            // Second span has italic style with bold weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              FontStyle.italic,
              FontWeight.bold,
            );

            // Third text span has italic style with normal weight.
            final InlineSpan thirdSpan = textSpan.children![2];
            expectTextSpanStyle(
              thirdSpan as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 416 from GFM.
          'emphasis nested inside emphasis',
          (WidgetTester tester) async {
            const String data = '_foo _bar_ baz_';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo bar baz');

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 417 from GFM.
          'intraword emphasis nested inside emphasis - _ delimiter',
          (WidgetTester tester) async {
            const String data = '__foo_ bar_';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo bar');

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 418 from GFM.
          'intraword emphasis nested inside emphasis - * delimiter',
          (WidgetTester tester) async {
            const String data = '*foo *bar**';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo bar');

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 419 from GFM.
          'strong emphasis nested inside emphasis - * delimiter',
          (WidgetTester tester) async {
            const String data = '*foo **bar** baz*';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo bar baz');

            // There should be three spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 3, isTrue);

            // First text span has italic style with normal weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );

            // Second span has italic style with bold weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              FontStyle.italic,
              FontWeight.bold,
            );

            // Third text span has italic style with normal weight.
            final InlineSpan thirdSpan = textSpan.children![2];
            expectTextSpanStyle(
              thirdSpan as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 418 from GFM.
          'intraword strong emphasis nested inside emphasis - * delimiter',
          (WidgetTester tester) async {
            const String data = '*foo**bar**baz*';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foobarbaz');

            // There should be three spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 3, isTrue);

            // First text span has italic style with normal weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );

            // Second span has italic style with bold weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              FontStyle.italic,
              FontWeight.bold,
            );

            // Third text span has italic style with normal weight.
            final InlineSpan thirdSpan = textSpan.children![2];
            expectTextSpanStyle(
              thirdSpan as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 421 from GFM.
          'consecutive emphasis sections are not allowed',
          (WidgetTester tester) async {
            const String data = '*foo**bar*';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo**bar');

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 422 from GFM.
          'strong emphasis nested inside emphasis - space after first word',
          (WidgetTester tester) async {
            const String data = '***foo** bar*';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo bar');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span has italic style with bold weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              FontStyle.italic,
              FontWeight.bold,
            );

            // Second span has italic style with normal weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 423 from GFM.
          'strong emphasis nested inside emphasis - space before second word',
          (WidgetTester tester) async {
            const String data = '*foo **bar***';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo bar');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span has italic style with normal weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );

            // Second span has italic style with bold weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              FontStyle.italic,
              FontWeight.bold,
            );
          },
        );

        testWidgets(
          // Example 424 from GFM.
          'intraword strong emphasis nested inside emphasis',
          (WidgetTester tester) async {
            const String data = '*foo**bar***';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foobar');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span has italic style with normal weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );

            // Second span has italic style with bold weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              FontStyle.italic,
              FontWeight.bold,
            );
          },
        );

        testWidgets(
          // Example 425 from GFM.
          'intraword emphasis and strong emphasis',
          (WidgetTester tester) async {
            const String data = 'foo***bar***baz';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foobarbaz');

            // There should be three spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 3, isTrue);

            // First text span is plain text with normal weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              null,
              FontWeight.normal,
            );

            // Second span has italic style with bold weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              FontStyle.italic,
              FontWeight.bold,
            );

            // Third text span is plain text with normal weight.
            final InlineSpan thirdSpan = textSpan.children![2];
            expectTextSpanStyle(
              thirdSpan as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 426 from GFM.
          'intraword emphasis and strong emphasis - multiples of 3',
          (WidgetTester tester) async {
            const String data = 'foo******bar*********baz';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foobar***baz');

            // There should be three spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 3, isTrue);

            // First text span is plain text with normal weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              null,
              FontWeight.normal,
            );

            // Second span is plain text with bold weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              null,
              FontWeight.bold,
            );

            // Third text span is plain text with normal weight.
            final InlineSpan thirdSpan = textSpan.children![2];
            expectTextSpanStyle(
              thirdSpan as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 427 from GFM.
          'infinite levels of nesting are possible within emphasis',
          (WidgetTester tester) async {
            const String data = '*foo **bar *baz*\nbim** bop*';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo bar baz bim bop');

            // There should be five spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length, 3);

            // First text span has italic style and normal weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );

            // Second span has both italic style with bold weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              FontStyle.italic,
              FontWeight.bold,
            );

            // Third text span has bold weight.
            final InlineSpan thirdSpan = textSpan.children![2];
            expectTextSpanStyle(
              thirdSpan as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 428 from GFM.
          'infinite levels of nesting are possible within emphasis - text and a link',
          (WidgetTester tester) async {
            const String data = '*foo [*bar*](/url)*';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo bar');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span has italic style and normal weight.
            final TextSpan firstSpan = textSpan.children![0] as TextSpan;
            expect(firstSpan.recognizer, isNull);
            expectTextSpanStyle(
              firstSpan,
              FontStyle.italic,
              FontWeight.normal,
            );

            // Second span has italic style with normal weight.
            final TextSpan secondSpan = textSpan.children![1] as TextSpan;
            expect(secondSpan.recognizer, isNotNull);
            expect(secondSpan.recognizer is GestureRecognizer, isTrue);
            expectTextSpanStyle(
              secondSpan,
              FontStyle.italic,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 429 from GFM.
          'there can be no empty emphasis * delimiter',
          (WidgetTester tester) async {
            const String data = '** is not an empty emphasis';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, data);

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 430 from GFM.
          'there can be no empty strong emphasis * delimiter',
          (WidgetTester tester) async {
            const String data = '**** is not an empty strong emphasis';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, data);

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );
      });

      group('Rule 10', () {
        testWidgets(
          // Example 431 from GFM.
          'nonempty sequence of inline elements with strong emphasis - text and a link',
          (WidgetTester tester) async {
            const String data = '**foo [bar](/url)**';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo bar');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span is normal text with bold weight.
            final TextSpan firstSpan = textSpan.children![0] as TextSpan;
            expect(firstSpan.recognizer, isNull);
            expectTextSpanStyle(
              firstSpan,
              null,
              FontWeight.bold,
            );

            // Second span is a link with bold weight.
            final TextSpan secondSpan = textSpan.children![1] as TextSpan;
            expect(secondSpan.recognizer, isNotNull);
            expect(secondSpan.recognizer is GestureRecognizer, isTrue);
            expectTextSpanStyle(
              secondSpan,
              null,
              FontWeight.bold,
            );
          },
        );

        testWidgets(
          // Example 432 from GFM.
          'nonempty sequence of inline elements with strong emphasis - two lines of texts',
          (WidgetTester tester) async {
            const String data = '**foo\nbar**';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo bar');

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.bold,
            );
          },
        );

        testWidgets(
          // Example 433 from GFM.
          'emphasis and strong emphasis nested inside strong emphasis - nested emphasis',
          (WidgetTester tester) async {
            const String data = '__foo _bar_ baz__';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo bar baz');

            // There should be three spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 3, isTrue);

            // First text span is plain text with bold weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              null,
              FontWeight.bold,
            );

            // Second span has italic style with bold weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              FontStyle.italic,
              FontWeight.bold,
            );

            // Third text span is plain text with bold weight.
            final InlineSpan thirdSpan = textSpan.children![2];
            expectTextSpanStyle(
              thirdSpan as TextSpan,
              null,
              FontWeight.bold,
            );
          },
        );

        testWidgets(
          // Example 434 from GFM.
          'emphasis and strong emphasis nested inside strong emphasis - nested strong emphasis',
          (WidgetTester tester) async {
            const String data = '__foo __bar__ baz__';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo bar baz');

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.bold,
            );
          },
        );

        testWidgets(
          // Example 435 from GFM.
          'emphasis and strong emphasis nested inside strong emphasis - nested strong emphasis',
          (WidgetTester tester) async {
            const String data = '____foo__ bar__';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo bar');

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.bold,
            );
          },
        );

        testWidgets(
          // Example 436 from GFM.
          'emphasis and strong emphasis nested inside strong emphasis - nested strong emphasis',
          (WidgetTester tester) async {
            const String data = '**foo **bar****';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo bar');

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.bold,
            );
          },
        );

        testWidgets(
          // Example 437 from GFM.
          'emphasis and strong emphasis nested inside strong emphasis - nested emphasis',
          (WidgetTester tester) async {
            const String data = '**foo *bar* baz**';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo bar baz');

            // There should be three spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 3, isTrue);

            // First text span is plain text with bold weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              null,
              FontWeight.bold,
            );

            // Second span has italic style with bold weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              FontStyle.italic,
              FontWeight.bold,
            );

            // Third text span is plain text with bold weight.
            final InlineSpan thirdSpan = textSpan.children![2];
            expectTextSpanStyle(
              thirdSpan as TextSpan,
              null,
              FontWeight.bold,
            );
          },
        );

        testWidgets(
          // Example 438 from GFM.
          'emphasis and strong emphasis nested inside strong emphasis - intraword nested emphasis',
          (WidgetTester tester) async {
            const String data = '**foo*bar*baz**';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foobarbaz');

            // There should be three spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 3, isTrue);

            // First text span is plain text with bold weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              null,
              FontWeight.bold,
            );

            // Second span has italic style with bold weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              FontStyle.italic,
              FontWeight.bold,
            );

            // Third text span is plain text with bold weight.
            final InlineSpan thirdSpan = textSpan.children![2];
            expectTextSpanStyle(
              thirdSpan as TextSpan,
              null,
              FontWeight.bold,
            );
          },
        );

        testWidgets(
          // Example 439 from GFM.
          'emphasis and strong emphasis nested inside strong emphasis - nested emphasis on first word',
          (WidgetTester tester) async {
            const String data = '***foo* bar**';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo bar');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span has italic style with bold weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              FontStyle.italic,
              FontWeight.bold,
            );

            // Second span is plain text with bold weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              null,
              FontWeight.bold,
            );
          },
        );

        testWidgets(
          // Example 440 from GFM.
          'emphasis and strong emphasis nested inside strong emphasis - nested emphasis on second word',
          (WidgetTester tester) async {
            const String data = '**foo *bar***';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo bar');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span is plain text with bold weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              null,
              FontWeight.bold,
            );

            // Second span has italic style with bold weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              FontStyle.italic,
              FontWeight.bold,
            );
          },
        );

        testWidgets(
          // Example 441 from GFM.
          'infinite levels of nesting are possible within strong emphasis',
          (WidgetTester tester) async {
            const String data = '**foo *bar **baz**\nbim* bop**';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo bar baz bim bop');

            // There should be five spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length, 3);

            // First text span is plain text with bold weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              null,
              FontWeight.bold,
            );

            // Second span has both italic style with bold weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              FontStyle.italic,
              FontWeight.bold,
            );

            // Third text span has both italic style with bold weight.
            final InlineSpan thirdSpan = textSpan.children![2];
            expectTextSpanStyle(
              thirdSpan as TextSpan,
              null,
              FontWeight.bold,
            );
          },
        );

        testWidgets(
          // Example 442 from GFM.
          'infinite levels of nesting are possible within strong emphasis - text and a link',
          (WidgetTester tester) async {
            const String data = '**foo [*bar*](/url)**';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo bar');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span is plain text and bold weight.
            final TextSpan firstSpan = textSpan.children![0] as TextSpan;
            expect(firstSpan.recognizer, isNull);
            expectTextSpanStyle(
              firstSpan,
              null,
              FontWeight.bold,
            );

            // Second span has both italic style with normal weight.
            final TextSpan secondSpan = textSpan.children![1] as TextSpan;
            expect(secondSpan.recognizer, isNotNull);
            expect(secondSpan.recognizer is GestureRecognizer, isTrue);
            expectTextSpanStyle(
              secondSpan,
              FontStyle.italic,
              FontWeight.bold,
            );
          },
        );

        testWidgets(
          // Example 443 from GFM.
          'there can be no empty emphasis _ delimiter',
          (WidgetTester tester) async {
            const String data = '__ is not an empty emphasis';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, data);

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 444 from GFM.
          'there can be no empty strong emphasis _ delimiter',
          (WidgetTester tester) async {
            const String data = '____ is not an empty strong emphasis';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, data);

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );
      });

      group('Rule 11', () {
        testWidgets(
          // Example 445 from GFM.
          'an * cannot occur at the beginning or end of * delimited emphasis',
          (WidgetTester tester) async {
            const String data = 'foo ***';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, data);

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 446 from GFM.
          'an escaped * can occur inside * delimited emphasis',
          (WidgetTester tester) async {
            const String data = r'foo *\**';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo *');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span is normal text with normal weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              null,
              FontWeight.normal,
            );

            // Second span has italic style with normal weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 446 from GFM.
          'an _ can occur inside * delimited emphasis',
          (WidgetTester tester) async {
            const String data = 'foo *_*';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo _');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span is normal text with normal weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              null,
              FontWeight.normal,
            );

            // Second span has italic style with normal weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 448 from GFM.
          'an * cannot occur at the beginning or end of ** delimited strong emphasis',
          (WidgetTester tester) async {
            const String data = 'foo *****';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, data);

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 449 from GFM.
          'an escaped * can occur inside ** delimited strong emphasis',
          (WidgetTester tester) async {
            const String data = r'foo **\***';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo *');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span is normal text with normal weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              null,
              FontWeight.normal,
            );

            // Second span is normal text with bold weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              null,
              FontWeight.bold,
            );
          },
        );

        testWidgets(
          // Example 450 from GFM.
          'an _ can occur inside ** delimited strong emphasis',
          (WidgetTester tester) async {
            const String data = 'foo **_**';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo _');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span is normal text with normal weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              null,
              FontWeight.normal,
            );

            // Second span is normal text with bold weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              null,
              FontWeight.bold,
            );
          },
        );

        testWidgets(
          // Example 451 from GFM.
          'unmatched emphasis delimiters excess * at beginning',
          (WidgetTester tester) async {
            const String data = '**foo*';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, '*foo');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span is normal text with normal weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              null,
              FontWeight.normal,
            );

            // Second span has italic style with normal weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 452 from GFM.
          'unmatched emphasis delimiters excess * at end',
          (WidgetTester tester) async {
            const String data = '*foo**';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo*');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span has italic style with normal weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );

            // Second span is normal text with normal weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 453 from GFM.
          'unmatched strong emphasis delimiters excess * at beginning',
          (WidgetTester tester) async {
            const String data = '***foo**';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, '*foo');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span is normal text with normal weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              null,
              FontWeight.normal,
            );

            // Second span is normal text with bold weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              null,
              FontWeight.bold,
            );
          },
        );

        testWidgets(
          // Example 454 from GFM.
          'unmatched strong emphasis delimiters excess * at beginning',
          (WidgetTester tester) async {
            const String data = '****foo*';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, '***foo');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span is normal text with normal weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              null,
              FontWeight.normal,
            );

            // Second span has italic style with normal weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 455 from GFM.
          'unmatched strong emphasis delimiters excess * at end',
          (WidgetTester tester) async {
            const String data = '**foo***';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo*');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span is normal text with bold weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              null,
              FontWeight.bold,
            );

            // Second span is plain text with normal weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 456 from GFM.
          'unmatched strong emphasis delimiters excess * at end',
          (WidgetTester tester) async {
            const String data = '*foo****';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo***');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span has italic style with normal weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );

            // Second span is plain text with normal weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );
      });

      group('Rule 12', () {
        testWidgets(
          // Example 457 from GFM.
          'an _ cannot occur at the beginning or end of _ delimited emphasis',
          (WidgetTester tester) async {
            const String data = 'foo ___';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, data);

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 458 from GFM.
          'an escaped _ can occur inside _ delimited emphasis',
          (WidgetTester tester) async {
            const String data = r'foo _\__';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo _');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span is normal text with normal weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              null,
              FontWeight.normal,
            );

            // Second span has italic style with normal weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 459 from GFM.
          'an * can occur inside _ delimited emphasis',
          (WidgetTester tester) async {
            const String data = 'foo _*_';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo *');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span is normal text with normal weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              null,
              FontWeight.normal,
            );

            // Second span has italic style with normal weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 460 from GFM.
          'an _ cannot occur at the beginning or end of __ delimited strong emphasis',
          (WidgetTester tester) async {
            const String data = 'foo _____';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, data);

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 461 from GFM.
          'an escaped _ can occur inside __ delimited strong emphasis',
          (WidgetTester tester) async {
            const String data = r'foo __\___';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo _');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span is normal text with normal weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              null,
              FontWeight.normal,
            );

            // Second span is normal text with bold weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              null,
              FontWeight.bold,
            );
          },
        );

        testWidgets(
          // Example 462 from GFM.
          'an * can occur inside __ delimited strong emphasis',
          (WidgetTester tester) async {
            const String data = 'foo __*__';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo *');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span is normal text with normal weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              null,
              FontWeight.normal,
            );

            // Second span is normal text with bold weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              null,
              FontWeight.bold,
            );
          },
        );

        testWidgets(
          // Example 463 from GFM.
          'unmatched emphasis delimiters excess _ at beginning',
          (WidgetTester tester) async {
            const String data = '__foo_';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, '_foo');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span is normal text with normal weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              null,
              FontWeight.normal,
            );

            // Second span has italic style with normal weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 464 from GFM.
          'unmatched emphasis delimiters excess _ at end',
          (WidgetTester tester) async {
            const String data = '_foo__';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo_');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span has italic style with normal weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );

            // Second span is normal text with normal weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 465 from GFM.
          'unmatched strong emphasis delimiters excess _ at beginning',
          (WidgetTester tester) async {
            const String data = '___foo__';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, '_foo');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span is normal text with normal weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              null,
              FontWeight.normal,
            );

            // Second span is normal text with bold weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              null,
              FontWeight.bold,
            );
          },
        );

        testWidgets(
          // Example 466 from GFM.
          'unmatched strong emphasis delimiters excess _ at beginning',
          (WidgetTester tester) async {
            const String data = '____foo_';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, '___foo');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span is normal text with normal weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              null,
              FontWeight.normal,
            );

            // Second span has italic style with normal weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 467 from GFM.
          'unmatched strong emphasis delimiters excess _ at end',
          (WidgetTester tester) async {
            const String data = '__foo___';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo_');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span is normal text with bold weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              null,
              FontWeight.bold,
            );

            // Second span is plain text with normal weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 468 from GFM.
          'unmatched strong emphasis delimiters excess _ at end',
          (WidgetTester tester) async {
            const String data = '_foo____';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            // Expect text to be unchanged from original data string.
            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo___');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span has italic style with normal weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );

            // Second span is plain text with normal weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );
      });

      group('Rule 13', () {
        testWidgets(
          // Example 469 from GFM.
          'nested delimiters must be different - nested * is strong emphasis',
          (WidgetTester tester) async {
            const String data = '**foo**';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo');

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.bold,
            );
          },
        );

        testWidgets(
          // Example 470 from GFM.
          'nested delimiters must be different - nest _ in * emphasis',
          (WidgetTester tester) async {
            const String data = '*_foo_*';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo');

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 471 from GFM.
          'nested delimiters must be different - nested _ is strong emphasis',
          (WidgetTester tester) async {
            const String data = '__foo__';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo');

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.bold,
            );
          },
        );

        testWidgets(
          // Example 472 from GFM.
          'nested delimiters must be different - nest * in _ emphasis',
          (WidgetTester tester) async {
            const String data = '_*foo*_';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo');

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 473 from GFM.
          'nested delimiters must be different - nested * strong emphasis',
          (WidgetTester tester) async {
            const String data = '****foo****';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo');

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.bold,
            );
          },
        );

        testWidgets(
          // Example 474 from GFM.
          'nested delimiters must be different - nested _ strong emphasis',
          (WidgetTester tester) async {
            const String data = '____foo____';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo');

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.bold,
            );
          },
        );

        testWidgets(
          // Example 475 from GFM.
          'nested delimiters must be different - long sequence of * delimiters',
          (WidgetTester tester) async {
            const String data = '******foo******';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo');

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              null,
              FontWeight.bold,
            );
          },
        );
      });

      // Rule 14 doesn't make any difference to flutter_markdown but tests for
      // rule 14 are included here for completeness.
      group('Rule 14', () {
        testWidgets(
          // Example 476 from GFM.
          'font style and weight order * delimiter',
          (WidgetTester tester) async {
            const String data = '***foo***';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo');

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              FontStyle.italic,
              FontWeight.bold,
            );
          },
        );

        testWidgets(
          // Example 476 from GFM.
          'font style and weight order _ delimiter',
          (WidgetTester tester) async {
            const String data = '_____foo_____';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo');

            expectTextSpanStyle(
              textWidget.textSpan! as TextSpan,
              FontStyle.italic,
              FontWeight.bold,
            );
          },
        );
      });

      group('Rule 15', () {
        testWidgets(
          // Example 478 from GFM.
          'overlapping * and _ emphasis delimiters',
          (WidgetTester tester) async {
            const String data = '*foo _bar* baz_';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo _bar baz_');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span has italic style with normal weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );

            // Second span is plain text with normal weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              null,
              FontWeight.normal,
            );
          },
        );

        testWidgets(
          // Example 479 from GFM.
          'overlapping * and __ emphasis delimiters',
          (WidgetTester tester) async {
            const String data = '*foo __bar *baz bim__ bam*';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, 'foo bar *baz bim bam');

            // There should be three spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 3, isTrue);

            // First text span has italic style with normal weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );

            // Second span has italic style with bold weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              FontStyle.italic,
              FontWeight.bold,
            );

            // Third text span has italic style with normal weight.
            final InlineSpan thirdSpan = textSpan.children![2];
            expectTextSpanStyle(
              thirdSpan as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );
          },
        );
      });

      group('Rule 16', () {
        testWidgets(
          // Example 480 from GFM.
          'overlapping ** strong emphasis delimiters',
          (WidgetTester tester) async {
            const String data = '**foo **bar baz**';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, '**foo bar baz');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span is plain text with normal weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              null,
              FontWeight.normal,
            );

            // Second span is plain text with bold weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              null,
              FontWeight.bold,
            );
          },
        );

        testWidgets(
          // Example 479 from GFM.
          'overlapping * emphasis delimiters',
          (WidgetTester tester) async {
            const String data = '*foo *bar baz*';
            await tester.pumpWidget(
              boilerplate(
                const MarkdownBody(data: data),
              ),
            );

            final Finder textFinder = find.byType(Text);
            expect(textFinder, findsOneWidget);

            final Text textWidget = textFinder.evaluate().first.widget as Text;
            final String text = textWidget.textSpan!.toPlainText();
            expect(text, '*foo bar baz');

            // There should be two spans of text.
            final TextSpan textSpan = textWidget.textSpan! as TextSpan;
            expect(textSpan, isNotNull);
            expect(textSpan.children!.length == 2, isTrue);

            // First text span is plain text with normal weight.
            final InlineSpan firstSpan = textSpan.children![0];
            expectTextSpanStyle(
              firstSpan as TextSpan,
              null,
              FontWeight.normal,
            );

            // Second span has italic style with normal weight.
            final InlineSpan secondSpan = textSpan.children![1];
            expectTextSpanStyle(
              secondSpan as TextSpan,
              FontStyle.italic,
              FontWeight.normal,
            );
          },
        );
      });

      group('Rule 17', () {
        // The markdown package does not follow rule 17. Sam Rawlins made the
        // following comment on issue #280 on March 7, 2020:
        //
        // In terms of the spec, we are not following Rule 17 of "Emphasis and
        // strong emphasis." Inline code spans, links, images, and HTML tags
        // group more tightly than emphasis. Currently the Dart package respects
        // the broader rule that any time we can close a tag, we do, attempting
        // in the order of most recent openings first. I don't think this is
        // terribly hard to correct.
        // https://github.com/dart-lang/markdown/issues/280
        //
        // Test for rule 17 are not included since markdown package is not
        // following the rule.
      }, skip: 'No Rule 17 tests implemented');
    },
  );
}
