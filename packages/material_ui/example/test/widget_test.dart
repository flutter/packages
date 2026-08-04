// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui_examples/main.dart';

import 'package:material_ui_examples/about/about_list_tile.0.dart';
import 'package:material_ui_examples/action_buttons/action_icon_theme.0.dart';

void main() {
  testWidgets('about_list_tile.0', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    await tester.tap(find.text('about/about_list_tile.0.dart'));
    await tester.pumpAndSettle();

    expect(find.byType(AboutListTileExample), findsOneWidget);
  });

  testWidgets('action_icon_theme.0', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    await tester.tap(find.text('action_buttons/action_icon_theme.0.dart'));
    await tester.pumpAndSettle();

    expect(find.byType(ActionIconThemeExampleApp), findsOneWidget);
  });
}
