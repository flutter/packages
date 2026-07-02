// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/stepper/stepper.controls_builder.0.dart'
    as example;

void main() {
  testWidgets(
    'Stepper control builder can be overridden to display custom buttons',
    (WidgetTester tester) async {
      await tester.pumpWidget(const example.ControlsBuilderExampleApp());

      expect(find.widgetWithText(AppBar, 'Stepper Sample'), findsOne);
      expect(find.text('A').hitTestable(), findsOne);
      expect(find.text('B').hitTestable(), findsOne);
      expect(find.widgetWithText(TextButton, 'NEXT').hitTestable(), findsOne);
      expect(find.widgetWithText(TextButton, 'CANCEL').hitTestable(), findsOne);
    },
  );
}
