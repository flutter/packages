// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/tooltip_theme/tooltip_theme.snippet.0.dart'
    as example;

void main() {
  testWidgets(
    'TooltipTheme applies blue BoxDecoration with zero borderRadius to Tooltip',
    (WidgetTester tester) async {
      await tester.pumpWidget(const example.ExampleApp());

      await tester.longPress(find.byType(IconButton));
      await tester.pumpAndSettle();

      final Finder tooltipText = find.text('Example tooltip');
      expect(tooltipText, findsOneWidget);

      final Container tooltipContainer = tester.widget<Container>(
        find.ancestor(of: tooltipText, matching: find.byType(Container)).first,
      );
      final BoxDecoration decoration =
          tooltipContainer.decoration! as BoxDecoration;
      expect(decoration.color, Colors.blue.withValues(alpha: 0.9));
      expect(decoration.borderRadius, BorderRadius.zero);
    },
  );
}
