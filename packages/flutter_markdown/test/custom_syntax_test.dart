// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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

        final Text textWidget = tester.widget(find.byType(Text));
        final TextSpan span =
            (textWidget.textSpan! as TextSpan).children![1] as TextSpan;

        expect(span.children, null);
        expect(span.recognizer.runtimeType, equals(TapGestureRecognizer));
      },
    );

    testWidgets(
      'WidgetSpan in Text.rich is handled correctly',
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

        final Text textWidget = tester.widget(find.byType(Text));
        final TextSpan textSpan = textWidget.textSpan! as TextSpan;
        final WidgetSpan widgetSpan = textSpan.children![0] as WidgetSpan;
        expect(widgetSpan.child, isInstanceOf<Container>());
      },
    );

    testWidgets(
      'visitElementAfterWithContext is handled correctly',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          boilerplate(
            Markdown(
              data: r'# This is a header with some \color1{color} in it',
              extensionSet: md.ExtensionSet.none,
              inlineSyntaxes: <md.InlineSyntax>[InlineTextColorSyntax()],
              builders: <String, MarkdownElementBuilder>{
                'inlineTextColor': InlineTextColorElementBuilder(),
              },
            ),
          ),
        );

        final Text textWidget = tester.widget(find.byType(Text));
        final TextSpan rootSpan = textWidget.textSpan! as TextSpan;
        final TextSpan firstSpan = rootSpan.children![0] as TextSpan;
        final TextSpan secondSpan = rootSpan.children![1] as TextSpan;
        final TextSpan thirdSpan = rootSpan.children![2] as TextSpan;

        expect(secondSpan.style!.color, Colors.red);
        expect(secondSpan.style!.fontSize, firstSpan.style!.fontSize);
        expect(secondSpan.style!.fontSize, thirdSpan.style!.fontSize);
      },
    );
  });

  testWidgets(
    'TextSpan and WidgetSpan as children in Text.rich are handled correctly',
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

      final Text textWidget = tester.widget(find.byType(Text));
      final TextSpan textSpan = textWidget.textSpan! as TextSpan;
      final TextSpan start = textSpan.children![0] as TextSpan;
      expect(start.text, 'this test replaces a string with a ');
      final TextSpan foo = textSpan.children![1] as TextSpan;
      expect(foo.text, 'foo');
      final WidgetSpan widgetSpan = textSpan.children![2] as WidgetSpan;
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
    return Text.rich(TextSpan(text: text));
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
    return Text.rich(TextSpan(
        text: element.textContent,
        recognizer: TapGestureRecognizer()..onTap = () {}));
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
    return Text.rich(
      TextSpan(
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
    return Text.rich(
      TextSpan(
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

// Note: The implementation of inline span is incomplete, it does not handle
// bold, italic, ... text with a colored block.
// This would not work: `\color1{Text with *bold* text}`
class InlineTextColorSyntax extends md.InlineSyntax {
  InlineTextColorSyntax() : super(r'\\color([1-9]){(.*?)}');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final String colorId = match.group(1)!;
    final String textContent = match.group(2)!;
    final md.Element node = md.Element.text(
      'inlineTextColor',
      textContent,
    )..attributes['color'] = colorId;

    parser.addNode(node);

    parser.addNode(
      md.Text(''),
    );
    return true;
  }
}

class InlineTextColorElementBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final String innerText = element.textContent;
    final String color = element.attributes['color'] ?? '';

    final Map<String, Color> contentColors = <String, Color>{
      '1': Colors.red,
      '2': Colors.green,
      '3': Colors.blue,
    };
    final Color? contentColor = contentColors[color];

    return Text.rich(
      TextSpan(
        text: innerText,
        style: parentStyle?.copyWith(color: contentColor),
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
