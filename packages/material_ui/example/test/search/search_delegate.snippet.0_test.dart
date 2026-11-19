// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/search/search_delegate.snippet.0.dart'
    as example;

void main() {
  testWidgets(
    'CustomSearchHintDelegate configures search field and renders delegate slots',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return TextButton(
                  onPressed: () {
                    showSearch<String>(
                      context: context,
                      delegate: example.CustomSearchHintDelegate(
                        hintText: 'Custom hint',
                      ),
                    );
                  },
                  child: const Text('Open Search'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Search'));
      await tester.pumpAndSettle();

      final TextField searchField = tester.widget<TextField>(
        find.byType(TextField),
      );
      expect(searchField.decoration?.hintText, 'Custom hint');
      expect(searchField.keyboardType, TextInputType.text);
      expect(searchField.textInputAction, TextInputAction.search);

      expect(find.text('leading'), findsOneWidget);
      expect(find.text('bottom'), findsOneWidget);
      expect(find.text('suggestions'), findsOneWidget);
      expect(find.text('results'), findsNothing);

      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(find.text('results'), findsOneWidget);
    },
  );
}
