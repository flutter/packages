// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:adaptive_scaffold/adaptive_scaffold.dart';
import 'package:adaptive_scaffold_example/adaptive_layout_demo.dart' as example;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final Finder body = find.byKey(const Key('body'));
  final Finder bn = find.byKey(const Key('bn'));

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
    expect(find.byKey(const Key('pnav')), findsNothing);
    expect(find.byKey(const Key('bn')), findsOneWidget);
    expect(find.byKey(const Key('body1')), findsNothing);
    expect(find.byKey(const Key('pn1')), findsNothing);

    await updateScreen(700, tester);
    expect(find.byKey(const Key('body')), findsNothing);
    expect(find.byKey(const Key('bn')), findsNothing);
    expect(find.byKey(const Key('body1')), findsOneWidget);
    expect(find.byKey(const Key('pnav1')), findsOneWidget);
    expect(find.byKey(const Key('pn1')), findsNothing);
  });

  testWidgets(
      'adaptive layout bottom navigation displays with correct properties',
      (WidgetTester tester) async {
    await updateScreen(400, tester);
    final BuildContext context = tester.element(find.byType(MaterialApp));

    // Bottom Navigation Bar
    final Finder findKey = find.byKey(const Key('bn'));
    final SlotLayoutConfig slotLayoutConfig =
        tester.firstWidget<SlotLayoutConfig>(findKey);
    final WidgetBuilder? widgetBuilder = slotLayoutConfig.builder;
    final Widget Function(BuildContext) widgetFunction =
        (widgetBuilder ?? () => Container()) as Widget Function(BuildContext);
    final BottomNavigationBarThemeData bottomNavigationBarThemeData =
        (widgetFunction(context) as BottomNavigationBarTheme).data;

    expect(bottomNavigationBarThemeData.selectedItemColor, Colors.black);
  });

  testWidgets(
      'adaptive layout navigation rail displays with correct properties',
      (WidgetTester tester) async {
    await updateScreen(620, tester);
    final BuildContext context = tester.element(find.byType(AdaptiveLayout));

    final Finder findKey = find.byKey(const Key('pnav1'));
    final SlotLayoutConfig slotLayoutConfig =
        tester.firstWidget<SlotLayoutConfig>(findKey);
    final WidgetBuilder? widgetBuilder = slotLayoutConfig.builder;
    final Widget Function(BuildContext) widgetFunction =
        (widgetBuilder ?? () => Container()) as Widget Function(BuildContext);
    final SizedBox sizedBox =
        (((widgetFunction(context) as Builder).builder(context) as Padding)
                .child ??
            () => const SizedBox()) as SizedBox;
    expect(sizedBox.width, 72);
  });

  testWidgets('adaptive layout displays children in correct places',
      (WidgetTester tester) async {
    await updateScreen(400, tester);
    expect(tester.getBottomLeft(bn), const Offset(0, 800));
    expect(tester.getBottomRight(bn), const Offset(400, 800));
    expect(tester.getTopRight(body), const Offset(400, 0));
    expect(tester.getTopLeft(body), Offset.zero);
  });

  testWidgets('adaptive layout does not animate when animations off',
      (WidgetTester tester) async {
    final Finder b = find.byKey(const Key('body1'));
    await updateScreen(690, tester);

    expect(tester.getTopLeft(b), const Offset(88, 0));
    expect(tester.getBottomRight(b), const Offset(690, 800));
  });
}
