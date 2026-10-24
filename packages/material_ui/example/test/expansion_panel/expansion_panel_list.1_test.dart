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

    expect(find.byType(ExpandIcon), findsNWidgets(3));

    final Finder visibilityFinder = find
        .ancestor(
          of: find.byType(ExpandIcon).first,
          matching: find.byType(Visibility),
        )
        .first;

    Visibility visibility = tester.widget(visibilityFinder);
    expect(visibility.visible, isTrue);

    await tester.tap(find.text('Hidden'));
    await tester.pumpAndSettle();

    visibility = tester.widget(visibilityFinder);
    expect(visibility.visible, isFalse);
    expect(visibility.maintainSize, isTrue);

    await tester.tap(find.text('Gone'));
    await tester.pumpAndSettle();

    expect(find.byType(ExpandIcon), findsNothing);
  });
}
