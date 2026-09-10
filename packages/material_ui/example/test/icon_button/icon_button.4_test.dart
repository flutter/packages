// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/icon_button/icon_button.4.dart' as example;

void main() {
  testWidgets('M3E IconButton example shows expressive variants', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.IconButtonM3EExampleApp());

    expect(find.text('Styles'), findsNothing);
    expect(find.text('Sizes'), findsOneWidget);
    expect(find.text('Widths'), findsOneWidget);

    final BuildContext context = tester.element(
      find.byType(example.IconButtonM3EExample),
    );
    expect(
      IconButtonTheme.of(context).variant,
      StyleVariant.material3Expressive,
    );

    final IconButton extraSmall = tester.widget<IconButton>(
      find.byKey(const ValueKey<String>('m3e-icon-button-x-small')),
    );
    expect(extraSmall.style?.sizeVariant, ButtonSizeVariant.xSmall);

    final IconButton wide = tester.widget<IconButton>(
      find.byKey(const ValueKey<String>('m3e-icon-button-width-wide')),
    );
    expect(wide.style?.iconButtonWidth, IconButtonWidthVariant.wide);
    expect(wide.style?.sizeVariant, ButtonSizeVariant.medium);

    await tester.scrollUntilVisible(find.text('Shapes'), 200.0);
    expect(find.text('Shapes'), findsOneWidget);

    final IconButton square = tester.widget<IconButton>(
      find.byKey(const ValueKey<String>('m3e-icon-button-shape-square')),
    );
    expect(square.style?.shapeVariant, ButtonShapeVariant.square);
    expect(square.style?.sizeVariant, isNull);
  });

  testWidgets('M3E IconButton example buttons can be selected and unselected', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.IconButtonM3EExampleApp());

    await _expectCanToggle(
      tester,
      const ValueKey<String>('m3e-icon-button-x-small'),
    );
    await _expectCanToggle(
      tester,
      const ValueKey<String>('m3e-icon-button-width-wide'),
    );
    await _expectCanToggle(
      tester,
      const ValueKey<String>('m3e-icon-button-shape-square'),
    );
  });
}

Future<void> _expectCanToggle(WidgetTester tester, Key key) async {
  final Finder finder = find.byKey(key);
  await tester.ensureVisible(finder);
  await tester.pump();

  expect(tester.widget<IconButton>(finder).isSelected, isFalse);

  await tester.tap(finder);
  await tester.pump();
  expect(tester.widget<IconButton>(finder).isSelected, isTrue);

  await tester.tap(finder);
  await tester.pump();
  expect(tester.widget<IconButton>(finder).isSelected, isFalse);
}
