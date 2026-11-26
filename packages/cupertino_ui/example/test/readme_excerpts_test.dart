// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// The README snippets intentionally demonstrate the deprecated migration
// utility.
// ignore_for_file: deprecated_member_use

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:cupertino_ui_examples/readme_excerpts.dart'
    show LegacyPackageWidget, MyApp, SubtreeExample;
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppWideUsage wraps the whole app in the bridge', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(CupertinoUiCompatibilityBridge), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(CupertinoUiCompatibilityBridge),
        matching: find.text('Home'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('SubtreeUsage wraps only the legacy subtree in the bridge', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CupertinoApp(home: SubtreeExample()));

    expect(find.text('Modern Screen'), findsOneWidget);
    expect(find.byType(CupertinoUiCompatibilityBridge), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(CupertinoUiCompatibilityBridge),
        matching: find.byType(LegacyPackageWidget),
      ),
      findsOneWidget,
    );

    // The navigation bar is outside the bridge.
    expect(
      find.descendant(
        of: find.byType(CupertinoUiCompatibilityBridge),
        matching: find.text('Modern Screen'),
      ),
      findsNothing,
    );

    expect(find.text('Legacy package widget'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
