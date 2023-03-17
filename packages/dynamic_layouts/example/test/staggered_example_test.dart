// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(pdblasi-google): Update `window` usages to new API after 3.9.0 is in stable. https://github.com/flutter/flutter/issues/122912
// ignore_for_file: deprecated_member_use

import 'package:example/staggered_layout_example.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('StaggeredExample lays out children correctly',
      (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(400, 200);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(
      const MaterialApp(
        home: StaggeredExample(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Index 0'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Index 0')), const Offset(0.0, 56.0));
    expect(find.text('Index 8'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Index 8')), const Offset(100.0, 146.0));
    expect(find.text('Index 10'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Index 10')),
      const Offset(200.0, 196.0),
    );
  });
}
