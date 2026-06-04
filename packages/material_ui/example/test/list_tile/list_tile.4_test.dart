// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/list_tile/list_tile.4.dart' as example;

void main() {
  testWidgets('Can choose different title alignments from popup menu', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.ListTileApp());

    Offset titleOffset = tester.getTopLeft(find.text('Headline Text'));
    Offset leadingOffset = tester.getTopLeft(find.byType(Checkbox));
    Offset trailingOffset = tester.getTopRight(
      find.byIcon(Icons.adaptive.more),
    );

    // The default title alignment is threeLine.
    expect(leadingOffset.dy - titleOffset.dy, 48.0);
    expect(trailingOffset.dy - titleOffset.dy, 60.0);

    await tester.tap(find.byIcon(Icons.adaptive.more));
    await tester.pumpAndSettle();

    // Change the title alignment to titleHeight.
    await tester.tap(find.text('titleHeight'));
    await tester.pumpAndSettle();

    titleOffset = tester.getTopLeft(find.text('Headline Text'));
    leadingOffset = tester.getTopLeft(find.byType(Checkbox));
    trailingOffset = tester.getTopRight(find.byIcon(Icons.adaptive.more));

    expect(leadingOffset.dy - titleOffset.dy, 8.0);
    expect(trailingOffset.dy - titleOffset.dy, 20.0);

    await tester.tap(find.byIcon(Icons.adaptive.more));
    await tester.pumpAndSettle();

    // Change the title alignment to bottom.
    await tester.tap(find.text('bottom'));
    await tester.pumpAndSettle();

    titleOffset = tester.getTopLeft(find.text('Headline Text'));
    leadingOffset = tester.getTopLeft(find.byType(Checkbox));
    trailingOffset = tester.getTopRight(find.byIcon(Icons.adaptive.more));

    expect(leadingOffset.dy - titleOffset.dy, 96.0);
    expect(trailingOffset.dy - titleOffset.dy, 108.0);
  });
}
