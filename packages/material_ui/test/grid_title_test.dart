// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('GridTile control test', (WidgetTester tester) async {
    final Key headerKey = UniqueKey();
    final Key footerKey = UniqueKey();

    await tester.pumpWidget(
      MaterialApp(
        home: GridTile(
          header: GridTileBar(
            key: headerKey,
            leading: const Icon(Icons.thumb_up),
            title: const Text('Header'),
            subtitle: const Text('Subtitle'),
            trailing: const Icon(Icons.thumb_up),
          ),
          footer: GridTileBar(
            key: footerKey,
            title: const Text('Footer'),
            backgroundColor: Colors.black38,
          ),
          child: DecoratedBox(decoration: BoxDecoration(color: Colors.green[500])),
        ),
      ),
    );

    expect(find.text('Header'), findsOneWidget);
    expect(find.text('Footer'), findsOneWidget);

    expect(
      tester.getBottomLeft(find.byKey(headerKey)).dy,
      lessThan(tester.getTopLeft(find.byKey(footerKey)).dy),
    );

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GridTile(child: Text('Simple')),
      ),
    );

    expect(find.text('Simple'), findsOneWidget);
  });

  testWidgets('GridTile does not crash at zero area', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SizedBox.shrink(child: GridTile(child: Text('X'))),
        ),
      ),
    );
    expect(tester.getSize(find.byType(GridTile)), Size.zero);
  });

  // Regression test for https://github.com/flutter/flutter/issues/82055
  testWidgets('GridTile with header and footer sizes itself to its child when unconstrained', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            height: 100.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                return GridTile(
                  header: const Text('Header'),
                  footer: const Text('Footer'),
                  child: Container(height: 100.0, width: 80.0, color: Colors.red),
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(GridTile)), const Size(80.0, 100.0));
    expect(find.text('Header'), findsOneWidget);
    expect(find.text('Footer'), findsOneWidget);
  });

  testWidgets('GridTile child fills the tile when the constraints are tight', (
    WidgetTester tester,
  ) async {
    final Key childKey = UniqueKey();

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 200.0,
            height: 150.0,
            child: GridTile(
              header: const Text('Header'),
              footer: const Text('Footer'),
              child: ColoredBox(key: childKey, color: Colors.red),
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(GridTile)), const Size(200.0, 150.0));
    expect(tester.getSize(find.byKey(childKey)), const Size(200.0, 150.0));
  });

  testWidgets('GridTile child fills the tile when the constraints are bounded but loose', (
    WidgetTester tester,
  ) async {
    final Key childKey = UniqueKey();

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200.0, maxHeight: 150.0),
            child: GridTile(
              header: const Text('Header'),
              footer: const Text('Footer'),
              child: Container(key: childKey, width: 80.0, height: 100.0, color: Colors.red),
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(GridTile)), const Size(200.0, 150.0));
    expect(tester.getSize(find.byKey(childKey)), const Size(200.0, 150.0));
  });

  testWidgets(
    'GridTile dry baseline matches its baseline when the constraints are bounded but loose',
    (WidgetTester tester) async {
      const constraints = BoxConstraints(maxWidth: 200.0, maxHeight: 150.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: ConstrainedBox(
              constraints: constraints,
              child: const GridTile(
                footer: Text('Footer'),
                // Shrink-wraps the text vertically under loose constraints, but
                // centers it vertically when forced to fill the tile.
                child: Align(alignment: Alignment.centerLeft, heightFactor: 1.0, child: Text('X')),
              ),
            ),
          ),
        ),
      );

      // The tile's baseline is the baseline of the child's text, which is above
      // the footer's.
      final RenderBox text = tester.renderObject<RenderBox>(find.text('X'));
      final double expectedBaseline =
          tester.getTopLeft(find.text('X')).dy -
          tester.getTopLeft(find.byType(GridTile)).dy +
          text.getDryBaseline(const BoxConstraints(), TextBaseline.alphabetic)!;
      expect(tester.getSize(find.byType(GridTile)), const Size(200.0, 150.0));

      final RenderBox tile = tester.renderObject<RenderBox>(
        find.descendant(of: find.byType(GridTile), matching: find.byType(Stack)),
      );
      expect(tile.getDryBaseline(constraints, TextBaseline.alphabetic), expectedBaseline);
    },
  );

  testWidgets('GridTileBar does not crash at zero area', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SizedBox.shrink(child: GridTileBar(title: Text('X'))),
        ),
      ),
    );
    expect(tester.getSize(find.byType(GridTileBar)), Size.zero);
  });
}
