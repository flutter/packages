// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/bottom_app_bar/bottom_app_bar.2.dart'
    as example;

void main() {
  testWidgets('Floating Action Button visibility can be toggled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.BottomAppBarDemo());

    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Tap the switch to hide the FAB.
    await tester.tap(find.byType(SwitchListTile).first);
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('BottomAppBar elevation can be toggled', (
    WidgetTester tester,
  ) async {
    // Build the app.
    await tester.pumpWidget(const example.BottomAppBarDemo());

    // Verify the BottomAppBar has elevation initially.
    BottomAppBar bottomAppBar = tester.widget(find.byType(BottomAppBar));
    expect(bottomAppBar.elevation, isNot(0.0));

    await tester.tap(find.text('Bottom App Bar Elevation'));
    await tester.pumpAndSettle();

    bottomAppBar = tester.widget(find.byType(BottomAppBar));
    expect(bottomAppBar.elevation, equals(0.0));
  });

  testWidgets('BottomAppBar hides on scroll down and shows on scroll up', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.BottomAppBarDemo());

    // Ensure the BottomAppBar is visible initially.
    expect(find.byType(BottomAppBar), findsOneWidget);

    // Scroll down to hide the BottomAppBar.
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();

    // Verify the BottomAppBar is hidden.
    final Size hiddenSize = tester.getSize(find.byType(AnimatedContainer));
    expect(hiddenSize.height, equals(0.0)); // AnimatedContainer's height

    // Scroll up to show the BottomAppBar again.
    await tester.drag(find.byType(ListView), const Offset(0, 300));
    await tester.pumpAndSettle();

    // Verify the BottomAppBar is visible again.
    final Size visibleSize = tester.getSize(find.byType(AnimatedContainer));
    expect(visibleSize.height, equals(80.0));
  });

  testWidgets('SnackBar is shown when Open popup menu is pressed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.BottomAppBarDemo());

    // Trigger the SnackBar.
    await tester.tap(findByTooltip('Open popup menu'));
    await tester.pump();

    expect(find.text('Yay! A SnackBar!'), findsOneWidget);

    expect(find.text('Undo'), findsOneWidget);
  });
}

/// Finds [RawTooltip] or [Tooltip] widgets with the given `message`.
///
/// ## Sample code
///
/// ```dart
/// expect(findByTooltip('Back'), findsOneWidget);
/// expect(findByTooltip(RegExp('Back.*')), findsNWidgets(2));
/// ```
///
/// If the `skipOffstage` argument is true (the default), then this skips
/// nodes that are [Offstage] or that are from inactive [Route]s.
///
/// This was copied from flutter_test, which uses flutter/material.dart.
///
Finder findByTooltip(Pattern message, {bool skipOffstage = true}) {
  return find.byWidgetPredicate((Widget widget) {
    // Compare RawTooltip's semantics tooltip with the given message.
    // However, Tooltip's message needs to be checked directly if:
    // 1. Tooltip.excludeFromSemantics is true, since in this case Tooltip
    //    provides no semantics tooltip to the underlying RawTooltip.
    // 2. Tooltip.message and Tooltip.richMessage are empty, since in this
    //    case no RawTooltip is created.
    if (widget is Tooltip) {
      final String tooltipMessage =
          widget.message ?? widget.richMessage!.toPlainText();
      if ((widget.excludeFromSemantics ?? false) || tooltipMessage.isEmpty) {
        return message is RegExp
            ? message.hasMatch(tooltipMessage)
            : tooltipMessage == message;
      }
    }
    return widget is RawTooltip &&
        (message is RegExp
            ? message.hasMatch(widget.semanticsTooltip ?? '')
            : widget.semanticsTooltip == message);
  }, skipOffstage: skipOffstage);
}
