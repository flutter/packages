// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'configuration.dart';
import 'logging.dart';
import 'path_utils.dart';
import 'typedefs.dart';

export 'route.dart';
export 'state.dart';

/// The route configuration for GoRouter configured by the app.
class RouteConfiguration {
  /// Constructs a [RouteConfiguration].
  RouteConfiguration({
    required this.routes,
    required this.redirectLimit,
    required this.topRedirect,
    required this.navigatorKey,
  }) {
    _cacheNameToPath('', routes);

    assert(() {
      log.info(_debugKnownRoutes());
      return true;
    }());

    for (final RouteBase route in routes) {
      if (route is GoRoute && !route.path.startsWith('/')) {
        assert(route.path.startsWith('/'),
            'top-level path must start with "/": ${route.path}');
      } else if (route is ShellRoute) {
        for (final RouteBase route in routes) {
          if (route is GoRoute) {
            assert(route.path.startsWith('/'),
                'top-level path must start with "/": ${route.path}');
          }
        }
      }
    }

    // Check that each parentNavigatorKey refers to either a ShellRoute's
    // navigatorKey or the root navigator key.
    final List<GlobalKey<NavigatorState>> keys = <GlobalKey<NavigatorState>>[];
    final List<GlobalKey<NavigatorState>> parentKeys =
        <GlobalKey<NavigatorState>>[];
    keys.add(navigatorKey);
    void checkParentNavigatorKeys(
        List<RouteBase> routes, List<GlobalKey<NavigatorState>> parentKeys) {
      for (final RouteBase route in routes) {
        if (route is GoRoute) {
          final GlobalKey<NavigatorState>? parentKey = route.parentNavigatorKey;
          if (parentKey != null) {
            // Verify that the root navigator or a ShellRoute ancestor has a
            // matching navigator key.
            assert(
                keys.contains(parentKey),
                'parentNavigatorKey $parentKey must refer to'
                " an ancestor ShellRoute's navigatorKey or GoRouter's"
                ' navigatorKey');

            // Verify that between each GoRoute with a parentNavigatorKey and the
            // ancestor ShellRoute or root navigator with that key, there are no
            // GoRoutes with other parentNavigatorKeys defined. For example:
            //
            // GoRouter(navigatorKey: root)
            //   ShellRoute(navigatorKey: shell)
            //     GoRoute('b' parentNavigatorKey: root)
            //       GoRoute('c' parentNavigatorKey: shell)
            if (parentKeys.isNotEmpty) {
              assert(
                  parentKeys.last == parentKey,
                  'Ancestor GoRoutes cannot '
                  'have a different parentNavigatorKey than child GoRoutes.');
            }

            checkParentNavigatorKeys(route.routes,
                <GlobalKey<NavigatorState>>[...parentKeys, parentKey]);
          } else {
            checkParentNavigatorKeys(route.routes, parentKeys);
          }
        } else if (route is ShellRoute && route.navigatorKey != null) {
          keys.add(route.navigatorKey);
          checkParentNavigatorKeys(route.routes, <GlobalKey<NavigatorState>>[]);
          keys.remove(route.navigatorKey);
        }
      }
    }

    checkParentNavigatorKeys(routes, parentKeys);
  }

  /// The list of top level routes used by [GoRouterDelegate].
  final List<RouteBase> routes;

  /// The limit for the number of consecutive redirects.
  final int redirectLimit;

  /// Top level page redirect.
  final GoRouterRedirect topRedirect;

  /// The key to use when building the root [Navigator].
  final GlobalKey<NavigatorState> navigatorKey;

  final Map<String, String> _nameToPath = <String, String>{};

  /// Looks up the url location by a [GoRoute]'s name.
  String namedLocation(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
  }) {
    assert(() {
      log.info('getting location for name: '
          '"$name"'
          '${params.isEmpty ? '' : ', params: $params'}'
          '${queryParams.isEmpty ? '' : ', queryParams: $queryParams'}');
      return true;
    }());
    final String keyName = name.toLowerCase();
    assert(_nameToPath.containsKey(keyName), 'unknown route name: $name');
    final String path = _nameToPath[keyName]!;
    assert(() {
      // Check that all required params are present
      final List<String> paramNames = <String>[];
      patternToRegExp(path, paramNames);
      for (final String paramName in paramNames) {
        assert(params.containsKey(paramName),
            'missing param "$paramName" for $path');
      }

      // Check that there are no extra params
      for (final String key in params.keys) {
        assert(paramNames.contains(key), 'unknown param "$key" for $path');
      }
      return true;
    }());
    final Map<String, String> encodedParams = <String, String>{
      for (final MapEntry<String, String> param in params.entries)
        param.key: Uri.encodeComponent(param.value)
    };
    final String location = patternToPath(path, encodedParams);
    return Uri(
            path: location,
            queryParameters: queryParams.isEmpty ? null : queryParams)
        .toString();
  }

  @override
  String toString() {
    return 'RouterConfiguration: $routes';
  }

  String _debugKnownRoutes() {
    final StringBuffer sb = StringBuffer();
    sb.writeln('Full paths for routes:');
    _debugFullPathsFor(routes, '', 0, sb);

    if (_nameToPath.isNotEmpty) {
      sb.writeln('known full paths for route names:');
      for (final MapEntry<String, String> e in _nameToPath.entries) {
        sb.writeln('  ${e.key} => ${e.value}');
      }
    }

    return sb.toString();
  }

  void _debugFullPathsFor(List<RouteBase> routes, String parentFullpath,
      int depth, StringBuffer sb) {
    for (final RouteBase route in routes) {
      if (route is GoRoute) {
        final String fullpath = concatenatePaths(parentFullpath, route.path);
        sb.writeln('  => ${''.padLeft(depth * 2)}$fullpath');
        _debugFullPathsFor(route.routes, fullpath, depth + 1, sb);
      }
    }
  }

  void _cacheNameToPath(String parentFullPath, List<RouteBase> childRoutes) {
    for (final RouteBase route in childRoutes) {
      if (route is GoRoute) {
        final String fullPath = concatenatePaths(parentFullPath, route.path);

        if (route.name != null) {
          final String name = route.name!.toLowerCase();
          assert(
              !_nameToPath.containsKey(name),
              'duplication fullpaths for name '
              '"$name":${_nameToPath[name]}, $fullPath');
          _nameToPath[name] = fullPath;
        }

        if (route.routes.isNotEmpty) {
          _cacheNameToPath(fullPath, route.routes);
        }
      } else if (route is ShellRoute) {
        if (route.routes.isNotEmpty) {
          _cacheNameToPath(parentFullPath, route.routes);
        }
      }
    }
  }
}
