// Copyright 2020 Quiverware LLC. Open source contribution. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'utils.dart';

void main() => defineTests();

void defineTests() {
  group('Blockquote', () {
    testWidgets(
      'simple one word blockquote',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          boilerplate(
            const MarkdownBody(data: '> quote'),
          ),
        );

        final Iterable<Widget> widgets = tester.allWidgets;
        expectTextStrings(widgets, <String>['quote']);
      },
    );
  });
}
