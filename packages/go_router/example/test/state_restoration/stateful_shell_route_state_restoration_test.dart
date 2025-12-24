// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router_examples/state_restoration/stateful_shell_route_state_restoration.dart';

void main() {
  testWidgets('StatefulShellRoute navigation location and route state '
      'is restored when restorationIds are provided', (
    WidgetTester tester,
  ) async {
    const homeLabel = 'Home';
    const profileLabel = 'Profile';

    const homeText = 'homeText';
    const profileText = 'profileText';

    await tester.pumpWidget(const App());
    expect(find.widgetWithText(TextField, homeLabel), findsOneWidget);

    await tester.enterText(find.byType(TextField), homeText);

    await tester.tap(find.byType(NavigationDestination).last);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, profileLabel), findsOneWidget);

    await tester.enterText(find.byType(TextField), profileText);
    // Trigger a frame so the text is saved
    await tester.pump();

    await tester.restartAndRestore();

    expect(find.widgetWithText(TextField, profileLabel), findsOneWidget);
    expect(find.text(profileText), findsOneWidget);

    await tester.tap(find.byType(NavigationDestination).first);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, homeLabel), findsOneWidget);
    expect(find.text(homeText), findsOneWidget);
  });
}
