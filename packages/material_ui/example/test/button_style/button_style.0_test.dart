// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/button_style/button_style.0.dart'
    as example;

void main() {
  testWidgets(
    'Shows ElevatedButtons, FilledButtons, OutlinedButtons and TextButtons in enabled and disabled states',
    (WidgetTester tester) async {
      await tester.pumpWidget(const example.ButtonApp());

      expect(
        find.byWidgetPredicate((Widget widget) {
          return widget is ElevatedButton && widget.onPressed == null;
        }),
        findsOne,
      );

      expect(
        find.byWidgetPredicate((Widget widget) {
          return widget is ElevatedButton && widget.onPressed != null;
        }),
        findsOne,
      );

      // One OutlinedButton with onPressed null.
      expect(
        find.byWidgetPredicate((Widget widget) {
          return widget is OutlinedButton && widget.onPressed == null;
        }),
        findsOne,
      );

      // One OutlinedButton with onPressed not null.
      expect(
        find.byWidgetPredicate((Widget widget) {
          return widget is OutlinedButton && widget.onPressed != null;
        }),
        findsOne,
      );

      expect(
        find.byWidgetPredicate((Widget widget) {
          return widget is TextButton && widget.onPressed == null;
        }),
        findsOne,
      );

      expect(
        find.byWidgetPredicate((Widget widget) {
          return widget is TextButton && widget.onPressed != null;
        }),
        findsOne,
      );

      expect(
        find.byWidgetPredicate((Widget widget) {
          return widget is FilledButton && widget.onPressed != null;
        }),
        findsNWidgets(2),
      );

      expect(
        find.byWidgetPredicate((Widget widget) {
          return widget is FilledButton && widget.onPressed == null;
        }),
        findsNWidgets(2),
      );
    },
  );
}
