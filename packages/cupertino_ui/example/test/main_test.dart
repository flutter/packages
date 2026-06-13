// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:cupertino_ui_examples/main.dart' as example;
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the showcase components', (WidgetTester tester) async {
    await tester.pumpWidget(const example.CupertinoExampleApp());

    expect(find.byType(CupertinoListSection), findsNWidgets(3));
    expect(find.byType(CupertinoSlidingSegmentedControl<int>), findsOneWidget);
    expect(find.byType(CupertinoSwitch), findsOneWidget);
    expect(find.byType(CupertinoSlider), findsOneWidget);
    expect(find.byType(CupertinoTextField), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('changes brightness via the segmented control', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.CupertinoExampleApp());

    CupertinoApp app = tester.widget(find.byType(CupertinoApp));
    expect(app.theme?.brightness, isNull);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    app = tester.widget(find.byType(CupertinoApp));
    expect(app.theme?.brightness, Brightness.dark);
  });

  testWidgets('opens and dismisses the info dialog', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.CupertinoExampleApp());

    await tester.tap(find.text('About this package'));
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoAlertDialog), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoAlertDialog), findsNothing);
  });

  testWidgets('toggles the notifications switch', (WidgetTester tester) async {
    await tester.pumpWidget(const example.CupertinoExampleApp());

    CupertinoSwitch toggle = tester.widget(find.byType(CupertinoSwitch));
    expect(toggle.value, isTrue);

    await tester.tap(find.byType(CupertinoSwitch));
    await tester.pumpAndSettle();

    toggle = tester.widget(find.byType(CupertinoSwitch));
    expect(toggle.value, isFalse);
  });
}
