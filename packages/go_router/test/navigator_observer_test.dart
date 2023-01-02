// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: cascade_invocations, diagnostic_describe_all_properties

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets(
    'It checks if the NavigatorObserver has been called on the routes inside the ShellRoute',
    (WidgetTester tester) async {
      int didPushNotifyCount = 0;
      int didPopNotifyCount = 0;

      final TestObserver testObserver = TestObserver()
        ..onPushed = (Route<dynamic>? route, Route<dynamic>? previousRoute) {
          if (route?.settings.name == 'new_route') {
            didPushNotifyCount++;
          }
        }
        ..onPopped = (Route<dynamic>? route, Route<dynamic>? previousRoute) {
          if (route?.settings.name == 'new_route') {
            didPopNotifyCount++;
          }
        };

      final GlobalKey<NavigatorState> shellNavigatorKey =
          GlobalKey<NavigatorState>();
      final GoRouter router = GoRouter(
        initialLocation: '/a',
        observers: <NavigatorObserver>[testObserver],
        routes: <RouteBase>[
          ShellRoute(
            navigatorKey: shellNavigatorKey,
            builder: (BuildContext context, GoRouterState state, Widget child) {
              return Scaffold(
                appBar: AppBar(title: const Text('Shell')),
                body: child,
              );
            },
            routes: <GoRoute>[
              GoRoute(
                path: '/a',
                builder: (BuildContext context, _) {
                  return Scaffold(
                    body: TextButton(
                      onPressed: () async {
                        shellNavigatorKey.currentState!.push(
                          MaterialPageRoute<void>(
                            settings: const RouteSettings(name: 'new_route'),
                            builder: (BuildContext context) {
                              return Scaffold(
                                body: Column(
                                  children: <Widget>[
                                    const Text('new route'),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Pop'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                      child: const Text('Push'),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
            routeInformationProvider: router.routeInformationProvider,
            routeInformationParser: router.routeInformationParser,
            routerDelegate: router.routerDelegate),
      );

      expect(find.text('Push'), findsOneWidget);

      await tester.tap(find.text('Push'));
      await tester.pumpAndSettle();

      expect(find.text('new route', skipOffstage: false), findsOneWidget);

      await tester.tap(find.text('Pop'));
      await tester.pumpAndSettle();

      expect(didPushNotifyCount, equals(1));
      expect(didPopNotifyCount, equals(1));
    },
  );
}

typedef OnObservation = void Function(
    Route<dynamic>? route, Route<dynamic>? previousRoute);

/// A trivial observer for testing the navigator.
class TestObserver extends NavigatorObserver {
  OnObservation? onPushed;
  OnObservation? onPopped;
  OnObservation? onRemoved;
  OnObservation? onReplaced;
  OnObservation? onStartUserGesture;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onPushed?.call(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onPopped?.call(route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onRemoved?.call(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? oldRoute, Route<dynamic>? newRoute}) {
    onReplaced?.call(newRoute, oldRoute);
  }

  @override
  void didStartUserGesture(
      Route<dynamic> route, Route<dynamic>? previousRoute) {
    onStartUserGesture?.call(route, previousRoute);
  }
}
