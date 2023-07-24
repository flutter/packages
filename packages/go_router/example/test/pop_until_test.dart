// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router_examples/pop_until.dart' as example;

void main() {
  testWidgets('example works', (WidgetTester tester) async {
    await tester.pumpWidget(const example.MyApp());
    expect(find.text('Go to the Details screen'), findsOneWidget);

    await tester.tap(find.text('Go to the Details screen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Push another Details screen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Push another Details screen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Push another Details screen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Push another Details screen'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pop to Home'));
    await tester.pumpAndSettle();
    expect(find.text('Go to the Details screen'), findsOneWidget);
  });
}
