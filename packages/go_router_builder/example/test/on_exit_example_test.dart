// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router_builder_example/on_exit_example.dart';

void main() {
  testWidgets('It should trigger the on exit when leaving the route',
      (WidgetTester tester) async {
    await tester.pumpWidget(App());
    expect(find.byType(HomeScreen), findsOne);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Go to sub screen'));
    await tester.pumpAndSettle();

    expect(find.byType(SubScreen), findsOne);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Go back'));
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(AlertDialog, 'Are you sure to leave this page?'),
      findsOne,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsNothing);
    expect(find.byType(SubScreen), findsOne);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Go back'));
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(AlertDialog, 'Are you sure to leave this page?'),
      findsOne,
    );
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOne);
    expect(find.byType(SubScreen), findsNothing);
  });
}
