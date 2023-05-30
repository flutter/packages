// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;

import 'utils.dart';

void main() => defineTests();

void defineTests() {
  group('Custom Syntax', () {
    testWidgets(
      'Subscript',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          boilerplate(
            Markdown(
              data: 'H_2O',
              extensionSet: md.ExtensionSet.none,
              inlineSyntaxes: <md.InlineSyntax>[SubscriptSyntax()],
              builders: <String, MarkdownElementBuilder>{
                'sub': SubscriptBuilder(),
              },
            ),
          ),
        );

        final Iterable<Widget> widgets = tester.allWidgets;
        expectTextStrings(widgets, <String>['H₂O']);
      },
    );

    testWidgets(
      'link for wikistyle',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          boilerplate(
            Markdown(
              data: 'This is a [[wiki link]]',
              extensionSet: md.ExtensionSet.none,
              inlineSyntaxes: <md.InlineSyntax>[WikilinkSyntax()],
              builders: <String, MarkdownElementBuilder>{
                'wikilink': WikilinkBuilder(),
              },
            ),
          ),
        );

        final RichText textWidget = tester.widget(find.byType(RichText));
        final TextSpan span =
            (textWidget.text as TextSpan).children![1] as TextSpan;

        expect(span.children, null);
        expect(span.recognizer.runtimeType, equals(TapGestureRecognizer));
      },
    );

    testWidgets(
      'WidgetSpan in RichText is handled correctly',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          boilerplate(
            Markdown(
              data: 'container is a widget that allows to customize its child',
              extensionSet: md.ExtensionSet.none,
              inlineSyntaxes: <md.InlineSyntax>[ContainerSyntax()],
              builders: <String, MarkdownElementBuilder>{
                'container': ContainerBuilder(),
              },
            ),
          ),
        );

        final RichText textWidget = tester.widget(find.byType(RichText));
        final TextSpan span =
            (textWidget.text as TextSpan).children![0] as TextSpan;
        final WidgetSpan widgetSpan = span.children![0] as WidgetSpan;
        expect(widgetSpan.child, isInstanceOf<Container>());
      },
    );
  });

  testWidgets(
    'TextSpan and WidgetSpan as children in RichText are handled correctly',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        boilerplate(
          Markdown(
            data: 'this test replaces a string with a container',
            extensionSet: md.ExtensionSet.none,
            inlineSyntaxes: <md.InlineSyntax>[ContainerSyntax()],
            builders: <String, MarkdownElementBuilder>{
              'container': ContainerBuilder2(),
            },
          ),
        ),
      );

      final RichText textWidget = tester.widget(find.byType(RichText));
      final TextSpan textSpan = textWidget.text as TextSpan;
      final TextSpan start = textSpan.children![0] as TextSpan;
      expect(start.text, 'this test replaces a string with a ');
      final TextSpan end = textSpan.children![1] as TextSpan;
      final TextSpan foo = end.children![0] as TextSpan;
      expect(foo.text, 'foo');
      final WidgetSpan widgetSpan = end.children![1] as WidgetSpan;
      expect(widgetSpan.child, isInstanceOf<Container>());
    },
  );

  testWidgets(
    'Custom rendering of tags without children',
    (WidgetTester tester) async {
      const String data = '![alt](/assets/images/logo.png)';
      await tester.pumpWidget(
        boilerplate(
          Markdown(
            data: data,
            builders: <String, MarkdownElementBuilder>{
              'img': ImgBuilder(),
            },
          ),
        ),
      );

      final Finder imageFinder = find.byType(Image);
      expect(imageFinder, findsNothing);
      final Finder textFinder = find.byType(Text);
      expect(textFinder, findsOneWidget);
      final Text textWidget = tester.widget(find.byType(Text));
      expect(textWidget.data, 'foo');
    },
  );
}

class SubscriptSyntax extends md.InlineSyntax {
  SubscriptSyntax() : super(_pattern);

  static const String _pattern = r'_([0-9]+)';

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text('sub', match[1]!));
    return true;
  }
}

class SubscriptBuilder extends MarkdownElementBuilder {
  static const List<String> _subscripts = <String>[
    '₀',
    '₁',
    '₂',
    '₃',
    '₄',
    '₅',
    '₆',
    '₇',
    '₈',
    '₉'
  ];

  @override
  Widget visitElementAfter(md.Element element, _) {
    // We don't currently have a way to control the vertical alignment of text spans.
    // See https://github.com/flutter/flutter/issues/10906#issuecomment-385723664
    final String textContent = element.textContent;
    String text = '';
    for (int i = 0; i < textContent.length; i++) {
      text += _subscripts[int.parse(textContent[i])];
    }
    return RichText(text: TextSpan(text: text));
  }
}

class WikilinkSyntax extends md.InlineSyntax {
  WikilinkSyntax() : super(_pattern);

  static const String _pattern = r'\[\[(.*?)\]\]';

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final String link = match[1]!;
    final md.Element el =
        md.Element('wikilink', <md.Element>[md.Element.text('span', link)])
          ..attributes['href'] = link.replaceAll(' ', '_');

    parser.addNode(el);
    return true;
  }
}

class WikilinkBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, _) {
    return RichText(
      text: TextSpan(
          text: element.textContent,
          recognizer: TapGestureRecognizer()..onTap = () {}),
    );
  }
}

class ContainerSyntax extends md.InlineSyntax {
  ContainerSyntax() : super(_pattern);

  static const String _pattern = 'container';

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(
      md.Element.text('container', ''),
    );
    return true;
  }
}

class ContainerBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, _) {
    return RichText(
      text: TextSpan(
        children: <InlineSpan>[
          WidgetSpan(
            child: Container(),
          ),
        ],
      ),
    );
  }
}

class ContainerBuilder2 extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, _) {
    return RichText(
      text: TextSpan(
        children: <InlineSpan>[
          const TextSpan(text: 'foo'),
          WidgetSpan(
            child: Container(),
          ),
        ],
      ),
    );
  }
}

class ImgBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Text('foo', style: preferredStyle);
  }
}
