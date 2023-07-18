// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:example/wrap_layout_example.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
    final Offset offset0 = usesMaterial3
        ? Offset(0.0, _getExpectedYOffset(91.0))
        : const Offset(0.0, 103.0);
    final Offset offset1 = usesMaterial3
        ? Offset(65.0, _getExpectedYOffset(121.0))
        : const Offset(66.0, 124.0);
    final Offset offset3 = usesMaterial3
        ? Offset(270.0, _getExpectedYOffset(171.0))
        : const Offset(271.0, 174.0);
    final Offset offset4 = usesMaterial3
        ? Offset(380.0, _getExpectedYOffset(221.0))
        : const Offset(381.0, 224.0);

    // See if they are in expected position.
    expect(tester.getTopLeft(find.text('Index 0')), offset0);
    expect(tester.getTopLeft(find.text('Index 1')), offset1);
    expect(tester.getTopLeft(find.text('Index 3')), offset3);
    expect(tester.getTopLeft(find.text('Index 4')), offset4);
  });
}

double _getExpectedYOffset(double nonWeb) {
  return kIsWeb ? nonWeb - 0.5 : nonWeb;
}
