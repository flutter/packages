// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router_builder_example/case_sensitive_example.dart';

void main() {
  testWidgets(
      'It should navigate to the correct screen when the route is case sensitive and the path matches exactly',
      (WidgetTester tester) async {
    tester.platformDispatcher.defaultRouteNameTestValue = '/case-sensitive';
    await tester.pumpWidget(CaseSensitivityApp());

    expect(find.widgetWithText(AppBar, 'Case Sensitive'), findsOne);
  });

  testWidgets(
      'It should navigate to the correct screen when the route is not case sensitive and the path matches exactly',
      (WidgetTester tester) async {
    tester.platformDispatcher.defaultRouteNameTestValue = '/not-case-sensitive';
    await tester.pumpWidget(CaseSensitivityApp());

    expect(find.widgetWithText(AppBar, 'Not Case Sensitive'), findsOne);
  });

  testWidgets(
      'It should throw an error when the route is case sensitive and the path does not match',
      (WidgetTester tester) async {
    final FlutterExceptionHandler? oldFlutterError = FlutterError.onError;
    addTearDown(() => FlutterError.onError = oldFlutterError);
    final List<FlutterErrorDetails> errors = <FlutterErrorDetails>[];
    FlutterError.onError = (FlutterErrorDetails details) {
      errors.add(details);
    };

    tester.platformDispatcher.defaultRouteNameTestValue = '/CASE-sensitive';
    await tester.pumpWidget(CaseSensitivityApp());

    expect(find.widgetWithText(AppBar, 'Case Sensitive'), findsNothing);
    expect(errors, hasLength(1));
    expect(
      errors.single.exception,
      isAssertionError,
      reason: 'The path is case sensitive',
    );
  });

  testWidgets(
      'It should navigate to the correct screen when the route is not case sensitive and the path case does not match',
      (WidgetTester tester) async {
    tester.platformDispatcher.defaultRouteNameTestValue = '/NOT-case-sensitive';
    await tester.pumpWidget(CaseSensitivityApp());

    expect(find.widgetWithText(AppBar, 'Not Case Sensitive'), findsOne);
  });
}
