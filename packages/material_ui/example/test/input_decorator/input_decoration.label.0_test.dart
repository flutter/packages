// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/input_decorator/input_decoration.label.0.dart'
    as example;

void main() {
  testWidgets('Decorates TextField in sample app with label', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.LabelExampleApp());
    expect(find.text('InputDecoration.label Sample'), findsOneWidget);

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('*'), findsOneWidget);
  });
}
