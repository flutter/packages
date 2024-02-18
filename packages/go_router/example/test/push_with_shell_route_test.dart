// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router_examples/push_with_shell_route.dart' as example;

void main() {
  testWidgets('example works', (WidgetTester tester) async {
    await tester.pumpWidget(example.PushWithShellRouteExampleApp());
    expect(find.text('shell1'), findsOneWidget);

    await tester.tap(find.text('push the same shell route /shell1'));
    await tester.pumpAndSettle();
    expect(find.text('shell1'), findsOneWidget);
    expect(find.text('shell1 body'), findsOneWidget);

    find.text('shell1 body').evaluate().first.pop();
    await tester.pumpAndSettle();
    expect(find.text('shell1'), findsOneWidget);
    expect(find.text('shell1 body'), findsNothing);

    await tester.tap(find.text('push the different shell route /shell2'));
    await tester.pumpAndSettle();
    expect(find.text('shell1'), findsNothing);
    expect(find.text('shell2'), findsOneWidget);
    expect(find.text('shell2 body'), findsOneWidget);

    find.text('shell2 body').evaluate().first.pop();
    await tester.pumpAndSettle();
    expect(find.text('shell1'), findsOneWidget);
    expect(find.text('shell2'), findsNothing);

    await tester.tap(find.text('push the regular route /regular-route'));
    await tester.pumpAndSettle();
    expect(find.text('shell1'), findsNothing);
    expect(find.text('regular route'), findsOneWidget);

    find.text('regular route').evaluate().first.pop();
    await tester.pumpAndSettle();
    expect(find.text('shell1'), findsOneWidget);
    expect(find.text('regular route'), findsNothing);
  });
}
