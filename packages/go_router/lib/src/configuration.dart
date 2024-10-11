// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'logging.dart';
import 'match.dart';
import 'misc/errors.dart';
import 'path_utils.dart';
import 'route.dart';
import 'router.dart';
import 'state.dart';

/// The signature of the redirect callback.
typedef GoRouterRedirect = FutureOr<String?> Function(
    BuildContext context, GoRouterState state);

/// The route configuration for GoRouter configured by the app.
class RouteConfiguration {
  /// Constructs a [RouteConfiguration].
  RouteConfiguration(
    this._routingConfig, {
    required this.navigatorKey,
    this.extraCodec,
  }) {
    _onRoutingTableChanged();
    _routingConfig.addListener(_onRoutingTableChanged);
  }

  static bool _debugCheckPath(List<RouteBase> routes, bool isTopLevel) {
    for (final RouteBase route in routes) {
      late bool subRouteIsTopLevel;
      if (route is GoRoute) {
        if (route.path != '/') {
          assert(!route.path.endsWith('/'),
              'route path may not end with "/" except for the top "/" route. Found: $route');
        }
        subRouteIsTopLevel = false;
      } else if (route is ShellRouteBase) {
        subRouteIsTopLevel = isTopLevel;
      }
      _debugCheckPath(route.routes, subRouteIsTopLevel);
    }
    return true;
  }

  // Check that each parentNavigatorKey refers to either a ShellRoute's
  // navigatorKey or the root navigator key.
  static bool _debugCheckParentNavigatorKeys(
      List<RouteBase> routes, List<GlobalKey<NavigatorState>> allowedKeys) {
    for (final RouteBase route in routes) {
      if (route is GoRoute) {
        final GlobalKey<NavigatorState>? parentKey = route.parentNavigatorKey;
        if (parentKey != null) {
          // Verify that the root navigator or a ShellRoute ancestor has a
          // matching navigator key.
          assert(
              allowedKeys.contains(parentKey),
              'parentNavigatorKey $parentKey must refer to'
              " an ancestor ShellRoute's navigatorKey or GoRouter's"
              ' navigatorKey');

          _debugCheckParentNavigatorKeys(
            route.routes,
            <GlobalKey<NavigatorState>>[
              // Once a parentNavigatorKey is used, only that navigator key
              // or keys above it can be used.
              ...allowedKeys.sublist(0, allowedKeys.indexOf(parentKey) + 1),
            ],
          );
        } else {
          _debugCheckParentNavigatorKeys(
            route.routes,
            <GlobalKey<NavigatorState>>[
              ...allowedKeys,
            ],
          );
        }
      } else if (route is ShellRoute) {
        _debugCheckParentNavigatorKeys(
          route.routes,
          <GlobalKey<NavigatorState>>[...allowedKeys..add(route.navigatorKey)],
        );
      } else if (route is StatefulShellRoute) {
        for (final StatefulShellBranch branch in route.branches) {
          assert(
              !allowedKeys.contains(branch.navigatorKey),
              'StatefulShellBranch must not reuse an ancestor navigatorKey '
              '(${branch.navigatorKey})');

          _debugCheckParentNavigatorKeys(
            branch.routes,
            <GlobalKey<NavigatorState>>[
              ...allowedKeys,
              branch.navigatorKey,
            ],
          );
        }
      }
    }
    return true;
  }

  static bool _debugVerifyNoDuplicatePathParameter(
      List<RouteBase> routes, Map<String, GoRoute> usedPathParams) {
    for (final RouteBase route in routes) {
      if (route is! GoRoute) {
        continue;
      }
      for (final String pathParam in route.pathParameters) {
        if (usedPathParams.containsKey(pathParam)) {
          final bool sameRoute = usedPathParams[pathParam] == route;
          throw GoError(
              "duplicate path parameter, '$pathParam' found in ${sameRoute ? '$route' : '${usedPathParams[pathParam]}, and $route'}");
        }
        usedPathParams[pathParam] = route;
      }
      _debugVerifyNoDuplicatePathParameter(route.routes, usedPathParams);
      route.pathParameters.forEach(usedPathParams.remove);
    }
    return true;
  }

  // Check to see that the configured initialLocation of StatefulShellBranches
  // points to a descendant route of the route branch.
  bool _debugCheckStatefulShellBranchDefaultLocations(List<RouteBase> routes) {
    for (final RouteBase route in routes) {
      if (route is StatefulShellRoute) {
        for (final StatefulShellBranch branch in route.branches) {
          if (branch.initialLocation == null) {
            // Recursively search for the first GoRoute descendant. Will
            // throw assertion error if not found.
            final GoRoute? route = branch.defaultRoute;
            final String? initialLocation =
                route != null ? locationForRoute(route) : null;
            assert(
                initialLocation != null,
                'The default location of a StatefulShellBranch must be '
                'derivable from GoRoute descendant');
            assert(
                route!.pathParameters.isEmpty,
                'The default location of a StatefulShellBranch cannot be '
                'a parameterized route');
          } else {
            final RouteMatchList matchList =
                findMatch(Uri.parse(branch.initialLocation!));
            assert(
                !matchList.isError,
                'initialLocation (${matchList.uri}) of StatefulShellBranch must '
                'be a valid location');
            final List<RouteBase> matchRoutes = matchList.routes;
            final int shellIndex = matchRoutes.indexOf(route);
            bool matchFound = false;
            if (shellIndex >= 0 && (shellIndex + 1) < matchRoutes.length) {
              final RouteBase branchRoot = matchRoutes[shellIndex + 1];
              matchFound = branch.routes.contains(branchRoot);
            }
            assert(
                matchFound,
                'The initialLocation (${branch.initialLocation}) of '
                'StatefulShellBranch must match a descendant route of the '
                'branch');
          }
        }
      }
      _debugCheckStatefulShellBranchDefaultLocations(route.routes);
    }
    return true;
  }

  /// The match used when there is an error during parsing.
  static RouteMatchList _errorRouteMatchList(
    Uri uri,
    GoException exception, {
    Object? extra,
  }) {
    return RouteMatchList(
      matches: const <RouteMatch>[],
      extra: extra,
      error: exception,
      uri: uri,
      pathParameters: const <String, String>{},
    );
  }

  void _onRoutingTableChanged() {
    final RoutingConfig routingTable = _routingConfig.value;
    assert(_debugCheckPath(routingTable.routes, true));
    assert(_debugVerifyNoDuplicatePathParameter(
        routingTable.routes, <String, GoRoute>{}));
    assert(_debugCheckParentNavigatorKeys(
        routingTable.routes, <GlobalKey<NavigatorState>>[navigatorKey]));
    assert(_debugCheckStatefulShellBranchDefaultLocations(routingTable.routes));
    _nameToPath.clear();
    _cacheNameToPath('', routingTable.routes);
    log(debugKnownRoutes());
  }

  /// Builds a [GoRouterState] suitable for top level callback such as
  /// `GoRouter.redirect` or `GoRouter.onException`.
  GoRouterState buildTopLevelGoRouterState(RouteMatchList matchList) {
    return GoRouterState(
      this,
      uri: matchList.uri,
      // No name available at the top level trim the query params off the
      // sub-location to match route.redirect
      fullPath: matchList.fullPath,
      pathParameters: matchList.pathParameters,
      matchedLocation: matchList.uri.path,
      extra: matchList.extra,
      pageKey: const ValueKey<String>('topLevel'),
      topRoute: matchList.lastOrNull?.route,
    );
  }

  /// The routing table.
  final ValueListenable<RoutingConfig> _routingConfig;

  /// The list of top level routes used by [GoRouterDelegate].
  List<RouteBase> get routes => _routingConfig.value.routes;

  /// Top level page redirect.
  GoRouterRedirect get topRedirect => _routingConfig.value.redirect;

  /// The limit for the number of consecutive redirects.
  int get redirectLimit => _routingConfig.value.redirectLimit;

  /// The global key for top level navigator.
  final GlobalKey<NavigatorState> navigatorKey;

  /// The codec used to encode and decode extra into a serializable format.
  ///
  /// When navigating using [GoRouter.go] or [GoRouter.push], one can provide
  /// an `extra` parameter along with it. If the extra contains complex data,
  /// consider provide a codec for serializing and deserializing the extra data.
  ///
  /// See also:
  ///  * [Navigation](https://pub.dev/documentation/go_router/latest/topics/Navigation-topic.html)
  ///    topic.
  ///  * [extra_codec](https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/extra_codec.dart)
  ///    example.
  final Codec<Object?, Object?>? extraCodec;

  final Map<String, String> _nameToPath = <String, String>{};

  /// Looks up the url location by a [GoRoute]'s name.
  String namedLocation(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
  }) {
    assert(() {
      log('getting location for name: '
          '"$name"'
          '${pathParameters.isEmpty ? '' : ', pathParameters: $pathParameters'}'
          '${queryParameters.isEmpty ? '' : ', queryParameters: $queryParameters'}');
      return true;
    }());
    assert(_nameToPath.containsKey(name), 'unknown route name: $name');
    final String path = _nameToPath[name]!;
    assert(() {
      // Check that all required params are present
      final List<String> paramNames = <String>[];
      patternToRegExp(path, paramNames);
      for (final String paramName in paramNames) {
        assert(pathParameters.containsKey(paramName),
            'missing param "$paramName" for $path');
      }

      // Check that there are no extra params
      for (final String key in pathParameters.keys) {
        assert(paramNames.contains(key), 'unknown param "$key" for $path');
      }
      return true;
    }());
    final Map<String, String> encodedParams = <String, String>{
      for (final MapEntry<String, String> param in pathParameters.entries)
        param.key: Uri.encodeComponent(param.value)
    };
    final String location = patternToPath(path, encodedParams);
    return Uri(
            path: location,
            queryParameters: queryParameters.isEmpty ? null : queryParameters)
        .toString();
  }

  /// Finds the routes that matched the given URL.
  RouteMatchList findMatch(Uri uri, {Object? extra}) {
    final Map<String, String> pathParameters = <String, String>{};
    final List<RouteMatchBase> matches =
        _getLocRouteMatches(uri, pathParameters);

    if (matches.isEmpty) {
      return _errorRouteMatchList(
        uri,
        GoException('no routes for location: $uri'),
        extra: extra,
      );
    }
    return RouteMatchList(
        matches: matches,
        uri: uri,
        pathParameters: pathParameters,
        extra: extra);
  }

  /// Reparse the input RouteMatchList
  RouteMatchList reparse(RouteMatchList matchList) {
    RouteMatchList result = findMatch(matchList.uri, extra: matchList.extra);

    for (final ImperativeRouteMatch imperativeMatch
        in matchList.matches.whereType<ImperativeRouteMatch>()) {
      final ImperativeRouteMatch match = ImperativeRouteMatch(
          pageKey: imperativeMatch.pageKey,
          matches: findMatch(imperativeMatch.matches.uri,
              extra: imperativeMatch.matches.extra),
          completer: imperativeMatch.completer);
      result = result.push(match);
    }
    return result;
  }

  List<RouteMatchBase> _getLocRouteMatches(
      Uri uri, Map<String, String> pathParameters) {
    for (final RouteBase route in _routingConfig.value.routes) {
      final List<RouteMatchBase> result = RouteMatchBase.match(
        rootNavigatorKey: navigatorKey,
        route: route,
        uri: uri,
        pathParameters: pathParameters,
      );
      if (result.isNotEmpty) {
        return result;
      }
    }
    return const <RouteMatchBase>[];
  }

  /// Processes redirects by returning a new [RouteMatchList] representing the new
  /// location.
  FutureOr<RouteMatchList> redirect(
      BuildContext context, FutureOr<RouteMatchList> prevMatchListFuture,
      {required List<RouteMatchList> redirectHistory}) {
    FutureOr<RouteMatchList> processRedirect(RouteMatchList prevMatchList) {
      final String prevLocation = prevMatchList.uri.toString();
      FutureOr<RouteMatchList> processTopLevelRedirect(
          String? topRedirectLocation) {
        if (topRedirectLocation != null &&
            topRedirectLocation != prevLocation) {
          final RouteMatchList newMatch = _getNewMatches(
            topRedirectLocation,
            prevMatchList.uri,
            redirectHistory,
          );
          if (newMatch.isError) {
            return newMatch;
          }
          return redirect(
            context,
            newMatch,
            redirectHistory: redirectHistory,
          );
        }

        FutureOr<RouteMatchList> processRouteLevelRedirect(
            String? routeRedirectLocation) {
          if (routeRedirectLocation != null &&
              routeRedirectLocation != prevLocation) {
            final RouteMatchList newMatch = _getNewMatches(
              routeRedirectLocation,
              prevMatchList.uri,
              redirectHistory,
            );

            if (newMatch.isError) {
              return newMatch;
            }
            return redirect(
              context,
              newMatch,
              redirectHistory: redirectHistory,
            );
          }
          return prevMatchList;
        }

        final List<RouteMatchBase> routeMatches = <RouteMatchBase>[];
        prevMatchList.visitRouteMatches((RouteMatchBase match) {
          if (match.route.redirect != null) {
            routeMatches.add(match);
          }
          return true;
        });
        final FutureOr<String?> routeLevelRedirectResult =
            _getRouteLevelRedirect(context, prevMatchList, routeMatches, 0);

        if (routeLevelRedirectResult is String?) {
          return processRouteLevelRedirect(routeLevelRedirectResult);
        }
        return routeLevelRedirectResult
            .then<RouteMatchList>(processRouteLevelRedirect);
      }

      redirectHistory.add(prevMatchList);
      // Check for top-level redirect
      final FutureOr<String?> topRedirectResult = _routingConfig.value.redirect(
        context,
        buildTopLevelGoRouterState(prevMatchList),
      );

      if (topRedirectResult is String?) {
        return processTopLevelRedirect(topRedirectResult);
      }
      return topRedirectResult.then<RouteMatchList>(processTopLevelRedirect);
    }

    if (prevMatchListFuture is RouteMatchList) {
      return processRedirect(prevMatchListFuture);
    }
    return prevMatchListFuture.then<RouteMatchList>(processRedirect);
  }

  FutureOr<String?> _getRouteLevelRedirect(
    BuildContext context,
    RouteMatchList matchList,
    List<RouteMatchBase> routeMatches,
    int currentCheckIndex,
  ) {
    if (currentCheckIndex >= routeMatches.length) {
      return null;
    }
    final RouteMatchBase match = routeMatches[currentCheckIndex];
    FutureOr<String?> processRouteRedirect(String? newLocation) =>
        newLocation ??
        _getRouteLevelRedirect(
            context, matchList, routeMatches, currentCheckIndex + 1);
    final RouteBase route = match.route;
    final FutureOr<String?> routeRedirectResult = route.redirect!.call(
      context,
      match.buildState(this, matchList),
    );
    if (routeRedirectResult is String?) {
      return processRouteRedirect(routeRedirectResult);
    }
    return routeRedirectResult.then<String?>(processRouteRedirect);
  }

  RouteMatchList _getNewMatches(
    String newLocation,
    Uri previousLocation,
    List<RouteMatchList> redirectHistory,
  ) {
    try {
      final RouteMatchList newMatch = findMatch(Uri.parse(newLocation));
      _addRedirect(redirectHistory, newMatch, previousLocation);
      return newMatch;
    } on GoException catch (e) {
      log('Redirection exception: ${e.message}');
      return _errorRouteMatchList(previousLocation, e);
    }
  }

  /// Adds the redirect to [redirects] if it is valid.
  ///
  /// Throws if a loop is detected or the redirection limit is reached.
  void _addRedirect(
    List<RouteMatchList> redirects,
    RouteMatchList newMatch,
    Uri prevLocation,
  ) {
    if (redirects.contains(newMatch)) {
      throw GoException(
          'redirect loop detected ${_formatRedirectionHistory(<RouteMatchList>[
            ...redirects,
            newMatch
          ])}');
    }
    if (redirects.length > _routingConfig.value.redirectLimit) {
      throw GoException(
          'too many redirects ${_formatRedirectionHistory(<RouteMatchList>[
            ...redirects,
            newMatch
          ])}');
    }

    redirects.add(newMatch);

    log('redirecting to $newMatch');
  }

  String _formatRedirectionHistory(List<RouteMatchList> redirections) {
    return redirections
        .map<String>(
            (RouteMatchList routeMatches) => routeMatches.uri.toString())
        .join(' => ');
  }

  /// Get the location for the provided route.
  ///
  /// Builds the absolute path for the route, by concatenating the paths of the
  /// route and all its ancestors.
  String? locationForRoute(RouteBase route) =>
      fullPathForRoute(route, '', _routingConfig.value.routes);

  @override
  String toString() {
    return 'RouterConfiguration: ${_routingConfig.value.routes}';
  }

  /// Returns the full path of [routes].
  ///
  /// Each path is indented based depth of the hierarchy, and its `name`
  /// is also appended if not null
  @visibleForTesting
  String debugKnownRoutes() {
    final StringBuffer sb = StringBuffer();
    sb.writeln('Full paths for routes:');
    _debugFullPathsFor(
        _routingConfig.value.routes, '', const <_DecorationType>[], sb);

    if (_nameToPath.isNotEmpty) {
      sb.writeln('known full paths for route names:');
      for (final MapEntry<String, String> e in _nameToPath.entries) {
        sb.writeln('  ${e.key} => ${e.value}');
      }
    }

    return sb.toString();
  }

  void _debugFullPathsFor(List<RouteBase> routes, String parentFullpath,
      List<_DecorationType> parentDecoration, StringBuffer sb) {
    for (final (int index, RouteBase route) in routes.indexed) {
      final List<_DecorationType> decoration =
          _getDecoration(parentDecoration, index, routes.length);
      final String decorationString =
          decoration.map((_DecorationType e) => e.toString()).join();
      String path = parentFullpath;
      if (route is GoRoute) {
        path = concatenatePaths(parentFullpath, route.path);
        final String? screenName =
            route.builder?.runtimeType.toString().split('=> ').last;
        sb.writeln('$decorationString$path '
            '${screenName == null ? '' : '($screenName)'}');
      } else if (route is ShellRouteBase) {
        sb.writeln('$decorationString (ShellRoute)');
      }
      _debugFullPathsFor(route.routes, path, decoration, sb);
    }
  }

  List<_DecorationType> _getDecoration(
    List<_DecorationType> parentDecoration,
    int index,
    int length,
  ) {
    final Iterable<_DecorationType> newDecoration =
        parentDecoration.map((_DecorationType e) {
      switch (e) {
        // swap
        case _DecorationType.branch:
          return _DecorationType.parentBranch;
        case _DecorationType.leaf:
          return _DecorationType.none;
        // no swap
        case _DecorationType.parentBranch:
          return _DecorationType.parentBranch;
        case _DecorationType.none:
          return _DecorationType.none;
      }
    });
    if (index == length - 1) {
      return <_DecorationType>[...newDecoration, _DecorationType.leaf];
    } else {
      return <_DecorationType>[...newDecoration, _DecorationType.branch];
    }
  }

  void _cacheNameToPath(String parentFullPath, List<RouteBase> childRoutes) {
    for (final RouteBase route in childRoutes) {
      if (route is GoRoute) {
        final String fullPath = concatenatePaths(parentFullPath, route.path);

        if (route.name != null) {
          final String name = route.name!;
          assert(
              !_nameToPath.containsKey(name),
              'duplication fullpaths for name '
              '"$name":${_nameToPath[name]}, $fullPath');
          _nameToPath[name] = fullPath;
        }

        if (route.routes.isNotEmpty) {
          _cacheNameToPath(fullPath, route.routes);
        }
      } else if (route is ShellRouteBase) {
        if (route.routes.isNotEmpty) {
          _cacheNameToPath(parentFullPath, route.routes);
        }
      }
    }
  }
}

enum _DecorationType {
  parentBranch('│ '),
  branch('├─'),
  leaf('└─'),
  none('  '),
  ;

  const _DecorationType(this.value);

  final String value;

  @override
  String toString() => value;
}
