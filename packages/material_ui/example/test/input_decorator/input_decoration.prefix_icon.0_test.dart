// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/input_decorator/input_decoration.prefix_icon.0.dart'
    as example;

void main() {
  testWidgets('InputDecorator prefixIcon alignment', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.PrefixIconExampleApp());
    expect(tester.getCenter(find.byIcon(Icons.person)).dy, 28.0);
  });
}
