// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/scaffold/scaffold.1.dart' as example;

void main() {
  testWidgets(
    'The count should be incremented when the floating action button is tapped',
    (WidgetTester tester) async {
      await tester.pumpWidget(const example.ScaffoldExampleApp());

      expect(find.widgetWithText(AppBar, 'Sample Code'), findsOne);
      expect(find.widgetWithIcon(FloatingActionButton, Icons.add), findsOne);
      expect(find.text('You have pressed the button 0 times.'), findsOne);

      for (int i = 1; i <= 5; i++) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();
        expect(find.text('You have pressed the button $i times.'), findsOne);
      }

      final Scaffold scaffold = tester.firstWidget<Scaffold>(
        find.byType(Scaffold),
      );
      expect(scaffold.backgroundColor, Colors.blueGrey.shade200);
    },
  );
}
