// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/app_bar/sliver_app_bar.snippet.0.dart'
    as example;

void main() {
  testWidgets(
    'SliverAppBar displays flexible space title and add_circle action',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: example.SliverAppBarExample())),
      );

      expect(find.text('Available seats'), findsOneWidget);
      expect(find.byIcon(Icons.add_circle), findsOneWidget);
      expect(find.byTooltip('Add new entry'), findsOneWidget);
    },
  );
}
