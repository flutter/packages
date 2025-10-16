// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router_examples/routing_config.dart' as example;

void main() {
  testWidgets('example works', (WidgetTester tester) async {
    await tester.pumpWidget(const example.MyApp());
    expect(find.text('Add a new route'), findsOneWidget);

    await tester.tap(find.text('Try going to /new-route'));
    await tester.pumpAndSettle();

    expect(find.text('Page not found'), findsOneWidget);

    await tester.tap(find.text('Go to home'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add a new route'));
    await tester.pumpAndSettle();

    expect(find.text('A route has been added'), findsOneWidget);

    await tester.tap(find.text('Try going to /new-route'));
    await tester.pumpAndSettle();

    expect(find.text('A new Route'), findsOneWidget);
  });
}
