// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';

import 'package:plaform_example/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    expect(find.text('Platform Example'), findsOneWidget);
    expect(find.text('Operating System:'), findsOneWidget);
    expect(find.text('Number of Processors:'), findsOneWidget);
    expect(find.text('Path Separator:'), findsOneWidget);
  });
}
