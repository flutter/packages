// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/app_bar/sliver_app_bar.2.dart' as example;

void main() {
  testWidgets('Visibility and interaction of crucial widgets', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.AppBarMediumApp());

    const String title = 'Medium App Bar';

    expect(
      find.descendant(
        of: find.byType(CustomScrollView),
        matching: find.widgetWithText(SliverAppBar, title),
      ),
      findsOne,
    );

    expect(
      find.descendant(
        of: find.byType(SliverAppBar),
        matching: find.byType(IconButton),
      ),
      findsExactly(2),
    );

    // Based on https://m3.material.io/components/top-app-bar/specs the title of
    // the SliverAppBar.medium widget is formatted with the headlineSmall style.
    final BuildContext context = tester.element(find.byType(MaterialApp));
    final TextStyle expectedTitleStyle = Theme.of(
      context,
    ).textTheme.headlineSmall!;

    // There are two Text widgets: expanded and collapsed. The expanded is first.
    final Finder titleFinder = find.text(title).first;
    final TextStyle actualTitleStyle = DefaultTextStyle.of(
      tester.element(titleFinder),
    ).style;

    expect(actualTitleStyle, expectedTitleStyle);

    // Scrolling the screen moves the title up.
    expect(tester.getBottomLeft(titleFinder).dy, 96.0);
    await tester.drag(titleFinder, const Offset(0.0, -200.0));
    await tester.pump();
    expect(tester.getBottomLeft(titleFinder).dy, 48.0);
  });
}
