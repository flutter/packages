// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router_examples/shell_route.dart' as example;

void main() {
  testWidgets('example works', (WidgetTester tester) async {
    await tester.pumpWidget(example.ShellRouteExampleApp());
    expect(find.text('Screen A'), findsOneWidget);
    // navigate to a/details
    await tester.tap(find.text('View A details'));
    await tester.pumpAndSettle();
    expect(find.text('Details for A'), findsOneWidget);

    // navigate to ScreenB
    await tester.tap(find.text('B Screen'));
    await tester.pumpAndSettle();
    expect(find.text('Screen B'), findsOneWidget);

    // navigate to b/details
    await tester.tap(find.text('View B details'));
    await tester.pumpAndSettle();
    expect(find.text('Details for B'), findsOneWidget);

    // back to ScreenB.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // navigate to ScreenC
    await tester.tap(find.text('C Screen'));
    await tester.pumpAndSettle();
    expect(find.text('Screen C'), findsOneWidget);

    // navigate to c/details
    await tester.tap(find.text('View C details'));
    await tester.pumpAndSettle();
    expect(find.text('Details for C'), findsOneWidget);
  });
}
