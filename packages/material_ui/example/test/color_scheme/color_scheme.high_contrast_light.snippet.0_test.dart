// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/color_scheme/color_scheme.high_contrast_light.snippet.0.dart'
    as example;

void main() {
  testWidgets(
    'ColorScheme.fromSeed copyWith configures high-contrast light colors',
    (WidgetTester tester) async {
      await tester.pumpWidget(const example.ExampleApp());

      final ColorScheme scheme = Theme.of(
        tester.element(find.byType(Scaffold)),
      ).colorScheme;
      expect(scheme.brightness, Brightness.light);
      expect(scheme.primaryContainer, const Color(0xff0000ba));
      expect(scheme.onPrimaryContainer, Colors.white);
      expect(scheme.secondaryContainer, const Color(0xff66fff9));
      expect(scheme.onSecondaryContainer, Colors.black);
      expect(scheme.error, const Color(0xff790000));
      expect(scheme.onError, Colors.white);
    },
  );
}
