// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_dimensional_examples/table_view/simple_table.dart';

void main() {
  testWidgets('Example app builds & scrolls', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TableExample()));
    await tester.pump();

    expect(find.text('Jump to Top'), findsOneWidget);
    expect(find.text('Jump to Bottom'), findsOneWidget);
    expect(find.text('Add 10 Rows'), findsOneWidget);

    final Finder scrollable = find.byWidgetPredicate((Widget widget) {
      if (widget is Scrollable) {
        return widget.axisDirection == AxisDirection.down;
      }
      return false;
    });
    final ScrollPosition position =
        (tester.state(scrollable) as ScrollableState).position;
    expect(position.axis, Axis.vertical);
    expect(position.pixels, 0.0);
    position.jumpTo(10);
    await tester.pump();
    expect(position.pixels, 10.0);
  });

  testWidgets('Example app buttons work', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TableExample()));
    await tester.pump();

    final Finder scrollable = find.byWidgetPredicate((Widget widget) {
      if (widget is Scrollable) {
        return widget.axisDirection == AxisDirection.down;
      }
      return false;
    });
    final ScrollPosition position =
        (tester.state(scrollable) as ScrollableState).position;

    expect(position.maxScrollExtent, greaterThan(750));
    await tester.tap(find.text('Add 10 Rows'));
    await tester.pump();
    expect(position.maxScrollExtent, greaterThan(1380));
    await tester.tap(find.text('Jump to Bottom'));
    await tester.pump();
    expect(position.pixels, greaterThan(1380));
    await tester.tap(find.text('Jump to Top'));
    await tester.pump();
    expect(position.pixels, 0.0);
  });

  testWidgets('Selection SegmentedButton control works',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TableExample()));
    await tester.pump();

    // Find two adjacent cells.  Adjust these finders as needed for your specific layout.
    final Finder cell1 = find.text('Tile c: 0, r: 0');
    final Finder cell2 = find.text('Tile c: 1, r: 0');

    final Offset cell1Center = tester.getCenter(cell1);
    final Offset cell2Center = tester.getCenter(cell2);

    // Enable multi-cell selection and verify.
    await tester.tap(find.textContaining('Multi-Cell'));
    await tester.pumpAndSettle();

    RenderParagraph paragraph1 = tester.renderObject<RenderParagraph>(
      find.descendant(of: cell1, matching: find.byType(RichText)),
    );
    RenderParagraph paragraph2 = tester.renderObject<RenderParagraph>(
      find.descendant(of: cell2, matching: find.byType(RichText)),
    );

    // Selection starts empty.
    expect(paragraph1.selections.isEmpty, isTrue);
    expect(paragraph2.selections.isEmpty, isTrue);

    // Long press and drag to select multiple cells.
    final TestGesture gesture = await tester.startGesture(cell1Center);
    await tester.pump(kLongPressTimeout);
    await gesture.moveTo(cell2Center);
    await gesture.up();
    await tester.pumpAndSettle();

    expect(paragraph1.selections.isEmpty, isFalse);
    expect(paragraph2.selections.isEmpty, isFalse);

    // Enable single-cell selection and verify.
    await tester.tap(find.textContaining('Single-Cell'));
    await tester.pumpAndSettle();

    paragraph1 = tester.renderObject<RenderParagraph>(
      find.descendant(of: cell1, matching: find.byType(RichText)),
    );
    paragraph2 = tester.renderObject<RenderParagraph>(
      find.descendant(of: cell2, matching: find.byType(RichText)),
    );

    // Selection has been cleared.
    expect(paragraph1.selections.isEmpty, isTrue);
    expect(paragraph2.selections.isEmpty, isTrue);

    // Selecting from cell1 to cell2 only selects cell1.
    await gesture.down(cell1Center);
    await tester.pump(kLongPressTimeout);
    await gesture.moveTo(cell2Center);
    await gesture.up();
    await tester.pumpAndSettle();

    expect(paragraph1.selections.isEmpty, isFalse);
    expect(paragraph2.selections.isEmpty, isTrue);

    // Disable selection and verify.
    await tester.tap(find.text('Disabled'));
    await tester.pumpAndSettle();

    paragraph1 = tester.renderObject<RenderParagraph>(
      find.descendant(of: cell1, matching: find.byType(RichText)),
    );
    paragraph2 = tester.renderObject<RenderParagraph>(
      find.descendant(of: cell2, matching: find.byType(RichText)),
    );

    // Selection has been cleared.
    expect(paragraph1.selections.isEmpty, isTrue);
    expect(paragraph2.selections.isEmpty, isTrue);

    // Long pressing should not select anything.
    await gesture.down(cell1Center);
    await tester.pump(kLongPressTimeout);
    await gesture.up();
    await tester.pumpAndSettle();

    expect(paragraph1.selections.isEmpty, isTrue);
    expect(paragraph2.selections.isEmpty, isTrue);
  });
}
