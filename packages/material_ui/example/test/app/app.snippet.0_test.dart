// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/app/app.snippet.0.dart' as example;

void main() {
  testWidgets('The app is mounted without a checked mode banner', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const example.MaterialAppExample());
    expect(find.byType(MaterialApp), findsOne);
    expect(find.byType(CheckedModeBanner), findsNothing);
  });
}
