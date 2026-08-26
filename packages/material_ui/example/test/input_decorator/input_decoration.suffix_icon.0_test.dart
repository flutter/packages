// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/input_decorator/input_decoration.suffix_icon.0.dart'
    as example;

void main() {
  testWidgets('InputDecorator suffixIcon alignment', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.SuffixIconExampleApp());
    expect(tester.getCenter(find.byIcon(Icons.remove_red_eye)).dy, 28.0);
  });
}
