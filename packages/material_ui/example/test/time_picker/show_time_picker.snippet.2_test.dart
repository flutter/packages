// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/time_picker/show_time_picker.snippet.2.dart'
    as example;

void main() {
  testWidgets('showTimePicker builder forces 24-hour format display', (
    WidgetTester tester,
  ) async {
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

    final Future<TimeOfDay?> future = example.pickTime24Hour(savedContext);
    await tester.pumpAndSettle();

    final BuildContext dialogContext = tester.element(
      find.byType(TimePickerDialog),
    );
    expect(MediaQuery.alwaysUse24HourFormatOf(dialogContext), isTrue);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('47'), findsOneWidget);
    expect(find.text('AM'), findsNothing);
    expect(find.text('PM'), findsNothing);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(await future, const TimeOfDay(hour: 10, minute: 47));
  });
}
