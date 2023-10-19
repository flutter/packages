// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router_examples/redirection.dart' as example;

void main() {
  testWidgets('example works', (WidgetTester tester) async {
    await tester.pumpWidget(example.App());
    expect(find.text('Login'), findsOneWidget);

    // Directly set the url to the home page.
    Map<String, dynamic> testRouteInformation = <String, dynamic>{
      'location': '/',
    };
    ByteData message = const JSONMethodCodec().encodeMethodCall(
      MethodCall('pushRouteInformation', testRouteInformation),
    );
    await tester.binding.defaultBinaryMessenger
        .handlePlatformMessage('flutter/navigation', message, (_) {});

    await tester.pumpAndSettle();
    // Still show login page due to redirection
    expect(find.text('Login'), findsOneWidget);

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.text('HomeScreen'), findsOneWidget);

    testRouteInformation = <String, dynamic>{
      'location': '/login',
    };
    message = const JSONMethodCodec().encodeMethodCall(
      MethodCall('pushRouteInformation', testRouteInformation),
    );
    await tester.binding.defaultBinaryMessenger
        .handlePlatformMessage('flutter/navigation', message, (_) {});

    await tester.pumpAndSettle();
    // Got redirected back to home page.
    expect(find.text('HomeScreen'), findsOneWidget);

    // Tap logout.
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
  });
}
