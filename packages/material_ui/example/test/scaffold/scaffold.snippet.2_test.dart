// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/scaffold/scaffold.snippet.2.dart'
    as example;

void main() {
  testWidgets(
    'persistentFooterButtons renders above the BottomNavigationBar',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: example.ScaffoldExample()),
      );

      expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Save'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    },
  );
}
