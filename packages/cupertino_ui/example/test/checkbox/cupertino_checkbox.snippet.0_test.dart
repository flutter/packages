// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:cupertino_ui_examples/checkbox/cupertino_checkbox.snippet.0.dart'
    as example;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show Colors;

void main() {
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
    expect(getCheckboxRenderer(), paints..rrect(color: Colors.orange));

    await tester.pumpWidget(buildApp(onChanged: null));
    await tester.pumpAndSettle();
    expect(
      getCheckboxRenderer(),
      paints..rrect(color: Colors.orange.withValues(alpha: .32)),
    );
  });
}
