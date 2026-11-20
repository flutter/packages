// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/icons/icons.adaptive.snippet.0.dart'
    as example;

void main() {
  testWidgets(
    'Icons.adaptive.share adapts between Apple and non-Apple platforms',
    (WidgetTester tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(const example.ExampleApp());
      expect(find.byIcon(Icons.share), findsOneWidget);
      expect(find.byIcon(Icons.ios_share), findsNothing);

      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await tester.pumpWidget(const example.ExampleApp());
      expect(find.byIcon(Icons.ios_share), findsOneWidget);
      expect(find.byIcon(Icons.share), findsNothing);

      debugDefaultTargetPlatformOverride = null;
    },
  );
}
