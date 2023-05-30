// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router_builder_example/shell_route_with_keys_example.dart';

void main() {
  testWidgets('Navigate from /home to /users', (WidgetTester tester) async {
    await tester.pumpWidget(App());
    expect(find.text('The home page'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.group));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsNWidgets(3));
  });
}
