// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';

void main() => defineTests();

void defineTests() {
  group('Compatible with SelectionArea when selectable is default to false',
      () {
    testWidgets(
      'Text can be selected',
      (WidgetTester tester) async {
        SelectedContent? content;

        const String data = 'How are you?';
        await tester.pumpWidget(MaterialApp(
            home: SelectionArea(
          child: const Markdown(
            data: data,
          ),
          onSelectionChanged: (SelectedContent? selectedContent) =>
              content = selectedContent,
        )));

        final TestGesture gesture = await tester.startGesture(
            tester.getTopLeft(find.text('How are you?')),
            kind: PointerDeviceKind.mouse);
        addTearDown(gesture.removePointer);
        await tester.pump();

        await gesture.moveTo(tester.getBottomRight(find.text('How are you?')));
        await gesture.up();
        await tester.pump();

        expect(content, isNotNull);
        expect(content!.plainText, 'How are you?');
      },
    );

    testWidgets(
      'List can be selected',
      (WidgetTester tester) async {
        SelectedContent? content;

        const String data = '- Item 1\n- Item 2\n- Item 3';
        await tester.pumpWidget(MaterialApp(
            home: SelectionArea(
          child: const Markdown(
            data: data,
          ),
          onSelectionChanged: (SelectedContent? selectedContent) =>
              content = selectedContent,
        )));

        final TestGesture gesture = await tester.startGesture(
            tester.getTopLeft(find.byType(Markdown)),
            kind: PointerDeviceKind.mouse);
        addTearDown(gesture.removePointer);
        await tester.pump();

        await gesture.moveTo(tester.getBottomRight(find.byType(Markdown)));
        await gesture.up();
        await tester.pump();

        expect(content, isNotNull);
        expect(content!.plainText, '•Item 1•Item 2•Item 3');
      },
    );
  });
}
