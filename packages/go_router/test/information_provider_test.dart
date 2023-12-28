// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
      provider.addListener(expectAsync0(() {}));
      provider.go(newRoute);
    });

    testWidgets('notifies its listeners when set by the platform',
        (WidgetTester tester) async {
      late final GoRouteInformationProvider provider =
          GoRouteInformationProvider(
              initialLocation: initialRoute, initialExtra: null);
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
      provider.addListener(expectAsync0(() {}));
      provider.didPushRouteInformation(
          RouteInformation(uri: Uri.parse(expectedUriString)));
      expect(provider.value.uri.scheme, 'https');
      expect(provider.value.uri.host, 'www.example.com');
      expect(provider.value.uri.path, '/some/path');
      expect(provider.value.uri.toString(), expectedUriString);
    });
  });
}
