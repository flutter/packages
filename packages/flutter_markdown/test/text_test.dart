// Copyright 2020 Quiverware LLC. Open source contribution. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
        final markdown = const Markdown(data: 'Data1');

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

        final Iterable<Widget> widgets = tester.allWidgets;
        expectWidgetTypes(
            widgets, <Type>[Directionality, MarkdownBody, Column]);
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

        final Iterable<Widget> widgets = tester.allWidgets;
        expectWidgetTypes(widgets,
            <Type>[Directionality, MarkdownBody, Column, Wrap, RichText]);
        expectTextStrings(widgets, <String>['Hello']);
      },
    );
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

        final Iterable<Widget> widgets = tester.allWidgets;
        expectWidgetTypes(widgets,
            <Type>[Directionality, MarkdownBody, Column, Wrap, RichText]);
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

        final Iterable<Widget> widgets = tester.allWidgets;
        expectWidgetTypes(widgets,
            <Type>[Directionality, MarkdownBody, Column, Wrap, RichText]);
        expectTextStrings(widgets, <String>['line 1\nline 2']);
      },
    );

    testWidgets(
      'non-applicable line break',
      (WidgetTester tester) async {
        const String data = 'line 1.\nline 2.';
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(data: data),
          ),
        );

        final Iterable<Widget> widgets = tester.allWidgets;
        expectWidgetTypes(widgets,
            <Type>[Directionality, MarkdownBody, Column, Wrap, RichText]);
        expectTextStrings(widgets, <String>['line 1. line 2.']);
      },
    );

    testWidgets(
      'non-applicable line break',
      (WidgetTester tester) async {
        const String data = 'line 1.\nline 2.';
        await tester.pumpWidget(
          boilerplate(
            MarkdownBody(data: data),
          ),
        );

        final Iterable<Widget> widgets = tester.allWidgets;
        expectWidgetTypes(widgets,
            <Type>[Directionality, MarkdownBody, Column, Wrap, RichText]);
        expectTextStrings(widgets, <String>['line 1. line 2.']);
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
            MediaQuery(
              data: MediaQueryData(),
              child: const Markdown(
                data: data,
                selectable: true,
              ),
            ),
          ),
        );

        expect(find.byType(SelectableText), findsNWidgets(2));
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

      final Iterable<Widget> widgets = tester.allWidgets;
      expectWidgetTypes(widgets,
          <Type>[Directionality, MarkdownBody, Column, Wrap, RichText]);
      expectTextStrings(widgets, <String>['strikethrough']);
    });
  });
}
