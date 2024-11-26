// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_svg_example/readme_excerpts.dart' as excerpts;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('example simple loadAsset works', (WidgetTester tester) async {
    final Widget svg = excerpts.loadAsset();
    expect(svg, isNotNull);
  });

  testWidgets('example loadAsset with color filter works',
      (WidgetTester tester) async {
    final Widget svg = excerpts.loadAsset();
    expect(svg, isNotNull);
  });

  testWidgets('example loadAsset with a non-existent asset works',
      (WidgetTester tester) async {
    final Widget svg = excerpts.loadMissingAsset();
    expect(svg, isNotNull);
  });

  testWidgets('example loadAsset with a precompiled asset works',
      (WidgetTester tester) async {
    final Widget svg = excerpts.loadPrecompiledAsset();
    expect(svg, isNotNull);
  });
}
