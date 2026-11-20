// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/tabs/tab.height.snippet.0.dart' as example;

void main() {
  testWidgets(
    'PreferredSize adjusts AppBar and TabBar height for custom Tab.height of 20.0',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: example.TabHeightExample()),
      );

      expect(tester.getSize(find.byType(AppBar)).height, kToolbarHeight + 20.0);
      expect(tester.getSize(find.widgetWithText(Tab, 'Tab 1')).height, 20.0);
      expect(tester.getSize(find.widgetWithText(Tab, 'Tab 2')).height, 20.0);
      // TabBar height equals Tab.height (20.0) + default indicatorWeight (2.0).
      expect(tester.getSize(find.byType(TabBar)).height, 22.0);
    },
  );
}
