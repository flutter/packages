// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/app_bar/sliver_app_bar.1.dart' as example;

const Offset _kOffset = Offset(0.0, -200.0);

void main() {
  testWidgets('SliverAppbar can be pinned', (WidgetTester tester) async {
    await tester.pumpWidget(const example.AppBarApp());

    expect(find.widgetWithText(SliverAppBar, 'SliverAppBar'), findsOneWidget);
    expect(tester.getBottomLeft(find.text('SliverAppBar')).dy, 144.0);

    await tester.drag(
      find.text('0'),
      _kOffset,
      touchSlopY: 0,
      warnIfMissed: false,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.getBottomLeft(find.text('SliverAppBar')).dy, 40.0);
  });
}
