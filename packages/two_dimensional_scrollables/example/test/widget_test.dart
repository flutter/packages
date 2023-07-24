// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:table_view_example/main.dart';

void main() {
  testWidgets('Example app builds & scrolls', (WidgetTester tester) async {
    final ScrollController controller = ScrollController();
    await tester.pumpWidget(TableExampleApp(controller: controller));
    await tester.pump();

    expect(find.text('Jump to Top'), findsOneWidget);
    expect(find.text('Jump to Bottom'), findsOneWidget);
    expect(find.text('Add 10 Rows'), findsOneWidget);
    expect(controller.hasClients, isTrue);
    expect(controller.position.axis, Axis.vertical);
    expect(controller.position.pixels, 0.0);
    controller.jumpTo(10);
    await tester.pump();
    expect(controller.position.pixels, 10.0);
  });

  testWidgets('Example app buttons work', (WidgetTester tester) async {
    final ScrollController controller = ScrollController();
    await tester.pumpWidget(TableExampleApp(controller: controller));
    await tester.pump();

    expect(controller.position.maxScrollExtent, greaterThan(750));
    await tester.tap(find.text('Add 10 Rows'));
    await tester.pump();
    expect(controller.position.maxScrollExtent, greaterThan(1380));
    await tester.tap(find.text('Jump to Bottom'));
    await tester.pump();
    expect(controller.position.pixels, greaterThan(1380));
    await tester.tap(find.text('Jump to Top'));
    await tester.pump();
    expect(controller.position.pixels, 0.0);
  });
}
