// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/material_state/material_state_border_side.0.dart'
    as example;

void main() {
  Finder findBorderColor(Color color) {
    return find.byWidgetPredicate((Widget widget) {
      if (widget is! Material) {
        return false;
      }
      final ShapeBorder? shape = widget.shape;
      if (shape is! OutlinedBorder) {
        return false;
      }
      return shape.side.color == color;
    });
  }

  testWidgets('FilterChip displays the correct border when selected', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.MaterialStateBorderSideExampleApp());

    expect(findBorderColor(Colors.red), findsOne);
  });

  testWidgets('FilterChip displays the correct border when not selected', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.MaterialStateBorderSideExampleApp());

    await tester.tap(find.byType(FilterChip));
    await tester.pumpAndSettle();

    expect(findBorderColor(const Color(0xffcac4d0)), findsOne);
  });
}
