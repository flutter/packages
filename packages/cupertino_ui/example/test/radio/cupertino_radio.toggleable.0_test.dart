// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:cupertino_ui_examples/radio/cupertino_radio.toggleable.0.dart'
    as example;
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Has 2 CupertinoRadio widgets that can be toggled off', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.CupertinoRadioApp());

    expect(
      find.byType(CupertinoRadio<example.SingingCharacter>),
      findsNWidgets(2),
    );

    RadioGroup<example.SingingCharacter> group = tester.widget(
      find.byType(RadioGroup<example.SingingCharacter>),
    );
    expect(group.groupValue, example.SingingCharacter.mulligan);

    await tester.tap(
      find.byType(CupertinoRadio<example.SingingCharacter>).last,
    );
    await tester.pumpAndSettle();

    group = tester.widget(find.byType(RadioGroup<example.SingingCharacter>));
    expect(group.groupValue, example.SingingCharacter.hamilton);

    await tester.tap(
      find.byType(CupertinoRadio<example.SingingCharacter>).last,
    );
    await tester.pumpAndSettle();

    group = tester.widget(find.byType(RadioGroup<example.SingingCharacter>));
    expect(group.groupValue, null);
  });
}
