// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'logging.dart';
import 'match.dart';
import 'misc/constants.dart';
import 'misc/errors.dart';
import 'path_utils.dart';
import 'route.dart';
import 'router.dart' show GoRouter, OnEnter, RoutingConfig;
import 'state.dart';

/// The signature of the redirect callback.
typedef GoRouterRedirect =
    FutureOr<String?> Function(BuildContext context, GoRouterState state);

typedef _NamedPath = ({String path, bool caseSensitive});

/// The route configuration for GoRouter configured by the app.
class RouteConfiguration {
  /// Constructs a [RouteConfiguration].
  RouteConfiguration(
    this._routingConfig, {
    required this.navigatorKey,
    this.extraCodec,
    this.router,
  }) {
    _onRoutingTableChanged();
    _routingConfig.addListener(_onRoutingTableChanged);
  }

  static bool _debugCheckPath(List<RouteBase> routes, bool isTopLevel) {
    for (final route in routes) {
      late bool subRouteIsTopLevel;
      if (route is GoRoute) {
        if (route.path != '/') {
          assert(
            !route.path.endsWith('/'),
            'route path may not end with "/" except for the top "/" route. Found: $route',
          );
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
    List<RouteBase> routes,
    List<GlobalKey<NavigatorState>> allowedKeys,
  ) {
    for (final route in routes) {
      if (route is GoRoute) {
        final GlobalKey<NavigatorState>? parentKey = route.parentNavigatorKey;
        if (parentKey != null) {
          // Verify that the root navigator or a ShellRoute ancestor has a
          // matching navigator key.
          assert(
            allowedKeys.contains(parentKey),
            'parentNavigatorKey $parentKey must refer to'
            " an ancestor ShellRoute's navigatorKey or GoRouter's"
            ' navigatorKey',
          );

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
            <GlobalKey<NavigatorState>>[...allowedKeys],
          );
        }
      } else if (route is ShellRoute) {
        _debugCheckParentNavigatorKeys(
          route.routes,
          <GlobalKey<NavigatorState>>[...allowedKeys, route.navigatorKey],
        );
      } else if (route is StatefulShellRoute) {
        for (final StatefulShellBranch branch in route.branches) {
          assert(
            !allowedKeys.contains(branch.navigatorKey),
            'StatefulShellBranch must not reuse an ancestor navigatorKey '
            '(${branch.navigatorKey})',
          );

          _debugCheckParentNavigatorKeys(
            branch.routes,
            <GlobalKey<NavigatorState>>[...allowedKeys, branch.navigatorKey],
          );
        }
      }
    }
    return true;
  }

  static bool _debugVerifyNoDuplicatePathParameter(
    List<RouteBase> routes,
    Map<String, GoRoute> usedPathParams,
  ) {
    for (final route in routes) {
      if (route is! GoRoute) {
        continue;
      }
      for (final String pathParam in route.pathParameters) {
        if (usedPathParams.containsKey(pathParam)) {
          final sameRoute = usedPathParams[pathParam] == route;
          throw GoError(
            "duplicate path parameter, '$pathParam' found in ${sameRoute ? '$route' : '${usedPathParams[pathParam]}, and $route'}",
          );
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
    for (final route in routes) {
      if (route is StatefulShellRoute) {
        for (final StatefulShellBranch branch in route.branches) {
          if (branch.initialLocation == null) {
            // Recursively search for the first GoRoute descendant. Will
            // throw assertion error if not found.
            final GoRoute? defaultGoRoute = branch.defaultRoute;
            final String? initialLocation = defaultGoRoute != null
                ? locationForRoute(defaultGoRoute)
                : null;
            assert(
              initialLocation != null,
              'The default location of a StatefulShellBranch must be '
              'derivable from GoRoute descendant',
            );
            assert(
              defaultGoRoute!.pathParameters.isEmpty,
              'The default location of a StatefulShellBranch cannot be '
              'a parameterized route',
            );
          } else {
            final RouteMatchList matchList = findMatch(
              Uri.parse(branch.initialLocation!),
            );
            assert(
              !matchList.isError,
              'initialLocation (${matchList.uri}) of StatefulShellBranch must '
              'be a valid location',
            );
            final List<RouteBase> matchRoutes = matchList.routes;
            final int shellIndex = matchRoutes.indexOf(route);
            var matchFound = false;
            if (shellIndex >= 0 && (shellIndex + 1) < matchRoutes.length) {
              final RouteBase branchRoot = matchRoutes[shellIndex + 1];
              matchFound = branch.routes.contains(branchRoot);
            }
            assert(
              matchFound,
              'The initialLocation (${branch.initialLocation}) of '
              'StatefulShellBranch must match a descendant route of the '
              'branch',
            );
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
    assert(
      _debugVerifyNoDuplicatePathParameter(
        routingTable.routes,
        <String, GoRoute>{},
      ),
    );
    assert(
      _debugCheckParentNavigatorKeys(
        routingTable.routes,
        <GlobalKey<NavigatorState>>[navigatorKey],
      ),
    );
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
      error: matchList.error,
    );
  }

  /// The routing table.
  final ValueListenable<RoutingConfig> _routingConfig;

  /// The list of top level routes used by [GoRouterDelegate].
  List<RouteBase> get routes => _routingConfig.value.routes;

  /// Legacy top level page redirect.
  ///
  /// This is handled via [applyTopLegacyRedirect] and runs at most once per navigation.
  GoRouterRedirect get topRedirect => _routingConfig.value.redirect;

  /// Top level page on enter.
  OnEnter? get topOnEnter => _routingConfig.value.onEnter;

  /// The limit for the number of consecutive redirects.
  int get redirectLimit => _routingConfig.value.redirectLimit;

  /// Normalizes a URI by ensuring it has a valid path and removing trailing slashes.
  static Uri normalizeUri(Uri uri) {
    if (uri.hasEmptyPath) {
      return uri.replace(path: '/');
    } else if (uri.path.length > 1 && uri.path.endsWith('/')) {
      return uri.replace(path: uri.path.substring(0, uri.path.length - 1));
    }
    return uri;
  }

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
  ///  * [topOnEnter] for navigation interception.
  ///  * [topRedirect] for legacy redirections.
  final Codec<Object?, Object?>? extraCodec;

  /// The GoRouter instance that owns this configuration.
  ///
  /// This is used to provide access to the router during redirects.
  final GoRouter? router;

  final Map<String, _NamedPath> _nameToPath = <String, _NamedPath>{};

  /// Looks up the url location by a [GoRoute]'s name.
  String namedLocation(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    String? fragment,
  }) {
    assert(() {
      log(
        'getting location for name: '
        '"$name"'
        '${pathParameters.isEmpty ? '' : ', pathParameters: $pathParameters'}'
        '${queryParameters.isEmpty ? '' : ', queryParameters: $queryParameters'}'
        '${fragment != null ? ', fragment: $fragment' : ''}',
      );
      return true;
    }());
    assert(_nameToPath.containsKey(name), 'unknown route name: $name');
    final _NamedPath path = _nameToPath[name]!;
    assert(() {
      // Check that all required params are present
      final paramNames = <String>[];
      patternToRegExp(path.path, paramNames, caseSensitive: path.caseSensitive);
      for (final paramName in paramNames) {
        assert(
          pathParameters.containsKey(paramName),
          'missing param "$paramName" for $path',
        );
      }

      // Check that there are no extra params
      for (final String key in pathParameters.keys) {
        assert(paramNames.contains(key), 'unknown param "$key" for $path');
      }
      return true;
    }());
    final encodedParams = <String, String>{
      for (final MapEntry<String, String> param in pathParameters.entries)
        param.key: Uri.encodeComponent(param.value),
    };
    final String location = patternToPath(path.path, encodedParams);
    return Uri(
      path: location,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
      fragment: fragment,
    ).toString();
  }

  /// Finds the routes that matched the given URL.
  RouteMatchList findMatch(Uri uri, {Object? extra}) {
    final pathParameters = <String, String>{};
    final List<RouteMatchBase> matches = _getLocRouteMatches(
      uri,
      pathParameters,
    );

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
      extra: extra,
    );
  }

  /// Reparse the input RouteMatchList
  RouteMatchList reparse(RouteMatchList matchList) {
    RouteMatchList result = findMatch(matchList.uri, extra: matchList.extra);

    for (final ImperativeRouteMatch imperativeMatch
        in matchList.matches.whereType<ImperativeRouteMatch>()) {
      final match = ImperativeRouteMatch(
        pageKey: imperativeMatch.pageKey,
        matches: findMatch(
          imperativeMatch.matches.uri,
          extra: imperativeMatch.matches.extra,
        ),
        completer: imperativeMatch.completer,
      );
      result = result.push(match);
    }
    return result;
  }

  List<RouteMatchBase> _getLocRouteMatches(
    Uri uri,
    Map<String, String> pathParameters,
  ) {
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

  /// Processes route-level redirects by returning a new [RouteMatchList] representing the new location.
  ///
  /// This method now handles ONLY route-level redirects.
  /// Top-level redirects are handled by applyTopLegacyRedirect.
  FutureOr<RouteMatchList> redirect(
    BuildContext context,
    FutureOr<RouteMatchList> prevMatchListFuture, {
    required List<RouteMatchList> redirectHistory,
  }) {
    FutureOr<RouteMatchList> processRedirect(RouteMatchList prevMatchList) {
      final prevLocation = prevMatchList.uri.toString();

      FutureOr<RouteMatchList> processRouteLevelRedirect(
        String? routeRedirectLocation,
      ) {
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
          return redirect(context, newMatch, redirectHistory: redirectHistory);
        }
        return prevMatchList;
      }

      final routeMatches = <RouteMatchBase>[];
      prevMatchList.visitRouteMatches((RouteMatchBase match) {
        if (match.route.redirect != null) {
          routeMatches.add(match);
        }
        return true;
      });

      try {
        final FutureOr<String?> routeLevelRedirectResult =
            _getRouteLevelRedirect(context, prevMatchList, routeMatches, 0);

        if (routeLevelRedirectResult is String?) {
          return processRouteLevelRedirect(routeLevelRedirectResult);
        }
        return routeLevelRedirectResult
            .then<RouteMatchList>(processRouteLevelRedirect)
            .catchError((Object error) {
              final GoException goException = error is GoException
                  ? error
                  : GoException('Exception during route redirect: $error');
              return _errorRouteMatchList(
                prevMatchList.uri,
                goException,
                extra: prevMatchList.extra,
              );
            });
      } catch (exception) {
        final GoException goException = exception is GoException
            ? exception
            : GoException('Exception during route redirect: $exception');
        return _errorRouteMatchList(
          prevMatchList.uri,
          goException,
          extra: prevMatchList.extra,
        );
      }
    }

    if (prevMatchListFuture is RouteMatchList) {
      return processRedirect(prevMatchListFuture);
    }
    return prevMatchListFuture.then<RouteMatchList>(processRedirect);
  }

  /// Applies the legacy top-level redirect to [prevMatchList] and returns the
  /// resulting matches.
  ///
  /// Returns [prevMatchList] when no redirect happens.
  ///
  /// Shares [redirectHistory] with later route-level redirects for proper loop detection.
  ///
  /// Note: Legacy top-level redirect is executed at most once per navigation,
  /// before route-level redirects. It does not re-evaluate if it redirects to
  /// a location that would itself trigger another top-level redirect.
  FutureOr<RouteMatchList> applyTopLegacyRedirect(
    BuildContext context,
    RouteMatchList prevMatchList, {
    required List<RouteMatchList> redirectHistory,
  }) {
    final prevLocation = prevMatchList.uri.toString();
    FutureOr<RouteMatchList> done(String? topLocation) {
      if (topLocation != null && topLocation != prevLocation) {
        final RouteMatchList newMatch = _getNewMatches(
          topLocation,
          prevMatchList.uri,
          redirectHistory,
        );
        return newMatch;
      }
      return prevMatchList;
    }

    try {
      final FutureOr<String?> res = _runInRouterZone(() {
        return _routingConfig.value.redirect(
          context,
          buildTopLevelGoRouterState(prevMatchList),
        );
      });
      if (res is String?) {
        return done(res);
      }
      return res.then<RouteMatchList>(done).catchError((Object error) {
        final GoException goException = error is GoException
            ? error
            : GoException('Exception during redirect: $error');
        return _errorRouteMatchList(
          prevMatchList.uri,
          goException,
          extra: prevMatchList.extra,
        );
      });
    } catch (exception) {
      final GoException goException = exception is GoException
          ? exception
          : GoException('Exception during redirect: $exception');
      return _errorRouteMatchList(
        prevMatchList.uri,
        goException,
        extra: prevMatchList.extra,
      );
    }
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
          context,
          matchList,
          routeMatches,
          currentCheckIndex + 1,
        );
    final RouteBase route = match.route;
    try {
      final FutureOr<String?> routeRedirectResult = _runInRouterZone(() {
        return route.redirect!.call(context, match.buildState(this, matchList));
      });
      if (routeRedirectResult is String?) {
        return processRouteRedirect(routeRedirectResult);
      }
      return routeRedirectResult.then<String?>(processRouteRedirect).catchError(
        (Object error) {
          // Convert any exception during async route redirect to a GoException
          final GoException goException = error is GoException
              ? error
              : GoException('Exception during route redirect: $error');
          // Throw the GoException to be caught by the redirect handling chain
          throw goException;
        },
      );
    } catch (exception) {
      // Convert any exception during route redirect to a GoException
      final GoException goException = exception is GoException
          ? exception
          : GoException('Exception during route redirect: $exception');
      // Throw the GoException to be caught by the redirect handling chain
      throw goException;
    }
  }

  RouteMatchList _getNewMatches(
    String newLocation,
    Uri previousLocation,
    List<RouteMatchList> redirectHistory,
  ) {
    try {
      // Normalize the URI to avoid trailing slash inconsistencies
      final Uri uri = normalizeUri(Uri.parse(newLocation));

      final RouteMatchList newMatch = findMatch(uri);
      // Only add successful matches to redirect history
      if (!newMatch.isError) {
        _addRedirect(redirectHistory, newMatch);
      }
      return newMatch;
    } catch (exception) {
      final GoException goException = exception is GoException
          ? exception
          : GoException('Exception during redirect: $exception');
      log('Redirection exception: ${goException.message}');
      return _errorRouteMatchList(previousLocation, goException);
    }
  }

  /// Adds the redirect to [redirects] if it is valid.
  ///
  /// Throws if a loop is detected or the redirection limit is reached.
  void _addRedirect(List<RouteMatchList> redirects, RouteMatchList newMatch) {
    if (redirects.contains(newMatch)) {
      throw GoException(
        'redirect loop detected ${_formatRedirectionHistory(<RouteMatchList>[...redirects, newMatch])}',
      );
    }
    // Check limit before adding (redirects should only contain actual redirects, not the initial location)
    if (redirects.length >= _routingConfig.value.redirectLimit) {
      throw GoException(
        'too many redirects ${_formatRedirectionHistory(<RouteMatchList>[...redirects, newMatch])}',
      );
    }

    redirects.add(newMatch);

    log('redirecting to $newMatch');
  }

  String _formatRedirectionHistory(List<RouteMatchList> redirections) {
    return redirections
        .map<String>(
          (RouteMatchList routeMatches) => routeMatches.uri.toString(),
        )
        .join(' => ');
  }

  /// Runs the given function in a Zone with the router context for redirects.
  T _runInRouterZone<T>(T Function() callback) {
    if (router == null) {
      return callback();
    }

    T? result;
    var errorOccurred = false;

    runZonedGuarded<void>(
      () {
        result = callback();
      },
      (Object error, StackTrace stack) {
        errorOccurred = true;
        // Convert any exception during redirect to a GoException and rethrow
        final GoException goException = error is GoException
            ? error
            : GoException('Exception during redirect: $error');
        throw goException;
      },
      zoneValues: <Object?, Object?>{currentRouterKey: router},
    );

    if (errorOccurred) {
      // This should not be reached since we rethrow in the error handler
      throw GoException('Unexpected error in router zone');
    }

    return result as T;
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
    final sb = StringBuffer();
    sb.writeln('Full paths for routes:');
    _debugFullPathsFor(
      _routingConfig.value.routes,
      '',
      const <_DecorationType>[],
      sb,
    );

    if (_nameToPath.isNotEmpty) {
      sb.writeln('known full paths for route names:');
      for (final MapEntry<String, _NamedPath> e in _nameToPath.entries) {
        sb.writeln(
          '  ${e.key} => ${e.value.path}${e.value.caseSensitive ? '' : ' (case-insensitive)'}',
        );
      }
    }

    return sb.toString();
  }

  void _debugFullPathsFor(
    List<RouteBase> routes,
    String parentFullpath,
    List<_DecorationType> parentDecoration,
    StringBuffer sb,
  ) {
    for (final (int index, RouteBase route) in routes.indexed) {
      final List<_DecorationType> decoration = _getDecoration(
        parentDecoration,
        index,
        routes.length,
      );
      final String decorationString = decoration
          .map((_DecorationType e) => e.toString())
          .join();
      var path = parentFullpath;
      if (route is GoRoute) {
        path = concatenatePaths(parentFullpath, route.path);
        final String? screenName = route.builder?.runtimeType
            .toString()
            .split('=> ')
            .last;
        sb.writeln(
          '$decorationString$path '
          '${screenName == null ? '' : '($screenName)'}',
        );
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
    final Iterable<_DecorationType> newDecoration = parentDecoration.map((
      _DecorationType e,
    ) {
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
    for (final route in childRoutes) {
      if (route is GoRoute) {
        final String fullPath = concatenatePaths(parentFullPath, route.path);

        if (route.name != null) {
          final String name = route.name!;
          assert(
            !_nameToPath.containsKey(name),
            'duplication fullpaths for name '
            '"$name":${_nameToPath[name]!.path}, $fullPath',
          );
          _nameToPath[name] = (
            path: fullPath,
            caseSensitive: route.caseSensitive,
          );
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
  none('  ');

  const _DecorationType(this.value);

  final String value;

  @override
  String toString() => value;
}
