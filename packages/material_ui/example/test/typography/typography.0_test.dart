// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/typography/typography.0.dart' as example;

void main() {
  testWidgets('Toggles between baseline and emphasized text styles', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.TypographyExampleApp());

    final TextTheme textTheme = TextTheme.of(
      tester.element(find.byType(example.TypographyExample)),
    );
    TextStyle? styleOf(String text) =>
        tester.widget<Text>(find.text(text)).style;

    expect(find.text('md.sys.typescale'), findsWidgets);
    expect(find.text('md.sys.typescale.emphasized'), findsNothing);
    expect(styleOf('Display Large'), textTheme.displayLarge);

    await tester.tap(find.text('Emphasized'));
    await tester.pumpAndSettle();

    expect(find.text('md.sys.typescale'), findsNothing);
    expect(find.text('md.sys.typescale.emphasized'), findsWidgets);
    expect(styleOf('Display Large'), textTheme.displayLargeEmphasized);

    await tester.scrollUntilVisible(find.text('Title Medium'), 200);
    expect(styleOf('Title Medium'), textTheme.titleMediumEmphasized);

    await tester.tap(find.text('Baseline'));
    await tester.pumpAndSettle();

    expect(styleOf('Title Medium'), textTheme.titleMedium);
  });
}
