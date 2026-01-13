// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router_examples/state_restoration/shell_route_state_restoration.dart';

void main() {
  testWidgets('ShellRoute navigation location and route state '
      'is restored when restorationIds are provided', (
    WidgetTester tester,
  ) async {
    const homeTitle = 'Home';
    const welcomeTitle = 'Welcome';
    const setupTitle = 'Setup';

    const homeText = 'homeText';
    const setupText = 'setupText';

    await tester.pumpWidget(const App());
    expect(find.text(homeTitle), findsOneWidget);

    await tester.enterText(find.byType(TextField), homeText);

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.text(welcomeTitle), findsOneWidget);

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.text(setupTitle), findsOneWidget);

    await tester.enterText(find.byType(TextField), setupText);
    // Trigger a frame so the text is saved
    await tester.pump();

    await tester.restartAndRestore();

    expect(find.text(setupTitle), findsOneWidget);
    expect(find.text(setupText), findsOneWidget);

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text(homeTitle), findsOneWidget);
    expect(find.text(homeText), findsOneWidget);
  });
}
