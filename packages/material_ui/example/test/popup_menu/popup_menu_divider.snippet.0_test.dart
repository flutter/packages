// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/popup_menu/popup_menu_divider.snippet.0.dart'
    as example;

void main() {
  testWidgets('PopupMenuDivider paints divider line with deepOrange color', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: example.PopupMenuDividerExample())),
      ),
    );

    expect(
      find.byType(PopupMenuDivider),
      paints..path(color: Colors.deepOrange.shade500),
    );
  });
}
