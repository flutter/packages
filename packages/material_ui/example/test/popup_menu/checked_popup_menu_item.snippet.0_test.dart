// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/popup_menu/checked_popup_menu_item.snippet.0.dart'
    as example;

class _PopupObserver extends NavigatorObserver {
  Future<dynamic>? lastPopped;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    lastPopped = route.popped;
  }
}

void main() {
  testWidgets(
    'CheckedPopupMenuItem toggles checkmark and handles second command',
    (WidgetTester tester) async {
      final _PopupObserver observer = _PopupObserver();
      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: <NavigatorObserver>[observer],
          home: const Scaffold(body: example.CheckedPopupMenuItemExample()),
        ),
      );

      // Open menu: initially unchecked, with divider and aligned second item.
      await tester.tap(find.byType(PopupMenuButton<example.Commands>));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<CheckedPopupMenuItem<example.Commands>>(
              find.byType(CheckedPopupMenuItem<example.Commands>),
            )
            .checked,
        isFalse,
      );
      expect(find.byType(PopupMenuDivider), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Hero and scholar')).dx,
        tester.getTopLeft(find.text('Bring hurricane')).dx,
      );

      // Tap CheckedPopupMenuItem to toggle _heroAndScholar to true.
      await tester.tap(find.byType(CheckedPopupMenuItem<example.Commands>));
      await tester.pumpAndSettle();

      // Re-open menu and verify checked is now true.
      await tester.tap(find.byType(PopupMenuButton<example.Commands>));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<CheckedPopupMenuItem<example.Commands>>(
              find.byType(CheckedPopupMenuItem<example.Commands>),
            )
            .checked,
        isTrue,
      );

      // Tap 'Bring hurricane' and verify route resolves to hurricaneCame.
      final Future<dynamic> popped = observer.lastPopped!;
      await tester.tap(
        find.widgetWithText(PopupMenuItem<example.Commands>, 'Bring hurricane'),
      );
      await tester.pumpAndSettle();
      expect(await popped, example.Commands.hurricaneCame);
    },
  );
}
