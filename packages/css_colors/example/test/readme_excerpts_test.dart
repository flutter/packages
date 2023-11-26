// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:css_colors/css_colors.dart';
import 'package:css_colors_example/readme_excerpts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Container uses CSSColors.orange', (WidgetTester tester) async {
    // Build the container and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: useCSSColors())));

    // Verify that the Container has the correct color.
    expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Container && widget.color == CSSColors.orange,
        ),
        findsOneWidget);
  });
}
