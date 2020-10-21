// Copyright 2020 Quiverware LLC. Open source contribution. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

final TextTheme textTheme =
    Typography.material2018(platform: TargetPlatform.android)
        .black
        .merge(TextTheme(bodyText2: TextStyle(fontSize: 12.0)));

void expectWidgetTypes(Iterable<Widget> widgets, List<Type> expected) {
  final List<Type> actual = widgets.map((Widget w) => w.runtimeType).toList();
  expect(actual, expected);
}

void expectTextStrings(Iterable<Widget> widgets, List<String> strings) {
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

// Check the font style and weight of the text span.
void expectTextSpanStyle(
    TextSpan textSpan, FontStyle style, FontWeight weight) {
  // Verify a text style is set
  expect(textSpan.style, isNotNull, reason: 'text span text style is null');

  // Font style check
  if (style == null) {
    expect(textSpan.style.fontStyle, isNull, reason: 'font style is not null');
  } else {
    expect(textSpan.style.fontStyle, isNotNull, reason: 'font style is null');
    expect(
      textSpan.style.fontStyle == style,
      isTrue,
      reason: 'font style is not $style',
    );
  }

  // Font weight check
  expect(textSpan.style, isNotNull, reason: 'font style is null');
  expect(
    textSpan.style.fontWeight == weight,
    isTrue,
    reason: 'font weight is not $weight',
  );
}

class MarkdownLink {
  final String text;
  final String destination;
  final String title;
  MarkdownLink(this.text, this.destination, [this.title = ""]);

  @override
  bool operator ==(Object other) =>
      other is MarkdownLink &&
      other.text == text &&
      other.destination == destination &&
      other.title == title;

  @override
  int get hashCode => '$text$destination$title'.hashCode;

  @override
  String toString() {
    return '[$text]($destination "$title")';
  }
}

/// Verify a valid link structure has been created. This routine checks for the
/// link text and the associated [TapGestureRecognizer] on the text span.
void expectValidLink(String linkText) {
  final richTextFinder = find.byType(RichText);
  expect(richTextFinder, findsOneWidget);
  final richText = richTextFinder.evaluate().first.widget as RichText;

  // Verify the link text.
  expect(richText.text, isNotNull);
  expect(richText.text, isA<TextSpan>());

  // Verify the link text is a onTap gesture recognizer.
  final TextSpan textSpan = richText.text;
  expectLinkTextSpan(textSpan, linkText);
}

void expectLinkTextSpan(TextSpan textSpan, String linkText) {
  expect(textSpan.children, isNull);
  expect(textSpan.toPlainText(), linkText);
  expect(textSpan.recognizer, isNotNull);
  expect(textSpan.recognizer, isA<TapGestureRecognizer>());
  final TapGestureRecognizer tapRecognizer = textSpan.recognizer;
  expect(tapRecognizer.onTap, isNotNull);

  // Execute the onTap callback handler.
  tapRecognizer.onTap();
}

void expectInvalidLink(String linkText) {
  final richTextFinder = find.byType(RichText);
  expect(richTextFinder, findsOneWidget);
  final richText = richTextFinder.evaluate().first.widget as RichText;

  expect(richText.text, isNotNull);
  expect(richText.text, isA<TextSpan>());
  final text = richText.text.toPlainText();
  expect(text, linkText);

  final TextSpan textSpan = richText.text;
  expect(textSpan.recognizer, isNull);
}

void expectTableSize(int rows, int columns) {
  final tableFinder = find.byType(Table);
  expect(tableFinder, findsOneWidget);
  final table = tableFinder.evaluate().first.widget as Table;

  expect(table.children.length, rows);
  for (int index = 0; index < rows; index++) {
    expect(table.children[index].children.length, columns);
  }
}

void expectLinkTap(MarkdownLink actual, MarkdownLink expected) {
  expect(actual, equals(expected),
      reason:
          'incorrect link tap results, actual: $actual expected: $expected');
}

String dumpRenderView() {
  return WidgetsBinding.instance.renderViewElement.toStringDeep().replaceAll(
      RegExp(r'SliverChildListDelegate#\d+', multiLine: true),
      'SliverChildListDelegate');
}

/// Wraps a widget with a left-to-right [Directionality] for tests.
Widget boilerplate(Widget child) {
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

  when(client.getUrl(any))
      .thenAnswer((_) => Future<io.HttpClientRequest>.value(request));
  when(request.headers).thenReturn(headers);
  when(request.close())
      .thenAnswer((_) => Future<io.HttpClientResponse>.value(response));
  when(response.contentLength).thenReturn(_transparentImage.length);
  when(response.statusCode).thenReturn(io.HttpStatus.ok);
  when(response.compressionState)
      .thenReturn(io.HttpClientResponseCompressionState.notCompressed);
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
