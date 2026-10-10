// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/radio/radio.snippet.0.dart' as example;

void main() {
  testWidgets('Radio fillColor resolves based on enabled state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: RadioGroup<int>(
              groupValue: 1,
              onChanged: (int? _) {},
              child: const example.RadioExample(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byType(Radio<int>),
      paints
        ..circle()
        ..circle(color: Colors.orange.shade500),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: example.RadioExample())),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byType(Radio<int>),
      paints
        ..circle()
        ..circle(color: Colors.orange.withValues(alpha: .32)),
    );
  });
}
