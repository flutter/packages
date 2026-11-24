// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/tab_controller/tab_controller.snippet.0.dart'
    as example;

void main() {
  testWidgets(
    'MyTabbedPage displays Scaffold with AppBar TabBar and switches TabBarView',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: example.MyTabbedPage()));

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.text('This is the left tab'), findsOneWidget);
      expect(find.text('This is the right tab'), findsNothing);

      await tester.tap(find.text('RIGHT'));
      await tester.pumpAndSettle();

      expect(find.text('This is the right tab'), findsOneWidget);
      expect(find.text('This is the left tab'), findsNothing);
    },
  );
}
