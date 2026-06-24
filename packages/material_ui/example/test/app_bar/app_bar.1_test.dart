// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/app_bar/app_bar.1.dart' as example;

const Offset _kOffset = Offset(0.0, -100.0);

void main() {
  testWidgets('Appbar Material 3 test', (WidgetTester tester) async {
    await tester.pumpWidget(const example.AppBarApp());

    expect(find.widgetWithText(AppBar, 'AppBar Demo'), findsOneWidget);
    Material appbarMaterial = _getAppBarMaterial(tester);
    expect(appbarMaterial.shadowColor, Colors.transparent);
    expect(appbarMaterial.elevation, 0);

    await tester.drag(
      find.text('Item 4'),
      _kOffset,
      touchSlopY: 0,
      warnIfMissed: false,
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('shadow color'));
    await tester.pumpAndSettle();
    appbarMaterial = _getAppBarMaterial(tester);
    expect(appbarMaterial.shadowColor, Colors.black);
    expect(appbarMaterial.elevation, 3.0);

    await tester.tap(find.text('scrolledUnderElevation: default'));
    await tester.pumpAndSettle();

    appbarMaterial = _getAppBarMaterial(tester);
    expect(appbarMaterial.shadowColor, Colors.black);
    expect(appbarMaterial.elevation, 4.0);

    await tester.tap(find.text('scrolledUnderElevation: 4.0'));
    await tester.pumpAndSettle();
    appbarMaterial = _getAppBarMaterial(tester);
    expect(appbarMaterial.shadowColor, Colors.black);
    expect(appbarMaterial.elevation, 5.0);
  });
}

Material _getAppBarMaterial(WidgetTester tester) {
  return tester.widget<Material>(
    find.descendant(of: find.byType(AppBar), matching: find.byType(Material)),
  );
}
