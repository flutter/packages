// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// #region body
import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [MaterialApp.router].

void main() {
  runApp(const MaterialAppRouterExample());
}

class MaterialAppRouterExample extends StatefulWidget {
  const MaterialAppRouterExample({super.key});

  @override
  State<MaterialAppRouterExample> createState() =>
      _MaterialAppRouterExampleState();
}

class _MaterialAppRouterExampleState extends State<MaterialAppRouterExample> {
  final _ExampleRouterDelegate _routerDelegate = _ExampleRouterDelegate();
  final _ExampleRouteInformationParser _routeInformationParser =
      _ExampleRouteInformationParser();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );
  }
}

/// The parsed representation of the current route.
class _RoutePath {
  const _RoutePath(this.pageId);

  final int pageId;
}

/// Converts the [RouteInformation] (such as the browser URL) to and from a
/// [_RoutePath].
class _ExampleRouteInformationParser
    extends RouteInformationParser<_RoutePath> {
  @override
  Future<_RoutePath> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final List<String> segments = routeInformation.uri.pathSegments;
    if (segments.isEmpty) {
      return const _RoutePath(0);
    }
    return _RoutePath(int.tryParse(segments.first) ?? 0);
  }

  @override
  RouteInformation? restoreRouteInformation(_RoutePath configuration) {
    return RouteInformation(uri: Uri(path: '/${configuration.pageId}'));
  }
}

/// Builds the [Navigator] pages that correspond to the current [_RoutePath].
class _ExampleRouterDelegate extends RouterDelegate<_RoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<_RoutePath> {
  int _pageId = 0;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  _RoutePath get currentConfiguration => _RoutePath(_pageId);

  @override
  Future<void> setNewRoutePath(_RoutePath configuration) async {
    _pageId = configuration.pageId;
  }

  void _openDetails() {
    _pageId = 1;
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: <Page<Object?>>[
        MaterialPage<void>(
          key: const ValueKey<String>('home'),
          child: Scaffold(
            appBar: AppBar(title: const Text('Home')),
            body: Center(
              child: ElevatedButton(
                onPressed: _openDetails,
                child: const Text('Go to details'),
              ),
            ),
          ),
        ),
        if (_pageId != 0)
          MaterialPage<void>(
            key: const ValueKey<String>('details'),
            child: Scaffold(
              appBar: AppBar(title: const Text('Details')),
              body: Center(child: Text('Page $_pageId')),
            ),
          ),
      ],
      onDidRemovePage: (Page<Object?> page) {
        if (_pageId != 0) {
          _pageId = 0;
          notifyListeners();
        }
      },
    );
  }
}
// #endregion body
