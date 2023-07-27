// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:two_dimensional_scrollables/table_view.dart';

void main() {
  group('TableView.builder', () {
    test('creates correct delegate', () {});

    test('asserts correct counts', () {
      // there are 6
    });
  });

  group('TableView.list', () {
    test('creates correct delegate', () {});

    test('asserts correct counts', () {});
  });

  group('RenderTableViewport', () {
    testWidgets('parent data', (WidgetTester tester) async {});

    testWidgets('hit testing', (WidgetTester tester) async {
      // cells, rows, columns, mainAxis
    });

    testWidgets('provides correct details in TableSpanExtentDelegate',
        (WidgetTester tester) async {});

    testWidgets('regular layout - no pinning', (WidgetTester tester) async {});

    testWidgets('pinned rows and columns', (WidgetTester tester) async {
      // Just pinned rows
      // Just pinned columns
      // Both
    });

    testWidgets('only paints visible cells', (WidgetTester tester) async {});

    testWidgets('paints decorations in order', (WidgetTester tester) async {});
  });
}
