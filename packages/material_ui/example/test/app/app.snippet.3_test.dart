// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/app/app.snippet.3.dart' as example;

void main() {
  testWidgets('WidgetsApp includes select key shortcut in shortcuts map', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.MaterialAppExample());

    expect(find.byType(Placeholder), findsOneWidget);

    final WidgetsApp app = tester.widget<WidgetsApp>(find.byType(WidgetsApp));
    expect(
      app.shortcuts?[const SingleActivator(LogicalKeyboardKey.select)],
      isA<ActivateIntent>(),
    );
  });
}
