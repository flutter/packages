// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/app_bar/app_bar.3.dart' as example;

void main() {
  testWidgets(
    'AppBar elevates when nested scroll view is scrolled underneath the AppBar',
    (WidgetTester tester) async {
      Material getMaterial() => tester.widget<Material>(
        find
            .descendant(
              of: find.byType(AppBar),
              matching: find.byType(Material),
            )
            .first,
      );

      await tester.pumpWidget(const example.AppBarApp());

      // Starts with the base elevation.
      expect(getMaterial().elevation, 0.0);

      await tester.fling(
        find.text('Beach 3'),
        const Offset(0.0, -600.0),
        2000.0,
      );
      await tester.pumpAndSettle();

      // After scrolling it should be the scrolledUnderElevation.
      expect(getMaterial().elevation, 4.0);
    },
  );
}
