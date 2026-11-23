// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/dialog/simple_dialog_option.snippet.0.dart'
    as example;

void main() {
  testWidgets('SimpleDialogOption pops dialog with Department.treasury', (
    WidgetTester tester,
  ) async {
    example.Department? selectedDepartment;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return TextButton(
                onPressed: () async {
                  selectedDepartment = await showDialog<example.Department>(
                    context: context,
                    builder: (BuildContext context) {
                      return const SimpleDialog(
                        children: <Widget>[example.SimpleDialogOptionExample()],
                      );
                    },
                  );
                },
                child: const Text('Open Dialog'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Treasury department'), findsOneWidget);

    await tester.tap(find.text('Treasury department'));
    await tester.pumpAndSettle();

    expect(find.text('Treasury department'), findsNothing);
    expect(selectedDepartment, example.Department.treasury);
  });
}
