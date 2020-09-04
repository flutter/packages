// Copyright 2020 Quiverware LLC. Open source contribution. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'utils.dart';

void main() => defineTests();

void defineTests() {
  group('Link', () {
    testWidgets(
      'should be tappable',
      (WidgetTester tester) async {
        String tapResult;
        const String data = '[Link Text](href)';
        await tester.pumpWidget(
          boilerplate(
            Markdown(
              data: data,
              onTapLink: (value) => tapResult = value,
            ),
          ),
        );

        final RichText textWidget = tester.widget(find.byType(RichText));
        final TextSpan span = textWidget.text;

        (span.recognizer as TapGestureRecognizer).onTap();

        expect(span.children, null);
        expect(span.recognizer.runtimeType, equals(TapGestureRecognizer));
        expect(tapResult, 'href');
      },
    );

    testWidgets(
      'should work with nested elements',
      (WidgetTester tester) async {
        final List<String> tapResults = <String>[];
        const String data = '[Link `with nested code` Text](href)';
        await tester.pumpWidget(
          boilerplate(
            Markdown(
              data: data,
              onTapLink: (value) => tapResults.add(value),
            ),
          ),
        );

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
      },
    );

    testWidgets(
      'should work next to other links',
      (WidgetTester tester) async {
        final List<String> tapResults = <String>[];
        const String data =
            '[First Link](firstHref) and [Second Link](secondHref)';
        await tester.pumpWidget(
          boilerplate(
            Markdown(
              data: data,
              onTapLink: (value) => tapResults.add(value),
            ),
          ),
        );

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
        expect(
          gestureRecognizerTypes,
          orderedEquals([TapGestureRecognizer, Null, TapGestureRecognizer]),
        );
        expect(tapResults, orderedEquals(['firstHref', 'secondHref']));
      },
    );
  });
}
