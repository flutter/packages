// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/expansion_panel/expansion_panel_list.1.dart'
    as example;

void main() {
  testWidgets('ExpansionPanel icon visibility can be toggled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const example.ExpansionPanelIconVisibilityExampleApp(),
    );

    final Finder firstHeader = find.widgetWithText(ListTile, 'Panel 1');
    final double visibleHeaderWidth = tester.getSize(firstHeader).width;
    expect(find.byType(ExpandIcon).hitTestable(), findsNWidgets(3));

    await tester.tap(find.text('Hidden'));
    await tester.pumpAndSettle();

    expect(find.byType(ExpandIcon).hitTestable(), findsNothing);
    expect(tester.getSize(firstHeader).width, visibleHeaderWidth);

    await tester.tap(find.text('Gone'));
    await tester.pumpAndSettle();

    expect(find.byType(ExpandIcon).hitTestable(), findsNothing);
    expect(tester.getSize(firstHeader).width, greaterThan(visibleHeaderWidth));
  });
}
