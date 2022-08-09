// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:adaptive_scaffold_example/adaptive_layout_demo.dart' as example;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> updateScreen(double width, WidgetTester tester) async {
    await tester.binding.setSurfaceSize(Size(width, 800));
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
            data: MediaQueryData(size: Size(width, 800)),
            child: const example.MyHomePage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('dislays correct item of config based on screen width',
      (WidgetTester tester) async {
    await updateScreen(300, tester);
    expect(find.byKey(const Key('body')), findsOneWidget);
    expect(find.byKey(const Key('pn')), findsNothing);
    expect(find.byKey(const Key('bn')), findsOneWidget);
    expect(find.byKey(const Key('body1')), findsNothing);
    expect(find.byKey(const Key('pn1')), findsNothing);

    await updateScreen(700, tester);
    expect(find.byKey(const Key('body')), findsNothing);
    expect(find.byKey(const Key('bn')), findsNothing);
    expect(find.byKey(const Key('body1')), findsOneWidget);
    expect(find.byKey(const Key('pn')), findsOneWidget);
    expect(find.byKey(const Key('pn1')), findsNothing);

    await updateScreen(900, tester);
    expect(find.byKey(const Key('pn')), findsNothing);
    expect(find.byKey(const Key('pn1')), findsOneWidget);
  });
}
