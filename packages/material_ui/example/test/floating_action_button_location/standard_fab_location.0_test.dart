// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/floating_action_button_location/standard_fab_location.0.dart'
    as example;

void main() {
  testWidgets('The FloatingActionButton should have a right padding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.StandardFabLocationExampleApp());

    expect(find.widgetWithIcon(FloatingActionButton, Icons.add), findsOne);
    final double right = tester.getCenter(find.byType(FloatingActionButton)).dx;
    expect(right, closeTo(706, 1));
  });
}
