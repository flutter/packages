// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/menu_anchor/menu_anchor.on_animation_status_changed.snippet.0.dart'
    as example;

void main() {
  testWidgets(
    'MenuAnchor.onAnimationStatusChanged toggles opening and closing mid-animation',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: example.MenuAnchorExample())),
      );

      expect(find.text('Menu Item'), findsNothing);

      // Tap to start opening animation.
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Menu Item'), findsOneWidget);

      // Tap again while forward/opening to reverse and close the menu.
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      expect(find.text('Menu Item'), findsNothing);

      // Tap to open completely, then tap to close completely.
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      expect(find.text('Menu Item'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      expect(find.text('Menu Item'), findsNothing);
    },
  );
}
