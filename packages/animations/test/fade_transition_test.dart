// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:animations/src/fade_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

void main() {
  testWidgets(
    'showModalWithFadeTransition builds a new route',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return Center(
                  child: RaisedButton(
                    onPressed: () {
                      showModalWithFadeTransition(
                        context: context,
                        child: const _FlutterLogoDialog(),
                      );
                    },
                    child: Icon(Icons.add),
                  ),
                );
              }
            ),
          ),
        ),
      );
      await tester.tap(find.byType(RaisedButton));
      await tester.pumpAndSettle();
      expect(find.byType(_FlutterLogoDialog), findsOneWidget);
    },
  );
}

class _FlutterLogoDialog extends StatelessWidget {
  const _FlutterLogoDialog();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 500,
          maxWidth: 500,
          minHeight: 250,
          minWidth: 250,
        ),
        child: const Material(
          child: Center(child: FlutterLogo(size: 250)),
        ),
      ),
    );
  }
}