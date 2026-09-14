// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets(
    'DropdownButton opened inside a dialog is dismissed on orientation change without throwing',
    (WidgetTester tester) async {
      // Regression test for https://github.com/flutter/flutter/issues/171011
      addTearDown(tester.view.reset);
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 600);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: DropdownButton<int>(
                              value: 1,
                              onChanged: (int? value) {},
                              items: const <DropdownMenuItem<int>>[
                                DropdownMenuItem<int>(value: 1, child: Text('1')),
                                DropdownMenuItem<int>(value: 2, child: Text('2')),
                                DropdownMenuItem<int>(value: 3, child: Text('3')),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: const Text('Open dialog'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Open the dialog, then open the dropdown menu inside it.
      await tester.tap(find.text('Open dialog'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButton<int>));
      await tester.pumpAndSettle();
      expect(find.byType(ListView), findsOneWidget);

      // Rotate the device (simulate by swapping the physical size dimensions).
      tester.view.physicalSize = const Size(600, 800);
      await tester.pumpAndSettle();

      // The route should be dismissed without mutating the Navigator during build.
      expect(tester.takeException(), isNull);
      expect(find.byType(ListView), findsNothing);
    },
  );
}
