// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/selection_area/selection_area.1.dart'
    as example;

void main() {
  testWidgets('SelectionArea SelectionListener Example Smoke Test', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const example.SelectionAreaSelectionListenerExampleApp(),
    );
    expect(find.byType(Column), findsNWidgets(2));
    expect(find.textContaining('Selection StartOffset:'), findsOneWidget);
    expect(find.textContaining('Selection EndOffset:'), findsOneWidget);
    expect(find.textContaining('Selection Status:'), findsOneWidget);
    expect(find.textContaining('Selectable Region Status:'), findsOneWidget);
    expect(
      find.textContaining(
        'This is some text under a SelectionArea that can be selected.',
      ),
      findsOneWidget,
    );
  });
}
