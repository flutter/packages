// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/text_theme/text_theme.merge.snippet.0.dart'
    as example;

void main() {
  testWidgets(
    'TitleColorTheme merges titleLarge color while keeping preexisting text styles',
    (WidgetTester tester) async {
      final ThemeData outerTheme = ThemeData(
        primaryColor: Colors.teal,
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 28.0, color: Colors.black),
          bodyMedium: TextStyle(fontSize: 16.0, color: Colors.green),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: outerTheme,
          home: const example.TitleColorTheme(
            titleColor: Colors.purple,
            child: Placeholder(),
          ),
        ),
      );

      final ThemeData descendantTheme = Theme.of(
        tester.element(find.byType(Placeholder)),
      );
      expect(descendantTheme.textTheme.titleLarge?.color, Colors.purple);
      expect(descendantTheme.textTheme.titleLarge?.fontSize, 28.0);
      expect(descendantTheme.textTheme.bodyMedium?.color, Colors.green);
      expect(descendantTheme.textTheme.bodyMedium?.fontSize, 16.0);
      expect(descendantTheme.primaryColor, Colors.teal);
    },
  );
}
