// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/app/app.snippet.4.dart' as example;

void main() {
  testWidgets('WidgetsApp registers custom CallbackAction for ActivateAction', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.MaterialAppExample());

    expect(find.byType(Placeholder), findsOneWidget);

    final WidgetsApp app = tester.widget<WidgetsApp>(find.byType(WidgetsApp));
    final Action<Intent>? action = app.actions?[ActivateAction];
    expect(action, isA<CallbackAction<Intent>>());
    expect(
      (action! as CallbackAction<Intent>).invoke(const ActivateIntent()),
      isNull,
    );
  });
}
