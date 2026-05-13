// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router_builder_example/stateful_shell_route_example.dart';

void main() {
  testWidgets('Navigate between section A and section B', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(App());
    expect(find.text('Details for A - Counter: 0'), findsOneWidget);

    await tester.tap(find.text('Increment counter'));
    await tester.pumpAndSettle();
    expect(find.text('Details for A - Counter: 1'), findsOneWidget);

    await tester.tap(find.text('Section B'));
    await tester.pumpAndSettle();
    expect(find.text('Details for B - Counter: 0'), findsOneWidget);

    await tester.tap(find.text('Section A'));
    await tester.pumpAndSettle();
    expect(find.text('Details for A - Counter: 1'), findsOneWidget);
  });
}
