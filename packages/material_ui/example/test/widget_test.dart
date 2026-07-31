// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui_examples/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ExampleApp());

    await tester.tap(find.text('about/about_list_tile.0.dart'));
    await tester.pumpAndSettle();

    expect(find.text('Show About Example'), findsNWidgets(2));
  });
}
