// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:cupertino_ui_examples/checkbox/cupertino_checkbox.snippet.0.dart'
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

  testWidgets('Checkbox color is affected by whether it is enabled', (
    WidgetTester tester,
  ) async {
    RenderBox getCheckboxRenderer() {
      return tester.renderObject<RenderBox>(find.byType(CupertinoCheckbox));
    }

    Widget buildApp({required ValueChanged<bool?>? onChanged}) {
      return CupertinoApp(
        theme: CupertinoThemeData(brightness: .light),
        home: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text('CupertinoCheckbox Example'),
          ),
          child: SafeArea(
            child: example.CupertinoCheckboxExample(onChanged: onChanged),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildApp(onChanged: (bool? _) {}));
    await tester.pumpAndSettle();
    expect(
      getCheckboxRenderer(),
      paints..rrect(color: CupertinoColors.activeOrange.color),
    );

    await tester.pumpWidget(buildApp(onChanged: null));
    await tester.pumpAndSettle();
    expect(
      getCheckboxRenderer(),
      paints..rrect(
        color: CupertinoColors.activeOrange.color.withValues(alpha: .32),
      ),
    );
  });
}
