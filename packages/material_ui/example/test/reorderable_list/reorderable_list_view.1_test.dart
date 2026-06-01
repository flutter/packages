// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/reorderable_list/reorderable_list_view.1.dart'
    as example;

void main() {
  testWidgets('Dragged item color is updated', (WidgetTester tester) async {
    await tester.pumpWidget(const example.ReorderableApp());

    final ThemeData theme = Theme.of(tester.element(find.byType(MaterialApp)));

    // Dragged item is wrapped in a Material widget with correct color.
    final TestGesture drag = await tester.startGesture(
      tester.getCenter(find.text('Item 1')),
    );
    await tester.pump(kLongPressTimeout + kPressTimeout);
    await tester.pumpAndSettle();
    final Material material = tester.widget<Material>(
      find.ancestor(of: find.text('Item 1'), matching: find.byType(Material)),
    );
    expect(material.color, theme.colorScheme.secondary);

    // Ends the drag gesture.
    await drag.moveTo(tester.getCenter(find.text('Item 4')));
    await drag.up();
    await tester.pumpAndSettle();
  });
}
