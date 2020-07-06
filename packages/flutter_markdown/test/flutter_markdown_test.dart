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
import 'package:markdown/markdown.dart' as md;
import 'package:mockito/mockito.dart';

void main() {
  final TextTheme textTheme =
      Typography.material2018(platform: TargetPlatform.android)
          .black
          .merge(TextTheme(bodyText2: TextStyle(fontSize: 12.0)));

  testWidgets('Simple string', (WidgetTester tester) async {
    await tester.pumpWidget(_boilerplate(const MarkdownBody(data: 'Hello')));

    final Iterable<Widget> widgets = tester.allWidgets;
    _expectWidgetTypes(
        widgets, <Type>[Directionality, MarkdownBody, Column, Wrap, RichText]);
    _expectTextStrings(widgets, <String>['Hello']);
  });

  testWidgets('Header', (WidgetTester tester) async {
    await tester.pumpWidget(_boilerplate(const MarkdownBody(data: '# Header')));

    final Iterable<Widget> widgets = tester.allWidgets;
    _expectWidgetTypes(
        widgets, <Type>[Directionality, MarkdownBody, Column, Wrap, RichText]);
    _expectTextStrings(widgets, <String>['Header']);
  });

  testWidgets('Blockquote', (WidgetTester tester) async {
    await tester.pumpWidget(_boilerplate(const MarkdownBody(data: '> quote')));

    final Iterable<Widget> widgets = tester.allWidgets;
    _expectTextStrings(widgets, <String>['quote']);
  });

  testWidgets('Scrollable code block', (WidgetTester tester) async {
    const String data =
        '```\nvoid main() {\n  print(\'Hello World!\');\n}\n```';

    await tester.pumpWidget(_boilerplate(MediaQuery(
      data: MediaQueryData(),
      child: const MarkdownBody(data: data),
    )));

    final Iterable<Widget> widgets = tester.allWidgets;
    expect(widgets.where((Widget widget) => widget is SingleChildScrollView),
        isNotEmpty);
  });

  testWidgets('Strikethrough', (WidgetTester tester) async {
    await tester.pumpWidget(
        _boilerplate(const MarkdownBody(data: '~~strikethrough~~')));

    final Iterable<Widget> widgets = tester.allWidgets;
    _expectWidgetTypes(
        widgets, <Type>[Directionality, MarkdownBody, Column, Wrap, RichText]);
    _expectTextStrings(widgets, <String>['strikethrough']);
  });

  testWidgets('Single line break', (WidgetTester tester) async {
    await tester
        .pumpWidget(_boilerplate(const MarkdownBody(data: 'line 1  \nline 2')));

    final Iterable<Widget> widgets = tester.allWidgets;
    _expectWidgetTypes(
        widgets, <Type>[Directionality, MarkdownBody, Column, Wrap, RichText]);
    _expectTextStrings(widgets, <String>['line 1\nline 2']);
  });

  testWidgets('Multiple line breaks', (WidgetTester tester) async {
    await tester.pumpWidget(
        _boilerplate(const MarkdownBody(data: 'line 1  \n  \nline 2')));

    final Iterable<Widget> widgets = tester.allWidgets;
    _expectWidgetTypes(
        widgets, <Type>[Directionality, MarkdownBody, Column, Wrap, RichText]);
    _expectTextStrings(widgets, <String>['line 1\n\nline 2']);
  });

  testWidgets('Non-applicable line break', (WidgetTester tester) async {
    final body = MarkdownBody(data: 'line 1.\nline 2.');
    await tester.pumpWidget(_boilerplate(body));

    final Iterable<Widget> widgets = tester.allWidgets;
    _expectWidgetTypes(
        widgets, <Type>[Directionality, MarkdownBody, Column, Wrap, RichText]);
    _expectTextStrings(widgets, <String>['line 1. line 2.']);
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

  testWidgets('Horizontal Rule - 3 hyphen', (WidgetTester tester) async {
    await tester.pumpWidget(_boilerplate(MarkdownBody(data: '---')));

    final Iterable<Widget> widgets = tester.allWidgets;
    _expectWidgetTypes(widgets, <Type>[
      Directionality,
      MarkdownBody,
      Container,
      DecoratedBox,
      Padding,
      LimitedBox,
      ConstrainedBox
    ]);
  });

  testWidgets('Horizontal Rule - 5 hyphen', (WidgetTester tester) async {
    await tester.pumpWidget(_boilerplate(MarkdownBody(data: '-----')));

    final Iterable<Widget> widgets = tester.allWidgets;
    _expectWidgetTypes(widgets, <Type>[
      Directionality,
      MarkdownBody,
      Container,
      DecoratedBox,
      Padding,
      LimitedBox,
      ConstrainedBox
    ]);
  });

  testWidgets('Horizontal Rule - 3 asterisk', (WidgetTester tester) async {
    await tester.pumpWidget(_boilerplate(MarkdownBody(data: '* * *')));

    final Iterable<Widget> widgets = tester.allWidgets;
    _expectWidgetTypes(widgets, <Type>[
      Directionality,
      MarkdownBody,
      Container,
      DecoratedBox,
      Padding,
      LimitedBox,
      ConstrainedBox
    ]);
  });

  testWidgets('Horizontal Rule * * * alongside text Markdown',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(_boilerplate(MarkdownBody(data: '# h1\n ## h2\n* * *')));
    final Iterable<Widget> widgets = tester.allWidgets;
    _expectWidgetTypes(widgets, <Type>[
      Directionality,
      MarkdownBody,
      Column,
      Column,
      Wrap,
      RichText,
      SizedBox,
      Column,
      Wrap,
      RichText,
      SizedBox,
      Container,
      DecoratedBox,
      Padding,
      LimitedBox,
      ConstrainedBox
    ]);
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

  testWidgets('Scrollable controller', (WidgetTester tester) async {
    final ScrollController controller = ScrollController(
      initialScrollOffset: 209.0,
    );

    await tester
        .pumpWidget(_boilerplate(Markdown(controller: controller, data: '')));

    double realOffset() {
      return tester
          .state<ScrollableState>(find.byType(Scrollable))
          .position
          .pixels;
    }

    expect(controller.offset, equals(209.0));
    expect(realOffset(), equals(controller.offset));
  });

  group('Links', () {
    testWidgets('should be tappable', (WidgetTester tester) async {
      String tapResult;
      await tester.pumpWidget(_boilerplate(Markdown(
        data: '[Link Text](href)',
        onTapLink: (value) => tapResult = value,
      )));

      final RichText textWidget = tester.widget(find.byType(RichText));
      final TextSpan span = textWidget.text;

      (span.recognizer as TapGestureRecognizer).onTap();

      expect(span.children, null);
      expect(span.recognizer.runtimeType, equals(TapGestureRecognizer));
      expect(tapResult, 'href');
    });

    testWidgets('should work with nested elements',
        (WidgetTester tester) async {
      final List<String> tapResults = <String>[];
      await tester.pumpWidget(_boilerplate(Markdown(
        data: '[Link `with nested code` Text](href)',
        onTapLink: (value) => tapResults.add(value),
      )));

      final RichText textWidget = tester.widget(find.byType(RichText));
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

      final RichText textWidget =
          tester.widgetList(find.byType(RichText)).first;
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
      expect(gestureRecognizerTypes,
          orderedEquals([TapGestureRecognizer, Null, TapGestureRecognizer]));
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

      final Iterable<RichText> texts = tester.widgetList(find.byType(RichText));
      final RichText firstTextWidget = texts.first;
      final TextSpan firstTextSpan = firstTextWidget.text;
      final Image image = tester.widget(find.byType(Image));
      final NetworkImage networkImage = image.image;
      final RichText secondTextWidget = texts.last;
      final TextSpan secondTextSpan = secondTextWidget.text;

      expect(firstTextSpan.text, 'textbefore ');
      expect(firstTextSpan.style.fontStyle, FontStyle.italic);
      expect(networkImage.url, 'http://img');
      expect(secondTextSpan.text, ' textafter');
      expect(secondTextSpan.style.fontStyle, FontStyle.italic);
    });

    testWidgets('should work with a link', (WidgetTester tester) async {
      await tester.pumpWidget(
          _boilerplate(const Markdown(data: '![alt](https://img#50x50)')));

      final Image image = tester.widget(find.byType(Image));
      final NetworkImage networkImage = image.image;
      expect(networkImage.url, 'https://img');
      expect(image.width, 50);
      expect(image.height, 50);
    });

    testWidgets('should work with relative remote image',
        (WidgetTester tester) async {
      await tester.pumpWidget(_boilerplate(const Markdown(
        data: '![alt](/img.png)',
        imageDirectory: 'http://localhost',
      )));

      final Iterable<Widget> widgets = tester.allWidgets;
      final Image image =
          widgets.firstWhere((Widget widget) => widget is Image);

      expect(image.image is NetworkImage, isTrue);
      expect((image.image as NetworkImage).url, 'http://localhost/img.png');
    });

    testWidgets('local files should be files', (WidgetTester tester) async {
      await tester
          .pumpWidget(_boilerplate(const Markdown(data: '![alt](http.png)')));

      final Iterable<Widget> widgets = tester.allWidgets;
      final Image image =
          widgets.firstWhere((Widget widget) => widget is Image);

      expect(image.image is FileImage, isTrue);
    });

    testWidgets('should work with resources', (WidgetTester tester) async {
      await tester.pumpWidget(_boilerplate(const Markdown(
        data: '![alt](resource:assets/logo.png)',
      )));

      final Iterable<Widget> widgets = tester.allWidgets;
      final Image image =
          widgets.firstWhere((Widget widget) => widget is Image);

      expect(image.image is AssetImage, isTrue);
      expect((image.image as AssetImage).assetName, 'assets/logo.png');
    });

    testWidgets('should work with local image files',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          _boilerplate(const Markdown(data: '![alt](img.png#50x50)')));

      final Image image = tester.widget(find.byType(Image));
      final FileImage fileImage = image.image;
      expect(fileImage.file.path, 'img.png');
      expect(image.width, 50);
      expect(image.height, 50);
    });

    testWidgets('should show properly next to text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          _boilerplate(const Markdown(data: 'Hello ![alt](img#50x50)')));

      final RichText richText = tester.widget(find.byType(RichText));
      TextSpan textSpan = richText.text;
      expect(textSpan.text, 'Hello ');
      expect(textSpan.style, isNotNull);
    });

    testWidgets('should work when nested in a link',
        (WidgetTester tester) async {
      final List<String> tapResults = <String>[];
      await tester.pumpWidget(_boilerplate(Markdown(
        data: '[![alt](https://img#50x50)](href)',
        onTapLink: (value) => tapResults.add(value),
      )));

      final GestureDetector detector =
          tester.widget(find.byType(GestureDetector));

      detector.onTap();

      expect(tapResults.length, 1);
      expect(tapResults, everyElement('href'));
    });

    testWidgets('should work when nested in a link with text',
        (WidgetTester tester) async {
      final List<String> tapResults = <String>[];
      await tester.pumpWidget(_boilerplate(Markdown(
        data: '[Text before ![alt](https://img#50x50) text after](href)',
        onTapLink: (value) => tapResults.add(value),
      )));

      final GestureDetector detector =
          tester.widget(find.byType(GestureDetector));
      detector.onTap();

      final Iterable<RichText> texts = tester.widgetList(find.byType(RichText));
      final RichText firstTextWidget = texts.first;
      final TextSpan firstSpan = firstTextWidget.text;
      (firstSpan.recognizer as TapGestureRecognizer).onTap();

      final RichText lastTextWidget = texts.last;
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

    testWidgets('should work alongside different links',
        (WidgetTester tester) async {
      final List<String> tapResults = <String>[];
      await tester.pumpWidget(_boilerplate(Markdown(
        data:
            '[Link before](firstHref)[![alt](https://img#50x50)](imageHref)[link after](secondHref)',
        onTapLink: (value) => tapResults.add(value),
      )));

      final Iterable<RichText> texts = tester.widgetList(find.byType(RichText));
      final RichText firstTextWidget = texts.first;
      final TextSpan firstSpan = firstTextWidget.text;
      (firstSpan.recognizer as TapGestureRecognizer).onTap();

      final GestureDetector detector =
          tester.widget(find.byType(GestureDetector));
      detector.onTap();

      final RichText lastTextWidget = texts.last;
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

      final Iterable<DefaultTextStyle> styles =
          tester.widgetList(find.byType(DefaultTextStyle));

      expect(styles.first.textAlign, TextAlign.center);
      expect(styles.last.textAlign, TextAlign.right);
    });

    testWidgets('should work with styling', (WidgetTester tester) async {
      const String data = '|Header|\n|----|\n|*italic*|';
      await tester.pumpWidget(_boilerplate(MarkdownBody(data: data)));

      final Iterable<Widget> widgets = tester.allWidgets;
      final RichText richText =
          widgets.lastWhere((Widget widget) => widget is RichText);

      _expectTextStrings(widgets, <String>['Header', 'italic']);
      expect(richText.text.style.fontStyle, FontStyle.italic);
    });

    testWidgets('should work next to other tables',
        (WidgetTester tester) async {
      const String data = '|first header|\n|----|\n|first col|\n\n'
          '|second header|\n|----|\n|second col|';
      await tester.pumpWidget(_boilerplate(const MarkdownBody(data: data)));

      final Iterable<Widget> tables = tester.widgetList(find.byType(Table));

      expect(tables.length, 2);
    });

    testWidgets('column width should follow stylesheet',
        (WidgetTester tester) async {
      final ThemeData theme = ThemeData.light().copyWith(textTheme: textTheme);

      const String data = '|Header|\n|----|\n|Column|';
      const FixedColumnWidth columnWidth = FixedColumnWidth(100);
      final MarkdownStyleSheet style =
          MarkdownStyleSheet.fromTheme(theme).copyWith(
        tableColumnWidth: columnWidth,
      );

      await tester.pumpWidget(
          _boilerplate(MarkdownBody(data: data, styleSheet: style)));

      final Table table = tester.widget(find.byType(Table));

      expect(table.defaultColumnWidth, columnWidth);
    });
  });

  group('Uri data scheme', () {
    testWidgets('should work with image in uri data scheme',
        (WidgetTester tester) async {
      await tester.pumpWidget(_boilerplate(const Markdown(
        data:
            '![alt](data:image/gif;base64,R0lGODlhAQABAIAAAAUEBAAAACwAAAAAAQABAAACAkQBADs=)',
      )));

      final Iterable<Widget> widgets = tester.allWidgets;
      final Image image =
          widgets.firstWhere((Widget widget) => widget is Image);
      expect(image.image.runtimeType, MemoryImage);
    });

    testWidgets('should work with base64 text in uri data scheme',
        (WidgetTester tester) async {
      const String imageData = '![alt](data:text/plan;base64,Rmx1dHRlcg==)';
      await tester.pumpWidget(_boilerplate(const Markdown(data: imageData)));

      final Text widget = tester.widget(find.byType(Text));
      expect(widget.runtimeType, Text);
      expect(widget.data, 'Flutter');
    });

    testWidgets('should work with text in uri data scheme',
        (WidgetTester tester) async {
      const String imageData = '![alt](data:text/plan,Hello%2C%20Flutter)';
      await tester.pumpWidget(_boilerplate(const Markdown(data: imageData)));

      final Text widget = tester.widget(find.byType(Text));
      expect(widget.runtimeType, Text);
      expect(widget.data, 'Hello, Flutter');
    });

    testWidgets('should work with empty uri data scheme',
        (WidgetTester tester) async {
      const String imageData = '![alt](data:,)';
      await tester.pumpWidget(_boilerplate(const Markdown(data: imageData)));

      final Text widget = tester.widget(find.byType(Text));
      expect(widget.runtimeType, Text);
      expect(widget.data, '');
    });

    testWidgets('should work with unsupported mime types of uri data scheme',
        (WidgetTester tester) async {
      await tester.pumpWidget(_boilerplate(const Markdown(
        data: '![alt](data:application/javascript,var%20test=1)',
      )));

      final Iterable<Widget> widgets = tester.allWidgets;
      final SizedBox widget =
          widgets.firstWhere((Widget widget) => widget is SizedBox);
      expect(widget.runtimeType, SizedBox);
    });
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

    testWidgets('existing HTML entities when parsing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          _boilerplate(const Markdown(data: '&amp; &copy; &#60; &#x0007B;')));
      _expectTextStrings(
          tester.allWidgets, <String>['&amp; &copy; &#60; &#x0007B;']);
    });
  });

  group('Changing configs', () {
    testWidgets(' - data', (WidgetTester tester) async {
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

    testWidgets(' - selectable', (WidgetTester tester) async {
      await tester.pumpWidget(_boilerplate(MediaQuery(
        data: MediaQueryData(),
        child: const Markdown(
          data: '# Title\nHello _World_!',
          selectable: true,
        ),
      )));

      expect(find.byType(SelectableText), findsNWidgets(2));
    });

    testWidgets(' - style', (WidgetTester tester) async {
      final ThemeData theme = ThemeData.light().copyWith(textTheme: textTheme);

      final MarkdownStyleSheet style1 = MarkdownStyleSheet.fromTheme(theme);
      final MarkdownStyleSheet style2 =
          MarkdownStyleSheet.largeFromTheme(theme);
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

    testWidgets(' - imageBuilder', (WidgetTester tester) async {
      final String data = '![alt](https://img.png)';
      final MarkdownImageBuilder builder =
          (_, __, ___) => Image.asset('assets/logo.png');

      await tester.pumpWidget(
          _boilerplate(Markdown(data: data, imageBuilder: builder)));

      final Iterable<Widget> widgets = tester.allWidgets;
      final Image image =
          widgets.firstWhere((Widget widget) => widget is Image);

      expect(image.image.runtimeType, AssetImage);
      expect((image.image as AssetImage).assetName, 'assets/logo.png');
    });

    testWidgets(' - checkboxBuilder', (WidgetTester tester) async {
      final String data = '- [x] Item 1\n- [ ] Item 2';
      final MarkdownCheckboxBuilder builder =
          (bool checked) => Text('$checked');

      await tester.pumpWidget(
          _boilerplate(Markdown(data: data, checkboxBuilder: builder)));

      final Iterable<Widget> widgets = tester.allWidgets;

      _expectTextStrings(widgets, <String>[
        'true',
        'Item 1',
        'false',
        'Item 2',
      ]);
    });

    testWidgets(' - should use style textScaleFactor in RichText',
        (WidgetTester tester) async {
      await tester.pumpWidget(_boilerplate(
        MarkdownBody(
          styleSheet: MarkdownStyleSheet(textScaleFactor: 2.0),
          data: 'Hello',
        ),
      ));

      final RichText richText = tester.widget(find.byType(RichText));
      expect(richText.textScaleFactor, 2.0);
    });
  });

  group('Custom builders', () {
    testWidgets('Subscript', (WidgetTester tester) async {
      await tester.pumpWidget(_boilerplate(Markdown(
        data: 'H_2O',
        extensionSet: md.ExtensionSet([], [SubscriptSyntax()]),
        builders: {
          'sub': SubscriptBuilder(),
        },
      )));

      final Iterable<Widget> widgets = tester.allWidgets;
      _expectTextStrings(widgets, ['H₂O']);
    });

    testWidgets('link for wikistyle', (WidgetTester tester) async {
      await tester.pumpWidget(
        _boilerplate(
          Markdown(
            data: 'This is [[wiki link]]',
            extensionSet: md.ExtensionSet([], [WikilinkSyntax()]),
            builders: {
              'wikilink': WikilinkBuilder(),
            },
          ),
        ),
      );

      final RichText textWidget = tester.widget(find.byType(RichText));
      final TextSpan span = (textWidget.text as TextSpan).children[1];

      expect(span.children, null);
      expect(span.recognizer.runtimeType, equals(TapGestureRecognizer));
    });
  });

  group('Style', () {
    testWidgets('equality - Material', (WidgetTester tester) async {
      final ThemeData theme = ThemeData.light().copyWith(textTheme: textTheme);

      final MarkdownStyleSheet style1 = MarkdownStyleSheet.fromTheme(theme);
      final MarkdownStyleSheet style2 = MarkdownStyleSheet.fromTheme(theme);
      expect(style1, equals(style2));
      expect(style1.hashCode, equals(style2.hashCode));
    });

    testWidgets('equality - Cupertino', (WidgetTester tester) async {
      final CupertinoThemeData theme =
          CupertinoThemeData(brightness: Brightness.light);

      final MarkdownStyleSheet style1 =
          MarkdownStyleSheet.fromCupertinoTheme(theme);
      final MarkdownStyleSheet style2 =
          MarkdownStyleSheet.fromCupertinoTheme(theme);
      expect(style1, equals(style2));
      expect(style1.hashCode, equals(style2.hashCode));
    });

    testWidgets('MarkdownStyleSheet.fromCupertinoTheme',
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
      expect(style.code.backgroundColor, CupertinoColors.systemGrey6.darkColor);

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
    });

    testWidgets('MarkdownStyleSheet.fromTheme', (WidgetTester tester) async {
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
    });

    testWidgets('merge', (WidgetTester tester) async {
      final ThemeData theme = ThemeData.light().copyWith(textTheme: textTheme);
      final MarkdownStyleSheet style1 = MarkdownStyleSheet.fromTheme(theme);
      final MarkdownStyleSheet style2 =
          MarkdownStyleSheet(p: TextStyle(color: Colors.red));

      final MarkdownStyleSheet merged = style1.merge(style2);
      expect(merged.p.color, Colors.red);
    });

    testWidgets('create based on which theme', (WidgetTester tester) async {
      await tester.pumpWidget(_boilerplate(const Markdown(
        data: '[title](url)',
        styleSheetTheme: MarkdownStyleSheetBaseTheme.cupertino,
      )));

      final RichText widget = tester.widget(find.byType(RichText));
      expect(widget.text.style.color, CupertinoColors.link.color);
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

  testWidgets('should apply text alignments from stylesheet',
      (WidgetTester tester) async {
    final ThemeData theme = ThemeData.light().copyWith(textTheme: textTheme);
    final MarkdownStyleSheet style1 =
        MarkdownStyleSheet.fromTheme(theme).copyWith(
      h1Align: WrapAlignment.center,
      h3Align: WrapAlignment.end,
    );

    const String data = '# h1\n ## h2';
    await tester.pumpWidget(_boilerplate(MarkdownBody(
      data: data,
      styleSheet: style1,
    )));

    final Iterable<Widget> widgets = tester.allWidgets;
    _expectWidgetTypes(widgets, <Type>[
      Directionality,
      MarkdownBody,
      Column,
      Column,
      Wrap,
      RichText,
      SizedBox,
      Column,
      Wrap,
      RichText,
    ]);

    expect((widgets.firstWhere((w) => w is RichText) as RichText).textAlign,
        TextAlign.center);
    expect((widgets.last as RichText).textAlign, TextAlign.start,
        reason: "default alignment if none is set in stylesheet");
  });

  testWidgets('should align formatted text', (WidgetTester tester) async {
    final ThemeData theme = ThemeData.light().copyWith(textTheme: textTheme);
    final MarkdownStyleSheet style =
        MarkdownStyleSheet.fromTheme(theme).copyWith(
      textAlign: WrapAlignment.spaceBetween,
    );

    const String data = 'hello __my formatted text__';
    await tester
        .pumpWidget(_boilerplate(MarkdownBody(data: data, styleSheet: style)));

    final RichText text = tester.widgetList(find.byType(RichText)).single;
    expect(text.textAlign, TextAlign.justify);
  });

  testWidgets('should align selectable text', (WidgetTester tester) async {
    final ThemeData theme = ThemeData.light().copyWith(textTheme: textTheme);
    final MarkdownStyleSheet style =
        MarkdownStyleSheet.fromTheme(theme).copyWith(
      textAlign: WrapAlignment.spaceBetween,
    );

    const String data = 'hello __my formatted text__';
    await tester.pumpWidget(
      _boilerplate(
        MediaQuery(
          data: MediaQueryData(),
          child: MarkdownBody(data: data, styleSheet: style, selectable: true),
        ),
      ),
    );

    final SelectableText text =
        tester.widgetList(find.byType(SelectableText)).single;
    expect(text.textAlign, TextAlign.justify);
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
  return WidgetsBinding.instance.renderViewElement.toStringDeep().replaceAll(
      RegExp(r'SliverChildListDelegate#\d+', multiLine: true),
      'SliverChildListDelegate');
}

/// Wraps a widget with a left-to-right [Directionality] for tests.
Widget _boilerplate(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: child,
  );
}

// Used by test 'Custom Builders'.
class SubscriptSyntax extends md.InlineSyntax {
  static final _pattern = r'_([0-9]+)';

  SubscriptSyntax() : super(_pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text('sub', match[1]));
    return true;
  }
}

class WikilinkSyntax extends md.InlineSyntax {
  static final _pattern = r'\[\[(.*?)\]\]';

  WikilinkSyntax() : super(_pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    md.Element el = md.Element.withTag("wikilink");
    el.attributes["href"] = match[1].replaceAll(" ", "_");
    el.children.add(md.Element.text("span", match[1]));

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

// Used by test 'Custom Builders'.
class SubscriptBuilder extends MarkdownElementBuilder {
  static const List<String> _subscripts = [
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
    String textContent = element.textContent;
    String text = '';
    for (int i = 0; i < textContent.length; i++) {
      text += _subscripts[int.parse(textContent[i])];
    }
    return RichText(text: TextSpan(text: text));
  }
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

  when(client.getUrl(any))
      .thenAnswer((_) => Future<io.HttpClientRequest>.value(request));
  when(request.headers).thenReturn(headers);
  when(request.close())
      .thenAnswer((_) => Future<io.HttpClientResponse>.value(response));
  when(response.contentLength).thenReturn(_transparentImage.length);
  when(response.statusCode).thenReturn(io.HttpStatus.ok);
  when(response.listen(any)).thenAnswer((Invocation invocation) {
    final void Function(List<int>) onData = invocation.positionalArguments[0];
    final void Function() onDone = invocation.namedArguments[#onDone];
    final void Function(Object, [StackTrace]) onError =
        invocation.namedArguments[#onError];
    final bool cancelOnError = invocation.namedArguments[#cancelOnError];

    return Stream<List<int>>.fromIterable(<List<int>>[_transparentImage])
        .listen(onData,
            onDone: onDone, onError: onError, cancelOnError: cancelOnError);
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
