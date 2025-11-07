// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router_builder_example/shared/data.dart';
import 'package:go_router_builder_example/simple_example.dart';

void main() {
  testWidgets('App starts on HomeScreen and displays families', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(App());
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(familyData.length));
    for (final Family family in familyData) {
      expect(find.text(family.name), findsOneWidget);
    }
  });
}
