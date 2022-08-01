// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router_examples/main.dart' as example;

void main() {
  testWidgets('example works', (WidgetTester tester) async {
    await tester.pumpWidget(example.App());
    expect(find.text('Go to page 2'), findsOneWidget);

    await tester.tap(find.text('Go to page 2'));
    await tester.pumpAndSettle();
    expect(find.text('Go back to home page'), findsOneWidget);

    await tester.tap(find.text('Go back to home page'));
    await tester.pumpAndSettle();
    expect(find.text('Go to page 2'), findsOneWidget);
  });
}
