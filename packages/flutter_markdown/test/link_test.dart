// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() => defineTests();

void defineTests() {
  group('Link', () {
    testWidgets(
      'should work with nested elements',
      (WidgetTester tester) async {
        final List<MarkdownLink> linkTapResults = <MarkdownLink>[];
        const String data = '[Link `with nested code` Text](href)';
        await tester.pumpWidget(
          boilerplate(
            Markdown(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults.add(MarkdownLink(text, href, title)),
            ),
          ),
        );

        final RichText textWidget = tester.widget(find.byType(RichText));
        final TextSpan span = textWidget.text as TextSpan;

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

        expect(span.children!.length, 3);
        expect(gestureRecognizerTypes.length, 3);
        expect(gestureRecognizerTypes, everyElement(TapGestureRecognizer));
        expect(linkTapResults.length, 3);

        // Each of the child text span runs should return the same link info.
        for (final MarkdownLink tapResult in linkTapResults) {
          expectLinkTap(tapResult,
              const MarkdownLink('Link with nested code Text', 'href'));
        }
      },
    );

    testWidgets(
      'should work next to other links',
      (WidgetTester tester) async {
        final List<MarkdownLink> linkTapResults = <MarkdownLink>[];
        const String data =
            '[First Link](firstHref) and [Second Link](secondHref)';
        await tester.pumpWidget(
          boilerplate(
            Markdown(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults.add(MarkdownLink(text, href, title)),
            ),
          ),
        );

        final RichText textWidget =
            tester.widgetList(find.byType(RichText)).first as RichText;
        final TextSpan span = textWidget.text as TextSpan;

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

        expect(span.children!.length, 3);
        expect(
          gestureRecognizerTypes,
          orderedEquals(
              <Type>[TapGestureRecognizer, Null, TapGestureRecognizer]),
        );
        expectLinkTap(
            linkTapResults[0], const MarkdownLink('First Link', 'firstHref'));
        expectLinkTap(
            linkTapResults[1], const MarkdownLink('Second Link', 'secondHref'));
      },
    );

    testWidgets(
      'multiple inline links with same name but different urls - unique keys are assigned automatically',
      (WidgetTester tester) async {
        //Arange
        final Widget toBePumped = boilerplate(
          Column(
            children: <Widget>[
              MarkdownBody(
                data: '[link](link1.com)',
                onTapLink: (String text, String? href, String title) {},
              ),
              MarkdownBody(
                data: '[link](link2.com)',
                onTapLink: (String text, String? href, String title) {},
              ),
            ],
          ),
        );

        //Act
        await tester.pumpWidget(toBePumped);

        //Assert
        final Finder widgetFinder = find.byType(RichText);
        final List<Element> elements = widgetFinder.evaluate().toList();
        final List<Widget> widgets =
            elements.map((Element e) => e.widget).toList();

        final List<String> keys = widgets
            .where((Widget w) => w.key != null && w.key.toString().isNotEmpty)
            .map((Widget w) => w.key.toString())
            .toList();
        expect(keys.length, 2); //Not empty
        expect(keys.toSet().length, 2); // Unique
      },
    );
    testWidgets(
      'multiple inline links with same content should not throw an exception',
      (WidgetTester tester) async {
        //Arange
        final Widget toBePumped = boilerplate(
          Column(
            children: <Widget>[
              Expanded(
                child: MarkdownBody(
                  data:
                      '''links: [![first](image.png)](https://link.com) [![second](image.png)](https://link.com) [![third](image.png)](https://link.com)''',
                  onTapLink: (String text, String? href, String title) {},
                ),
              ),
            ],
          ),
        );

        //Act
        await tester.pumpWidget(toBePumped);

        //Assert
        final Finder widgetFinder = find.byType(RichText, skipOffstage: false);
        final List<Element> elements = widgetFinder.evaluate().toList();
        final List<Widget> widgets =
            elements.map((Element e) => e.widget).toList();

        final List<String> keys = widgets
            .where((Widget w) => w.key != null && w.key.toString().isNotEmpty)
            .map((Widget w) => w.key.toString())
            .toList();
        expect(keys.length, 3); //all three links.
        expect(keys.toSet().length, 3); // all three unique.
      },
    );

    testWidgets(
      // Example 493 from GFM.
      'simple inline link',
      (WidgetTester tester) async {
        const String data = '[link](/uri "title")';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('link');
        expectLinkTap(
            linkTapResults, const MarkdownLink('link', '/uri', 'title'));
      },
    );

    testWidgets(
      'empty inline link',
      (WidgetTester tester) async {
        const String data = '[](/uri "title")';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expect(find.byType(RichText), findsNothing);
        expect(linkTapResults, isNull);
      },
    );

    testWidgets(
      // Example 494 from GFM.
      'simple inline link - title omitted',
      (WidgetTester tester) async {
        const String data = '[link](/uri)';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('link');
        expectLinkTap(linkTapResults, const MarkdownLink('link', '/uri'));
      },
    );

    testWidgets(
      // Example 495 from GFM.
      'simple inline link - both destination and title omitted',
      (WidgetTester tester) async {
        const String data = '[link]()';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('link');
        expectLinkTap(linkTapResults, const MarkdownLink('link', ''));
      },
    );

    testWidgets(
      // Example 496 from GFM.
      'simple inline link - both < > enclosed destination and title omitted',
      (WidgetTester tester) async {
        const String data = '[link](<>)';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('link');
        expectLinkTap(linkTapResults, const MarkdownLink('link', ''));
      },
    );

    testWidgets(
      // Example 497 from GFM.
      'link destination with space and not < > enclosed',
      (WidgetTester tester) async {
        const String data = '[link](/my url)';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        // Link is treated as ordinary text.
        expectInvalidLink('[link](/my url)');
        expect(linkTapResults, isNull);
      },
    );

    testWidgets(
      // Example 498 from GFM.
      'link destination with space and < > enclosed',
      (WidgetTester tester) async {
        const String data = '[link](</my url>)';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('link');
        expectLinkTap(linkTapResults, const MarkdownLink('link', '/my%20url'));
      },
    );

    testWidgets(
      // Example 499 from GFM.
      'link destination cannot contain line breaks - not < > enclosed',
      (WidgetTester tester) async {
        const String data = '[link](foo\nbar)';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        // Link is treated as ordinary text.
        expectInvalidLink('[link](foo bar)');
        expect(linkTapResults, isNull);
      },
    );

    testWidgets(
      // Example 500 from GFM.
      'link destination cannot contain line breaks - < > enclosed',
      (WidgetTester tester) async {
        const String data = '[link](<foo\nbar>)';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        // Link is treated as ordinary text.
        expectInvalidLink('[link](<foo bar>)');
        expect(linkTapResults, isNull);
      },
    );

    testWidgets(
      // Example 501 from GFM.
      'link destination containing ")" and < > enclosed',
      (WidgetTester tester) async {
        const String data = '[link](</my)url>)';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('link');
        expectLinkTap(linkTapResults, const MarkdownLink('link', '/my)url'));
      },
    );

    testWidgets(
      // Example 502 from GFM.
      'pointy brackets that enclose links must be unescaped',
      (WidgetTester tester) async {
        const String data = r'[link](<foo\>)';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        // Link is treated as ordinary text.
        expectInvalidLink('[link](<foo>)');
        expect(linkTapResults, isNull);
      },
    );

    testWidgets(
      // Example 503 from GFM.
      'opening pointy brackets are not properly matched',
      (WidgetTester tester) async {
        const String data =
            '[link](<foo)bar\n[link](<foo)bar>\n[link](<foo>bar)';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        // Link is treated as ordinary text.
        expectInvalidLink('[link](<foo)bar [link](<foo)bar> [link](<foo>bar)');
        expect(linkTapResults, isNull);
      },
    );

    testWidgets(
      // Example 504 from GFM.
      'parentheses inside link destination may be escaped',
      (WidgetTester tester) async {
        const String data = r'[link](\(foo\))';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('link');
        expectLinkTap(linkTapResults, const MarkdownLink('link', '(foo)'));
      },
    );

    testWidgets(
      // Example 505 from GFM.
      'multiple balanced parentheses are allowed without escaping',
      (WidgetTester tester) async {
        const String data = '[link](foo(and(bar)))';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('link');
        expectLinkTap(
            linkTapResults, const MarkdownLink('link', 'foo(and(bar))'));
      },
    );

    testWidgets(
      // Example 506 from GFM.
      'escaped unbalanced parentheses',
      (WidgetTester tester) async {
        // Use raw string so backslash isn't treated as an escape character.
        const String data = r'[link](foo\(and\(bar\))';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('link');
        expectLinkTap(
            linkTapResults, const MarkdownLink('link', 'foo(and(bar)'));
      },
    );

    testWidgets(
      // Example 507 from GFM.
      'pointy brackets enclosed unbalanced parentheses',
      (WidgetTester tester) async {
        const String data = '[link](<foo(and(bar)>)';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('link');
        expectLinkTap(
            linkTapResults, const MarkdownLink('link', 'foo(and(bar)'));
      },
    );

    testWidgets(
      // Example 508 from GFM.
      'parentheses and other symbols can be escaped',
      (WidgetTester tester) async {
        // Use raw string so backslash isn't treated as an escape character.
        const String data = r'[link](foo\)\:)';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('link');
        expectLinkTap(linkTapResults, const MarkdownLink('link', 'foo):'));
      },
    );

    testWidgets(
      // Example 509 case 1 from GFM.
      'link destinations with just fragment identifier',
      (WidgetTester tester) async {
        const String data = '[link](#fragment)';

        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('link');
        expectLinkTap(linkTapResults, const MarkdownLink('link', '#fragment'));
      },
    );

    testWidgets(
      // Example 509 case 2 from GFM.
      'link destinations with URL and fragment identifier',
      (WidgetTester tester) async {
        const String data = '[link](http://example.com#fragment)';

        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('link');
        expectLinkTap(linkTapResults,
            const MarkdownLink('link', 'http://example.com#fragment'));
      },
    );

    testWidgets(
      // Example 509 case 3 from GFM.
      'link destinations with URL, fragment identifier, and query',
      (WidgetTester tester) async {
        const String data = '[link](http://example.com?foo=3#fragment)';

        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('link');
        expectLinkTap(linkTapResults,
            const MarkdownLink('link', 'http://example.com?foo=3#fragment'));
      },
    );

    testWidgets(
      // Example 510 from GFM.
      'link destinations with backslash before non-escapable character',
      (WidgetTester tester) async {
        const String data = '[link](foo\bar)';

        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('link');
        expectLinkTap(linkTapResults, const MarkdownLink('link', 'foo%08ar'));
      },
    );

    testWidgets(
      // Example 511 from GFM.
      'URL escaping should be left alone inside link destination',
      (WidgetTester tester) async {
        const String data = '[link](foo%20b&auml;)';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('link');
        expectLinkTap(
            linkTapResults, const MarkdownLink('link', 'foo%20b%C3%A4'));
      },
    );

    testWidgets(
      // Example 512 from GFM.
      'omitting link destination uses title for destination',
      (WidgetTester tester) async {
        const String data = '[link]("title")';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('link');
        expectLinkTap(
            linkTapResults, const MarkdownLink('link', '%22title%22'));
      },
    );

    testWidgets(
      // Example 513a from GFM.
      'link title in double quotes',
      (WidgetTester tester) async {
        const String data = '[link](/url "title")';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('link');
        expectLinkTap(
            linkTapResults, const MarkdownLink('link', '/url', 'title'));
      },
    );

    testWidgets(
      // Example 513b from GFM.
      'link title in single quotes',
      (WidgetTester tester) async {
        const String data = "[link](/url 'title')";
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('link');
        expectLinkTap(
            linkTapResults, const MarkdownLink('link', '/url', 'title'));
      },
    );

    testWidgets(
      // Example 513c from GFM.
      'link title in parentheses',
      (WidgetTester tester) async {
        const String data = '[link](/url (title))';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('link');
        expectLinkTap(
            linkTapResults, const MarkdownLink('link', '/url', 'title'));
      },
    );

    testWidgets(
      // Example 514 from GFM.
      'backslash escapes, entity, and numeric character references are allowed in title',
      (WidgetTester tester) async {
        const String data = r'[link](/url "title \"&quot;")';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('link');
        expectLinkTap(linkTapResults,
            const MarkdownLink('link', '/url', 'title &quot;&quot;'));
      },
    );

    testWidgets(
      // Example 515 from GFM.
      'link title must be separated with whitespace and not Unicode whitespace',
      (WidgetTester tester) async {
        const String data = '[link](/url\u{C2A0}"title")';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('link');
        expectLinkTap(linkTapResults,
            const MarkdownLink('link', '/url%EC%8A%A0%22title%22'));
      },
    );

    testWidgets(
      // Example 516 from GFM.
      'nested balanced quotes are not allowed without escaping',
      (WidgetTester tester) async {
        const String data = '[link](/url "title "and" title")';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        // Link is treated as ordinary text.
        expectInvalidLink('[link](/url "title "and" title")');
        expect(linkTapResults, isNull);
      },
    );

    testWidgets(
      // Example 517 from GFM.
      'nested balanced quotes using different quote type',
      (WidgetTester tester) async {
        const String data = '[link](/url \'title "and" title\')';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('link');
        expectLinkTap(
          linkTapResults,
          const MarkdownLink('link', '/url', 'title &quot;and&quot; title'),
        );
      },
    );

    testWidgets(
      // Example 518 from GFM.
      'whitespace is allowed around the destination and title',
      (WidgetTester tester) async {
        const String data = '[link](   /url  "title")';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('link');
        expectLinkTap(
            linkTapResults, const MarkdownLink('link', '/url', 'title'));
      },
    );

    testWidgets(
      // Example 519 from GFM.
      'whitespace is not allowed between link text and following parentheses',
      (WidgetTester tester) async {
        const String data = '[link] (/url)';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        // Link is treated as ordinary text.
        expectInvalidLink('[link] (/url)');
        expect(linkTapResults, isNull);
      },
    );

    testWidgets(
      // Example 520 from GFM.
      'link text may contain balanced brackets',
      (WidgetTester tester) async {
        const String data = '[link [foo [bar]]](/uri)';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('link [foo [bar]]');
        expectLinkTap(
            linkTapResults, const MarkdownLink('link [foo [bar]]', '/uri'));
      },
    );

    testWidgets(
      // Example 521 from GFM.
      'link text may not contain unbalanced brackets',
      (WidgetTester tester) async {
        const String data = '[link] bar](/uri)';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        // Link is treated as ordinary text.
        expectInvalidLink('[link] bar](/uri)');
        expect(linkTapResults, isNull);
      },
    );

    testWidgets(
      // Example 522 from GFM.
      'link text may not contain unbalanced brackets - unintended link text',
      (WidgetTester tester) async {
        const String data = '[link [bar](/uri)';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        final RichText textWidget = tester.widget(find.byType(RichText));
        final TextSpan span = textWidget.text as TextSpan;
        expect(span.children!.length, 2);
        expect(span.children![0], isA<TextSpan>());
        expect(span.children![0].toPlainText(), '[link ');

        expectLinkTextSpan(span.children![1] as TextSpan, 'bar');
        expectLinkTap(linkTapResults, const MarkdownLink('bar', '/uri'));
      },
    );

    testWidgets(
      // Example 523 from GFM.
      'link text with escaped open square bracket',
      (WidgetTester tester) async {
        const String data = r'[link \[bar](/uri)';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('link [bar');
        expectLinkTap(linkTapResults, const MarkdownLink('link [bar', '/uri'));
      },
    );

    testWidgets(
      // Example 524 from GFM.
      'link text with inline emphasis and code',
      (WidgetTester tester) async {
        const String data = '[link *foo **bar** `#`*](/uri)';
        final List<MarkdownLink> linkTapResults = <MarkdownLink>[];
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults.add(MarkdownLink(text, href, title)),
            ),
          ),
        );

        final RichText textWidget = tester.widget(find.byType(RichText));
        final TextSpan span = textWidget.text as TextSpan;
        expect(span.children!.length, 5);
        expectTextSpanStyle(
            span.children![0] as TextSpan, null, FontWeight.normal);
        expectTextSpanStyle(
            span.children![1] as TextSpan, FontStyle.italic, FontWeight.normal);
        expectTextSpanStyle(
            span.children![2] as TextSpan, FontStyle.italic, FontWeight.bold);
        expectTextSpanStyle(
            span.children![3] as TextSpan, FontStyle.italic, FontWeight.normal);
        expect((span.children![4] as TextSpan).style!.fontFamily, 'monospace');

        final List<Type> gestureRecognizerTypes = <Type>[];
        span.visitChildren((InlineSpan inlineSpan) {
          if (inlineSpan is TextSpan) {
            final TapGestureRecognizer? recognizer =
                inlineSpan.recognizer as TapGestureRecognizer?;
            gestureRecognizerTypes.add(recognizer.runtimeType);
            recognizer!.onTap!();
          }
          return true;
        });

        expect(gestureRecognizerTypes.length, 5);
        expect(gestureRecognizerTypes, everyElement(TapGestureRecognizer));
        expect(linkTapResults.length, 5);

        // Each of the child text span runs should return the same link info.
        for (final MarkdownLink tapResult in linkTapResults) {
          expectLinkTap(
              tapResult, const MarkdownLink('link foo bar #', '/uri'));
        }
      },
    );

    testWidgets(
      // Example 525 from GFM.
      'inline image link text',
      (WidgetTester tester) async {
        const String data = '[![moon](moon.jpg)](/uri)';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        final Finder gestureFinder = find.byType(GestureDetector);
        expect(gestureFinder, findsOneWidget);
        final GestureDetector gestureWidget =
            gestureFinder.evaluate().first.widget as GestureDetector;
        expect(gestureWidget.child, isA<Image>());
        expect(gestureWidget.onTap, isNotNull);

        gestureWidget.onTap!();
        expectLinkTap(linkTapResults, const MarkdownLink('moon', '/uri'));
      },
    );

    testWidgets(
      // Example 526 from GFM.
      'links cannot be nested - outter link ignored',
      (WidgetTester tester) async {
        const String data = '[foo [bar](/uri)](/uri)';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        final RichText textWidget = tester.widget(find.byType(RichText));
        final TextSpan span = textWidget.text as TextSpan;
        expect(span.children!.length, 3);
        expect(span.children![0], isA<TextSpan>());
        expect(span.children![0].toPlainText(), '[foo ');

        expectLinkTextSpan(span.children![1] as TextSpan, 'bar');
        expectLinkTap(linkTapResults, const MarkdownLink('bar', '/uri'));

        expect(span.children![2], isA<TextSpan>());
        expect(span.children![2].toPlainText(), '](/uri)');
      },
    );

    testWidgets(
      // Example 527 from GFM.
      'links cannot be nested - outter link ignored with emphasis',
      (WidgetTester tester) async {
        const String data = '[foo *[bar [baz](/uri)](/uri)*](/uri)';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        final RichText textWidget = tester.widget(find.byType(RichText));
        final TextSpan span = textWidget.text as TextSpan;
        expect(span.children!.length, 5);
        expect(span.children, everyElement(isA<TextSpan>()));

        expect(span.children![0].toPlainText(), '[foo ');
        expectTextSpanStyle(
            span.children![0] as TextSpan, null, FontWeight.normal);

        expect(span.children![1].toPlainText(), '[bar ');
        expectTextSpanStyle(
            span.children![1] as TextSpan, FontStyle.italic, FontWeight.normal);

        expect(span.children![2].toPlainText(), 'baz');
        expectTextSpanStyle(
            span.children![2] as TextSpan, FontStyle.italic, FontWeight.normal);

        expect(span.children![3].toPlainText(), '](/uri)');
        expectTextSpanStyle(
            span.children![3] as TextSpan, FontStyle.italic, FontWeight.normal);

        expect(span.children![4].toPlainText(), '](/uri)');
        expectTextSpanStyle(
            span.children![4] as TextSpan, null, FontWeight.normal);

        expectLinkTextSpan(span.children![2] as TextSpan, 'baz');
        expectLinkTap(linkTapResults, const MarkdownLink('baz', '/uri'));
      },
    );

    testWidgets(
      // Example 528 from GFM.
      'links cannot be nested in image linksinline image link text',
      (WidgetTester tester) async {
        const String data = '![[[foo](uri1)](uri2)](uri3)';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        final Finder gestureFinder = find.byType(GestureDetector);
        expect(gestureFinder, findsNothing);

        final Finder imageFinder = find.byType(Image);
        expect(imageFinder, findsOneWidget);
        final Image image = imageFinder.evaluate().first.widget as Image;
        if (kIsWeb) {
          final NetworkImage fi = image.image as NetworkImage;
          expect(fi.url.endsWith('uri3'), true);
        } else {
          final FileImage fi = image.image as FileImage;
          expect(fi.file.path, equals('uri3'));
        }
        expect(linkTapResults, isNull);
      },
    );

    testWidgets(
      // Example 529 from GFM.
      'link text grouping has precedence over emphasis grouping example 1',
      (WidgetTester tester) async {
        const String data = r'*[foo*](/uri)';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        final RichText textWidget = tester.widget(find.byType(RichText));
        final TextSpan span = textWidget.text as TextSpan;
        expect(span.children!.length, 2);
        expect(span.children![0], isA<TextSpan>());
        expect(span.children![0].toPlainText(), '*');
        expectTextSpanStyle(
            span.children![0] as TextSpan, null, FontWeight.normal);

        expectLinkTextSpan(span.children![1] as TextSpan, 'foo*');
        expectLinkTap(linkTapResults, const MarkdownLink('foo*', '/uri'));
      },
    );

    testWidgets(
      // Example 530 from GFM.
      'link text grouping has precedence over emphasis grouping example 2',
      (WidgetTester tester) async {
        const String data = '[foo *bar](baz*)';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('foo *bar');
        expectLinkTap(linkTapResults, const MarkdownLink('foo *bar', 'baz*'));
      },
    );

    testWidgets(
      // Example 531 from GFM.
      "brackets that aren't part of links do not take precedence",
      (WidgetTester tester) async {
        const String data = '*foo [bar* baz]';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final RichText textWidget = tester.widget(find.byType(RichText));
        final TextSpan span = textWidget.text as TextSpan;
        expect(span.children!.length, 2);
        expect(span.children, everyElement(isA<TextSpan>()));

        expect(span.children![0].toPlainText(), 'foo [bar');
        expectTextSpanStyle(
            span.children![0] as TextSpan, FontStyle.italic, FontWeight.normal);

        expect(span.children![1].toPlainText(), ' baz]');
        expectTextSpanStyle(
            span.children![1] as TextSpan, null, FontWeight.normal);
      },
    );

    testWidgets(
      // Example 532 from GFM.
      'HTML tag takes precedence over link grouping',
      (WidgetTester tester) async {
        const String data = '[foo <bar attr="](baz)">';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        // Link is treated as ordinary text.
        expectInvalidLink('[foo <bar attr="](baz)">');
        expect(linkTapResults, isNull);
      },
    );

    testWidgets(
      // Example 533 from GFM.
      'code span takes precedence over link grouping',
      (WidgetTester tester) async {
        const String data = '[foo`](/uri)`';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        final Finder gestureFinder = find.byType(GestureDetector);
        expect(gestureFinder, findsNothing);

        final RichText textWidget = tester.widget(find.byType(RichText));
        final TextSpan span = textWidget.text as TextSpan;
        expect(span.children!.length, 2);
        expect(span.children, everyElement(isA<TextSpan>()));

        expect(span.children![0], isA<TextSpan>());
        expect(span.children![0].toPlainText(), '[foo');
        expectTextSpanStyle(
            span.children![0] as TextSpan, null, FontWeight.normal);

        expectTextSpanStyle(
            span.children![0] as TextSpan, null, FontWeight.normal);
        expect((span.children![1] as TextSpan).style!.fontFamily, 'monospace');
        expect(linkTapResults, isNull);
      },
    );

    testWidgets(
      // Example 534 from GFM.
      'autolinks take precedence over link grouping',
      (WidgetTester tester) async {
        const String data = '[foo<http://example.com/?search=](uri)>';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        final RichText textWidget = tester.widget(find.byType(RichText));
        final TextSpan span = textWidget.text as TextSpan;
        expect(span.children!.length, 2);
        expect(span.children, everyElement(isA<TextSpan>()));

        expect(span.children![0].toPlainText(), '[foo');
        expectTextSpanStyle(
            span.children![0] as TextSpan, null, FontWeight.normal);

        expectLinkTextSpan(
            span.children![1] as TextSpan, 'http://example.com/?search=](uri)');
        expectLinkTap(
            linkTapResults,
            const MarkdownLink('http://example.com/?search=](uri)',
                'http://example.com/?search=%5D(uri)'));
      },
    );
  });
  group('Reference Link', () {
    testWidgets(
      // Example 535 from GFM.
      'simple reference link',
      (WidgetTester tester) async {
        const String data = '[foo][bar]\n\n[bar]: /url "title"';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('foo');
        expectLinkTap(
            linkTapResults, const MarkdownLink('foo', '/url', 'title'));
      },
    );

    testWidgets(
      // Example 536 from GFM.
      'reference link with balanced brackets in link text',
      (WidgetTester tester) async {
        const String data = '[link [foo [bar]]][ref]\n\n[ref]: /uri';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('link [foo [bar]]');
        expectLinkTap(
            linkTapResults, const MarkdownLink('link [foo [bar]]', '/uri'));
      },
    );

    testWidgets(
      // Example 537 from GFM.
      'reference link with unbalanced but escaped bracket in link text',
      (WidgetTester tester) async {
        const String data = '[link \\[bar][ref]\n\n[ref]: /uri';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('link [bar');
        expectLinkTap(linkTapResults, const MarkdownLink('link [bar', '/uri'));
      },
    );

    testWidgets(
      // Example 538 from GFM.
      'reference link with inline emphasis and code span in link text',
      (WidgetTester tester) async {
        const String data = '[link *foo **bar** `#`*][ref]\n\n[ref]: /uri';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        final RichText textWidget = tester.widget(find.byType(RichText));
        final TextSpan span = textWidget.text as TextSpan;
        expect(span.children!.length, 5);
        expect(span.children, everyElement(isA<TextSpan>()));

        expect(span.children![0].toPlainText(), 'link ');
        expectTextSpanStyle(
            span.children![0] as TextSpan, null, FontWeight.normal);

        expect(span.children![1].toPlainText(), 'foo ');
        expectTextSpanStyle(
            span.children![1] as TextSpan, FontStyle.italic, FontWeight.normal);

        expect(span.children![2].toPlainText(), 'bar');
        expectTextSpanStyle(
            span.children![2] as TextSpan, FontStyle.italic, FontWeight.bold);

        expect(span.children![3].toPlainText(), ' ');
        expectTextSpanStyle(
            span.children![3] as TextSpan, FontStyle.italic, FontWeight.normal);

        expect(span.children![4].toPlainText(), '#');
        expectTextSpanStyle(
            span.children![4] as TextSpan, null, FontWeight.normal);
        expect((span.children![4] as TextSpan).style!.fontFamily, 'monospace');

        for (final InlineSpan element in span.children!) {
          final TextSpan textSpan = element as TextSpan;
          expect(textSpan.recognizer, isNotNull);
          expect(textSpan.recognizer, isA<TapGestureRecognizer>());
          final TapGestureRecognizer? tapRecognizer =
              textSpan.recognizer as TapGestureRecognizer?;
          expect(tapRecognizer?.onTap, isNotNull);

          tapRecognizer!.onTap!();
          expectLinkTap(
              linkTapResults, const MarkdownLink('link foo bar #', '/uri'));

          // Clear link tap results.
          linkTapResults = null;
        }
      },
    );

    testWidgets(
      // Example 539 from GFM.
      'referenence link with inline image link text',
      (WidgetTester tester) async {
        const String data = '[![moon](moon.jpg)][ref]\n\n[ref]: /uri';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        final Finder gestureFinder = find.byType(GestureDetector);
        expect(gestureFinder, findsOneWidget);
        final GestureDetector gestureWidget =
            gestureFinder.evaluate().first.widget as GestureDetector;
        expect(gestureWidget.child, isA<Image>());
        expect(gestureWidget.onTap, isNotNull);

        gestureWidget.onTap!();
        expectLinkTap(linkTapResults, const MarkdownLink('moon', '/uri'));
      },
    );

    testWidgets(
      // Example 540 from GFM.
      'reference links cannot have nested links',
      (WidgetTester tester) async {
        const String data = '[foo [bar](/uri)][ref]\n\n[ref]: /uri';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        final RichText textWidget = tester.widget(find.byType(RichText));
        final TextSpan span = textWidget.text as TextSpan;
        expect(span.children!.length, 4);

        expect(span.children![0], isA<TextSpan>());
        expect(span.children![0].toPlainText(), '[foo ');

        expectLinkTextSpan(span.children![1] as TextSpan, 'bar');
        expectLinkTap(linkTapResults, const MarkdownLink('bar', '/uri'));

        expect(span.children![2], isA<TextSpan>());
        expect(span.children![2].toPlainText(), ']');

        expectLinkTextSpan(span.children![3] as TextSpan, 'ref');
        expectLinkTap(linkTapResults, const MarkdownLink('ref', '/uri'));
      },
    );

    testWidgets(
      // Example 541 from GFM.
      'reference links cannot have nested reference links',
      (WidgetTester tester) async {
        const String data = '[foo *bar [baz][ref]*][ref]\n\n[ref]: /uri';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        final RichText textWidget = tester.widget(find.byType(RichText));
        final TextSpan span = textWidget.text as TextSpan;
        expect(span.children!.length, 5);

        expect(span.children![0], isA<TextSpan>());
        expect(span.children![0].toPlainText(), '[foo ');
        expectTextSpanStyle(
            span.children![0] as TextSpan, null, FontWeight.normal);

        expect(span.children![1], isA<TextSpan>());
        expect(span.children![1].toPlainText(), 'bar ');
        expectTextSpanStyle(
            span.children![1] as TextSpan, FontStyle.italic, FontWeight.normal);

        expectLinkTextSpan(span.children![2] as TextSpan, 'baz');
        expectTextSpanStyle(
            span.children![2] as TextSpan, FontStyle.italic, FontWeight.normal);
        expectLinkTap(linkTapResults, const MarkdownLink('baz', '/uri'));

        expect(span.children![3], isA<TextSpan>());
        expect(span.children![3].toPlainText(), ']');
        expectTextSpanStyle(
            span.children![3] as TextSpan, null, FontWeight.normal);

        expectLinkTextSpan(span.children![4] as TextSpan, 'ref');
        expectTextSpanStyle(
            span.children![4] as TextSpan, null, FontWeight.normal);
        expectLinkTap(linkTapResults, const MarkdownLink('ref', '/uri'));
      },
    );

    testWidgets(
      // Example 542 from GFM.
      'reference link text grouping has precedence over emphasis grouping example 1',
      (WidgetTester tester) async {
        const String data = '*[foo*][ref]\n\n[ref]: /uri';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        final RichText textWidget = tester.widget(find.byType(RichText));
        final TextSpan span = textWidget.text as TextSpan;
        expect(span.children!.length, 2);
        expect(span.children![0], isA<TextSpan>());
        expect(span.children![0].toPlainText(), '*');
        expectTextSpanStyle(
            span.children![0] as TextSpan, null, FontWeight.normal);

        expectLinkTextSpan(span.children![1] as TextSpan, 'foo*');
        expectLinkTap(linkTapResults, const MarkdownLink('foo*', '/uri'));
      },
    );

    testWidgets(
      // Example 543 from GFM.
      'reference link text grouping has precedence over emphasis grouping example 2',
      (WidgetTester tester) async {
        const String data = '[foo *bar][ref]*\n\n[ref]: /uri';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        final RichText textWidget = tester.widget(find.byType(RichText));
        final TextSpan span = textWidget.text as TextSpan;
        expect(span.children!.length, 2);

        expectLinkTextSpan(span.children![0] as TextSpan, 'foo *bar');
        expectTextSpanStyle(
            span.children![0] as TextSpan, null, FontWeight.normal);
        expectLinkTap(linkTapResults, const MarkdownLink('foo *bar', '/uri'));

        expect(span.children![1], isA<TextSpan>());
        expect(span.children![1].toPlainText(), '*');
        expectTextSpanStyle(
            span.children![0] as TextSpan, null, FontWeight.normal);
      },
    );

    testWidgets(
      // Example 544 from GFM.
      'HTML tag takes precedence over reference link grouping',
      (WidgetTester tester) async {
        const String data = '[foo <bar attr="][ref]">\n\n[ref]: /uri';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        // Link is treated as ordinary text.
        expectInvalidLink('[foo <bar attr="][ref]">');
        expect(linkTapResults, isNull);
      },
    );

    testWidgets(
      // Example 545 from GFM.
      'code span takes precedence over reference link grouping',
      (WidgetTester tester) async {
        const String data = '[foo`][ref]`\n\n[ref]: /uri';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        final Finder gestureFinder = find.byType(GestureDetector);
        expect(gestureFinder, findsNothing);

        final RichText textWidget = tester.widget(find.byType(RichText));
        final TextSpan span = textWidget.text as TextSpan;
        expect(span.children!.length, 2);
        expect(span.children, everyElement(isA<TextSpan>()));

        expect(span.children![0], isA<TextSpan>());
        expect(span.children![0].toPlainText(), '[foo');
        expectTextSpanStyle(
            span.children![0] as TextSpan, null, FontWeight.normal);

        expect(span.children![1].toPlainText(), '][ref]');
        expect((span.children![1] as TextSpan).style!.fontFamily, 'monospace');
        expect(linkTapResults, isNull);
      },
    );

    testWidgets(
      // Example 534 from GFM.
      'autolinks take precedence over reference link grouping',
      (WidgetTester tester) async {
        const String data =
            '[foo<http://example.com/?search=][ref]>\n\n[ref]: /uri';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        final RichText textWidget = tester.widget(find.byType(RichText));
        final TextSpan span = textWidget.text as TextSpan;
        expect(span.children!.length, 2);
        expect(span.children, everyElement(isA<TextSpan>()));

        expect(span.children![0].toPlainText(), '[foo');
        expectTextSpanStyle(
            span.children![0] as TextSpan, null, FontWeight.normal);

        expectLinkTextSpan(
            span.children![1] as TextSpan, 'http://example.com/?search=][ref]');
        expectLinkTap(
            linkTapResults,
            const MarkdownLink('http://example.com/?search=][ref]',
                'http://example.com/?search=%5D%5Bref%5D'));
      },
    );

    testWidgets(
      // Example 547 from GFM.
      'reference link matching is case-insensitive',
      (WidgetTester tester) async {
        const String data = '[foo][BaR]\n\n[bar]: /url "title"';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('foo');
        expectLinkTap(
            linkTapResults, const MarkdownLink('foo', '/url', 'title'));
      },
    );

    testWidgets(
      // Example 548 from GFM.
      'reference link support Unicode case fold - GFM',
      (WidgetTester tester) async {
        const String data = '[ẞ]\n\n[SS]: /url';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('ẞ');
        expectLinkTap(linkTapResults, const MarkdownLink('ẞ', '/url', 'title'));
      },
      // TODO(mjordan56): Remove skip once the issue #333 in the markdown package
      // is fixed and released. https://github.com/dart-lang/markdown/issues/333
      skip: true,
    );

    testWidgets(
      // Example 536 from CommonMark. NOTE: The CommonMark and GFM specifications
      // use different examples for Unicode case folding. Both are being added
      // to the test suite since each example produces different cases to test.
      'reference link support Unicode case fold - CommonMark',
      (WidgetTester tester) async {
        const String data =
            '[Толпой][Толпой] is a Russian word.\n\n[ТОЛПОЙ]: /url';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        final RichText textWidget = tester.widget(find.byType(RichText));
        final TextSpan span = textWidget.text as TextSpan;
        expect(span.children!.length, 2);

        expectLinkTextSpan(span.children![0] as TextSpan, 'Толпой');
        expectLinkTap(linkTapResults, const MarkdownLink('Толпой', '/url'));

        expect(span.children![1], isA<TextSpan>());
        expect(span.children![1].toPlainText(), ' is a Russian word.');
        expectTextSpanStyle(
            span.children![0] as TextSpan, null, FontWeight.normal);
      },
    );

    testWidgets(
      // Example 549 from GFM.
      'reference link with internal whitespace',
      (WidgetTester tester) async {
        const String data = '[Foo\n  bar]: /url\n\n[Baz][Foo bar]';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('Baz');
        expectLinkTap(linkTapResults, const MarkdownLink('Baz', '/url'));
      },
    );

    testWidgets(
      // Example 550 from GFM.
      'reference link no whitespace between link text and link label',
      (WidgetTester tester) async {
        const String data = '[foo] [bar]\n\n[bar]: /url "title"';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        final RichText textWidget = tester.widget(find.byType(RichText));
        final TextSpan span = textWidget.text as TextSpan;
        expect(span.children!.length, 2);

        expect(span.children![0], isA<TextSpan>());
        expect(span.children![0].toPlainText(), '[foo] ');
        expectTextSpanStyle(
            span.children![0] as TextSpan, null, FontWeight.normal);

        expectLinkTextSpan(span.children![1] as TextSpan, 'bar');
        expectLinkTap(
            linkTapResults, const MarkdownLink('bar', '/url', 'title'));
      },
    );

    testWidgets(
      // Example 551 from GFM.
      'reference link no line break between link text and link label',
      (WidgetTester tester) async {
        const String data = '[foo]\n[bar]\n\n[bar]: /url "title"';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        final RichText textWidget = tester.widget(find.byType(RichText));
        final TextSpan span = textWidget.text as TextSpan;
        expect(span.children!.length, 2);

        expect(span.children![0], isA<TextSpan>());
        expect(span.children![0].toPlainText(), '[foo] ');
        expectTextSpanStyle(
            span.children![0] as TextSpan, null, FontWeight.normal);

        expectLinkTextSpan(span.children![1] as TextSpan, 'bar');
        expectLinkTap(
            linkTapResults, const MarkdownLink('bar', '/url', 'title'));
      },
    );

    testWidgets(
      // Example 552 from GFM.
      'multiple matching reference link definitions use first definition',
      (WidgetTester tester) async {
        const String data = '[foo]: /url1\n\n[foo]: /url2\n\n[bar][foo]';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('bar');
        expectLinkTap(linkTapResults, const MarkdownLink('bar', '/url1'));
      },
    );

    testWidgets(
      // Example 553 from GFM.
      'reference link matching is performed on normalized strings',
      (WidgetTester tester) async {
        const String data = '[bar][foo\\!]\n\n[foo!]: /url';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        // Link is treated as ordinary text.
        expectInvalidLink('[bar][foo!]');
        expect(linkTapResults, isNull);
      },
    );

    testWidgets(
      // Example 554 from GFM.
      'reference link labels cannot contain brackets - case 1',
      (WidgetTester tester) async {
        const String data = '[foo][ref[]\n\n[ref[]: /uri';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        final List<RichText> textWidgets =
            tester.widgetList(find.byType(RichText)).toList().cast<RichText>();
        expect(textWidgets.length, 2);

        expect(textWidgets[0].text, isA<TextSpan>());
        expect(textWidgets[0].text.toPlainText(), '[foo][ref[]');
        expectTextSpanStyle(
            textWidgets[0].text as TextSpan, null, FontWeight.normal);

        expect(textWidgets[1].text, isA<TextSpan>());
        expect(textWidgets[1].text.toPlainText(), '[ref[]: /uri');
        expectTextSpanStyle(
            textWidgets[1].text as TextSpan, null, FontWeight.normal);

        expect(linkTapResults, isNull);
      },
      // TODO(mjordan56): Remove skip once the issue #335 in the markdown package
      // is fixed and released. https://github.com/dart-lang/markdown/issues/335
      skip: true,
    );

    testWidgets(
      // Example 555 from GFM.
      'reference link labels cannot contain brackets - case 2',
      (WidgetTester tester) async {
        const String data = '[foo][ref[bar]]\n\n[ref[bar]]: /uri';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        final List<RichText> textWidgets =
            tester.widgetList(find.byType(RichText)).toList().cast<RichText>();
        expect(textWidgets.length, 2);

        expect(textWidgets[0].text, isNotNull);
        expect(textWidgets[0].text, isA<TextSpan>());
        expect(textWidgets[0].text.toPlainText(), '[foo][ref[bar]]');
        expectTextSpanStyle(
            textWidgets[0].text as TextSpan, null, FontWeight.normal);

        expect(textWidgets[1].text, isNotNull);
        expect(textWidgets[1].text, isA<TextSpan>());
        expect(textWidgets[1].text.toPlainText(), '[ref[bar]]: /uri');
        expectTextSpanStyle(
            textWidgets[1].text as TextSpan, null, FontWeight.normal);

        expect(linkTapResults, isNull);
      },
    );

    testWidgets(
      // Example 556 from GFM.
      'reference link labels cannot contain brackets - case 3',
      (WidgetTester tester) async {
        const String data = '[[[foo]]]\n\n[[[foo]]]: /url';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        final List<RichText> textWidgets =
            tester.widgetList(find.byType(RichText)).toList().cast<RichText>();
        expect(textWidgets.length, 2);

        expect(textWidgets[0].text, isNotNull);
        expect(textWidgets[0].text, isA<TextSpan>());
        expect(textWidgets[0].text.toPlainText(), '[[[foo]]]');
        expectTextSpanStyle(
            textWidgets[0].text as TextSpan, null, FontWeight.normal);

        expect(textWidgets[1].text, isNotNull);
        expect(textWidgets[1].text, isA<TextSpan>());
        expect(textWidgets[1].text.toPlainText(), '[[[foo]]]: /url');
        expectTextSpanStyle(
            textWidgets[1].text as TextSpan, null, FontWeight.normal);

        expect(linkTapResults, isNull);
      },
    );

    testWidgets(
      // Example 557 from GFM.
      'reference link labels can have escaped brackets',
      (WidgetTester tester) async {
        const String data = '[foo][ref\\[]\n\n[ref\\[]: /uri';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('foo');
        expectLinkTap(linkTapResults, const MarkdownLink('foo', '/uri'));
      },
    );

    testWidgets(
      // Example 558 from GFM.
      'reference link labels can have escaped characters',
      (WidgetTester tester) async {
        const String data = '[bar\\]: /uri\n\n[bar\\]';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink(r'bar\');
        expectLinkTap(linkTapResults, const MarkdownLink(r'bar\', '/uri'));
      },
      // TODO(mjordan56): Remove skip once the issue #336 in the markdown package
      // is fixed and released. https://github.com/dart-lang/markdown/issues/336
      skip: true,
    );

    testWidgets(
      // Example 559 from GFM.
      'reference link labels must contain at least on non-whitespace character - case 1',
      (WidgetTester tester) async {
        const String data = '[]\n\n[]: /uri';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        final List<RichText> textWidgets =
            tester.widgetList(find.byType(RichText)).toList().cast<RichText>();
        expect(textWidgets.length, 2);

        expect(textWidgets[0].text, isNotNull);
        expect(textWidgets[0].text, isA<TextSpan>());
        expect(textWidgets[0].text.toPlainText(), '[]');
        expectTextSpanStyle(
            textWidgets[0].text as TextSpan, null, FontWeight.normal);

        expect(textWidgets[1].text, isNotNull);
        expect(textWidgets[1].text, isA<TextSpan>());
        expect(textWidgets[1].text.toPlainText(), '[]: /uri');
        expectTextSpanStyle(
            textWidgets[1].text as TextSpan, null, FontWeight.normal);

        expect(linkTapResults, isNull);
      },
    );

    testWidgets(
      // Example 560 from GFM.
      'reference link labels must contain at least on non-whitespace character - case 2',
      (WidgetTester tester) async {
        const String data = '[\n ]\n\n[\n ]: /uri';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        final List<RichText> textWidgets =
            tester.widgetList(find.byType(RichText)).toList().cast<RichText>();
        expect(textWidgets.length, 2);

        expect(textWidgets[0].text, isNotNull);
        expect(textWidgets[0].text, isA<TextSpan>());
        expect(textWidgets[0].text.toPlainText(), '[ ]');
        expectTextSpanStyle(
            textWidgets[0].text as TextSpan, null, FontWeight.normal);

        expect(textWidgets[1].text, isNotNull);
        expect(textWidgets[1].text, isA<TextSpan>());
        expect(textWidgets[1].text.toPlainText(), '[ ]: /uri');
        expectTextSpanStyle(
            textWidgets[1].text as TextSpan, null, FontWeight.normal);

        expect(linkTapResults, isNull);
      },
    );

    testWidgets(
      // Example 561 from GFM.
      'collapsed reference link',
      (WidgetTester tester) async {
        const String data = '[foo][]\n\n[foo]: /url "title"';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('foo');
        expectLinkTap(
            linkTapResults, const MarkdownLink('foo', '/url', 'title'));
      },
    );

    testWidgets(
      // Example 562 from GFM.
      'collapsed reference link with inline emphasis in link text',
      (WidgetTester tester) async {
        const String data = '[*foo* bar][]\n\n[*foo* bar]: /url "title"';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        final RichText textWidget = tester.widget(find.byType(RichText));
        final TextSpan span = textWidget.text as TextSpan;
        expect(span.children!.length, 2);
        expect(span.children, everyElement(isA<TextSpan>()));

        expect(span.children![0].toPlainText(), 'foo');
        expectTextSpanStyle(
            span.children![0] as TextSpan, FontStyle.italic, FontWeight.normal);

        expect(span.children![1].toPlainText(), ' bar');
        expectTextSpanStyle(
            span.children![1] as TextSpan, null, FontWeight.normal);

        for (final InlineSpan element in span.children!) {
          final TextSpan textSpan = element as TextSpan;
          expect(textSpan.recognizer, isNotNull);
          expect(textSpan.recognizer, isA<TapGestureRecognizer>());
          final TapGestureRecognizer? tapRecognizer =
              textSpan.recognizer as TapGestureRecognizer?;
          expect(tapRecognizer?.onTap, isNotNull);

          tapRecognizer!.onTap!();
          expectLinkTap(
              linkTapResults, const MarkdownLink('foo bar', '/url', 'title'));

          // Clear link tap results.
          linkTapResults = null;
        }
      },
    );

    testWidgets(
      // Example 563 from GFM.
      'collapsed reference links are case-insensitive',
      (WidgetTester tester) async {
        const String data = '[Foo][]\n\n[foo]: /url "title"';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('Foo');
        expectLinkTap(
            linkTapResults, const MarkdownLink('Foo', '/url', 'title'));
      },
    );

    testWidgets(
      // Example 564 from GFM.
      'collapsed reference link no whitespace between link text and link label',
      (WidgetTester tester) async {
        const String data = '[foo] \n\n[]\n\n[foo]: /url "title"';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        final List<RichText> textWidgets =
            tester.widgetList(find.byType(RichText)).toList().cast<RichText>();
        expect(textWidgets.length, 2);

        expect(textWidgets[0].text, isNotNull);
        expect(textWidgets[0].text, isA<TextSpan>());
        expect(textWidgets[0].text.toPlainText(), 'foo');

        expect(textWidgets[0].text, isNotNull);
        expect(textWidgets[0].text, isA<TextSpan>());
        expectLinkTextSpan(textWidgets[0].text as TextSpan, 'foo');
        expectLinkTap(
            linkTapResults, const MarkdownLink('foo', '/url', 'title'));

        expect(textWidgets[1].text, isNotNull);
        expect(textWidgets[1].text, isA<TextSpan>());
        expect(textWidgets[1].text.toPlainText(), '[]');
        expectTextSpanStyle(
            textWidgets[1].text as TextSpan, null, FontWeight.normal);
      },
    );

    testWidgets(
      // Example 565 from GFM.
      'shortcut reference link',
      (WidgetTester tester) async {
        const String data = '[foo]\n\n[foo]: /url "title"';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('foo');
        expectLinkTap(
            linkTapResults, const MarkdownLink('foo', '/url', 'title'));
      },
    );

    testWidgets(
      // Example 566 from GFM.
      'shortcut reference link with inline emphasis in link text',
      (WidgetTester tester) async {
        const String data = '[*foo* bar]\n\n[*foo* bar]: /url "title"';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        final RichText textWidget = tester.widget(find.byType(RichText));
        final TextSpan span = textWidget.text as TextSpan;
        expect(span.children!.length, 2);
        expect(span.children, everyElement(isA<TextSpan>()));

        expect(span.children![0].toPlainText(), 'foo');
        expectTextSpanStyle(
            span.children![0] as TextSpan, FontStyle.italic, FontWeight.normal);

        expect(span.children![1].toPlainText(), ' bar');
        expectTextSpanStyle(
            span.children![1] as TextSpan, null, FontWeight.normal);

        for (final InlineSpan element in span.children!) {
          final TextSpan textSpan = element as TextSpan;
          expect(textSpan.recognizer, isNotNull);
          expect(textSpan.recognizer, isA<TapGestureRecognizer>());
          final TapGestureRecognizer? tapRecognizer =
              textSpan.recognizer as TapGestureRecognizer?;
          expect(tapRecognizer?.onTap, isNotNull);

          tapRecognizer!.onTap!();
          expectLinkTap(
              linkTapResults, const MarkdownLink('foo bar', '/url', 'title'));

          // Clear link tap results.
          linkTapResults = null;
        }
      },
    );

    testWidgets(
      // Example 567 from GFM.
      'shortcut reference link with inline emphasis nested in link text',
      (WidgetTester tester) async {
        const String data = '[*foo* bar]\n\n[*foo* bar]: /url "title"';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        final RichText textWidget = tester.widget(find.byType(RichText));
        final TextSpan span = textWidget.text as TextSpan;
        expect(span.children!.length, 2);
        expect(span.children, everyElement(isA<TextSpan>()));

        expect(span.children![0].toPlainText(), 'foo');
        expectTextSpanStyle(
            span.children![0] as TextSpan, FontStyle.italic, FontWeight.normal);

        expect(span.children![1].toPlainText(), ' bar');
        expectTextSpanStyle(
            span.children![1] as TextSpan, null, FontWeight.normal);

        for (final InlineSpan element in span.children!) {
          final TextSpan textSpan = element as TextSpan;
          expect(textSpan.recognizer, isNotNull);
          expect(textSpan.recognizer, isA<TapGestureRecognizer>());
          final TapGestureRecognizer? tapRecognizer =
              textSpan.recognizer as TapGestureRecognizer?;
          expect(tapRecognizer?.onTap, isNotNull);

          tapRecognizer!.onTap!();
          expectLinkTap(
              linkTapResults, const MarkdownLink('foo bar', '/url', 'title'));

          // Clear link tap results.
          linkTapResults = null;
        }
      },
    );

    testWidgets(
      // Example 568 from GFM.
      'shortcut reference link with unbalanced open square brackets',
      (WidgetTester tester) async {
        const String data = '[[bar [foo]\n\n[foo]: /url';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        final RichText textWidget = tester.widget(find.byType(RichText));
        final TextSpan span = textWidget.text as TextSpan;
        expect(span.children!.length, 2);

        expect(span.children![0], isA<TextSpan>());
        expect(span.children![0].toPlainText(), '[[bar ');
        expectTextSpanStyle(
            span.children![0] as TextSpan, null, FontWeight.normal);

        expectLinkTextSpan(span.children![1] as TextSpan, 'foo');
        expectLinkTap(linkTapResults, const MarkdownLink('foo', '/url'));
      },
    );

    testWidgets(
      // Example 569 from GFM.
      'shortcut reference links are case-insensitive',
      (WidgetTester tester) async {
        const String data = '[Foo]\n\n[foo]: /url "title"';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('Foo');
        expectLinkTap(
            linkTapResults, const MarkdownLink('Foo', '/url', 'title'));
      },
    );

    testWidgets(
      // Example 570 from GFM.
      'shortcut reference link should preserve space after link text',
      (WidgetTester tester) async {
        const String data = '[foo] bar\n\n[foo]: /url';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        final RichText textWidget = tester.widget(find.byType(RichText));
        final TextSpan span = textWidget.text as TextSpan;
        expect(span.children!.length, 2);

        expectLinkTextSpan(span.children![0] as TextSpan, 'foo');
        expectLinkTap(linkTapResults, const MarkdownLink('foo', '/url'));

        expect(span.children![1], isA<TextSpan>());
        expect(span.children![1].toPlainText(), ' bar');
        expectTextSpanStyle(
            span.children![1] as TextSpan, null, FontWeight.normal);
      },
    );

    testWidgets(
      // Example 571 from GFM.
      'shortcut reference link backslash escape opening bracket to avoid link',
      (WidgetTester tester) async {
        const String data = '\\[foo]\n\n[foo]: /url "title"';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        // Link is treated as ordinary text.
        expectInvalidLink('[foo]');
        expect(linkTapResults, isNull);
      },
    );

    testWidgets(
      // Example 572 from GFM.
      'shortcut reference link text grouping has precedence over emphasis grouping',
      (WidgetTester tester) async {
        const String data = '[foo*]: /url\n\n*[foo*]';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        final RichText textWidget = tester.widget(find.byType(RichText));
        final TextSpan span = textWidget.text as TextSpan;
        expect(span.children!.length, 2);
        expect(span.children![0], isA<TextSpan>());
        expect(span.children![0].toPlainText(), '*');
        expectTextSpanStyle(
            span.children![0] as TextSpan, null, FontWeight.normal);

        expectLinkTextSpan(span.children![1] as TextSpan, 'foo*');
        expectLinkTap(linkTapResults, const MarkdownLink('foo*', '/url'));
      },
    );

    testWidgets(
      // Example 573 from GFM.
      'full link reference takes precedence over shortcut link reference',
      (WidgetTester tester) async {
        const String data = '[foo][bar]\n\n[foo]: /url1\n[bar]: /url2';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('foo');
        expectLinkTap(linkTapResults, const MarkdownLink('foo', '/url2'));
      },
    );

    testWidgets(
      // Example 574 from GFM.
      'compact link reference takes precedence over shortcut link reference',
      (WidgetTester tester) async {
        const String data = '[foo][]\n\n[foo]: /url1';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('foo');
        expectLinkTap(linkTapResults, const MarkdownLink('foo', '/url1'));
      },
    );

    testWidgets(
      // Example 575 from GFM.
      'inline link reference, no link destination takes precedence over shortcut link reference',
      (WidgetTester tester) async {
        const String data = '[foo]()\n\n[foo]: /url1';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        expectValidLink('foo');
        expectLinkTap(linkTapResults, const MarkdownLink('foo', ''));
      },
    );

    testWidgets(
      // Example 576 from GFM.
      'inline link reference, invalid link destination is a link followed by text',
      (WidgetTester tester) async {
        const String data = '[foo](not a link)\n\n[foo]: /url1';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        final RichText textWidget = tester.widget(find.byType(RichText));
        final TextSpan span = textWidget.text as TextSpan;
        expect(span.children!.length, 2);

        expectLinkTextSpan(span.children![0] as TextSpan, 'foo');
        expectLinkTap(linkTapResults, const MarkdownLink('foo', '/url1'));

        expect(span.children![1], isA<TextSpan>());
        expect(span.children![1].toPlainText(), '(not a link)');
        expectTextSpanStyle(
            span.children![1] as TextSpan, null, FontWeight.normal);
      },
    );

    testWidgets(
      // Example 577 from GFM.
      'three sequential runs of square-bracketed text, normal text and a link reference',
      (WidgetTester tester) async {
        const String data = '[foo][bar][baz]\n\n[baz]: /url';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        final RichText textWidget = tester.widget(find.byType(RichText));
        final TextSpan span = textWidget.text as TextSpan;
        expect(span.children!.length, 2);

        expect(span.children![0], isA<TextSpan>());
        expect(span.children![0].toPlainText(), '[foo]');
        expectTextSpanStyle(
            span.children![0] as TextSpan, null, FontWeight.normal);

        expectLinkTextSpan(span.children![1] as TextSpan, 'bar');
        expectLinkTap(linkTapResults, const MarkdownLink('bar', '/url'));
      },
    );

    testWidgets(
      // Example 578 from GFM.
      'three sequential runs of square-bracketed text, two link references',
      (WidgetTester tester) async {
        const String data = '[foo][bar][baz]\n\n[baz]: /url1\n[bar]: /url2';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        final RichText textWidget = tester.widget(find.byType(RichText));
        final TextSpan span = textWidget.text as TextSpan;
        expect(span.children!.length, 2);

        expectLinkTextSpan(span.children![0] as TextSpan, 'foo');
        expectLinkTap(linkTapResults, const MarkdownLink('foo', '/url2'));

        expectLinkTextSpan(span.children![1] as TextSpan, 'baz');
        expectLinkTap(linkTapResults, const MarkdownLink('baz', '/url1'));
      },
    );

    testWidgets(
      // Example 579 from GFM.
      'full reference link followed by a shortcut reference link',
      (WidgetTester tester) async {
        const String data = '[foo][bar][baz]\n\n[baz]: /url1\n[foo]: /url2';
        MarkdownLink? linkTapResults;
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(
              data: data,
              onTapLink: (String text, String? href, String title) =>
                  linkTapResults = MarkdownLink(text, href, title),
            ),
          ),
        );

        final RichText textWidget = tester.widget(find.byType(RichText));
        final TextSpan span = textWidget.text as TextSpan;
        expect(span.children!.length, 2);
        expect(span.children![0], isA<TextSpan>());
        expect(span.children![0].toPlainText(), '[foo]');

        expectLinkTextSpan(span.children![1] as TextSpan, 'bar');
        expectLinkTap(linkTapResults, const MarkdownLink('bar', '/url1'));
      },
    );
  });
}
