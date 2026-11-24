// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/tab_controller/default_tab_controller.of.snippet.0.dart'
    as example;

void main() {
  testWidgets(
    'DefaultTabController.of returns closest controller and asserts when absent',
    (WidgetTester tester) async {
      late TabController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultTabController(
            length: 3,
            child: Builder(
              builder: (BuildContext context) {
                controller = example.lookupTabController(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      expect(controller.length, 3);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              example.lookupTabController(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(tester.takeException(), isFlutterError);
    },
  );
}
