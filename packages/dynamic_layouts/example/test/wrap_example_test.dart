// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:example/wrap_layout_example.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Check wrap layout', (WidgetTester tester) async {
    const MaterialApp app = MaterialApp(
      home: WrapExample(),
    );
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    // Validate which children are laid out.
    for (int i = 0; i <= 12; i++) {
      expect(find.text('Index $i'), findsOneWidget);
    }
    for (int i = 13; i < 19; i++) {
      expect(find.text('Index $i'), findsNothing);
    }

    // Validate with the position of the box, not the text.
    Finder getContainer(String text) {
      return find.ancestor(
        of: find.text(text),
        matching: find.byType(Container),
      );
    }

    // Validate layout position.
    expect(
      tester.getTopLeft(getContainer('Index 0')),
      const Offset(0.0, 56.0),
    );
    expect(
      tester.getTopLeft(getContainer('Index 1')),
      const Offset(40.0, 56.0),
    );
    expect(
      tester.getTopLeft(getContainer('Index 2')),
      const Offset(190.0, 56.0),
    );
    expect(
      tester.getTopLeft(getContainer('Index 3')),
      const Offset(270.0, 56.0),
    );
    expect(
      tester.getTopLeft(getContainer('Index 4')),
      const Offset(370.0, 56.0),
    );
    expect(
      tester.getTopLeft(getContainer('Index 5')),
      const Offset(490.0, 56.0),
    );
    expect(
      tester.getTopLeft(getContainer('Index 6')),
      const Offset(690.0, 56.0),
    );
    expect(
      tester.getTopLeft(getContainer('Index 7')),
      const Offset(0.0, 506.0),
    );
    expect(
      tester.getTopLeft(getContainer('Index 8')),
      const Offset(150.0, 506.0),
    );
    expect(
      tester.getTopLeft(getContainer('Index 9')),
      const Offset(250.0, 506.0),
    );
    expect(
      tester.getTopLeft(getContainer('Index 10')),
      const Offset(350.0, 506.0),
    );
    expect(
      tester.getTopLeft(getContainer('Index 11')),
      const Offset(390.0, 506.0),
    );
    expect(
      tester.getTopLeft(getContainer('Index 12')),
      const Offset(590.0, 506.0),
    );
  });
}
