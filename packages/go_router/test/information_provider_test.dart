// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/src/information_provider.dart';

const RouteInformation initialRoute = RouteInformation(location: '/');
const RouteInformation newRoute = RouteInformation(location: '/new');

void main() {
  group('GoRouteInformationProvider', () {
    testWidgets('notifies its listeners when set by the app',
        (WidgetTester tester) async {
      final GoRouteInformationProvider provider = GoRouteInformationProvider(
        initialRouteInformation: initialRoute,
      );
      provider.addListener(expectAsync0(() {}));
      provider.value = newRoute;
    });

    testWidgets('notifies its listeners when set by the platform',
        (WidgetTester tester) async {
      final GoRouteInformationProvider provider = GoRouteInformationProvider(
        initialRouteInformation: initialRoute,
      );
      provider.addListener(expectAsync0(() {}));
      provider.didPushRouteInformation(newRoute);
    });

    group('[push route decision]', () {
      test('didPushRoute is false for "delegate"', () async {
        final GoRouteInformationProvider provider = GoRouteInformationProvider(
          initialRouteInformation: initialRoute,
          onPushRoute: (_) => PushRouteDecision.delegate,
        );
        expect(await provider.didPushRoute('/new'), isFalse);
        expect(await provider.didPushRouteInformation(newRoute), isFalse);
      });

      test('didPushRoute is true for "prevent"', () async {
        final GoRouteInformationProvider provider = GoRouteInformationProvider(
          initialRouteInformation: initialRoute,
          onPushRoute: (_) => PushRouteDecision.prevent,
        );
        expect(await provider.didPushRoute('/new'), isTrue);
        expect(await provider.didPushRouteInformation(newRoute), isTrue);
      });

      test('didPushRoute is true for "navigate"', () async {
        final GoRouteInformationProvider provider = GoRouteInformationProvider(
          initialRouteInformation: initialRoute,
          onPushRoute: (_) => PushRouteDecision.navigate,
        );
        provider.addListener(expectAsync0(() {}));
        expect(await provider.didPushRoute('/new'), isTrue);
        expect(await provider.didPushRouteInformation(newRoute), isTrue);
      });
    });
  });
}
