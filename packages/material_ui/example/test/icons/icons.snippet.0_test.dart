// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/icons/icons.snippet.0.dart' as example;

void main() {
  testWidgets(
    'Row displays three Icons with expected colors, sizes, and semantics',
    (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(const example.ExampleApp());

      final Finder favoriteFinder = find.byIcon(Icons.favorite);
      final Finder audiotrackFinder = find.byIcon(Icons.audiotrack);
      final Finder beachFinder = find.byIcon(Icons.beach_access);

      expect(tester.widget<Icon>(favoriteFinder).color, Colors.pink);
      expect(tester.getSize(favoriteFinder), const Size(24.0, 24.0));
      expect(
        find.bySemanticsLabel('Text to announce in accessibility modes'),
        findsOneWidget,
      );

      expect(tester.widget<Icon>(audiotrackFinder).color, Colors.green);
      expect(tester.getSize(audiotrackFinder), const Size(30.0, 30.0));

      expect(tester.widget<Icon>(beachFinder).color, Colors.blue);
      expect(tester.getSize(beachFinder), const Size(36.0, 36.0));

      handle.dispose();
    },
  );
}
