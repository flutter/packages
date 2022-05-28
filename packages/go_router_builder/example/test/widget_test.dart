// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router_builder_example/main.dart';

void main() {
  testWidgets('Validate extra logic walkthrough', (WidgetTester tester) async {
    await tester.pumpWidget(App());

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Push home'));
    await tester.pumpAndSettle();

    expect(find.text('Push home'), findsOneWidget);
    expect(find.text('Push home', skipOffstage: false), findsNWidgets(2));

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sells'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Chris'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('hobbies - coding'));
    await tester.pumpAndSettle();

    expect(find.text('No extra click!'), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('With extra...').first);
    await tester.pumpAndSettle();

    expect(find.text('Extra click count: 1'), findsOneWidget);
  });
}
