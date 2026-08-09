// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/refresh_indicator/refresh_indicator.1.dart'
    as example;

void main() {
  testWidgets('Pulling from nested scroll view triggers refresh indicator', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.RefreshIndicatorExampleApp());

    // Pull from the upper scroll view.
    await tester.fling(
      find.text('Pull down here').first,
      const Offset(0.0, 300.0),
      1000.0,
    );
    await tester.pump();
    expect(find.byType(RefreshProgressIndicator), findsNothing);
    await tester.pumpAndSettle(); // Advance pending time

    // Pull from the nested scroll view.
    await tester.fling(
      find.text('Pull down here').at(3),
      const Offset(0.0, 300.0),
      1000.0,
    );
    await tester.pump();
    expect(find.byType(RefreshProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle(); // Advance pending time
  });
}
