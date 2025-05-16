// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router_examples/stream_listener_router.dart';

void main() {
  // For issue https://github.com/flutter/flutter/issues/150312.
  testWidgets('GoRouter.of(context).pop() works', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Navigate to the second page
    expect(find.text('Push ->'), findsOneWidget);
    await tester.tap(find.text('Push ->'));
    await tester.pumpAndSettle();

    // Navigate to the third page
    expect(find.text('Push ->'), findsOneWidget);
    await tester.tap(find.text('Push ->'));
    await tester.pumpAndSettle();

    // Verify we are on the second page
    expect(find.text('<- Go Back'), findsOneWidget);
    await tester.tap(find.text('<- Go Back'));
    await tester.pumpAndSettle();

    // Expect the Count is 1.
    expect(find.text('Count: 1'), findsOneWidget);

    // Check if we are pop back to the second page
    // and push to the third page again.
    expect(find.text('Push ->'), findsOneWidget);
    await tester.tap(find.text('Push ->'));
    await tester.pumpAndSettle();

    // Now we try pop again.
    expect(find.text('<- Go Back'), findsOneWidget);
    await tester.tap(find.text('<- Go Back'));
    await tester.pumpAndSettle();

    // Check count increment.
    expect(find.text('Count: 2'), findsOneWidget);
  });
}
