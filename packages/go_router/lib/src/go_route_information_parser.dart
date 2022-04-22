// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/src/go_route_information_provider.dart';

import 'go_route.dart';
import 'go_route_match.dart';
import 'go_router_state.dart';
import 'logging.dart';
import 'path_parser.dart';
import 'typedefs.dart';

class _ParserError extends Error implements UnsupportedError {
  _ParserError(this.message);

  @override
  final String? message;
}

/// GoRouter implementation of the RouteInformationParser base class
class GoRouteInformationParser
    extends RouteInformationParser<List<GoRouteMatch>> {
  /// Creates a [GoRouteInformationParser].
  GoRouteInformationParser({
    required this.routes,
    required this.redirectLimit,
    required this.topRedirect,
    this.debugRequireGoRouteInformationProvider = false,
  }) : assert(() {
          // check top-level route paths are valid
          for (final GoRoute route in routes) {
            assert(route.path.startsWith('/'),
                'top-level path must start with "/": ${route.path}');
          }
          return true;
        }()) {
    _cacheNameToPath('', routes);
    assert(() {
      _debugLogKnownRoutes();
      return true;
    }());
  }

  /// List of top level routes used by the go router delegate.
  final List<GoRoute> routes;

  /// The limit for the number of consecutive redirects.
  final int redirectLimit;

  /// Top level page redirect.
  final GoRouterRedirect topRedirect;

  /// A debug property to assert [GoRouteInformationProvider] is in use along
  /// with this parser.
  ///
  /// An assertion error will be thrown if this property set to true and the
  /// [GoRouteInformationProvider] is in not in use.
  ///
  /// Defaults to false.
  final bool debugRequireGoRouteInformationProvider;

  final Map<String, String> _nameToPath = <String, String>{};

  void _cacheNameToPath(String parentFullPath, List<GoRoute> childRoutes) {
    for (final GoRoute route in childRoutes) {
      final String fullPath = concatenatePaths(parentFullPath, route.path);

      if (route.name != null) {
        final String name = route.name!.toLowerCase();
        assert(!_nameToPath.containsKey(name),
            'duplication fullpaths for name "$name":${_nameToPath[name]}, $fullPath');
        _nameToPath[name] = fullPath;
      }

      if (route.routes.isNotEmpty) {
        _cacheNameToPath(fullPath, route.routes);
      }
    }
  }

  /// Looks up the url location by a [GoRoute]'s name.
  String namedLocation(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, String> queryParams = const <String, String>{},
  }) {
    assert(() {
      log.info('getting location for name: '
          '"$name"'
          '${params.isEmpty ? '' : ', params: $params'}'
          '${queryParams.isEmpty ? '' : ', queryParams: $queryParams'}');
      return true;
    }());
    assert(_nameToPath.containsKey(name), 'unknown route name: $name');
    final String path = _nameToPath[name]!;
    assert(() {
      // Check that all required params are presented.
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
    return Uri(path: location, queryParameters: queryParams).toString();
  }

  /// Concatenates two paths.
  ///
  /// e.g: pathA = /a, pathB = c/d,  concatenatePaths(pathA, pathB) = /a/c/d.
  static String concatenatePaths(String parentPath, String childPath) {
    // at the root, just return the path
    if (parentPath.isEmpty) {
      assert(childPath.startsWith('/'));
      assert(childPath == '/' || !childPath.endsWith('/'));
      return childPath;
    }

    // not at the root, so append the parent path
    assert(childPath.isNotEmpty);
    assert(!childPath.startsWith('/'));
    assert(!childPath.endsWith('/'));
    return '${parentPath == '/' ? '' : parentPath}/$childPath';
  }

  /// for use by the Router architecture as part of the RouteInformationParser
  @override
  Future<List<GoRouteMatch>> parseRouteInformation(
    RouteInformation routeInformation,
  ) {
    assert(() {
      if (debugRequireGoRouteInformationProvider) {
        assert(
            routeInformation is DebugGoRouteInformation,
            'This GoRouteInformationParser needs to be used with '
            'GoRouteInformationProvider, do you forget to pass in '
            'GoRouter.routeinformationProvider to the Router constructor?');
      }
      return true;
    }());
    final List<GoRouteMatch> matches =
        _getLocRouteMatchesWithRedirects(routeInformation);
    // Use [SynchronousFuture] so that the initial url is processed
    // synchronously and remove unwanted initial animations on deep-linking
    return SynchronousFuture<List<GoRouteMatch>>(matches);
  }

  List<GoRouteMatch> _getLocRouteMatchesWithRedirects(
      RouteInformation routeInformation) {
    // start redirecting from the initial location
    List<GoRouteMatch> matches;
    final String location = routeInformation.location!;
    try {
      // watch redirects for loops
      final List<String> redirects = <String>[_canonicalUri(location)];
      bool redirected(String? redir) {
        if (redir == null) {
          return false;
        }

        assert(() {
          if (Uri.tryParse(redir) == null) {
            throw _ParserError('invalid redirect: $redir');
          }
          if (redirects.contains(redir)) {
            throw _ParserError('redirect loop detected: ${<String>[
              ...redirects,
              redir
            ].join(' => ')}');
          }
          if (redirects.length > redirectLimit) {
            throw _ParserError('too many redirects: ${<String>[
              ...redirects,
              redir
            ].join(' => ')}');
          }
          return true;
        }());

        redirects.add(redir);
        assert(() {
          log.info('redirecting to $redir');
          return true;
        }());
        return true;
      }

      // keep looping till we're done redirecting
      while (true) {
        final String loc = redirects.last;

        // check for top-level redirect
        final Uri uri = Uri.parse(loc);
        if (redirected(
          topRedirect(
            GoRouterState(
              this,
              location: loc,
              name: null, // no name available at the top level
              // trim the query params off the subloc to match route.redirect
              subloc: uri.path,
              // pass along the query params 'cuz that's all we have right now
              queryParams: uri.queryParameters,
              extra: routeInformation.state,
            ),
          ),
        )) {
          continue;
        }

        // get stack of route matches
        matches = _getLocRouteMatches(loc, routeInformation.state);

        // merge new params to keep params from previously matched paths, e.g.
        // /family/:fid/person/:pid provides fid and pid to person/:pid
        Map<String, String> previouslyMatchedParams = <String, String>{};
        for (final GoRouteMatch match in matches) {
          assert(
            !previouslyMatchedParams.keys.any(match.encodedParams.containsKey),
            'Duplicated parameter names',
          );
          match.encodedParams.addAll(previouslyMatchedParams);
          previouslyMatchedParams = match.encodedParams;
        }

        // check top route for redirect
        final GoRouteMatch top = matches.last;
        if (redirected(
          top.route.redirect(
            GoRouterState(
              this,
              location: loc,
              subloc: top.subloc,
              name: top.route.name,
              path: top.route.path,
              fullpath: top.fullpath,
              params: top.decodedParams,
              queryParams: top.queryParams,
            ),
          ),
        )) {
          continue;
        }

        // no more redirects!
        break;
      }

      // note that we need to catch it this way to get all the info, e.g. the
      // file/line info for an error in an inline function impl, e.g. an inline
      // `redirect` impl
      // ignore: avoid_catches_without_on_clauses
    } on _ParserError catch (err) {
      // create a match that routes to the error page
      final Exception error = Exception(err.message);
      final Uri uri = Uri.parse(location);
      matches = <GoRouteMatch>[
        GoRouteMatch(
          subloc: uri.path,
          fullpath: uri.path,
          encodedParams: <String, String>{},
          queryParams: uri.queryParameters,
          extra: null,
          error: error,
          route: GoRoute(
              path: location,
              pageBuilder: (BuildContext context, GoRouterState state) {
                throw UnimplementedError();
              }),
        ),
      ];
    }
    assert(matches.isNotEmpty);
    return matches;
  }

  List<GoRouteMatch> _getLocRouteMatches(String location, Object? extra) {
    final Uri uri = Uri.parse(location);
    return _getLocRouteRecursively(
      loc: uri.path,
      restLoc: uri.path,
      routes: routes,
      parentFullpath: '',
      parentSubloc: '',
      queryParams: uri.queryParameters,
      extra: extra,
    );
  }

  static List<GoRouteMatch> _getLocRouteRecursively({
    required String loc,
    required String restLoc,
    required String parentSubloc,
    required List<GoRoute> routes,
    required String parentFullpath,
    required Map<String, String> queryParams,
    required Object? extra,
  }) {
    bool debugGatherAllMatches = false;
    assert(() {
      debugGatherAllMatches = true;
      return true;
    }());
    final List<List<GoRouteMatch>> result = <List<GoRouteMatch>>[];
    // find the set of matches at this level of the tree
    for (final GoRoute route in routes) {
      final String fullpath = concatenatePaths(parentFullpath, route.path);
      final GoRouteMatch? match = GoRouteMatch.match(
        route: route,
        restLoc: restLoc,
        parentSubloc: parentSubloc,
        fullpath: fullpath,
        queryParams: queryParams,
        extra: extra,
      );

      if (match == null) {
        continue;
      }
      if (match.subloc.toLowerCase() == loc.toLowerCase()) {
        // If it is a complete match, then return the matched route
        // NOTE: need a lower case match because subloc is canonicalized to match
        // the path case whereas the location can be of any case and still match
        result.add(<GoRouteMatch>[match]);
      } else if (route.routes.isEmpty) {
        // If it is partial match but no sub-routes, bail.
        continue;
      } else {
        // otherwise recurse
        final String childRestLoc =
            loc.substring(match.subloc.length + (match.subloc == '/' ? 0 : 1));
        assert(loc.startsWith(match.subloc));
        assert(restLoc.isNotEmpty);

        final List<GoRouteMatch> subRouteMatch = _getLocRouteRecursively(
          loc: loc,
          restLoc: childRestLoc,
          parentSubloc: match.subloc,
          routes: route.routes,
          parentFullpath: fullpath,
          queryParams: queryParams,
          extra: extra,
        ).toList();

        // if there's no sub-route matches, there is no match for this
        // location
        if (subRouteMatch.isEmpty) {
          continue;
        }
        result.add(<GoRouteMatch>[match, ...subRouteMatch]);
      }
      // Should only reach here if there is a match.
      if (debugGatherAllMatches) {
        continue;
      } else {
        break;
      }
    }

    if (result.isEmpty) {
      throw _ParserError('no routes for location: $loc');
    }

    // If there are multiple routes that match the location, returning the first one.
    // To make predefined routes to take precedence over dynamic routes eg. '/:id'
    // consider adding the dynamic route at the end of the routes
    return result.first;
  }

  void _debugLogKnownRoutes() {
    log.info('known full paths for routes:');
    _debugLogFullPathsFor(routes, '', 0);

    if (_nameToPath.isNotEmpty) {
      log.info('known full paths for route names:');
      for (final MapEntry<String, String> e in _nameToPath.entries) {
        log.info('  ${e.key} => ${e.value}');
      }
    }
  }

  void _debugLogFullPathsFor(
    List<GoRoute> routes,
    String parentFullpath,
    int depth,
  ) {
    for (final GoRoute route in routes) {
      final String fullpath = concatenatePaths(parentFullpath, route.path);
      assert(() {
        log.info('  => ${''.padLeft(depth * 2)}$fullpath');
        return true;
      }());
      _debugLogFullPathsFor(route.routes, fullpath, depth + 1);
    }
  }

  /// for use by the Router architecture as part of the RouteInformationParser
  @override
  RouteInformation restoreRouteInformation(List<GoRouteMatch> configuration) {
    return RouteInformation(
        location: configuration.last.fullUriString,
        state: configuration.last.extra);
  }
}

/// Normalizes the location string.
String _canonicalUri(String loc) {
  String canon = Uri.parse(loc).toString();
  canon = canon.endsWith('?') ? canon.substring(0, canon.length - 1) : canon;

  // remove trailing slash except for when you shouldn't, e.g.
  // /profile/ => /profile
  // / => /
  // /login?from=/ => login?from=/
  canon = canon.endsWith('/') && canon != '/' && !canon.contains('?')
      ? canon.substring(0, canon.length - 1)
      : canon;

  // /login/?from=/ => /login?from=/
  // /?from=/ => /?from=/
  canon = canon.replaceFirst('/?', '?', 1);

  return canon;
}
