// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui_examples/app/app.1.dart' as example;

void main() {
  testWidgets('MaterialApp.router navigates to the details page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.MaterialAppRouterExample());

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Details'), findsNothing);

    await tester.tap(find.text('Go to details'));
    await tester.pumpAndSettle();

    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Page 1'), findsOneWidget);
  });
}
