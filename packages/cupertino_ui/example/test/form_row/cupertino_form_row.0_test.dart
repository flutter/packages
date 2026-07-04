// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:cupertino_ui_examples/form_row/cupertino_form_row.0.dart'
    as example;
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Cupertino form section displays cupertino form rows', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.CupertinoFormRowApp());

    expect(find.byType(CupertinoFormSection), findsOneWidget);
    expect(find.byType(CupertinoFormRow), findsNWidgets(4));
    expect(
      find.widgetWithText(CupertinoFormSection, 'Connectivity'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(CupertinoFormRow, 'Airplane Mode'),
      findsOneWidget,
    );
    expect(find.widgetWithText(CupertinoFormRow, 'Wi-Fi'), findsOneWidget);
    expect(find.widgetWithText(CupertinoFormRow, 'Bluetooth'), findsOneWidget);
    expect(
      find.widgetWithText(CupertinoFormRow, 'Mobile Data'),
      findsOneWidget,
    );
  });
}
