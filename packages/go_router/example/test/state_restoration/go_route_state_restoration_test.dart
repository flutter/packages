// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router_examples/state_restoration/go_route_state_restoration.dart';

void main() {
  testWidgets('GoRoute navigation location and route state '
      'is restored when restorationIds are provided', (
    WidgetTester tester,
  ) async {
    const String homeTitle = 'Home';
    const String loginTitle = 'Login';

    const String homeText = 'homeText';
    const String loginText = 'loginText';

    await tester.pumpWidget(const App());
    expect(find.text(homeTitle), findsOneWidget);

    await tester.enterText(find.byType(TextField), homeText);

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.text(loginTitle), findsOneWidget);

    await tester.enterText(find.byType(TextField), loginText);
    // Trigger a frame so the text is saved
    await tester.pump();

    await tester.restartAndRestore();

    expect(find.text(loginTitle), findsOneWidget);
    expect(find.text(loginText), findsOneWidget);

    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();

    expect(find.text(homeTitle), findsOneWidget);
    expect(find.text(homeText), findsOneWidget);
  });
}
