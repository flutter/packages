// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router_examples/others/custom_stateful_shell_route.dart';

void main() {
  testWidgets(
      'Changing active tab in TabController (in TabbedRootScreen, '
      'Section B) correctly navigates to appropriate screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(NestedTabNavigationExampleApp());
    expect(find.text('Screen A'), findsOneWidget);

    // navigate to ScreenB
    await tester.tap(find.text('Section B'));
    await tester.pumpAndSettle();
    expect(find.text('Screen B1'), findsOneWidget);

    final TabController? tabController =
        tabbedRootScreenKey.currentState?.tabController;
    expect(tabController, isNotNull);

    tabbedRootScreenKey.currentState?.tabController.index = 1;
    await tester.pumpAndSettle();
    expect(find.text('Screen B2'), findsOneWidget);
  });
}
