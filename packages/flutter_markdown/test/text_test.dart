// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() => defineTests();

void defineTests() {
  group('Data', () {
    testWidgets(
      'simple data',
      (WidgetTester tester) async {
        // extract to variable; if run with --track-widget-creation using const
        // widgets aren't necessarily identical if created on different lines.
        const Markdown markdown = Markdown(data: 'Data1');

        await tester.pumpWidget(boilerplate(markdown));
        expectTextStrings(tester.allWidgets, <String>['Data1']);

        final String stateBefore = dumpRenderView();
        await tester.pumpWidget(boilerplate(markdown));
        final String stateAfter = dumpRenderView();
        expect(stateBefore, equals(stateAfter));

        await tester.pumpWidget(boilerplate(const Markdown(data: 'Data2')));
        expectTextStrings(tester.allWidgets, <String>['Data2']);
      },
    );
  });

  group('Text', () {
    testWidgets(
      'Empty string',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: ''),
          ),
        );

        final Iterable<Widget> widgets = selfAndDescendantWidgetsOf(
          find.byType(MarkdownBody),
          tester,
        );
        expectWidgetTypes(widgets, <Type>[
          MarkdownBody,
          Column,
        ]);
      },
    );

    testWidgets(
      'Simple string',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: 'Hello'),
          ),
        );

        final Iterable<Widget> widgets = selfAndDescendantWidgetsOf(
          find.byType(MarkdownBody),
          tester,
        );
        expectWidgetTypes(widgets, <Type>[
          MarkdownBody,
          Column,
          Wrap,
          Text,
          RichText,
        ]);
        expectTextStrings(widgets, <String>['Hello']);
      },
    );
  });

  group('Leading spaces', () {
    testWidgets(
        // Example 192 from the GitHub Flavored Markdown specification.
        'leading space are ignored', (WidgetTester tester) async {
      const String data = '  aaa\n bbb';
      await tester.pumpWidget(
        boilerplate(
          const MarkdownBody(data: data),
        ),
      );

      final Iterable<Widget> widgets = selfAndDescendantWidgetsOf(
        find.byType(MarkdownBody),
        tester,
      );
      expectWidgetTypes(widgets, <Type>[
        MarkdownBody,
        Column,
        Wrap,
        Text,
        RichText,
      ]);
      expectTextStrings(widgets, <String>['aaa bbb']);
    });
  });

  group('Line Break', () {
    testWidgets(
      // Example 654 from the GitHub Flavored Markdown specification.
      'two spaces at end of line inside a block element',
      (WidgetTester tester) async {
        const String data = 'line 1  \nline 2';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final Iterable<Widget> widgets = selfAndDescendantWidgetsOf(
          find.byType(MarkdownBody),
          tester,
        );
        expectWidgetTypes(
            widgets, <Type>[MarkdownBody, Column, Wrap, Text, RichText]);
        expectTextStrings(widgets, <String>['line 1\nline 2']);
      },
    );

    testWidgets(
      // Example 655 from the GitHub Flavored Markdown specification.
      'backslash at end of line inside a block element',
      (WidgetTester tester) async {
        const String data = 'line 1\\\nline 2';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final Iterable<Widget> widgets = selfAndDescendantWidgetsOf(
          find.byType(MarkdownBody),
          tester,
        );
        expectWidgetTypes(
            widgets, <Type>[MarkdownBody, Column, Wrap, Text, RichText]);
        expectTextStrings(widgets, <String>['line 1\nline 2']);
      },
    );

    testWidgets(
      'non-applicable line break',
      (WidgetTester tester) async {
        const String data = 'line 1.\nline 2.';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final Iterable<Widget> widgets = selfAndDescendantWidgetsOf(
          find.byType(MarkdownBody),
          tester,
        );
        expectWidgetTypes(widgets, <Type>[
          MarkdownBody,
          Column,
          Wrap,
          Text,
          RichText,
        ]);
        expectTextStrings(widgets, <String>['line 1. line 2.']);
      },
    );

    testWidgets(
      'non-applicable line break',
      (WidgetTester tester) async {
        const String data = 'line 1.\nline 2.';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: data),
          ),
        );

        final Iterable<Widget> widgets = selfAndDescendantWidgetsOf(
          find.byType(MarkdownBody),
          tester,
        );
        expectWidgetTypes(widgets, <Type>[
          MarkdownBody,
          Column,
          Wrap,
          Text,
          RichText,
        ]);
        expectTextStrings(widgets, <String>['line 1. line 2.']);
      },
    );

    testWidgets(
      'soft line break',
      (WidgetTester tester) async {
        const String data = 'line 1.\nline 2.';
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(
              data: data,
              softLineBreak: true,
            ),
          ),
        );

        final Iterable<Widget> widgets = selfAndDescendantWidgetsOf(
          find.byType(MarkdownBody),
          tester,
        );
        expectWidgetTypes(
            widgets, <Type>[MarkdownBody, Column, Wrap, Text, RichText]);
        expectTextStrings(widgets, <String>['line 1.\nline 2.']);
      },
    );
  });

  group('Selectable', () {
    testWidgets(
      'header with line of text',
      (WidgetTester tester) async {
        const String data = '# Title\nHello _World_!';
        await tester.pumpWidget(
          boilerplate(
            const MediaQuery(
              data: MediaQueryData(),
              child: Markdown(
                data: data,
                selectable: true,
              ),
            ),
          ),
        );

        expect(find.byType(SelectableText), findsNWidgets(2));
      },
    );

    testWidgets(
      'header with line of text and onTap callback',
      (WidgetTester tester) async {
        const String data = '# Title\nHello _World_!';
        String? textTapResults;

        await tester.pumpWidget(
          boilerplate(
            MediaQuery(
              data: const MediaQueryData(),
              child: Markdown(
                data: data,
                selectable: true,
                onTapText: () => textTapResults = 'Text has been tapped.',
              ),
            ),
          ),
        );

        final Iterable<Widget> selectableWidgets =
            tester.widgetList(find.byType(SelectableText));
        expect(selectableWidgets.length, 2);

        final SelectableText selectableTitle =
            selectableWidgets.first as SelectableText;
        expect(selectableTitle, isNotNull);
        expect(selectableTitle.onTap, isNotNull);
        selectableTitle.onTap!();
        expect(textTapResults == 'Text has been tapped.', true);

        textTapResults = null;
        final SelectableText selectableText =
            selectableWidgets.last as SelectableText;
        expect(selectableText, isNotNull);
        expect(selectableText.onTap, isNotNull);
        selectableText.onTap!();
        expect(textTapResults == 'Text has been tapped.', true);
      },
    );

    testWidgets(
      'header with line of text and onSelectionChanged callback',
      (WidgetTester tester) async {
        const String data = '# abc def ghi\njkl opq';
        String? selectableText;
        String? selectedText;
        void onSelectionChanged(String? text, TextSelection selection,
            SelectionChangedCause? cause) {
          selectableText = text;
          selectedText = text != null ? selection.textInside(text) : null;
        }

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: MarkdownBody(
                data: data,
                selectable: true,
                onSelectionChanged: onSelectionChanged,
              ),
            ),
          ),
        );

        // Find the positions before character 'd' and 'f'.
        final Offset dPos = positionInRenderedText(tester, 'abc def ghi', 4);
        final Offset fPos = positionInRenderedText(tester, 'abc def ghi', 6);
        // Select from 'd' until 'f'.
        final TestGesture firstGesture =
            await tester.startGesture(dPos, kind: PointerDeviceKind.mouse);
        addTearDown(firstGesture.removePointer);
        await tester.pump();
        await firstGesture.moveTo(fPos);
        await firstGesture.up();
        await tester.pump();

        expect(selectableText, 'abc def ghi');
        expect(selectedText, 'de');

        // Find the positions before character 'j' and 'o'.
        final Offset jPos = positionInRenderedText(tester, 'jkl opq', 0);
        final Offset oPos = positionInRenderedText(tester, 'jkl opq', 4);
        // Select from 'j' until 'o'.
        final TestGesture secondGesture =
            await tester.startGesture(jPos, kind: PointerDeviceKind.mouse);
        addTearDown(secondGesture.removePointer);
        await tester.pump();
        await secondGesture.moveTo(oPos);
        await secondGesture.up();
        await tester.pump();

        expect(selectableText, 'jkl opq');
        expect(selectedText, 'jkl ');
      },
    );
  });

  group('Strikethrough', () {
    testWidgets('single word', (WidgetTester tester) async {
      const String data = '~~strikethrough~~';
      await tester.pumpWidget(
        boilerplate(
          const MarkdownBody(data: data),
        ),
      );

      final Iterable<Widget> widgets = selfAndDescendantWidgetsOf(
        find.byType(MarkdownBody),
        tester,
      );
      expectWidgetTypes(widgets, <Type>[
        MarkdownBody,
        Column,
        Wrap,
        Text,
        RichText,
      ]);
      expectTextStrings(widgets, <String>['strikethrough']);
    });
  });
}
