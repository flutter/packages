// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/badge/badge.0.dart' as example;

void main() {
  testWidgets('Verify Badges have label and count', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.BadgeExampleApp());
    // Verify that two Badge(s) are present
    expect(find.byType(Badge), findsNWidgets(2));

    // Verify that Badge.count displays label 999+ when count is greater than 999
    expect(find.text('999+'), findsOneWidget);

    // Verify that Badge displays custom label
    expect(find.text('Your label'), findsOneWidget);
  });
}
