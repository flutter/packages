// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/divider/divider.color.snippet.0.dart'
    as example;

void main() {
  testWidgets('Divider paints line with deepOrange color', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.ExampleApp());

    final Finder dividerFinder = find.byType(Divider);
    expect(dividerFinder, findsOneWidget);
    expect(dividerFinder, paints..path(color: Colors.deepOrange));
  });
}
