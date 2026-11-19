// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/dialog/simple_dialog.snippet.0.dart'
    as example;

class _DialogObserver extends NavigatorObserver {
  Future<dynamic>? lastPopped;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    lastPopped = route.popped;
  }
}

void main() {
  testWidgets(
    'SimpleDialog returns selected Department or null when dismissed',
    (WidgetTester tester) async {
      final _DialogObserver observer = _DialogObserver();
      late BuildContext savedContext;

      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: <NavigatorObserver>[observer],
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                savedContext = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      final example.SimpleDialogExample dialogExample =
          example.SimpleDialogExample(savedContext);

      // Select Treasury department.
      Future<void> future = dialogExample.askedToLead();
      await tester.pumpAndSettle();
      expect(find.text('Select assignment'), findsOneWidget);
      Future<dynamic> popped = observer.lastPopped!;
      await tester.tap(find.text('Treasury department'));
      await tester.pumpAndSettle();
      expect(await popped, example.Department.treasury);
      await future;

      // Select State department.
      future = dialogExample.askedToLead();
      await tester.pumpAndSettle();
      popped = observer.lastPopped!;
      await tester.tap(find.text('State department'));
      await tester.pumpAndSettle();
      expect(await popped, example.Department.state);
      await future;

      // Dismiss dialog by tapping the barrier.
      future = dialogExample.askedToLead();
      await tester.pumpAndSettle();
      popped = observer.lastPopped!;
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(await popped, isNull);
      await future;
    },
  );
}
