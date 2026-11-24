// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/drawer/drawer_controller.maybe_of.snippet.0.dart'
    as example;

void main() {
  testWidgets(
    'DrawerController.maybeOf returns null outside drawer and controller inside',
    (WidgetTester tester) async {
      DrawerController? bodyController;
      DrawerController? drawerController;
      final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            key: scaffoldKey,
            drawer: Drawer(
              child: Builder(
                builder: (BuildContext context) {
                  drawerController = example.lookupDrawerController(context);
                  return const SizedBox.shrink();
                },
              ),
            ),
            body: Builder(
              builder: (BuildContext context) {
                bodyController = example.lookupDrawerController(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(bodyController, isNull);

      scaffoldKey.currentState!.openDrawer();
      await tester.pumpAndSettle();

      expect(drawerController, isNotNull);
    },
  );
}
