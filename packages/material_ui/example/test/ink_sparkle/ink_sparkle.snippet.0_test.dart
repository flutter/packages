// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/ink_sparkle/ink_sparkle.snippet.0.dart'
    as example;

void main() {
  testWidgets(
    'ElevatedButton uses InkSparkle.splashFactory and renders sparkle splash',
    (WidgetTester tester) async {
      await tester.pumpWidget(const example.ExampleApp());

      final ElevatedButton button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.style?.splashFactory, InkSparkle.splashFactory);

      final Finder buttonText = find.text('Sparkle!');
      await tester.tap(buttonText);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final MaterialInkController material = Material.of(
        tester.element(buttonText),
      );
      expect(material, paintsExactlyCountTimes(#drawRect, 1));

      await tester.pumpAndSettle();
    },
    skip: kIsWeb, // [intended] shaders are not yet supported for web.
  );
}
