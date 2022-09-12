// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
  }) {
    _cacheNameToPath('', routes);

    assert(() {
      log.info(_debugKnownRoutes());
      return true;
    }());

    for (final GoRoute route in routes) {
      if (!route.path.startsWith('/')) {
        throw RouteConfigurationError(
            'top-level path must start with "/": ${route.path}');
      }
    }
  }

  /// The list of top level routes used by [GoRouterDelegate].
  final List<GoRoute> routes;

  /// The limit for the number of consecutive redirects.
  final int redirectLimit;

  /// Top level page redirect.
  final GoRouterRedirect topRedirect;

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

  void _debugFullPathsFor(
      List<GoRoute> routes, String parentFullpath, int depth, StringBuffer sb) {
    for (final GoRoute route in routes) {
      final String fullpath = concatenatePaths(parentFullpath, route.path);
      sb.writeln('  => ${''.padLeft(depth * 2)}$fullpath');
      _debugFullPathsFor(route.routes, fullpath, depth + 1, sb);
    }
  }

  void _cacheNameToPath(String parentFullPath, List<GoRoute> childRoutes) {
    for (final GoRoute route in childRoutes) {
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
    }
  }
}

/// Thrown when the [RouteConfiguration] is invalid.
class RouteConfigurationError extends Error {
  /// [RouteConfigurationError] constructor.
  RouteConfigurationError(this.message);

  /// The error message.
  final String message;

  @override
  String toString() => 'Route configuration error: $message';
}
