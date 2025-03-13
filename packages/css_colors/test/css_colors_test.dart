// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:css_colors/css_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CSSColors.orange should be correct',
      (WidgetTester tester) async {
    // Create a Container widget using CSSColors.orange.
    // #docregion Usage
    final Container orange = Container(color: CSSColors.orange);
    // #enddocregion Usage

    // Ensure the color of the container is the expected one.
    expect(orange.color, equals(const Color(0xFFFFA500)));
  });
}
