// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const String initialRoute = '/';
const String newRoute = '/new';

void main() {
  group('GoRouteInformationProvider', () {
    testWidgets('notifies its listeners when set by the app',
        (WidgetTester tester) async {
      late final GoRouteInformationProvider provider =
          GoRouteInformationProvider(
              initialLocation: initialRoute, initialExtra: null);
      addTearDown(provider.dispose);
      provider.addListener(expectAsync0(() {}));
      provider.go(newRoute);
    });

    testWidgets('notifies its listeners when set by the platform',
        (WidgetTester tester) async {
      late final GoRouteInformationProvider provider =
          GoRouteInformationProvider(
              initialLocation: initialRoute, initialExtra: null);
      addTearDown(provider.dispose);
      provider.addListener(expectAsync0(() {}));
      provider
          .didPushRouteInformation(RouteInformation(uri: Uri.parse(newRoute)));
    });

    testWidgets('didPushRouteInformation maintains uri scheme and host',
        (WidgetTester tester) async {
      const String expectedScheme = 'https';
      const String expectedHost = 'www.example.com';
      const String expectedPath = '/some/path';
      const String expectedUriString =
          '$expectedScheme://$expectedHost$expectedPath';
      late final GoRouteInformationProvider provider =
          GoRouteInformationProvider(
              initialLocation: initialRoute, initialExtra: null);
      addTearDown(provider.dispose);
      provider.addListener(expectAsync0(() {}));
      provider.didPushRouteInformation(
          RouteInformation(uri: Uri.parse(expectedUriString)));
      expect(provider.value.uri.scheme, 'https');
      expect(provider.value.uri.host, 'www.example.com');
      expect(provider.value.uri.path, '/some/path');
      expect(provider.value.uri.toString(), expectedUriString);
    });

    testWidgets('didPushRoute maintains uri scheme and host',
        (WidgetTester tester) async {
      const String expectedScheme = 'https';
      const String expectedHost = 'www.example.com';
      const String expectedPath = '/some/path';
      const String expectedUriString =
          '$expectedScheme://$expectedHost$expectedPath';
      late final GoRouteInformationProvider provider =
          GoRouteInformationProvider(
              initialLocation: initialRoute, initialExtra: null);
      addTearDown(provider.dispose);
      provider.addListener(expectAsync0(() {}));
      provider.didPushRouteInformation(
          RouteInformation(uri: Uri.parse(expectedUriString)));
      expect(provider.value.uri.scheme, 'https');
      expect(provider.value.uri.host, 'www.example.com');
      expect(provider.value.uri.path, '/some/path');
      expect(provider.value.uri.toString(), expectedUriString);
    });

    testWidgets('Route is correctly neglected when routerNeglect is true',
        (WidgetTester tester) async {
      final _SystemChannelsNavigationMock systemChannelsMock =
          _SystemChannelsNavigationMock();
      late final GoRouteInformationProvider provider =
          GoRouteInformationProvider(
              initialLocation: initialRoute,
              initialExtra: null,
              routerNeglect: true);
      addTearDown(provider.dispose);
      provider.addListener(expectAsync0(() {}));
      provider.go(newRoute);
      provider.routerReportsNewRouteInformation(
          RouteInformation(
              uri: Uri.parse(newRoute), state: <Object?, Object?>{}),
          type: RouteInformationReportingType.navigate);
      expect(systemChannelsMock.uriIsNeglected[newRoute], true);
    });

    testWidgets('Route is NOT neglected when routerNeglect is false',
        (WidgetTester tester) async {
      final _SystemChannelsNavigationMock systemChannelsMock =
          _SystemChannelsNavigationMock();
      late final GoRouteInformationProvider provider =
          GoRouteInformationProvider(
              initialLocation: initialRoute, initialExtra: null);
      addTearDown(provider.dispose);
      provider.addListener(expectAsync0(() {}));
      provider.go(newRoute);
      provider.routerReportsNewRouteInformation(
          RouteInformation(
              uri: Uri.parse(newRoute), state: <Object?, Object?>{}),
          type: RouteInformationReportingType.navigate);
      expect(systemChannelsMock.uriIsNeglected[newRoute], false);
    });
  });
}

class _SystemChannelsNavigationMock {
  _SystemChannelsNavigationMock() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.navigation,
            (MethodCall methodCall) async {
      if (methodCall.method == 'routeInformationUpdated' &&
          methodCall.arguments is Map<String, dynamic>) {
        final Map<String, dynamic> args =
            methodCall.arguments as Map<String, dynamic>;
        final String? uri =
            args['location'] as String? ?? args['uri'] as String?;
        uriIsNeglected[uri ?? ''] = args['replace'] as bool;
      }
      return null;
    });
  }

  Map<String, bool> uriIsNeglected = <String, bool>{};
}
