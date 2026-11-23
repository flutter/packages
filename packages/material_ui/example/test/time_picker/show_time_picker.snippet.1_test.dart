// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/time_picker/show_time_picker.snippet.1.dart'
    as example;

void main() {
  testWidgets('showTimePicker builder overrides text direction to RTL', (
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

    final Future<TimeOfDay?> future = example.pickTimeRTL(savedContext);
    await tester.pumpAndSettle();

    final BuildContext dialogContext = tester.element(
      find.byType(TimePickerDialog),
    );
    expect(Directionality.of(dialogContext), TextDirection.rtl);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(await future, isNotNull);
  });
}
