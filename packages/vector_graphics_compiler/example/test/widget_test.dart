// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics_compiler_example/main.dart';

void main() {
  testWidgets('ExampleApp renders the Dart logo VectorGraphic', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    // Verify the app bar title is present.
    expect(find.text('Build-time SVG Transformer'), findsOneWidget);

    // Verify the VectorGraphic widget is present inside a 200x200 SizedBox.
    final SizedBox sizedBox = tester.widget<SizedBox>(
      find.byType(SizedBox).first,
    );
    expect(sizedBox.width, 200);
    expect(sizedBox.height, 200);
  });
}
