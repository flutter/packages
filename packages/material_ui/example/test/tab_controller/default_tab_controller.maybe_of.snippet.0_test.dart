// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/tab_controller/default_tab_controller.maybe_of.snippet.0.dart'
    as example;

void main() {
  testWidgets(
    'DefaultTabController.maybeOf returns null when absent and tracks closest ancestor',
    (WidgetTester tester) async {
      TabController? controller;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              controller = example.lookupTabController(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(controller, isNull);

      int buildCount = 0;
      Widget buildWithDefaultController(int length) {
        return MaterialApp(
          home: DefaultTabController(
            length: length,
            child: Builder(
              builder: (BuildContext context) {
                buildCount += 1;
                controller = example.lookupTabController(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );
      }

      await tester.pumpWidget(buildWithDefaultController(2));
      expect(controller, isNotNull);
      expect(controller!.length, 2);
      expect(buildCount, 1);

      await tester.pumpWidget(buildWithDefaultController(4));
      expect(controller!.length, 4);
      expect(buildCount, 2);
    },
  );
}
