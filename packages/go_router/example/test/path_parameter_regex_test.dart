// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router_examples/path_parameter_regex.dart' as example;

void main() {
  testWidgets('matches numeric path parameter', (WidgetTester tester) async {
    example.router.go('/users/42');

    await tester.pumpWidget(const example.PathParameterRegexApp());
    await tester.pumpAndSettle();

    expect(find.text('User 42'), findsOneWidget);
  });
}
