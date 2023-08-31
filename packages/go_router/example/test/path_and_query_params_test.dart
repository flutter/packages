// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router_examples/path_and_query_parameters.dart' as example;

void main() {
  testWidgets('example works', (WidgetTester tester) async {
    await tester.pumpWidget(example.App());
    expect(find.text(example.App.title), findsOneWidget);

    // Directly set the url through platform message.
    Map<String, dynamic> testRouteInformation = <String, dynamic>{
      'location': '/family/f1?sort=asc',
    };
    ByteData message = const JSONMethodCodec().encodeMethodCall(
      MethodCall('pushRouteInformation', testRouteInformation),
    );
    await tester.binding.defaultBinaryMessenger
        .handlePlatformMessage('flutter/navigation', message, (_) {});

    await tester.pumpAndSettle();
    // 'Chris' should be higher than 'Tom'.
    expect(
        tester.getCenter(find.text('Jane')).dy <
            tester.getCenter(find.text('John')).dy,
        isTrue);

    testRouteInformation = <String, dynamic>{
      'location': '/family/f1?privacy=false',
    };
    message = const JSONMethodCodec().encodeMethodCall(
      MethodCall('pushRouteInformation', testRouteInformation),
    );
    await tester.binding.defaultBinaryMessenger
        .handlePlatformMessage('flutter/navigation', message, (_) {});

    await tester.pumpAndSettle();
    // 'Chris' should be lower than 'Tom'.
    expect(
        tester.getCenter(find.text('Jane')).dy >
            tester.getCenter(find.text('John')).dy,
        isTrue);
  });
}
