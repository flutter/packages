// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/divider/divider.0.dart' as example;

void main() {
  testWidgets('Horizontal Divider', (WidgetTester tester) async {
    await tester.pumpWidget(const example.DividerExampleApp());

    expect(find.byType(Divider), findsOneWidget);

    // Divider is positioned horizontally.
    final Offset container = tester.getBottomLeft(
      find
          .descendant(
            of: find.byType(example.DividerExample),
            matching: find.byType(ColoredBox),
          )
          .first,
    );
    expect(container.dy, tester.getTopLeft(find.byType(Divider)).dy);

    final Offset subheader = tester.getTopLeft(find.text('Subheader'));
    expect(subheader.dy, tester.getBottomLeft(find.byType(Divider)).dy);
  });
}
