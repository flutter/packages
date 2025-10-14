// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router_builder_example/stateful_shell_route_initial_location_example.dart';

void main() {
  testWidgets(
    'Navigate to Notifications section with old tab selected by default',
    (WidgetTester tester) async {
      await tester.pumpWidget(App());
      expect(find.text('Home'), findsOneWidget);

      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();
      expect(find.text('Old notifications'), findsOneWidget);
    },
  );
}
