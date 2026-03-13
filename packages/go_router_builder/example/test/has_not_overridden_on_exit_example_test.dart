// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router_builder_example/has_not_overridden_on_exit_example.dart';

void main() {
  testWidgets('HomeScreen should return result from Sub2Screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(App());
    expect(find.byType(HomeScreen), findsOne);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Go to sub 1 screen'));
    await tester.pumpAndSettle();

    expect(find.byType(Sub1Screen), findsOne);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Go to sub 2 screen'));
    await tester.pumpAndSettle();

    expect(find.byType(Sub2Screen), findsOne);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Go back to sub 1 screen'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOne);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Sub2Screen'));

    expect(find.byType(Sub1Screen), findsNothing);
    expect(find.byType(Sub2Screen), findsNothing);
  });
}
