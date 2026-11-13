// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  setUp(() {
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
  });

  tearDown(() {
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
  });

  Widget buildApp({TooltipThemeData? tooltipTheme, bool? showOnFocus}) {
    return MaterialApp(
      theme: ThemeData(tooltipTheme: tooltipTheme),
      home: Scaffold(
        body: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Tooltip(
                message: 'Previous month',
                showOnFocus: showOnFocus,
                child: IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left)),
              ),
              Tooltip(
                message: 'Next month',
                showOnFocus: showOnFocus,
                child: IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('Shows on keyboard focus and moves with Tab when the theme opts in', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp(tooltipTheme: const TooltipThemeData(showOnFocus: true)));

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(find.text('Previous month'), findsOneWidget);
    expect(find.text('Next month'), findsNothing);

    // One Tab reaches the second button, so the tooltip adds no focus stop.
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(find.text('Previous month'), findsNothing);
    expect(find.text('Next month'), findsOneWidget);
  });

  testWidgets('Tooltip.showOnFocus opts in without the theme', (WidgetTester tester) async {
    await tester.pumpWidget(buildApp(showOnFocus: true));

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(find.text('Previous month'), findsOneWidget);
  });

  testWidgets('Tooltip.showOnFocus false overrides the theme', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildApp(tooltipTheme: const TooltipThemeData(showOnFocus: true), showOnFocus: false),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(find.text('Previous month'), findsNothing);
  });

  testWidgets('Does not show on keyboard focus by default', (WidgetTester tester) async {
    await tester.pumpWidget(buildApp());

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(find.text('Previous month'), findsNothing);
  });

  testWidgets('Does not show for focus in touch highlight mode', (WidgetTester tester) async {
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTouch;
    await tester.pumpWidget(buildApp(tooltipTheme: const TooltipThemeData(showOnFocus: true)));

    final FocusNode node = Focus.of(tester.element(find.byIcon(Icons.chevron_left)));
    node.requestFocus();
    await tester.pumpAndSettle();
    expect(node.hasFocus, isTrue);
    expect(find.text('Previous month'), findsNothing);
  });

  testWidgets('Escape dismisses a tooltip shown for focus and keeps focus', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp(tooltipTheme: const TooltipThemeData(showOnFocus: true)));

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(find.text('Previous month'), findsOneWidget);
    final FocusNode focused = FocusManager.instance.primaryFocus!;

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Previous month'), findsNothing);
    expect(FocusManager.instance.primaryFocus, focused);
  });

  testWidgets('Hides when focus leaves the widget', (WidgetTester tester) async {
    await tester.pumpWidget(buildApp(tooltipTheme: const TooltipThemeData(showOnFocus: true)));

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(find.text('Previous month'), findsOneWidget);

    FocusManager.instance.primaryFocus!.unfocus();
    await tester.pumpAndSettle();
    expect(find.text('Previous month'), findsNothing);
  });

  testWidgets('IconButton.tooltip shows on keyboard focus when the theme opts in', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(tooltipTheme: const TooltipThemeData(showOnFocus: true)),
        home: Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              IconButton(
                tooltip: 'Go to the next page',
                onPressed: () {},
                icon: const Icon(Icons.navigate_next),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(find.text('Go to the next page'), findsOneWidget);
  });
}
