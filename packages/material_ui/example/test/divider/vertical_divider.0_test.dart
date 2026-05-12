// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/divider/vertical_divider.0.dart'
    as example;

void main() {
  testWidgets('Vertical Divider', (WidgetTester tester) async {
    await tester.pumpWidget(const example.VerticalDividerExampleApp());

    expect(find.byType(VerticalDivider), findsOneWidget);

    // Divider is positioned horizontally.
    Offset expanded = tester.getTopRight(find.byType(Expanded).first);
    expect(expanded.dx, tester.getTopLeft(find.byType(VerticalDivider)).dx);

    expanded = tester.getTopLeft(find.byType(Expanded).last);
    expect(expanded.dx, tester.getTopRight(find.byType(VerticalDivider)).dx);
  });
}
