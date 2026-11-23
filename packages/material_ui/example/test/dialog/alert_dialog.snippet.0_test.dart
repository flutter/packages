// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/dialog/alert_dialog.snippet.0.dart'
    as example;

void main() {
  testWidgets(
    'AlertDialog shows non-barrier-dismissible dialog and completes Future on Approve',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: example.AlertDialogExample())),
      );

      expect(find.byType(AlertDialog), findsNothing);

      final example.AlertDialogExampleState state = tester.state(
        find.byType(example.AlertDialogExample),
      );
      bool dialogCompleted = false;
      final Future<void> dialogFuture = state.showMyDialog().then((_) {
        dialogCompleted = true;
      });
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('AlertDialog Title'), findsOneWidget);
      expect(find.text('This is a demo alert dialog.'), findsOneWidget);
      expect(
        find.text('Would you like to approve of this message?'),
        findsOneWidget,
      );
      expect(dialogCompleted, isFalse);

      // Tapping outside the dialog does not dismiss it or complete the Future.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(dialogCompleted, isFalse);

      // Tapping Approve dismisses the dialog and completes the returned Future.
      await tester.tap(find.text('Approve'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(dialogCompleted, isTrue);
      await dialogFuture;
    },
  );
}
