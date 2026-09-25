// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/app/app.snippet.0.dart' as example;

void main() {
  testWidgets(
    'MaterialApp displays home route and disables debug mode banner',
    (WidgetTester tester) async {
      await tester.pumpWidget(const example.MaterialAppExample());

      final MaterialApp app = tester.widget<MaterialApp>(
        find.byType(MaterialApp),
      );
      expect(app.debugShowCheckedModeBanner, isFalse);
      expect(find.widgetWithText(AppBar, 'Home'), findsOneWidget);
    },
  );
}
