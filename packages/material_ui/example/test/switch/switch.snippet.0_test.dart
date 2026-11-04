// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/switch/switch.snippet.0.dart' as example;

void main() {
  testWidgets('Switch thumbColor resolves based on enabled state', (
    WidgetTester tester,
  ) async {
    Widget buildApp({required ValueChanged<bool>? onChanged}) {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: example.SwitchExample(onChanged: onChanged)),
        ),
      );
    }

    await tester.pumpWidget(buildApp(onChanged: (bool _) {}));
    await tester.pumpAndSettle();
    expect(
      find.byType(Switch),
      paints
        ..rrect()
        ..rrect()
        ..rrect(color: Colors.orange),
    );

    await tester.pumpWidget(buildApp(onChanged: null));
    await tester.pumpAndSettle();
    expect(
      find.byType(Switch),
      paints
        ..rrect()
        ..rrect()
        ..rrect(
          color: Color.alphaBlend(
            Colors.orange.withValues(alpha: .48),
            ThemeData().colorScheme.surface,
          ),
        ),
    );
  });
}
