// Copyright 2020 Quiverware LLC. Open source contribution. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

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
      final TextSpan span = widget.text as TextSpan;
      final String text = _extractTextFromTextSpan(span);
      expect(text, equals(strings[currentString]));
      currentString += 1;
    }
  }
}

String _extractTextFromTextSpan(TextSpan span) {
  String text = span.text ?? '';
  if (span.children != null) {
    for (TextSpan child in span.children as Iterable<TextSpan>) {
      text += _extractTextFromTextSpan(child);
    }
  }
  return text;
}

// Check the font style and weight of the text span.
void expectTextSpanStyle(
    TextSpan textSpan, FontStyle? style, FontWeight weight) {
  // Verify a text style is set
  expect(textSpan.style, isNotNull, reason: 'text span text style is null');

  // Font style check
  if (style == null) {
    expect(textSpan.style!.fontStyle, isNull, reason: 'font style is not null');
  } else {
    expect(textSpan.style!.fontStyle, isNotNull, reason: 'font style is null');
    expect(
      textSpan.style!.fontStyle == style,
      isTrue,
      reason: 'font style is not $style',
    );
  }

  // Font weight check
  expect(textSpan.style, isNotNull, reason: 'font style is null');
  expect(
    textSpan.style!.fontWeight == weight,
    isTrue,
    reason: 'font weight is not $weight',
  );
}

class MarkdownLink {
  final String text;
  final String? destination;
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
  final TextSpan textSpan = richText.text as TextSpan;
  expectLinkTextSpan(textSpan, linkText);
}

void expectLinkTextSpan(TextSpan textSpan, String linkText) {
  expect(textSpan.children, isNull);
  expect(textSpan.toPlainText(), linkText);
  expect(textSpan.recognizer, isNotNull);
  expect(textSpan.recognizer, isA<TapGestureRecognizer>());
  final TapGestureRecognizer tapRecognizer =
      textSpan.recognizer as TapGestureRecognizer;
  expect(tapRecognizer.onTap, isNotNull);

  // Execute the onTap callback handler.
  tapRecognizer.onTap!();
}

void expectInvalidLink(String linkText) {
  final richTextFinder = find.byType(RichText);
  expect(richTextFinder, findsOneWidget);
  final richText = richTextFinder.evaluate().first.widget as RichText;

  expect(richText.text, isNotNull);
  expect(richText.text, isA<TextSpan>());
  final text = richText.text.toPlainText();
  expect(text, linkText);

  final TextSpan textSpan = richText.text as TextSpan;
  expect(textSpan.recognizer, isNull);
}

void expectTableSize(int rows, int columns) {
  final tableFinder = find.byType(Table);
  expect(tableFinder, findsOneWidget);
  final table = tableFinder.evaluate().first.widget as Table;

  expect(table.children.length, rows);
  for (int index = 0; index < rows; index++) {
    expect(table.children[index].children!.length, columns);
  }
}

void expectLinkTap(MarkdownLink? actual, MarkdownLink expected) {
  expect(actual, equals(expected),
      reason:
          'incorrect link tap results, actual: $actual expected: $expected');
}

String dumpRenderView() {
  return WidgetsBinding.instance!.renderViewElement!.toStringDeep().replaceAll(
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
