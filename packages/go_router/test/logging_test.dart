// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/src/logging.dart';
import 'package:logging/logging.dart';

void main() {
  tearDown(() {
    // Reset the logging state
    hierarchicalLoggingEnabled = false;

    // Reset the developer log function.
    testDeveloperLog = null;
  });
  test('setLogging does not clear listeners', () {
    final StreamSubscription<LogRecord> subscription = logger.onRecord.listen(
      expectAsync1<void, LogRecord>((LogRecord r) {}, count: 2),
    );
    addTearDown(subscription.cancel);

    setLogging(enabled: true);
    logger.info('message');
    setLogging();
    logger.info('message');
  });

  testWidgets(
    'It should not log anything the if debugLogDiagnostics is false',
    (WidgetTester tester) async {
      testDeveloperLog = expectAsync1((LogRecord data) {}, count: 0);
      final StreamSubscription<LogRecord> subscription =
          Logger.root.onRecord.listen(
        expectAsync1((LogRecord data) {}, count: 0),
      );
      addTearDown(subscription.cancel);
      GoRouter(
        routes: <RouteBase>[
          GoRoute(
            path: '/',
            builder: (_, GoRouterState state) => const Text('home'),
          ),
        ],
      );
    },
  );

  testWidgets(
    'It should log the known routes and the initial route if debugLogDiagnostics is true',
    (WidgetTester tester) async {
      testDeveloperLog = expectAsync1(
        (LogRecord data) {},
        count: 2,
        reason: 'Go router should log the 2 events',
      );
      final List<String> logs = <String>[];
      Logger.root.onRecord.listen(
        (LogRecord event) => logs.add(event.message),
      );
      GoRouter(
        debugLogDiagnostics: true,
        routes: <RouteBase>[
          GoRoute(
            path: '/',
            builder: (_, GoRouterState state) => const Text('home'),
          ),
        ],
      );

      expect(
        logs,
        const <String>[
          'Full paths for routes:\n└─/ (Text)\n',
          'setting initial location null'
        ],
        reason: 'Go router should have sent the 2 events to the logger',
      );
    },
  );

  testWidgets(
    'Go router should not log itself the known routes but send the events to the logger when hierarchicalLoggingEnabled is true',
    (WidgetTester tester) async {
      testDeveloperLog = expectAsync1(
        (LogRecord data) {},
        count: 0,
        reason: 'Go router should log the events itself',
      );
      hierarchicalLoggingEnabled = true;

      final List<String> logs = <String>[];
      Logger.root.onRecord.listen(
        (LogRecord event) => logs.add(event.message),
      );
      GoRouter(
        debugLogDiagnostics: true,
        routes: <RouteBase>[
          GoRoute(
            path: '/',
            builder: (_, GoRouterState state) => const Text('home'),
          ),
        ],
      );

      expect(
        logs,
        const <String>[
          'Full paths for routes:\n└─/ (Text)\n',
          'setting initial location null'
        ],
        reason: 'Go router should have sent the 2 events to the logger',
      );
    },
  );
}
