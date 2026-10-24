// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/scaffold/scaffold.snippet.1.dart'
    as example;

void main() {
  testWidgets(
    'floatingActionButtonLocation positions the FloatingActionButton',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: example.ScaffoldExample()),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      final Scaffold scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(
        scaffold.floatingActionButtonLocation,
        FloatingActionButtonLocation.centerTop,
      );
    },
  );
}
