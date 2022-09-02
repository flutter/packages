// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:example/wrap_layout_example.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Check that the children are layed out.',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WrapExample(),
      ),
    );
    await tester.pumpAndSettle();

    // See if there are children layed out.
    expect(find.text('Index 0'), findsOneWidget);
    expect(find.text('Index 1'), findsOneWidget);
    expect(find.text('Index 2'), findsOneWidget);
    expect(find.text('Index 3'), findsOneWidget);
    expect(find.text('Index 4'), findsOneWidget);

    // See if they are in expected position.
    expect(tester.getTopLeft(find.text('Index 0')), const Offset(0.0, 103.0));
    expect(tester.getTopLeft(find.text('Index 1')), const Offset(66.0, 124.0));
    expect(tester.getTopLeft(find.text('Index 3')), const Offset(271.0, 174.0));
    expect(tester.getTopLeft(find.text('Index 4')), const Offset(381.0, 224.0));
  });
}
