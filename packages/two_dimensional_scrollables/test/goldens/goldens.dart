// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Inconsequential golden test', (WidgetTester tester) async {
    // The test validates the Flutter Gold integration. Any changes to the
    // golden file can be approved at any time.
    await tester.pumpWidget(RepaintBoundary(child: Container(color: const Color(0xAFF61145))));

    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary),
      matchesGoldenFile('inconsequential_golden_file.png'),
    );
  });
}
