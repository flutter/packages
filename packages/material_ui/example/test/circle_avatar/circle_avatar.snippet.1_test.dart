// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/circle_avatar/circle_avatar.snippet.1.dart'
    as example;

void main() {
  testWidgets('CircleAvatar displays initials on brown circular background', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.ExampleApp());

    expect(find.text('AH'), findsOneWidget);
    expect(
      find.byType(CircleAvatar),
      paints..circle(color: Colors.brown.shade800),
    );
  });
}
