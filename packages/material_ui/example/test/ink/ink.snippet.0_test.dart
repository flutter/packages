// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/ink/ink.snippet.0.dart' as example;

void main() {
  testWidgets(
    'Ink paints yellow rectangle on Material with InkWell effects over it',
    (WidgetTester tester) async {
      await tester.pumpWidget(const example.ExampleApp());

      expect(find.text('YELLOW'), findsOneWidget);
      expect(tester.getSize(find.byType(Ink)), const Size(200.0, 100.0));

      final Finder materialFinder = find.ancestor(
        of: find.byType(Ink),
        matching: find.byType(Material),
      );
      final Material materialWidget = tester.widget<Material>(materialFinder);
      expect(materialWidget.color, Colors.teal[900]);

      final MaterialInkController controller = Material.of(
        tester.element(find.text('YELLOW')),
      );
      expect(
        controller,
        paints..rect(
          rect: const Rect.fromLTWH(300.0, 250.0, 200.0, 100.0),
          color: Colors.yellow,
        ),
      );

      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.text('YELLOW')),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // The yellow Ink decoration is painted first, followed by the InkWell highlight/splash over it.
      expect(
        controller,
        paints
          ..rect(
            rect: const Rect.fromLTWH(300.0, 250.0, 200.0, 100.0),
            color: Colors.yellow,
          )
          ..rect(),
      );

      await gesture.up();
      await tester.pumpAndSettle();
    },
  );
}
