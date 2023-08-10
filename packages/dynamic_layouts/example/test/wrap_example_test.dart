// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:example/wrap_layout_example.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  void withinTolerance(Offset actual, Offset expected, double tolerance) {
    expect(
      actual.dx,
      (double actual) => actual <= expected.dx + tolerance,
      reason: '${actual.dx} <= ${expected.dx + tolerance}',
    );
    expect(
      actual.dx,
      (double actual) => actual >= expected.dx - tolerance,
      reason: '${actual.dx} >= ${expected.dx - tolerance}',
    );
    expect(
      actual.dy,
      (double actual) => actual <= expected.dy + tolerance,
      reason: '${actual.dy} <= ${expected.dy + tolerance}',
    );
    expect(
      actual.dy,
      (double actual) => actual >= expected.dy - tolerance,
      reason: '${actual.dy} >= ${expected.dy - tolerance}',
    );
  }

  testWidgets('Check that the children are layed out.',
      (WidgetTester tester) async {
    const MaterialApp app = MaterialApp(
      home: WrapExample(),
    );
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    // See if there are children layed out.
    expect(find.text('Index 0'), findsOneWidget);
    expect(find.text('Index 1'), findsOneWidget);
    expect(find.text('Index 2'), findsOneWidget);
    expect(find.text('Index 3'), findsOneWidget);
    expect(find.text('Index 4'), findsOneWidget);

    // Material 3 changes the expected layout positioning.
    final bool usesMaterial3 = (app.theme ?? ThemeData.light()).useMaterial3;
    final Offset offset0 =
        usesMaterial3 ? const Offset(0.0, 91.0) : const Offset(0.0, 103.0);
    final Offset offset1 =
        usesMaterial3 ? const Offset(65.0, 121.0) : const Offset(66.0, 124.0);
    final Offset offset3 =
        usesMaterial3 ? const Offset(270.0, 171.0) : const Offset(271.0, 174.0);
    final Offset offset4 =
        usesMaterial3 ? const Offset(380.0, 221.0) : const Offset(381.0, 224.0);

    // See if they are in expected position.
    withinTolerance(tester.getTopLeft(find.text('Index 0')), offset0, 0.2);
    withinTolerance(tester.getTopLeft(find.text('Index 1')), offset1, 0.2);
    withinTolerance(tester.getTopLeft(find.text('Index 3')), offset3, 0.2);
    withinTolerance(tester.getTopLeft(find.text('Index 4')), offset4, 0.2);
  });
}
