// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  TextTheme textTheme = new Typography(platform: TargetPlatform.android)
      .black
      .merge(new TextTheme(body1: new TextStyle(fontSize: 12.0)));

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

  testWidgets('Strikethrough', (WidgetTester tester) async {
    await tester.pumpWidget(_boilerplate(const MarkdownBody(data: '~~strikethrough~~')));

    final Iterable<Widget> widgets = tester.allWidgets;
    _expectWidgetTypes(
        widgets, <Type>[Directionality, MarkdownBody, Column, Wrap, RichText]);
    _expectTextStrings(widgets, <String>['strikethrough']);
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

  testWidgets('Horizontal Rule', (WidgetTester tester) async {
    await tester.pumpWidget(_boilerplate(const MarkdownBody(data: '-----')));

    final Iterable<Widget> widgets = tester.allWidgets;
    _expectWidgetTypes(
        widgets, <Type>[Directionality, MarkdownBody, DecoratedBox, SizedBox]);
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
      await tester.pumpWidget(_boilerplate(new Markdown(
        data: '[Link Text](href)',
        onTapLink: (value) => tapResult = value,
      )));

      final RichText textWidget =
          tester.allWidgets.firstWhere((Widget widget) => widget is RichText);
      final TextSpan span = textWidget.text;

      (span.recognizer as TapGestureRecognizer).onTap();

      expect(span.children, null);
      expect(span.recognizer.runtimeType, equals(TapGestureRecognizer));
      expect(tapResult, 'href');
    });

    testWidgets('should work with nested elements', (WidgetTester tester) async {
      final List<String> tapResults = <String>[];
      await tester.pumpWidget(_boilerplate(new Markdown(
        data: '[Link `with nested code` Text](href)',
        onTapLink: (value) => tapResults.add(value),
      )));

      final RichText textWidget =
          tester.allWidgets.firstWhere((Widget widget) => widget is RichText);
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

      await tester.pumpWidget(_boilerplate(new Markdown(
          data: '[First Link](firstHref) and [Second Link](secondHref)',
          onTapLink: (value) => tapResults.add(value),
      )));

      final RichText textWidget =
          tester.allWidgets.firstWhere((Widget widget) => widget is RichText);
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
      io.HttpOverrides.global = new TestHttpOverrides();
    });

    testWidgets('should not interrupt styling', (WidgetTester tester) async {
      await tester.pumpWidget(_boilerplate(const Markdown(
        data:'_textbefore ![alt](http://img) textafter_',
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
      await tester
          .pumpWidget(_boilerplate(const Markdown(data: '![alt](https://img#50x50)')));

      final Image image =
        tester.allWidgets.firstWhere((Widget widget) => widget is Image);
      final NetworkImage networkImage = image.image;
      expect(networkImage.url, 'https://img');
      expect(image.width, 50);
      expect(image.height, 50);
    });

    testWidgets('local files should be files', (WidgetTester tester) async {
      await tester
          .pumpWidget(_boilerplate(const Markdown(data: '![alt](http.png)')));

      final Image image =
        tester.allWidgets.firstWhere((Widget widget) => widget is Image);
      expect(image.image is FileImage, isTrue);
    });

    testWidgets('should work with resources', (WidgetTester tester) async {
      await tester.pumpWidget(_boilerplate(
          const Markdown(data: '![alt](resource:assets/logo.png)')));

      final Image image =
        tester.allWidgets.firstWhere((Widget widget) => widget is Image);
      expect(image.image is AssetImage, isTrue);
      expect((image.image as AssetImage).assetName == 'assets/logo.png', isTrue);
    });

    testWidgets('should work with local image files', (WidgetTester tester) async {
      await tester
          .pumpWidget(_boilerplate(const Markdown(data: '![alt](img.png#50x50)')));

      final Image image =
        tester.allWidgets.firstWhere((Widget widget) => widget is Image);
      final FileImage fileImage = image.image;
      expect(fileImage.file.path, 'img.png');
      expect(image.width, 50);
      expect(image.height, 50);
    });

    testWidgets('should show properly next to text', (WidgetTester tester) async {
      await tester
          .pumpWidget(_boilerplate(const Markdown(data: 'Hello ![alt](img#50x50)')));

      final RichText richText =
        tester.allWidgets.firstWhere((Widget widget) => widget is RichText);
      TextSpan textSpan = richText.text;
      expect(textSpan.text, 'Hello ');
      expect(textSpan.style, isNotNull);
    });

    testWidgets('should work when nested in a link', (WidgetTester tester) async {
      final List<String> tapResults = <String>[];
      await tester.pumpWidget(_boilerplate(new Markdown(
        data: '[![alt](https://img#50x50)](href)',
        onTapLink: (value) => tapResults.add(value),
      )));

      final GestureDetector detector =
        tester.allWidgets.firstWhere((Widget widget) => widget is GestureDetector);

      detector.onTap();

      expect(tapResults.length, 1);
      expect(tapResults, everyElement('href'));
    });

    testWidgets('should work when nested in a link with text', (WidgetTester tester) async {
      final List<String> tapResults = <String>[];
      await tester.pumpWidget(_boilerplate(new Markdown(
        data: '[Text before ![alt](https://img#50x50) text after](href)',
        onTapLink: (value) => tapResults.add(value),
      )));

      final GestureDetector detector =
        tester.allWidgets.firstWhere((Widget widget) => widget is GestureDetector);
      detector.onTap();

      final RichText firstTextWidget =
        tester.allWidgets.firstWhere((Widget widget) => widget is RichText);
      final TextSpan firstSpan = firstTextWidget.text;
      (firstSpan.recognizer as TapGestureRecognizer).onTap();

      final RichText lastTextWidget =
        tester.allWidgets.lastWhere((Widget widget) => widget is RichText);
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
      await tester.pumpWidget(_boilerplate(new Markdown(
        data: '[Link before](firstHref)[![alt](https://img#50x50)](imageHref)[link after](secondHref)',
        onTapLink: (value) => tapResults.add(value),
      )));

      final RichText firstTextWidget =
        tester.allWidgets.firstWhere((Widget widget) => widget is RichText);
      final TextSpan firstSpan = firstTextWidget.text;
      (firstSpan.recognizer as TapGestureRecognizer).onTap();

      final GestureDetector detector =
        tester.allWidgets.firstWhere((Widget widget) => widget is GestureDetector);
      detector.onTap();

      final RichText lastTextWidget =
        tester.allWidgets.lastWhere((Widget widget) => widget is RichText);
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

  group('uri data scheme', () {
    testWidgets('should work with image in uri data scheme', (WidgetTester tester) async {
      const String imageData = '![alt](data:image/gif;base64,R0lGODlhAQABAIAAAAUEBAAAACwAAAAAAQABAAACAkQBADs=)';
      await tester
          .pumpWidget(_boilerplate(const Markdown(data: imageData)));

      final Image image =
      tester.allWidgets.firstWhere((Widget widget) => widget is Image);
      expect(image.image.runtimeType, MemoryImage);
    });

    testWidgets('should work with base64 text in uri data scheme', (WidgetTester tester) async {
      const String imageData = '![alt](data:text/plan;base64,Rmx1dHRlcg==)';
      await tester
          .pumpWidget(_boilerplate(const Markdown(data: imageData)));

      final Text widget =
      tester.allWidgets.firstWhere((Widget widget) => widget is Text);
      expect(widget.runtimeType, Text);
      expect(widget.data, 'Flutter');
    });

    testWidgets('should work with text in uri data scheme', (WidgetTester tester) async {
      const String imageData = '![alt](data:text/plan,Hello%2C%20Flutter)';
      await tester
          .pumpWidget(_boilerplate(const Markdown(data: imageData)));

      final Text widget =
      tester.allWidgets.firstWhere((Widget widget) => widget is Text);
      expect(widget.runtimeType, Text);
      expect(widget.data, 'Hello, Flutter');
    });

    testWidgets('should work with empty uri data scheme', (WidgetTester tester) async {
      const String imageData = '![alt](data:,)';
      await tester
          .pumpWidget(_boilerplate(const Markdown(data: imageData)));

      final Text widget =
      tester.allWidgets.firstWhere((Widget widget) => widget is Text);
      expect(widget.runtimeType, Text);
      expect(widget.data, '');
    });

    testWidgets('should work with unsupported mime types of uri data scheme', (WidgetTester tester) async {
      const String imageData = '![alt](data:application/javascript,var%20test=1)';
      await tester
          .pumpWidget(_boilerplate(const Markdown(data: imageData)));

      final SizedBox widget =
      tester.allWidgets.firstWhere((Widget widget) => widget is SizedBox);
      expect(widget.runtimeType, SizedBox);
    });
  });

  testWidgets('HTML tag ignored ', (WidgetTester tester) async {
    final List<String> mdData = <String>[
      'Line 1\n<p>HTML content</p>\nLine 2',
      'Line 1\n<!-- HTML\n comment\n ignored --><\nLine 2'
    ];

    for (String mdLine in mdData) {
      await tester.pumpWidget(_boilerplate(new MarkdownBody(data: mdLine)));

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
    final ThemeData theme = new ThemeData.light().copyWith(textTheme: textTheme);

    final MarkdownStyleSheet style1 = new MarkdownStyleSheet.fromTheme(theme);
    final MarkdownStyleSheet style2 =
    new MarkdownStyleSheet.largeFromTheme(theme);
    expect(style1, isNot(style2));

    await tester.pumpWidget(
      _boilerplate(new Markdown(data: '# Test', styleSheet: style1)),
    );
    final RichText text1 = tester.widget(find.byType(RichText));
    await tester.pumpWidget(
      _boilerplate(new Markdown(data: '# Test', styleSheet: style2)),
    );
    final RichText text2 = tester.widget(find.byType(RichText));

    expect(text1.text, isNot(text2.text));
  });

  testWidgets('Style equality', (WidgetTester tester) async {
    final ThemeData theme = new ThemeData.light().copyWith(textTheme: textTheme);

    final MarkdownStyleSheet style1 = new MarkdownStyleSheet.fromTheme(theme);
    final MarkdownStyleSheet style2 = new MarkdownStyleSheet.fromTheme(theme);
    expect(style1, equals(style2));
    expect(style1.hashCode, equals(style2.hashCode));
  });

  testWidgets('should use style textScaleFactor in RichText', (WidgetTester tester) async {
    await tester.pumpWidget(_boilerplate(
      MarkdownBody(
        styleSheet: MarkdownStyleSheet(textScaleFactor: 2.0),
        data: 'Hello',
      ),
    ));

    final RichText richText =
    tester.allWidgets.firstWhere((Widget widget) => widget is RichText);
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
  return WidgetsBinding.instance.renderViewElement.toStringDeep().replaceAll(
      new RegExp(r'SliverChildListDelegate#\d+', multiLine: true),
      'SliverChildListDelegate');
}

/// Wraps a widget with a left-to-right [Directionality] for tests.
Widget _boilerplate(Widget child) {
  return new Directionality(
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
  final MockHttpClient client = new MockHttpClient();
  final MockHttpClientRequest request = new MockHttpClientRequest();
  final MockHttpClientResponse response = new MockHttpClientResponse();
  final MockHttpHeaders headers = new MockHttpHeaders();

  when(client.getUrl(any)).thenAnswer((_) => new Future<io.HttpClientRequest>.value(request));
  when(request.headers).thenReturn(headers);
  when(request.close()).thenAnswer((_) => new Future<io.HttpClientResponse>.value(response));
  when(response.contentLength).thenReturn(_transparentImage.length);
  when(response.statusCode).thenReturn(io.HttpStatus.ok);
  when(response.listen(any)).thenAnswer((Invocation invocation) {
    final void Function(List<int>) onData = invocation.positionalArguments[0];
    final void Function() onDone = invocation.namedArguments[#onDone];
    final void Function(Object, [StackTrace]) onError = invocation.namedArguments[#onError];
    final bool cancelOnError = invocation.namedArguments[#cancelOnError];

    return new Stream<List<int>>.fromIterable(<List<int>>[_transparentImage])
        .listen(onData, onDone: onDone, onError: onError, cancelOnError: cancelOnError);
  });

  return client;
}

const List<int> _transparentImage = const <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
];
