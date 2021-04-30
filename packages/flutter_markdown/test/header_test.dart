// Copyright 2020 Quiverware LLC. Open source contribution. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'utils.dart';

void main() => defineTests();

void defineTests() {
  group('Header', () {
    testWidgets(
      'level one',
      (WidgetTester tester) async {
        const String data = '# Header';
        await tester.pumpWidget(boilerplate(const MarkdownBody(data: data)));

        final Iterable<Widget> widgets = tester.allWidgets;
        expectWidgetTypes(widgets, <Type>[
          Directionality,
          MarkdownBody,
          Column,
          Wrap,
          RichText,
        ]);
        expectTextStrings(widgets, <String>['Header']);
      },
    );
  });
}
