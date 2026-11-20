// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/dialog/dialog.snippet.0.dart' as example;

void main() {
  testWidgets('Dialog applies M3 BoxConstraints', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: example.DialogExample())),
    );

    final Finder dialogMaterial = find.descendant(
      of: find.byType(Dialog),
      matching: find.byType(Material),
    );
    expect(tester.getSize(dialogMaterial), const Size(0, 280));

    final RenderConstrainedBox constrainedBox = tester.renderObject(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.byWidgetPredicate(
          (Widget widget) =>
              widget is ConstrainedBox &&
              widget.constraints ==
                  const BoxConstraints(maxWidth: 560, minHeight: 280),
        ),
      ),
    );
    expect(
      constrainedBox.additionalConstraints,
      const BoxConstraints(maxWidth: 560, minHeight: 280),
    );
  });
}
