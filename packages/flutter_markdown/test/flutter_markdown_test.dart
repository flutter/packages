// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_markdown/src/style_sheet.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  TextTheme materialTextTheme =
      Typography(platform: TargetPlatform.android).black.merge(TextTheme(body1: TextStyle(fontSize: 12.0)));
  CupertinoTextThemeData cupertinoTextTheme = CupertinoTextThemeData(
    textStyle: TextStyle(
      fontFamily: '.SF Pro Text',
      fontSize: 17.0,
      letterSpacing: -0.41,
    ),
  );

  testWidgets('Simple string', (WidgetTester tester) async {
    await tester.pumpWidget(_boilerplate(const MarkdownBody(data: 'Hello')));

    final Iterable<Widget> widgets = tester.allWidgets;
    _expectWidgetTypes(widgets, <Type>[Directionality, MarkdownBody, Column, Wrap, RichText]);
    _expectTextStrings(widgets, <String>['Hello']);
  });

  testWidgets('Header', (WidgetTester tester) async {
    await tester.pumpWidget(_boilerplate(const MarkdownBody(data: '# Header')));

    final Iterable<Widget> widgets = tester.allWidgets;
    _expectWidgetTypes(widgets, <Type>[Directionality, MarkdownBody, Column, Wrap, RichText]);
    _expectTextStrings(widgets, <String>['Header']);
  });

  testWidgets('Strikethrough', (WidgetTester tester) async {
    await tester.pumpWidget(_boilerplate(const MarkdownBody(data: '~~strikethrough~~')));

    final Iterable<Widget> widgets = tester.allWidgets;
    _expectWidgetTypes(
        widgets, <Type>[Directionality, MarkdownBody, Column, Wrap, RichText]);
    _expectTextStrings(widgets, <String>['strikethrough']);
  });

  testWidgets('Line break', (WidgetTester tester) async {
    await tester.pumpWidget(_boilerplate(const MarkdownBody(data: 'line 1  \nline 2')));

    final Iterable<Widget> widgets = tester.allWidgets;
    _expectWidgetTypes(
        widgets, <Type>[Directionality, MarkdownBody, Column, Wrap, RichText]);
    _expectTextStrings(widgets, <String>['line 1\nline 2']);
  });

  testWidgets('Empty string', (WidgetTester tester) async {
    await tester.pumpWidget(_boilerplate(const MarkdownBody(data: '')));

    final Iterable<Widget> widgets = tester.allWidgets;
    _expectWidgetTypes(widgets, <Type>[Directionality, MarkdownBody, Column]);
  });

  testWidgets('Ordered list', (WidgetTester tester) async {
    await tester.pumpWidget(_boilerplate(
      const MarkdownBody(data: '1. Item 1\n1. Item 2\n2. Item 3'),
    ));

    final Iterable<Widget> widgets = tester.allWidgets;
    _expectTextStrings(widgets, <String>[
      '1.',
      'Item 1',
      '2.',
      'Item 2',
      '3.',
      'Item 3',
    ]);
  });

  testWidgets('Unordered list', (WidgetTester tester) async {
    await tester.pumpWidget(
      _boilerplate(const MarkdownBody(data: '- Item 1\n- Item 2\n- Item 3')),
    );

    final Iterable<Widget> widgets = tester.allWidgets;
    _expectTextStrings(widgets, <String>[
      '•',
      'Item 1',
      '•',
      'Item 2',
      '•',
      'Item 3',
    ]);
  });

  testWidgets('Empty List Item', (WidgetTester tester) async {
    await tester.pumpWidget(
      _boilerplate(const MarkdownBody(data: '- \n- Item 2\n- Item 3')),
    );

    final Iterable<Widget> widgets = tester.allWidgets;
    _expectTextStrings(widgets, <String>[
      '•',
      '•',
      'Item 2',
      '•',
      'Item 3',
    ]);
  });

  testWidgets('Task list', (WidgetTester tester) async {
    await tester.pumpWidget(
      _boilerplate(const MarkdownBody(data: '- [x] Item 1\n- [ ] Item 2')),
    );

    final Iterable<Widget> widgets = tester.allWidgets;

    _expectTextStrings(widgets, <String>[
      String.fromCharCode(Icons.check_box.codePoint),
      'Item 1',
      String.fromCharCode(Icons.check_box_outline_blank.codePoint),
      'Item 2',
    ]);
  });

  testWidgets('Horizontal Rule', (WidgetTester tester) async {
    await tester.pumpWidget(_boilerplate(const MarkdownBody(data: '-----')));

    final Iterable<Widget> widgets = tester.allWidgets;
    _expectWidgetTypes(widgets, <Type>[Directionality, MarkdownBody, DecoratedBox, SizedBox]);
  });

  testWidgets('Scrollable wrapping', (WidgetTester tester) async {
    await tester.pumpWidget(_boilerplate(const Markdown(data: '')));

    final List<Widget> widgets = tester.allWidgets.toList();
    _expectWidgetTypes(widgets.take(3), <Type>[
      Directionality,
      Markdown,
      ListView,
    ]);
    _expectWidgetTypes(widgets.reversed.take(2).toList().reversed, <Type>[
      SliverPadding,
      SliverList,
    ]);
  });

  group('Links', () {
    testWidgets('should be tappable', (WidgetTester tester) async {
      String tapResult;
      await tester.pumpWidget(_boilerplate(Markdown(
        data: '[Link Text](href)',
        onTapLink: (value) => tapResult = value,
      )));

      final RichText textWidget = tester.allWidgets.firstWhere((Widget widget) => widget is RichText);
      final TextSpan span = textWidget.text;

      (span.recognizer as TapGestureRecognizer).onTap();

      expect(span.children, null);
      expect(span.recognizer.runtimeType, equals(TapGestureRecognizer));
      expect(tapResult, 'href');
    });

    testWidgets('should work with nested elements', (WidgetTester tester) async {
      final List<String> tapResults = <String>[];
      await tester.pumpWidget(_boilerplate(Markdown(
        data: '[Link `with nested code` Text](href)',
        onTapLink: (value) => tapResults.add(value),
      )));

      final RichText textWidget = tester.allWidgets.firstWhere((Widget widget) => widget is RichText);
      final TextSpan span = textWidget.text;

      final List<Type> gestureRecognizerTypes = <Type>[];
      span.visitChildren((InlineSpan inlineSpan) {
        if (inlineSpan is TextSpan) {
          TapGestureRecognizer recognizer = inlineSpan.recognizer;
          gestureRecognizerTypes.add(recognizer.runtimeType);
          recognizer.onTap();
        }
        return true;
      });

      expect(span.children.length, 3);
      expect(gestureRecognizerTypes.length, 3);
      expect(gestureRecognizerTypes, everyElement(TapGestureRecognizer));
      expect(tapResults.length, 3);
      expect(tapResults, everyElement('href'));
    });

    testWidgets('should work next to other links', (WidgetTester tester) async {
      final List<String> tapResults = <String>[];

      await tester.pumpWidget(_boilerplate(Markdown(
        data: '[First Link](firstHref) and [Second Link](secondHref)',
        onTapLink: (value) => tapResults.add(value),
      )));

      final RichText textWidget = tester.allWidgets.firstWhere((Widget widget) => widget is RichText);
      final TextSpan span = textWidget.text;

      final List<Type> gestureRecognizerTypes = <Type>[];
      span.visitChildren((InlineSpan inlineSpan) {
        if (inlineSpan is TextSpan) {
          TapGestureRecognizer recognizer = inlineSpan.recognizer;
          gestureRecognizerTypes.add(recognizer.runtimeType);
          recognizer?.onTap();
        }
        return true;
      });

      expect(span.children.length, 3);
      expect(gestureRecognizerTypes, orderedEquals([TapGestureRecognizer, Null, TapGestureRecognizer]));
      expect(tapResults, orderedEquals(['firstHref', 'secondHref']));
    });
  });

  group('Images', () {
    setUp(() {
      // Only needs to be done once since the HttpClient generated by this
      // override is cached as a static singleton.
      io.HttpOverrides.global = TestHttpOverrides();
    });

    testWidgets('should not interrupt styling', (WidgetTester tester) async {
      await tester.pumpWidget(_boilerplate(const Markdown(
        data: '_textbefore ![alt](http://img) textafter_',
      )));

      final RichText firstTextWidget =
          tester.allWidgets.firstWhere((Widget widget) => widget is RichText);
      final TextSpan firstTextSpan = firstTextWidget.text;
      final Image image =
          tester.allWidgets.firstWhere((Widget widget) => widget is Image);
      final NetworkImage networkImage = image.image;
      final RichText secondTextWidget =
          tester.allWidgets.lastWhere((Widget widget) => widget is RichText);
      final TextSpan secondTextSpan = secondTextWidget.text;

      expect(firstTextSpan.text, 'textbefore ');
      expect(firstTextSpan.style.fontStyle, FontStyle.italic);
      expect(networkImage.url,'http://img');
      expect(secondTextSpan.text, ' textafter');
      expect(secondTextSpan.style.fontStyle, FontStyle.italic);
    });

    testWidgets('should work with a link', (WidgetTester tester) async {
      await tester.pumpWidget(_boilerplate(const Markdown(data: '![alt](https://img#50x50)')));

      final Image image = tester.allWidgets.firstWhere((Widget widget) => widget is Image);
      final NetworkImage networkImage = image.image;
      expect(networkImage.url, 'https://img');
      expect(image.width, 50);
      expect(image.height, 50);
    });

    testWidgets('should not escape ampersands in links',
        (WidgetTester tester) async {
      await tester.pumpWidget(_boilerplate(const Markdown(
          data:
              '![alt](https://preview.redd.it/sg3q5cuedod31.jpg?width=640&crop=smart&auto=webp&s=497e6295e0c0fc2ce7df5a324fe1acd7b5a5264f)')));

      final Image image =
          tester.allWidgets.firstWhere((Widget widget) => widget is Image);
      final NetworkImage networkImage = image.image;
      expect(networkImage.url, 'https://preview.redd.it/sg3q5cuedod31.jpg?width=640&crop=smart&auto=webp&s=497e6295e0c0fc2ce7df5a324fe1acd7b5a5264f');
    });

    testWidgets('local files should be files', (WidgetTester tester) async {
      await tester.pumpWidget(_boilerplate(const Markdown(data: '![alt](http.png)')));

      final Image image = tester.allWidgets.firstWhere((Widget widget) => widget is Image);
      expect(image.image is FileImage, isTrue);
    });

    testWidgets('should work with resources', (WidgetTester tester) async {
      await tester.pumpWidget(_boilerplate(const Markdown(data: '![alt](resource:assets/logo.png)')));

      final Image image = tester.allWidgets.firstWhere((Widget widget) => widget is Image);
      expect(image.image is AssetImage, isTrue);
      expect((image.image as AssetImage).assetName == 'assets/logo.png', isTrue);
    });

    testWidgets('should work with local image files', (WidgetTester tester) async {
      await tester.pumpWidget(_boilerplate(const Markdown(data: '![alt](img.png#50x50)')));

      final Image image = tester.allWidgets.firstWhere((Widget widget) => widget is Image);
      final FileImage fileImage = image.image;
      expect(fileImage.file.path, 'img.png');
      expect(image.width, 50);
      expect(image.height, 50);
    });

    testWidgets('should show properly next to text', (WidgetTester tester) async {
      await tester.pumpWidget(_boilerplate(const Markdown(data: 'Hello ![alt](img#50x50)')));

      final RichText richText = tester.allWidgets.firstWhere((Widget widget) => widget is RichText);
      TextSpan textSpan = richText.text;
      expect(textSpan.text, 'Hello ');
      expect(textSpan.style, isNotNull);
    });

    testWidgets('should work when nested in a link', (WidgetTester tester) async {
      final List<String> tapResults = <String>[];
      await tester.pumpWidget(_boilerplate(Markdown(
        data: '[![alt](https://img#50x50)](href)',
        onTapLink: (value) => tapResults.add(value),
      )));

      final GestureDetector detector = tester.allWidgets.firstWhere((Widget widget) => widget is GestureDetector);

      detector.onTap();

      expect(tapResults.length, 1);
      expect(tapResults, everyElement('href'));
    });

    testWidgets('should work when nested in a link with text', (WidgetTester tester) async {
      final List<String> tapResults = <String>[];
      await tester.pumpWidget(_boilerplate(Markdown(
        data: '[Text before ![alt](https://img#50x50) text after](href)',
        onTapLink: (value) => tapResults.add(value),
      )));

      final GestureDetector detector = tester.allWidgets.firstWhere((Widget widget) => widget is GestureDetector);
      detector.onTap();

      final RichText firstTextWidget = tester.allWidgets.firstWhere((Widget widget) => widget is RichText);
      final TextSpan firstSpan = firstTextWidget.text;
      (firstSpan.recognizer as TapGestureRecognizer).onTap();

      final RichText lastTextWidget = tester.allWidgets.lastWhere((Widget widget) => widget is RichText);
      final TextSpan lastSpan = lastTextWidget.text;
      (lastSpan.recognizer as TapGestureRecognizer).onTap();

      expect(firstSpan.children, null);
      expect(firstSpan.text, 'Text before ');
      expect(firstSpan.recognizer.runtimeType, equals(TapGestureRecognizer));

      expect(lastSpan.children, null);
      expect(lastSpan.text, ' text after');
      expect(lastSpan.recognizer.runtimeType, equals(TapGestureRecognizer));

      expect(tapResults.length, 3);
      expect(tapResults, everyElement('href'));
    });

    testWidgets('should work alongside different links', (WidgetTester tester) async {
      final List<String> tapResults = <String>[];
      await tester.pumpWidget(_boilerplate(Markdown(
        data: '[Link before](firstHref)[![alt](https://img#50x50)](imageHref)[link after](secondHref)',
        onTapLink: (value) => tapResults.add(value),
      )));

      final RichText firstTextWidget = tester.allWidgets.firstWhere((Widget widget) => widget is RichText);
      final TextSpan firstSpan = firstTextWidget.text;
      (firstSpan.recognizer as TapGestureRecognizer).onTap();

      final GestureDetector detector = tester.allWidgets.firstWhere((Widget widget) => widget is GestureDetector);
      detector.onTap();

      final RichText lastTextWidget = tester.allWidgets.lastWhere((Widget widget) => widget is RichText);
      final TextSpan lastSpan = lastTextWidget.text;
      (lastSpan.recognizer as TapGestureRecognizer).onTap();

      expect(firstSpan.children, null);
      expect(firstSpan.text, 'Link before');
      expect(firstSpan.recognizer.runtimeType, equals(TapGestureRecognizer));

      expect(lastSpan.children, null);
      expect(lastSpan.text, 'link after');
      expect(lastSpan.recognizer.runtimeType, equals(TapGestureRecognizer));

      expect(tapResults.length, 3);
      expect(tapResults, ['firstHref', 'imageHref', 'secondHref']);
    });
  });

  group('Tables', () {
    testWidgets('should show properly', (WidgetTester tester) async {
      const String data = '|Header 1|Header 2|\n|-----|-----|\n|Col 1|Col 2|';
      await tester.pumpWidget(_boilerplate(const MarkdownBody(data: data)));

      final Iterable<Widget> widgets = tester.allWidgets;
      _expectTextStrings(
          widgets, <String>['Header 1', 'Header 2', 'Col 1', 'Col 2']);
    });

    testWidgets('work without the outer pipes', (WidgetTester tester) async {
      const String data = 'Header 1|Header 2\n-----|-----\nCol 1|Col 2';
      await tester.pumpWidget(_boilerplate(const MarkdownBody(data: data)));

      final Iterable<Widget> widgets = tester.allWidgets;
      _expectTextStrings(
          widgets, <String>['Header 1', 'Header 2', 'Col 1', 'Col 2']);
    });

    testWidgets('should work with alignments', (WidgetTester tester) async {
      const String data = '|Header 1|Header 2|\n|:----:|----:|\n|Col 1|Col 2|';
      await tester.pumpWidget(_boilerplate(const MarkdownBody(data: data)));

      final Iterable<Widget> widgets = tester.allWidgets;
      final DefaultTextStyle style = widgets.firstWhere((Widget widget) => widget is DefaultTextStyle);
      final DefaultTextStyle style2 = widgets.lastWhere((Widget widget) => widget is DefaultTextStyle);

      expect(style.textAlign, TextAlign.center);
      expect(style2.textAlign, TextAlign.right);
    });

    testWidgets('should work with styling', (WidgetTester tester) async {
      const String data = '|Header|\n|----|\n|*italic*|';
      await tester.pumpWidget(_boilerplate(MarkdownBody(data: data)));

      final Iterable<Widget> widgets = tester.allWidgets;
      final RichText richText = widgets.lastWhere((Widget widget) => widget is RichText);

      _expectTextStrings(widgets, <String>['Header', 'italic']);
      expect(richText.text.style.fontStyle, FontStyle.italic);
    });

    testWidgets('should work next to other tables', (WidgetTester tester) async {
      const String data = '|first header|\n|----|\n|first col|\n\n'
          '|second header|\n|----|\n|second col|';
      await tester.pumpWidget(_boilerplate(const MarkdownBody(data: data)));

      final Iterable<Widget> tables = tester.allWidgets.where((Widget widget) => widget is Table);

      expect(tables.length, 2);
    });

    testWidgets('column width should follow stylesheet', (WidgetTester tester) async {
      final ThemeData theme = ThemeData.light().copyWith(textTheme: materialTextTheme);

      const String data = '|Header|\n|----|\n|Column|';
      const FixedColumnWidth columnWidth = FixedColumnWidth(100);
      final MarkdownStyleSheet style = MarkdownStyleSheet.fromTheme(theme)
          .copyWith(tableColumnWidth: columnWidth);

      await tester.pumpWidget(_boilerplate(MarkdownBody(data: data, styleSheet: style)));

      final Table table = tester.widget(find.byType(Table));

      expect(table.defaultColumnWidth, columnWidth);
    });
  });

  group('uri data scheme', () {
    testWidgets('should work with image in uri data scheme', (WidgetTester tester) async {
      const String imageData = '![alt](data:image/gif;base64,R0lGODlhAQABAIAAAAUEBAAAACwAAAAAAQABAAACAkQBADs=)';
      await tester.pumpWidget(_boilerplate(const Markdown(data: imageData)));

      final Image image = tester.allWidgets.firstWhere((Widget widget) => widget is Image);
      expect(image.image.runtimeType, MemoryImage);
    });

    testWidgets('should work with base64 text in uri data scheme', (WidgetTester tester) async {
      const String imageData = '![alt](data:text/plan;base64,Rmx1dHRlcg==)';
      await tester.pumpWidget(_boilerplate(const Markdown(data: imageData)));

      final Text widget = tester.allWidgets.firstWhere((Widget widget) => widget is Text);
      expect(widget.runtimeType, Text);
      expect(widget.data, 'Flutter');
    });

    testWidgets('should work with text in uri data scheme', (WidgetTester tester) async {
      const String imageData = '![alt](data:text/plan,Hello%2C%20Flutter)';
      await tester.pumpWidget(_boilerplate(const Markdown(data: imageData)));

      final Text widget = tester.allWidgets.firstWhere((Widget widget) => widget is Text);
      expect(widget.runtimeType, Text);
      expect(widget.data, 'Hello, Flutter');
    });

    testWidgets('should work with empty uri data scheme', (WidgetTester tester) async {
      const String imageData = '![alt](data:,)';
      await tester.pumpWidget(_boilerplate(const Markdown(data: imageData)));

      final Text widget = tester.allWidgets.firstWhere((Widget widget) => widget is Text);
      expect(widget.runtimeType, Text);
      expect(widget.data, '');
    });

    testWidgets('should work with unsupported mime types of uri data scheme', (WidgetTester tester) async {
      const String imageData = '![alt](data:application/javascript,var%20test=1)';
      await tester.pumpWidget(_boilerplate(const Markdown(data: imageData)));

      final SizedBox widget = tester.allWidgets.firstWhere((Widget widget) => widget is SizedBox);
      expect(widget.runtimeType, SizedBox);
    });
  });

  testWidgets('HTML tag ignored ', (WidgetTester tester) async {
    final List<String> mdData = <String>[
      'Line 1\n<p>HTML content</p>\nLine 2',
      'Line 1\n<!-- HTML\n comment\n ignored --><\nLine 2'
    ];

    for (String mdLine in mdData) {
      await tester.pumpWidget(_boilerplate(MarkdownBody(data: mdLine)));

      final Iterable<Widget> widgets = tester.allWidgets;
      _expectTextStrings(widgets, <String>['Line 1', 'Line 2']);
    }
  });

  group('Parser does not convert', () {
    testWidgets('& to &amp; when parsing', (WidgetTester tester) async {
      await tester.pumpWidget(_boilerplate(const Markdown(data: '&')));
      _expectTextStrings(tester.allWidgets, <String>['&']);
    });

    testWidgets('< to &lt; when parsing', (WidgetTester tester) async {
      await tester.pumpWidget(_boilerplate(const Markdown(data: '<')));
      _expectTextStrings(tester.allWidgets, <String>['<']);
    });

    testWidgets('existing HTML entities when parsing', (WidgetTester tester) async {
      await tester.pumpWidget(_boilerplate(const Markdown(data: '&amp; &copy; &#60; &#x0007B;')));
      _expectTextStrings(tester.allWidgets, <String>['&amp; &copy; &#60; &#x0007B;']);
    });
  });

  testWidgets('Changing config - data', (WidgetTester tester) async {
    // extract to variable; if run with --track-widget-creation using const
    // widgets aren't necessarily identical if created on different lines.
    final markdown = const Markdown(data: 'Data1');

    await tester.pumpWidget(_boilerplate(markdown));
    _expectTextStrings(tester.allWidgets, <String>['Data1']);

    final String stateBefore = _dumpRenderView();
    await tester.pumpWidget(_boilerplate(markdown));
    final String stateAfter = _dumpRenderView();
    expect(stateBefore, equals(stateAfter));

    await tester.pumpWidget(_boilerplate(const Markdown(data: 'Data2')));
    _expectTextStrings(tester.allWidgets, <String>['Data2']);
  });

  testWidgets('Changing config - style', (WidgetTester tester) async {
    final ThemeData theme = ThemeData.light().copyWith(textTheme: materialTextTheme);

    final MarkdownStyleSheet style1 = MarkdownStyleSheet.fromTheme(theme);
    final MarkdownStyleSheet style2 = MarkdownStyleSheet.largeFromTheme(theme);
    expect(style1, isNot(style2));

    await tester.pumpWidget(
      _boilerplate(Markdown(data: '# Test', styleSheet: style1)),
    );
    final RichText text1 = tester.widget(find.byType(RichText));
    await tester.pumpWidget(
      _boilerplate(Markdown(data: '# Test', styleSheet: style2)),
    );
    final RichText text2 = tester.widget(find.byType(RichText));

    expect(text1.text, isNot(text2.text));
  });

  testWidgets('Changing config - imageBuilder', (WidgetTester tester) async {
    final String data = '![alt](https://img.png)';
    final MarkdownImageBuilder builder = (_) => Image.asset('assets/logo.png');

    await tester.pumpWidget(_boilerplate(Markdown(data: data, imageBuilder: builder)));

    final Image image = tester.widget(find.byType(Image));

    expect(image.image.runtimeType, AssetImage);
    expect((image.image as AssetImage).assetName, 'assets/logo.png');
  });

  testWidgets('Style equality', (WidgetTester tester) async {
    final ThemeData theme = ThemeData.light().copyWith(textTheme: materialTextTheme);

    final MarkdownStyleSheet style1 = MarkdownStyleSheet.fromTheme(theme);
    final MarkdownStyleSheet style2 = MarkdownStyleSheet.fromTheme(theme);
    expect(style1, equals(style2));
    expect(style1.hashCode, equals(style2.hashCode));
  });

  testWidgets('Cupertino style equality', (WidgetTester tester) async {
    final CupertinoThemeData theme =
        CupertinoThemeData(brightness: Brightness.light).copyWith(textTheme: cupertinoTextTheme);

    final MarkdownStyleSheet style1 = MarkdownStyleSheet.fromCupertinoTheme(theme);
    final MarkdownStyleSheet style2 = MarkdownStyleSheet.fromCupertinoTheme(theme);
    expect(style1, equals(style2));
    expect(style1.hashCode, equals(style2.hashCode));
  });

  testWidgets('Cupertino brightness change', (WidgetTester tester) async {
    final CupertinoThemeData lightTheme =
        CupertinoThemeData(brightness: Brightness.light).copyWith(textTheme: cupertinoTextTheme);
    final CupertinoThemeData darkTheme =
        CupertinoThemeData(brightness: Brightness.dark).copyWith(textTheme: cupertinoTextTheme);

    final MarkdownStyleSheet lightStyle1 = MarkdownStyleSheet.fromCupertinoTheme(lightTheme);
    final MarkdownStyleSheet lightStyle2 = MarkdownStyleSheet.fromCupertinoTheme(lightTheme);

    final MarkdownStyleSheet darkStyle1 = MarkdownStyleSheet.fromCupertinoTheme(darkTheme);
    final MarkdownStyleSheet darkStyle2 = MarkdownStyleSheet.fromCupertinoTheme(darkTheme);

    expect(lightStyle1, equals(lightStyle2));
    expect(lightStyle1.hashCode, equals(lightStyle2.hashCode));

    expect(darkStyle1, equals(darkStyle2));
    expect(darkStyle1.hashCode, equals(darkStyle2.hashCode));

    expect(lightStyle1, isNot(darkStyle1));
  });

  testWidgets('should use style textScaleFactor in RichText', (WidgetTester tester) async {
    await tester.pumpWidget(_boilerplate(
      MarkdownBody(
        styleSheet: MarkdownStyleSheet(textScaleFactor: 2.0),
        data: 'Hello',
      ),
    ));

    final RichText richText = tester.allWidgets.firstWhere((Widget widget) => widget is RichText);
    expect(richText.textScaleFactor, 2.0);
  });
}

void _expectWidgetTypes(Iterable<Widget> widgets, List<Type> expected) {
  final List<Type> actual = widgets.map((Widget w) => w.runtimeType).toList();
  expect(actual, expected);
}

void _expectTextStrings(Iterable<Widget> widgets, List<String> strings) {
  int currentString = 0;
  for (Widget widget in widgets) {
    if (widget is RichText) {
      final TextSpan span = widget.text;
      final String text = _extractTextFromTextSpan(span);
      expect(text, equals(strings[currentString]));
      currentString += 1;
    }
  }
}

String _extractTextFromTextSpan(TextSpan span) {
  String text = span.text ?? '';
  if (span.children != null) {
    for (TextSpan child in span.children) {
      text += _extractTextFromTextSpan(child);
    }
  }
  return text;
}

String _dumpRenderView() {
  return WidgetsBinding.instance.renderViewElement
      .toStringDeep()
      .replaceAll(RegExp(r'SliverChildListDelegate#\d+', multiLine: true), 'SliverChildListDelegate');
}

/// Wraps a widget with a left-to-right [Directionality] for tests.
Widget _boilerplate(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: child,
  );
}

class MockHttpClient extends Mock implements io.HttpClient {}

class MockHttpClientRequest extends Mock implements io.HttpClientRequest {}

class MockHttpClientResponse extends Mock implements io.HttpClientResponse {}

class MockHttpHeaders extends Mock implements io.HttpHeaders {}

class TestHttpOverrides extends io.HttpOverrides {
  io.HttpClient createHttpClient(io.SecurityContext context) {
    return createMockImageHttpClient(context);
  }
}

// Returns a mock HTTP client that responds with an image to all requests.
MockHttpClient createMockImageHttpClient(io.SecurityContext _) {
  final MockHttpClient client = MockHttpClient();
  final MockHttpClientRequest request = MockHttpClientRequest();
  final MockHttpClientResponse response = MockHttpClientResponse();
  final MockHttpHeaders headers = MockHttpHeaders();

  when(client.getUrl(any)).thenAnswer((_) => Future<io.HttpClientRequest>.value(request));
  when(request.headers).thenReturn(headers);
  when(request.close()).thenAnswer((_) => Future<io.HttpClientResponse>.value(response));
  when(response.contentLength).thenReturn(_transparentImage.length);
  when(response.statusCode).thenReturn(io.HttpStatus.ok);
  when(response.listen(any)).thenAnswer((Invocation invocation) {
    final void Function(List<int>) onData = invocation.positionalArguments[0];
    final void Function() onDone = invocation.namedArguments[#onDone];
    final void Function(Object, [StackTrace]) onError = invocation.namedArguments[#onError];
    final bool cancelOnError = invocation.namedArguments[#cancelOnError];

    return Stream<List<int>>.fromIterable(<List<int>>[_transparentImage])
        .listen(onData, onDone: onDone, onError: onError, cancelOnError: cancelOnError);
  });

  return client;
}

const List<int> _transparentImage = const <int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
];
