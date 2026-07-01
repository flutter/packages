// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/app_bar/app_bar.2.dart' as example;

void main() {
  testWidgets('Appbar and actions', (WidgetTester tester) async {
    await tester.pumpWidget(const example.AppBarApp());

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Action 1'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Action 2'), findsOneWidget);
  });
}
