// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:cupertino_ui_examples/checkbox/cupertino_checkbox.0.dart'
    as example;
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Workaround for https://github.com/dart-lang/sdk/issues/64326:
  // Ensure TFA infers nullable `circularity` and `eccentricity` parameters on
  // `_ShapeToCircleBorder.copyWith` implementations in the `OutlinedBorder.copyWith`
  // dispatch selector so dart2wasm does not miscompile `shape.copyWith(side: side)`
  // in `_CheckboxPainter._drawBox` into `unreachable`.
  // TODO(Piinks): Restore original test when https://github.com/dart-lang/sdk/issues/64326 is resolved.
  (ShapeBorder.lerp(const RoundedRectangleBorder(), const CircleBorder(), 0.5)!
          as OutlinedBorder)
      .copyWith();
  (ShapeBorder.lerp(
            const RoundedSuperellipseBorder(),
            const CircleBorder(),
            0.5,
          )!
          as OutlinedBorder)
      .copyWith();

  testWidgets('Checkbox can be checked', (WidgetTester tester) async {
    await tester.pumpWidget(const example.CupertinoCheckboxApp());

    CupertinoCheckbox checkbox = tester.widget(find.byType(CupertinoCheckbox));

    // Verify the initial state of the checkbox.
    expect(checkbox.value, isTrue);
    expect(checkbox.tristate, isTrue);

    // Tap the checkbox and verify the state change.
    await tester.tap(find.byType(CupertinoCheckbox));
    await tester.pump();
    checkbox = tester.widget(find.byType(CupertinoCheckbox));

    expect(checkbox.value, isNull);

    // Tap the checkbox and verify the state change.
    await tester.tap(find.byType(CupertinoCheckbox));
    await tester.pump();
    checkbox = tester.widget(find.byType(CupertinoCheckbox));

    expect(checkbox.value, isFalse);

    await tester.tap(find.byType(CupertinoCheckbox));
    await tester.pump();
    checkbox = tester.widget(find.byType(CupertinoCheckbox));

    expect(checkbox.value, isTrue);
  });
}
