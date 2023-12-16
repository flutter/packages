// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router_builder_example/readme_excerpts.dart';

void main() {
  testWidgets('App starts on HomeScreen', (WidgetTester tester) async {
    await tester.pumpWidget(App());
    expect(find.text('In App Purchase Examples'), findsOneWidget);
  });

  testWidgets('AuthorDetailsScreen renders correctly',
      (WidgetTester tester) async {
    const int testAuthorId = 42;
    await tester.pumpWidget(const MaterialApp(
      home: AuthorDetailsScreen(authorId: testAuthorId),
    ));
    expect(find.text('Author ID: $testAuthorId'), findsOneWidget);
  });
}
