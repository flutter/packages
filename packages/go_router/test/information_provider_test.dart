// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/src/information_provider.dart';

const RouteInformation initialRoute = RouteInformation(location: '/');
const RouteInformation newRoute = RouteInformation(location: '/new');

void main() {
  group('GoRouteInformationProvider', () {
    testWidgets('notifies its listeners when set by the app',
        (WidgetTester tester) async {
      final GoRouteInformationProvider provider =
          GoRouteInformationProvider(initialRouteInformation: initialRoute);
      provider.addListener(expectAsync0(() {}));
      provider.value = newRoute;
      provider.dispose();
    });

    testWidgets('notifies its listeners when set by the platform',
        (WidgetTester tester) async {
      final GoRouteInformationProvider provider =
          GoRouteInformationProvider(initialRouteInformation: initialRoute);
      provider.addListener(expectAsync0(() {}));
      provider.didPushRouteInformation(newRoute);
      provider.dispose();
    });

    testWidgets('updates route information', (WidgetTester tester) async {
      final List<MethodCall> log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.navigation,
              (MethodCall methodCall) async {
        log.add(methodCall);
        return null;
      });
      late final GoRouteInformationProvider provider =
          GoRouteInformationProvider(
              initialRouteInformation: const RouteInformation(location: '/'));

      log.clear();
      final String jsonString1 =
          const JsonEncoder().convert(<String, String>{'1': '2'});
      provider.routerReportsNewRouteInformation(RouteInformation(
          location: '/a', state: BrowserState(jsonString: jsonString1)));
      // Implicit reporting pushes new history entry if the location changes.
      expect(log, <Object>[
        isMethodCall('selectMultiEntryHistory', arguments: null),
        isMethodCall('routeInformationUpdated', arguments: <String, dynamic>{
          'location': '/a',
          'state': jsonString1,
          'replace': false
        }),
      ]);
      log.clear();
      final String jsonString2 =
          const JsonEncoder().convert(<String, String>{'2': '3'});
      provider.routerReportsNewRouteInformation(RouteInformation(
          location: '/a', state: BrowserState(jsonString: jsonString2)));
      // Since the location is the same, the provider sends replaces message.
      expect(log, <Object>[
        isMethodCall('selectMultiEntryHistory', arguments: null),
        isMethodCall('routeInformationUpdated', arguments: <String, dynamic>{
          'location': '/a',
          'state': jsonString2,
          'replace': true
        }),
      ]);

      log.clear();
      provider.routerReportsNewRouteInformation(
          const RouteInformation(location: '/a', state: false),
          type: RouteInformationReportingType.neglect);
      // If the state is not a BrowserState, GoRouteInformationProvider will not report.
      expect(log, <Object>[
        isMethodCall('selectMultiEntryHistory', arguments: null),
        isMethodCall('routeInformationUpdated', arguments: <String, dynamic>{
          'location': '/a',
          'state': null,
          'replace': true
        }),
      ]);
    });

    testWidgets('can convert browser state', (WidgetTester tester) async {
      final GoRouteInformationProvider provider = GoRouteInformationProvider(
        initialRouteInformation: const RouteInformation(
          location: 'initial',
        ),
      );
      RouteInformation? notifiedInformation;
      provider.addListener(() {
        notifiedInformation = provider.value;
      });

      final String jsonString =
          const JsonEncoder().convert(<String, String>{'1': '2'});
      const String newLocation = 'testRouteName';
      // Pushes through the `pushRouteInformation` in the navigation method channel.
      final Map<String, dynamic> testRouteInformation = <String, dynamic>{
        'location': newLocation,
        'state': jsonString,
      };
      final ByteData routerMessage = const JSONMethodCodec().encodeMethodCall(
        MethodCall('pushRouteInformation', testRouteInformation),
      );
      await tester.binding.defaultBinaryMessenger
          .handlePlatformMessage('flutter/navigation', routerMessage, (_) {});
      expect(notifiedInformation, isNotNull);
      expect(notifiedInformation!.location, newLocation);
      expect(notifiedInformation!.state, isA<BrowserState>());
      expect(
          (notifiedInformation!.state! as BrowserState).jsonString, jsonString);
    });
  });
}
