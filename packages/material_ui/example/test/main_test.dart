// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/main.dart' as example;

void main() {
  testWidgets('renders the showcase components', (WidgetTester tester) async {
    await tester.pumpWidget(const example.MaterialExampleApp());

    expect(find.byType(SegmentedButton<ThemeMode>), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.byType(FilterChip), findsNWidgets(3));
    expect(find.byType(Card), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('increments the counter when the FAB is tapped', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.MaterialExampleApp());
    expect(find.text('Button tapped 0 times'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    expect(find.text('Button tapped 1 times'), findsOneWidget);
  });

  testWidgets('changes theme mode via the segmented button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.MaterialExampleApp());

    MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.system);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    app = tester.widget(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
  });

  testWidgets('toggles the notifications switch', (WidgetTester tester) async {
    await tester.pumpWidget(const example.MaterialExampleApp());

    SwitchListTile tile = tester.widget(find.byType(SwitchListTile));
    expect(tile.value, isTrue);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    tile = tester.widget(find.byType(SwitchListTile));
    expect(tile.value, isFalse);
  });

  testWidgets('toggles a filter chip selection', (WidgetTester tester) async {
    await tester.pumpWidget(const example.MaterialExampleApp());

    // The 'Flutter' topic starts selected; tapping it clears the selection.
    FilterChip chip = tester.widget(find.widgetWithText(FilterChip, 'Flutter'));
    expect(chip.selected, isTrue);

    await tester.tap(find.text('Flutter'));
    await tester.pumpAndSettle();

    chip = tester.widget(find.widgetWithText(FilterChip, 'Flutter'));
    expect(chip.selected, isFalse);
  });
}
