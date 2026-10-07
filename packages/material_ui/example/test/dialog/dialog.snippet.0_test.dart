// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/dialog/dialog.snippet.0.dart' as example;

void main() {
  testWidgets('Dialog.constraints constrains dialog size', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: example.DialogExample(
            child: SizedBox(width: 1000, height: 100),
          ),
        ),
      ),
    );

    final Finder dialogMaterial = find.descendant(
      of: find.byType(Dialog),
      matching: find.byType(Material),
    );
    expect(tester.getSize(dialogMaterial), const Size(560, 280));
  });
}
