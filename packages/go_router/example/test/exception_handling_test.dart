// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router_examples/exception_handling.dart' as example;

void main() {
  testWidgets('example works', (WidgetTester tester) async {
    await tester.pumpWidget(const example.MyApp());
    expect(find.text('Simulates user entering unknown url'), findsOneWidget);

    await tester.tap(find.text('Simulates user entering unknown url'));
    await tester.pumpAndSettle();
    expect(find.text("Can't find a page for: /some-unknown-route"),
        findsOneWidget);
  });
}
