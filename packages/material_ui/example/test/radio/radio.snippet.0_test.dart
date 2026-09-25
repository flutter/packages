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
    Widget buildApp({required bool enabled}) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: RadioGroup<int>(
              groupValue: 1,
              onChanged: (int? _) {},
              child: AbsorbPointer(
                absorbing: !enabled,
                child: const example.RadioExample(),
              ),
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildApp(enabled: true));
    await tester.pumpAndSettle();
    final Radio<int> radio = tester.widget<Radio<int>>(find.byType(Radio<int>));
    expect(radio.fillColor!.resolve(<WidgetState>{}), Colors.orange);
    expect(
      radio.fillColor!.resolve(<WidgetState>{WidgetState.disabled}),
      Colors.orange.withValues(alpha: .32),
    );
  });
}
