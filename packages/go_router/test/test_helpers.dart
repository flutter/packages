// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: cascade_invocations, diagnostic_describe_all_properties

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Future<GoRouter> createGoRouter(WidgetTester tester) async {
  final GoRouter goRouter = GoRouter(
    initialLocation: '/',
    routes: <GoRoute>[
      GoRoute(path: '/', builder: (_, __) => const DummyStatefulWidget()),
      GoRoute(
        path: '/error',
        builder: (_, __) => TestErrorScreen(TestFailure('Exception')),
      ),
    ],
  );
  await tester.pumpWidget(MaterialApp.router(
    routerConfig: goRouter,
  ));
  return goRouter;
}

Widget fakeNavigationBuilder(
  BuildContext context,
  GoRouterState state,
  Widget child,
) =>
    child;

class GoRouterNamedLocationSpy extends GoRouter {
  GoRouterNamedLocationSpy({required List<RouteBase> routes})
      : super.routingConfig(
            routingConfig:
                ConstantRoutingConfig(RoutingConfig(routes: routes)));

  String? name;
  Map<String, String>? pathParameters;
  Map<String, dynamic>? queryParameters;
  String? fragment;

  @override
  String namedLocation(String name,
      {Map<String, String> pathParameters = const <String, String>{},
      Map<String, dynamic> queryParameters = const <String, dynamic>{},
      String? fragment}) {
    this.name = name;
    this.pathParameters = pathParameters;
    this.queryParameters = queryParameters;
    this.fragment = fragment;
    return '';
  }
}

class GoRouterGoSpy extends GoRouter {
  GoRouterGoSpy({required List<RouteBase> routes})
      : super.routingConfig(
            routingConfig:
                ConstantRoutingConfig(RoutingConfig(routes: routes)));

  String? myLocation;
  Object? extra;

  @override
  void go(String location, {Object? extra}) {
    myLocation = location;
    this.extra = extra;
  }
}

class GoRouterGoNamedSpy extends GoRouter {
  GoRouterGoNamedSpy({required List<RouteBase> routes})
      : super.routingConfig(
            routingConfig:
                ConstantRoutingConfig(RoutingConfig(routes: routes)));

  String? name;
  Map<String, String>? pathParameters;
  Map<String, dynamic>? queryParameters;
  Object? extra;
  String? fragment;

  @override
  void goNamed(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
    String? fragment,
  }) {
    this.name = name;
    this.pathParameters = pathParameters;
    this.queryParameters = queryParameters;
    this.extra = extra;
    this.fragment = fragment;
  }
}

class GoRouterPushSpy extends GoRouter {
  GoRouterPushSpy({required List<RouteBase> routes})
      : super.routingConfig(
            routingConfig:
                ConstantRoutingConfig(RoutingConfig(routes: routes)));

  String? myLocation;
  Object? extra;

  @override
  Future<T?> push<T extends Object?>(String location, {Object? extra}) {
    myLocation = location;
    this.extra = extra;
    return Future<T?>.value(extra as T?);
  }
}

class GoRouterPushNamedSpy extends GoRouter {
  GoRouterPushNamedSpy({required List<RouteBase> routes})
      : super.routingConfig(
            routingConfig:
                ConstantRoutingConfig(RoutingConfig(routes: routes)));

  String? name;
  Map<String, String>? pathParameters;
  Map<String, dynamic>? queryParameters;
  Object? extra;

  @override
  Future<T?> pushNamed<T extends Object?>(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) {
    this.name = name;
    this.pathParameters = pathParameters;
    this.queryParameters = queryParameters;
    this.extra = extra;
    return Future<T?>.value(extra as T?);
  }
}

class GoRouterPopSpy extends GoRouter {
  GoRouterPopSpy({required List<RouteBase> routes})
      : super.routingConfig(
            routingConfig:
                ConstantRoutingConfig(RoutingConfig(routes: routes)));

  bool popped = false;
  Object? poppedResult;

  @override
  void pop<T extends Object?>([T? result]) {
    popped = true;
    poppedResult = result;
  }
}

Future<GoRouter> createRouter(
  List<RouteBase> routes,
  WidgetTester tester, {
  GoRouterRedirect? redirect,
  String initialLocation = '/',
  Object? initialExtra,
  int redirectLimit = 5,
  GlobalKey<NavigatorState>? navigatorKey,
  GoRouterWidgetBuilder? errorBuilder,
  String? restorationScopeId,
  Codec<Object?, Object?>? extraCodec,
  GoExceptionHandler? onException,
  bool requestFocus = true,
  bool overridePlatformDefaultLocation = false,
}) async {
  final GoRouter goRouter = GoRouter(
    routes: routes,
    redirect: redirect,
    extraCodec: extraCodec,
    initialLocation: initialLocation,
    onException: onException,
    initialExtra: initialExtra,
    redirectLimit: redirectLimit,
    errorBuilder: errorBuilder,
    navigatorKey: navigatorKey,
    restorationScopeId: restorationScopeId,
    requestFocus: requestFocus,
    overridePlatformDefaultLocation: overridePlatformDefaultLocation,
  );
  addTearDown(goRouter.dispose);
  await tester.pumpWidget(
    MaterialApp.router(
      restorationScopeId:
          restorationScopeId != null ? '$restorationScopeId-root' : null,
      routerConfig: goRouter,
    ),
  );
  return goRouter;
}

Future<GoRouter> createRouterWithRoutingConfig(
  ValueListenable<RoutingConfig> config,
  WidgetTester tester, {
  String initialLocation = '/',
  Object? initialExtra,
  GlobalKey<NavigatorState>? navigatorKey,
  GoRouterWidgetBuilder? errorBuilder,
  String? restorationScopeId,
  GoExceptionHandler? onException,
  bool requestFocus = true,
  bool overridePlatformDefaultLocation = false,
}) async {
  final GoRouter goRouter = GoRouter.routingConfig(
    routingConfig: config,
    initialLocation: initialLocation,
    onException: onException,
    initialExtra: initialExtra,
    errorBuilder: errorBuilder,
    navigatorKey: navigatorKey,
    restorationScopeId: restorationScopeId,
    requestFocus: requestFocus,
    overridePlatformDefaultLocation: overridePlatformDefaultLocation,
  );
  addTearDown(goRouter.dispose);
  await tester.pumpWidget(
    MaterialApp.router(
      restorationScopeId:
          restorationScopeId != null ? '$restorationScopeId-root' : null,
      routerConfig: goRouter,
    ),
  );
  return goRouter;
}

class TestErrorScreen extends DummyScreen {
  const TestErrorScreen(this.ex, {super.key});

  final Exception ex;
}

class HomeScreen extends DummyScreen {
  const HomeScreen({super.key});
}

class Page1Screen extends DummyScreen {
  const Page1Screen({super.key});
}

class Page2Screen extends DummyScreen {
  const Page2Screen({super.key});
}

class LoginScreen extends DummyScreen {
  const LoginScreen({super.key});
}

class FamilyScreen extends DummyScreen {
  const FamilyScreen(this.fid, {super.key});

  final String fid;
}

class FamiliesScreen extends DummyScreen {
  const FamiliesScreen({required this.selectedFid, super.key});

  final String selectedFid;
}

class PersonScreen extends DummyScreen {
  const PersonScreen(this.fid, this.pid, {super.key});

  final String fid;
  final String pid;
}

class DummyScreen extends StatelessWidget {
  const DummyScreen({
    this.queryParametersAll = const <String, dynamic>{},
    super.key,
  });

  final Map<String, dynamic> queryParametersAll;

  @override
  Widget build(BuildContext context) => const Placeholder();
}

Widget dummy(BuildContext context, GoRouterState state) => const DummyScreen();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class DummyStatefulWidget extends StatefulWidget {
  const DummyStatefulWidget({super.key});

  @override
  State<StatefulWidget> createState() => DummyStatefulWidgetState();
}

class DummyStatefulWidgetState extends State<DummyStatefulWidget> {
  int counter = 0;

  void increment() => setState(() {
        counter++;
      });

  @override
  Widget build(BuildContext context) => Container();
}

class DummyRestorableStatefulWidget extends StatefulWidget {
  const DummyRestorableStatefulWidget({super.key, this.restorationId});

  final String? restorationId;

  @override
  State<StatefulWidget> createState() => DummyRestorableStatefulWidgetState();
}

class DummyRestorableStatefulWidgetState
    extends State<DummyRestorableStatefulWidget> with RestorationMixin {
  final RestorableInt _counter = RestorableInt(0);

  @override
  String? get restorationId => widget.restorationId;

  int get counter => _counter.value;

  void increment([int count = 1]) => setState(() {
        _counter.value += count;
      });

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    if (restorationId != null) {
      registerForRestoration(_counter, restorationId!);
    }
  }

  @override
  void dispose() {
    _counter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container();
}

Future<void> simulateAndroidBackButton(WidgetTester tester) async {
  final ByteData message =
      const JSONMethodCodec().encodeMethodCall(const MethodCall('popRoute'));
  await tester.binding.defaultBinaryMessenger
      .handlePlatformMessage('flutter/navigation', message, (_) {});
}

GoRouterPageBuilder createPageBuilder(
        {String? restorationId, required Widget child}) =>
    (BuildContext context, GoRouterState state) =>
        MaterialPage<dynamic>(restorationId: restorationId, child: child);

StatefulShellRouteBuilder mockStackedShellBuilder = (BuildContext context,
    GoRouterState state, StatefulNavigationShell navigationShell) {
  return navigationShell;
};

/// A routing config that is never going to change.
class ConstantRoutingConfig extends ValueListenable<RoutingConfig> {
  const ConstantRoutingConfig(this.value);
  @override
  void addListener(VoidCallback listener) {
    // Intentionally empty because listener will never be called.
  }

  @override
  void removeListener(VoidCallback listener) {
    // Intentionally empty because listener will never be called.
  }

  @override
  final RoutingConfig value;
}

RouteConfiguration createRouteConfiguration({
  required List<RouteBase> routes,
  required GlobalKey<NavigatorState> navigatorKey,
  required GoRouterRedirect topRedirect,
  required int redirectLimit,
}) {
  return RouteConfiguration(
      ConstantRoutingConfig(RoutingConfig(
        routes: routes,
        redirect: topRedirect,
        redirectLimit: redirectLimit,
      )),
      navigatorKey: navigatorKey);
}

class SimpleDependencyProvider extends InheritedNotifier<SimpleDependency> {
  const SimpleDependencyProvider(
      {super.key, required SimpleDependency dependency, required super.child})
      : super(notifier: dependency);

  static SimpleDependency of(BuildContext context) {
    final SimpleDependencyProvider result =
        context.dependOnInheritedWidgetOfExactType<SimpleDependencyProvider>()!;
    return result.notifier!;
  }
}

class SimpleDependency extends ChangeNotifier {
  bool get boolProperty => _boolProperty;
  bool _boolProperty = true;
  set boolProperty(bool value) {
    if (value == _boolProperty) {
      return;
    }
    _boolProperty = value;
    notifyListeners();
  }
}
