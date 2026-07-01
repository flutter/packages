// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/date_picker/show_date_range_picker.0.dart'
    as example;

void main() {
  testWidgets('Can show date range picker', (WidgetTester tester) async {
    const String datePickerTitle = 'Select range';

    await tester.pumpWidget(const example.DatePickerApp());

    // The date range picker is not shown initially.
    expect(find.text(datePickerTitle), findsNothing);
    expect(find.text('Jan 1'), findsNothing);
    expect(find.text('Jan 5, 2021'), findsNothing);

    // Tap the button to show the date range picker.
    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();

    // The date range picker shows initial date range.
    expect(find.text(datePickerTitle), findsOneWidget);
    expect(find.text('Jan 1'), findsOneWidget);
    expect(find.text('Jan 5, 2021'), findsOneWidget);

    // Tap to select new date range.
    await tester.tap(find.text('18').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('22').first);
    await tester.pumpAndSettle();

    // The selected date range is shown.
    expect(find.text(datePickerTitle), findsOneWidget);
    expect(find.text('Jan 18'), findsOneWidget);
    expect(find.text('Jan 22, 2021'), findsOneWidget);

    // Tap Save to confirm the selection and close the date range picker.
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // The date range picker is closed.
    expect(find.text(datePickerTitle), findsNothing);
    expect(find.text('Jan 18'), findsNothing);
    expect(find.text('Jan 22, 2021'), findsNothing);
  });
}
