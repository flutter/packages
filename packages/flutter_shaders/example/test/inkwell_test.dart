// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart' as example;

void main() {
  testWidgets('Can apply inkwell shader effects', (WidgetTester tester) async {
    final ui.FragmentProgram program =
        await ui.FragmentProgram.fromAsset('shaders/inkwell.frag');
    await tester.pumpWidget(example.MyApp(program: program));

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    await tester.pump(Duration(milliseconds: 100));

    // Validate that color is Colors.red from child widget.
    await expectLater(find.byIcon(Icons.add),
        matchesGoldenFile('goldens/shaders.inkwell.png'));
  }, skip: !io.Platform.isWindows);
}
