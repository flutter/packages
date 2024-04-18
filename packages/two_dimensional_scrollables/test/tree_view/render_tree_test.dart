// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

void main() {
  group('RenderTreeViewport', () {
    // Asserts proper axis directions
    // Sets mainAxis based on tree traversal order
    testWidgets('provides correct details in TreeRowExtentDelegate',
        (WidgetTester tester) async {});

    testWidgets('TreeRow gesture hit testing', (WidgetTester tester) async {});

    testWidgets('mouse handling', (WidgetTester tester) async {});

    group('Layout', () {
      testWidgets('Basic', (WidgetTester tester) async {});

      testWidgets('Custom AnimationStyle', (WidgetTester tester) async {});

      testWidgets('Disabled animation', (WidgetTester tester) async {});

      testWidgets('Animating node segment', (WidgetTester tester) async {});

      testWidgets(
          'Multiple animating node segments', (WidgetTester tester) async {});

      testWidgets('TreeRowPadding', (WidgetTester tester) async {});
    });

    group('Painting', () {
      testWidgets('only paints visible rows', (WidgetTester tester) async {});
      testWidgets('paints decorations in correct order',
          (WidgetTester tester) async {});
    });
  });
}
