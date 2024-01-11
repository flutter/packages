// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router_builder_example/shell_route_example.dart';

void main() {
  testWidgets('Navigate from /foo to /bar', (WidgetTester tester) async {
    await tester.pumpWidget(App());
    expect(find.byType(FooScreen), findsOneWidget);

    await tester.tap(find.text('Bar'));
    await tester.pumpAndSettle();
    expect(find.byType(BarScreen), findsOneWidget);
  });
}
