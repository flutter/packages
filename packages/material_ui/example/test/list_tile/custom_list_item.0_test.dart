// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/list_tile/custom_list_item.0.dart'
    as example;

void main() {
  testWidgets('Custom list item uses Expanded widgets for the layout', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.CustomListItemApp());

    // The Expanded widget is used to control the size of the thumbnail.
    Expanded thumbnailExpanded = tester.widget(
      find.ancestor(
        of: find.byType(Container).first,
        matching: find.byType(Expanded),
      ),
    );
    expect(thumbnailExpanded.flex, 2);

    // The Expanded widget is used to control the size of the text.
    Expanded textExpanded = tester.widget(
      find.ancestor(
        of: find.text('The Flutter YouTube Channel'),
        matching: find.byType(Expanded),
      ),
    );
    expect(textExpanded.flex, 3);

    // The Expanded widget is used to control the size of the thumbnail.
    thumbnailExpanded = tester.widget(
      find.ancestor(
        of: find.byType(Container).last,
        matching: find.byType(Expanded),
      ),
    );
    expect(thumbnailExpanded.flex, 2);

    // The Expanded widget is used to control the size of the text.
    textExpanded = tester.widget(
      find.ancestor(
        of: find.text('Announcing Flutter 1.0'),
        matching: find.byType(Expanded),
      ),
    );
    expect(textExpanded.flex, 3);
  });
}
