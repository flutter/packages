// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:cupertino_ui_examples/text_form_field_row/cupertino_text_form_field_row.1.dart'
    as example;
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Can enter text in CupertinoTextFormFieldRow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.FormSectionApp());

    expect(find.byType(CupertinoFormSection), findsOneWidget);
    expect(find.byType(CupertinoTextFormFieldRow), findsNWidgets(5));

    expect(
      find.widgetWithText(CupertinoTextFormFieldRow, 'abcd'),
      findsNothing,
    );
    await tester.enterText(
      find.byType(CupertinoTextFormFieldRow).first,
      'abcd',
    );
    await tester.pump();
    expect(
      find.widgetWithText(CupertinoTextFormFieldRow, 'abcd'),
      findsOneWidget,
    );
  });
}
