// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/scaffold/scaffold_messenger_state.show_material_banner.0.dart'
    as example;

void main() {
  testWidgets('Pressing the button should show a material banner', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.ShowMaterialBannerExampleApp());

    expect(
      find.widgetWithText(AppBar, 'ScaffoldMessengerState Sample'),
      findsOne,
    );
    await tester.tap(
      find.widgetWithText(OutlinedButton, 'Show MaterialBanner'),
    );
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(MaterialBanner, 'This is a MaterialBanner'),
      findsOne,
    );
    expect(
      find.descendant(
        of: find.byType(MaterialBanner),
        matching: find.widgetWithText(TextButton, 'DISMISS'),
      ),
      findsOne,
    );
  });
}
