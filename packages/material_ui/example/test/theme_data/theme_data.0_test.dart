// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/theme_data/theme_data.0.dart' as example;

void main() {
  testWidgets('ThemeData basics', (WidgetTester tester) async {
    await tester.pumpWidget(const example.ThemeDataExampleApp());

    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
    );

    final Material fabMaterial = tester.widget<Material>(
      find.descendant(
        of: find.byType(FloatingActionButton),
        matching: find.byType(Material),
      ),
    );
    expect(fabMaterial.color, colorScheme.tertiary);

    final RichText iconRichText = tester.widget<RichText>(
      find.descendant(
        of: find.byIcon(Icons.add),
        matching: find.byType(RichText),
      ),
    );
    expect(iconRichText.text.style!.color, colorScheme.onTertiary);

    expect(find.text('8 Points'), isNotNull);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('9 Points'), isNotNull);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('10 Points'), isNotNull);
  });
}
