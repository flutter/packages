// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'test_helpers.dart';

// Regression test for https://github.com/flutter/flutter/issues/120353
void main() {
  group('iOS back gesture inside a StatefulShellRoute', () {
    testWidgets('pops the top sub-route '
        'when there is an active sub-route', (WidgetTester tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await tester.pumpWidget(const _TestApp());
      expect(find.text('Home'), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.text('Post'), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.text('Comment'), findsOneWidget);

      await simulateIosBackGesture(tester);
      await tester.pumpAndSettle();
      expect(find.text('Post'), findsOneWidget);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('pops StatefulShellRoute '
        'when there are no active sub-routes', (WidgetTester tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await tester.pumpWidget(const _TestApp());
      expect(find.text('Home'), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.text('Post'), findsOneWidget);

      await simulateIosBackGesture(tester);
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);

      debugDefaultTargetPlatformOverride = null;
    });
  });

  group('Android back button inside a StatefulShellRoute', () {
    testWidgets('pops the top sub-route '
        'when there is an active sub-route', (WidgetTester tester) async {
      await tester.pumpWidget(const _TestApp());
      expect(find.text('Home'), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.text('Post'), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.text('Comment'), findsOneWidget);

      await simulateAndroidBackButton(tester);
      await tester.pumpAndSettle();
      expect(find.text('Post'), findsOneWidget);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('pops StatefulShellRoute '
        'when there are no active sub-routes', (WidgetTester tester) async {
      await tester.pumpWidget(const _TestApp());
      expect(find.text('Home'), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.text('Post'), findsOneWidget);

      await simulateAndroidBackButton(tester);
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('does not pop inactive StatefulShellRoute branches', (WidgetTester tester) async {
      final pops = <String>[];
      StatefulNavigationShell? navigationShell;
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      });

      final GoRouter router = await createRouter(
        <RouteBase>[
          StatefulShellRoute.indexedStack(
            builder: (BuildContext context, GoRouterState state, StatefulNavigationShell shell) {
              navigationShell = shell;
              return shell;
            },
            branches: <StatefulShellBranch>[
              StatefulShellBranch(
                observers: <NavigatorObserver>[_RecordingNavigatorObserver('/A', pops)],
                routes: <RouteBase>[
                  GoRoute(
                    path: '/A1',
                    builder: (_, _) => const _BranchScreen(title: 'Stack A - 1', canPop: false),
                    routes: <RouteBase>[
                      GoRoute(
                        path: '/A2',
                        builder: (_, _) => const _BranchScreen(title: 'Stack A - 2'),
                        routes: <RouteBase>[
                          GoRoute(
                            path: '/A3',
                            builder: (_, _) => const _BranchScreen(title: 'Stack A - 3'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              StatefulShellBranch(
                observers: <NavigatorObserver>[_RecordingNavigatorObserver('/B', pops)],
                routes: <RouteBase>[
                  GoRoute(
                    path: '/B1',
                    builder: (_, _) => const _BranchScreen(title: 'Stack B - 1', canPop: false),
                  ),
                ],
              ),
              StatefulShellBranch(
                observers: <NavigatorObserver>[_RecordingNavigatorObserver('/C', pops)],
                routes: <RouteBase>[
                  GoRoute(
                    path: '/C1',
                    builder: (_, _) => const _BranchScreen(title: 'Stack C - 1', canPop: false),
                    routes: <RouteBase>[
                      GoRoute(
                        path: '/C2',
                        builder: (_, _) => const _BranchScreen(title: 'Stack C - 2'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
        tester,
        initialLocation: '/A1',
      );

      router.go('/A1/A2/A3');
      await tester.pumpAndSettle();
      expect(find.text('Stack A - 3'), findsOneWidget);

      router.go('/C1/C2');
      await tester.pumpAndSettle();
      expect(find.text('Stack C - 2'), findsOneWidget);

      navigationShell!.goBranch(1);
      await tester.pumpAndSettle();
      expect(find.text('Stack B - 1'), findsOneWidget);

      await simulateAndroidPredictiveBackGesture(tester);
      await tester.pump();

      expect(find.text('Stack B - 1'), findsOneWidget);
      expect(pops, isEmpty);
    });
  });
}

class _TestApp extends StatefulWidget {
  const _TestApp();

  @override
  State<_TestApp> createState() => _TestAppState();
}

class _TestAppState extends State<_TestApp> {
  final GoRouter _router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Home')),
            body: Center(
              child: FilledButton(
                onPressed: () {
                  GoRouter.of(context).go('/post');
                },
                child: const Text('Go to Post'),
              ),
            ),
          );
        },
        routes: <RouteBase>[
          StatefulShellRoute.indexedStack(
            builder:
                (
                  BuildContext context,
                  GoRouterState state,
                  StatefulNavigationShell navigationShell,
                ) {
                  return navigationShell;
                },
            branches: <StatefulShellBranch>[
              StatefulShellBranch(
                routes: <GoRoute>[
                  GoRoute(
                    path: '/post',
                    builder: (BuildContext context, GoRouterState state) {
                      return Scaffold(
                        appBar: AppBar(title: const Text('Post')),
                        body: Center(
                          child: FilledButton(
                            onPressed: () {
                              GoRouter.of(context).go('/post/comment');
                            },
                            child: const Text('Comment'),
                          ),
                        ),
                      );
                    },
                    routes: <GoRoute>[
                      GoRoute(
                        path: 'comment',
                        builder: (BuildContext context, GoRouterState state) {
                          return Scaffold(appBar: AppBar(title: const Text('Comment')));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _router);
  }
}

class _BranchScreen extends StatelessWidget {
  const _BranchScreen({required this.title, this.canPop = true});

  final String title;
  final bool canPop;

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: canPop,
      child: Scaffold(body: Center(child: Text(title))),
    );
  }
}

class _RecordingNavigatorObserver extends NavigatorObserver {
  _RecordingNavigatorObserver(this.branch, this.pops);

  final String branch;
  final List<String> pops;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pops.add('$branch ${route.settings.name} -> ${previousRoute?.settings.name}');
  }
}

Future<void> simulateAndroidPredictiveBackGesture(WidgetTester tester) async {
  await _handleAndroidPredictiveBackMessage(
    tester,
    const MethodCall('startBackGesture', <String, dynamic>{
      'touchOffset': <double>[5.0, 300.0],
      'progress': 0.0,
      'swipeEdge': 0,
    }),
  );
  await tester.pump();

  await _handleAndroidPredictiveBackMessage(
    tester,
    const MethodCall('updateBackGestureProgress', <String, dynamic>{
      'x': 100.0,
      'y': 300.0,
      'progress': 0.35,
      'swipeEdge': 0,
    }),
  );
  await tester.pump();

  await _handleAndroidPredictiveBackMessage(tester, const MethodCall('commitBackGesture'));
}

Future<void> _handleAndroidPredictiveBackMessage(WidgetTester tester, MethodCall methodCall) async {
  final ByteData message = const StandardMethodCodec().encodeMethodCall(methodCall);
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    'flutter/backgesture',
    message,
    (ByteData? _) {},
  );
}
