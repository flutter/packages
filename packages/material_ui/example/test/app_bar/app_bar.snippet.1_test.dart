// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/app_bar/app_bar.snippet.1.dart' as example;

void main() {
  testWidgets('SliverAppBar displays title and shopping cart action button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: example.AppBarExample()));

    expect(find.text('Hello World'), findsOneWidget);
    expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
    expect(find.byTooltip('Open shopping cart'), findsOneWidget);
  });
}
