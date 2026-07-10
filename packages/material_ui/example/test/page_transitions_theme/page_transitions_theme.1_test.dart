// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/page_transitions_theme/page_transitions_theme.1.dart'
    as example;

void main() {
  testWidgets('MaterialApp defines a custom PageTransitionsTheme', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.PageTransitionsThemeApp());

    final Finder homePage = find.byType(example.HomePage);
    expect(homePage, findsOneWidget);

    final PageTransitionsTheme theme = Theme.of(
      tester.element(homePage),
    ).pageTransitionsTheme;
    expect(theme.builders, isNotNull);

    // Check defined page transitions builder for each platform.
    for (final TargetPlatform platform in TargetPlatform.values) {
      switch (platform) {
        case .android:
          expect(theme.builders[platform], isA<ZoomPageTransitionsBuilder>());
          final ZoomPageTransitionsBuilder builder =
              theme.builders[platform]! as ZoomPageTransitionsBuilder;
          expect(builder.allowSnapshotting, isFalse);
        case .iOS:
        case .macOS:
        case .linux:
        case .fuchsia:
        case .windows:
          expect(theme.builders[platform], isNull);
      }
    }

    // Can navigate to the second page.
    expect(find.text('To SecondPage'), findsOneWidget);
    await tester.tap(find.text('To SecondPage'));
    await tester.pumpAndSettle();

    // Can navigate back to the home page.
    expect(find.text('Back to HomePage'), findsOneWidget);
    await tester.tap(find.text('Back to HomePage'));
    await tester.pumpAndSettle();
    expect(find.text('To SecondPage'), findsOneWidget);
  });
}
