// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/time_picker/show_time_picker.snippet.0.dart'
    as example;

void main() {
  testWidgets(
    'showTimePicker resolves to TimeOfDay on OK and null when canceled',
    (WidgetTester tester) async {
      late BuildContext savedContext;
      await tester.pumpWidget(
        MaterialApp(
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

      Future<TimeOfDay?> future = example.pickTime(savedContext);
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(await future, isNotNull);

      future = example.pickTime(savedContext);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(await future, isNull);
    },
  );
}
