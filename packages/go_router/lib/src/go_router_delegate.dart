// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'custom_transition_page.dart';
import 'go_route.dart';
import 'go_route_match.dart';
import 'go_router_cupertino.dart';
import 'go_router_error_page.dart';
import 'go_router_material.dart';
import 'go_router_state.dart';
import 'logging.dart';
import 'typedefs.dart';

/// GoRouter implementation of the RouterDelegate base class.
class GoRouterDelegate extends RouterDelegate<Uri>
    with
        PopNavigatorRouterDelegateMixin<Uri>,
        // ignore: prefer_mixin
        ChangeNotifier {
  /// Constructor for GoRouter's implementation of the
  /// RouterDelegate base class.
  GoRouterDelegate({
    required this.builderWithNav,
    required this.routes,
    required this.errorPageBuilder,
    required this.errorBuilder,
    required this.topRedirect,
    required this.redirectLimit,
    required this.refreshListenable,
    required Uri initUri,
    required this.observers,
    required this.debugLogDiagnostics,
    required this.routerNeglect,
    this.restorationScopeId,
  }) {
    // check top-level route paths are valid
    for (final route in routes) {
      if (!route.path.startsWith('/')) {
        throw Exception('top-level path must start with "/": ${route.path}');
      }
    }

    // cache the set of named routes for fast lookup
    _cacheNamedRoutes(routes, '', _namedMatches);

    // output known routes
    _outputKnownRoutes();

    // build the list of route matches
    log.info('setting initial location $initUri');
    _go(initUri.toString());

    // when the listener changes, refresh the route
    refreshListenable?.addListener(refresh);
  }

  /// Builder function for a go router with Navigator.
  final GoRouterBuilderWithNav builderWithNav;

  /// List of top level routes used by the go router delegate.
  final List<GoRoute> routes;

  /// Error page builder for the go router delegate.
  final GoRouterPageBuilder? errorPageBuilder;

  /// Error widget builder for the go router delegate.
  final GoRouterWidgetBuilder? errorBuilder;

  /// Top level page redirect.
  final GoRouterRedirect topRedirect;

  /// The limit for the number of consecutive redirects.
  final int redirectLimit;

  /// Listenable used to cause the router to refresh it's route.
  final Listenable? refreshListenable;

  /// NavigatorObserver used to receive change notifications when
  /// navigation changes.
  final List<NavigatorObserver> observers;

  /// Set to true to log diagnostic info for your routes.
  final bool debugLogDiagnostics;

  /// Set to true to disable creating history entries on the web.
  final bool routerNeglect;

  /// Restoration ID to save and restore the state of the navigator, including
  /// its history.
  final String? restorationScopeId;

  final _key = GlobalKey<NavigatorState>();
  final List<GoRouteMatch> _matches = [];
  final _namedMatches = <String, GoRouteMatch>{};
  final _pushCounts = <String, int>{};

  void _cacheNamedRoutes(
    List<GoRoute> routes,
    String parentFullpath,
    Map<String, GoRouteMatch> namedFullpaths,
  ) {
    for (final route in routes) {
      final fullpath = fullLocFor(parentFullpath, route.path);

      if (route.name != null) {
        final name = route.name!.toLowerCase();
        if (namedFullpaths.containsKey(name)) {
          throw Exception('duplication fullpaths for name "$name":'
              '${namedFullpaths[name]!.fullpath}, $fullpath');
        }

        // we only have a partial match until we have a location;
        // we're really only caching the route and fullpath at this point
        final match = GoRouteMatch(
          route: route,
          subloc: '/TBD',
          fullpath: fullpath,
          encodedParams: {},
          queryParams: {},
          extra: null,
          error: null,
        );

        namedFullpaths[name] = match;
      }

      if (route.routes.isNotEmpty) {
        _cacheNamedRoutes(route.routes, fullpath, namedFullpaths);
      }
    }
  }

  /// Get a location from route name and parameters.
  /// This is useful for redirecting to a named location.
  String namedLocation(
    String name, {
    required Map<String, String> params,
    required Map<String, String> queryParams,
  }) {
    log.info('getting location for name: '
        '"$name"'
        '${params.isEmpty ? '' : ', params: $params'}'
        '${queryParams.isEmpty ? '' : ', queryParams: $queryParams'}');

    // find route and build up the full path along the way
    final match = _getNameRouteMatch(
      name.toLowerCase(), // case-insensitive name matching
      params: params,
      queryParams: queryParams,
    );
    if (match == null) throw Exception('unknown route name: $name');

    assert(identical(match.queryParams, queryParams));
    return _addQueryParams(match.subloc, queryParams);
  }

  /// Navigate to the given location.
  void go(String location, {Object? extra}) {
    log.info('going to $location');
    _go(location, extra: extra);
    notifyListeners();
  }

  /// Push the given location onto the page stack
  void push(String location, {Object? extra}) {
    log.info('pushing $location');
    _push(location, extra: extra);
    notifyListeners();
  }

  /// Pop the top page off the GoRouter's page stack.
  void pop() {
    _matches.remove(_matches.last);
    if (_matches.isEmpty) {
      throw Exception(
        'have popped the last page off of the stack; '
        'there are no pages left to show',
      );
    }
    notifyListeners();
  }

  /// Refresh the current location, including re-evaluating redirections.
  void refresh() {
    log.info('refreshing $location');
    _go(location, extra: _matches.last.extra);
    notifyListeners();
  }

  /// Get the current location, e.g. /family/f2/person/p1
  String get location =>
      _addQueryParams(_matches.last.subloc, _matches.last.queryParams);

  /// For internal use; visible for testing only.
  @visibleForTesting
  List<GoRouteMatch> get matches => _matches;

  /// Dispose resources held by the router delegate.
  @override
  void dispose() {
    refreshListenable?.removeListener(refresh);
    super.dispose();
  }

  /// For use by the Router architecture as part of the RouterDelegate.
  @override
  GlobalKey<NavigatorState> get navigatorKey => _key;

  /// For use by the Router architecture as part of the RouterDelegate.
  @override
  Uri get currentConfiguration => Uri.parse(location);

  /// For use by the Router architecture as part of the RouterDelegate.
  @override
  Widget build(BuildContext context) => _builder(context, _matches);

  /// For use by the Router architecture as part of the RouterDelegate.
  @override
  Future<void> setInitialRoutePath(Uri configuration) {
    // if the initial location is /, then use the dev initial location;
    // otherwise, we're cruising to a deep link, so ignore dev initial location
    final config = configuration.toString();
    if (config == '/') {
      _go(location);
    } else {
      log.info('deep linking to $config');
      _go(config);
    }

    // Use [SynchronousFuture] so that the initial url is processed
    // synchronously and remove unwanted initial animations on deep-linking
    return SynchronousFuture(null);
  }

  /// For use by the Router architecture as part of the RouterDelegate.
  @override
  Future<void> setNewRoutePath(Uri configuration) async {
    final config = configuration.toString();
    log.info('going to $config');
    _go(config);
  }

  void _go(String location, {Object? extra}) {
    final matches = _getLocRouteMatchesWithRedirects(location, extra: extra);
    assert(matches.isNotEmpty);

    // replace the stack of matches w/ the new ones
    _matches
      ..clear()
      ..addAll(matches);
  }

  void _push(String location, {Object? extra}) {
    final matches = _getLocRouteMatchesWithRedirects(location, extra: extra);
    assert(matches.isNotEmpty);
    final top = matches.last;

    // remap the pageKey so allow any number of the same page on the stack
    final fullpath = top.fullpath;
    final count = (_pushCounts[fullpath] ?? 0) + 1;
    _pushCounts[fullpath] = count;
    final pageKey = ValueKey('$fullpath-p$count');
    final match = GoRouteMatch(
      route: top.route,
      subloc: top.subloc,
      fullpath: top.fullpath,
      encodedParams: top.encodedParams,
      queryParams: top.queryParams,
      extra: extra,
      error: null,
      pageKey: pageKey,
    );

    // add a new match onto the stack of matches
    assert(matches.isNotEmpty);
    _matches.add(match);
  }

  List<GoRouteMatch> _getLocRouteMatchesWithRedirects(
    String location, {
    required Object? extra,
  }) {
    // start redirecting from the initial location
    List<GoRouteMatch> matches;

    try {
      // watch redirects for loops
      final redirects = [_canonicalUri(location)];
      bool redirected(String? redir) {
        if (redir == null) return false;

        if (Uri.tryParse(redir) == null) {
          throw Exception('invalid redirect: $redir');
        }

        if (redirects.contains(redir)) {
          redirects.add(redir);
          final msg = 'redirect loop detected: ${redirects.join(' => ')}';
          throw Exception(msg);
        }

        redirects.add(redir);
        if (redirects.length - 1 > redirectLimit) {
          final msg = 'too many redirects: ${redirects.join(' => ')}';
          throw Exception(msg);
        }

        log.info('redirecting to $redir');
        return true;
      }

      // keep looping till we're done redirecting
      for (;;) {
        final loc = redirects.last;

        // check for top-level redirect
        final uri = Uri.parse(loc);
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
            ),
          ),
        )) continue;

        // get stack of route matches
        matches = _getLocRouteMatches(loc, extra: extra);

        // merge new params to keep params from previously matched paths, e.g.
        // /family/:fid/person/:pid provides fid and pid to person/:pid
        var previouslyMatchedParams = <String, String>{};
        for (final match in matches) {
          assert(
            !previouslyMatchedParams.keys.any(match.encodedParams.containsKey),
            'Duplicated parameter names',
          );
          match.encodedParams.addAll(previouslyMatchedParams);
          previouslyMatchedParams = match.encodedParams;
        }

        // check top route for redirect
        final top = matches.last;
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
              extra: extra,
            ),
          ),
        )) continue;

        // let Router know to update the address bar
        // (the initial route is not a redirect)
        if (redirects.length > 1) notifyListeners();

        // no more redirects!
        break;
      }

      // note that we need to catch it this way to get all the info, e.g. the
      // file/line info for an error in an inline function impl, e.g. an inline
      // `redirect` impl
      // ignore: avoid_catches_without_on_clauses
    } catch (err, stack) {
      log.severe('Exception during GoRouter navigation', err, stack);

      // create a match that routes to the error page
      final error = err is Exception ? err : Exception(err);
      final uri = Uri.parse(location);
      matches = [
        GoRouteMatch(
          subloc: uri.path,
          fullpath: uri.path,
          encodedParams: {},
          queryParams: uri.queryParameters,
          extra: null,
          error: error,
          route: GoRoute(
            path: location,
            pageBuilder: (context, state) => _errorPageBuilder(
              context,
              GoRouterState(
                this,
                location: state.location,
                subloc: state.subloc,
                name: state.name,
                path: state.path,
                error: error,
                fullpath: state.path,
                params: state.params,
                queryParams: state.queryParams,
                extra: state.extra,
              ),
            ),
          ),
        ),
      ];
    }

    assert(matches.isNotEmpty);
    return matches;
  }

  List<GoRouteMatch> _getLocRouteMatches(
    String location, {
    Object? extra,
  }) {
    final uri = Uri.parse(location);
    final matchStacks = _getLocRouteMatchStacks(
      loc: uri.path,
      restLoc: uri.path,
      routes: routes,
      parentFullpath: '',
      parentSubloc: '',
      queryParams: uri.queryParameters,
      extra: extra,
    ).toList();

    if (matchStacks.isEmpty) {
      throw Exception('no routes for location: $location');
    }

    if (matchStacks.length > 1) {
      final sb = StringBuffer()
        ..writeln('too many routes for location: $location');

      for (final stack in matchStacks) {
        sb.writeln('\t${stack.map((m) => m.route.path).join(' => ')}');
      }

      throw Exception(sb.toString());
    }

    if (kDebugMode) {
      assert(matchStacks.length == 1);
      final match = matchStacks.first.last;
      final loc1 = _addQueryParams(match.subloc, match.queryParams);
      final uri2 = Uri.parse(location);
      final loc2 = _addQueryParams(uri2.path, uri2.queryParameters);

      // NOTE: match the lower case, since subloc is canonicalized to match the
      // path case whereas the location can be any case
      assert(loc1.toLowerCase() == loc2.toLowerCase(), '$loc1 != $loc2');
    }

    return matchStacks.first;
  }

  /// turns a list of routes into a list of routes match stacks for the location
  /// e.g. routes: [
  ///   /
  ///     family/:fid
  ///   /login
  /// ]
  ///
  /// loc: /
  /// stacks: [
  ///   matches: [
  ///     match(route.path=/, loc=/)
  ///   ]
  /// ]
  ///
  /// loc: /login
  /// stacks: [
  ///   matches: [
  ///     match(route.path=/login, loc=login)
  ///   ]
  /// ]
  ///
  /// loc: /family/f2
  /// stacks: [
  ///   matches: [
  ///     match(route.path=/, loc=/),
  ///     match(route.path=family/:fid, loc=family/f2, params=[fid=f2])
  ///   ]
  /// ]
  ///
  /// loc: /family/f2/person/p1
  /// stacks: [
  ///   matches: [
  ///     match(route.path=/, loc=/),
  ///     match(route.path=family/:fid, loc=family/f2, params=[fid=f2])
  ///     match(route.path=person/:pid, loc=person/p1, params=[fid=f2, pid=p1])
  ///   ]
  /// ]
  ///
  /// A stack count of 0 means there's no match.
  /// A stack count of >1 means there's a malformed set of routes.
  ///
  /// NOTE: Uses recursion, which is why _getLocRouteMatchStacks calls this
  /// function and does the actual error checking, using the returned stacks to
  /// provide better errors
  static Iterable<List<GoRouteMatch>> _getLocRouteMatchStacks({
    required String loc,
    required String restLoc,
    required String parentSubloc,
    required List<GoRoute> routes,
    required String parentFullpath,
    required Map<String, String> queryParams,
    required Object? extra,
  }) sync* {
    // find the set of matches at this level of the tree
    for (final route in routes) {
      final fullpath = fullLocFor(parentFullpath, route.path);
      final match = GoRouteMatch.match(
        route: route,
        restLoc: restLoc,
        parentSubloc: parentSubloc,
        path: route.path,
        fullpath: fullpath,
        queryParams: queryParams,
        extra: extra,
      );
      if (match == null) continue;

      // if we have a complete match, then return the matched route
      // NOTE: need a lower case match because subloc is canonicalized to match
      // the path case whereas the location can be of any case and still match
      if (match.subloc.toLowerCase() == loc.toLowerCase()) {
        yield [match];
        continue;
      }

      // if we have a partial match but no sub-routes, bail
      if (route.routes.isEmpty) continue;

      // otherwise recurse
      final childRestLoc =
          loc.substring(match.subloc.length + (match.subloc == '/' ? 0 : 1));
      assert(loc.startsWith(match.subloc));
      assert(restLoc.isNotEmpty);

      // if there's no sub-route matches, then we don't have a match for this
      // location
      final subRouteMatchStacks = _getLocRouteMatchStacks(
        loc: loc,
        restLoc: childRestLoc,
        parentSubloc: match.subloc,
        routes: route.routes,
        parentFullpath: fullpath,
        queryParams: queryParams,
        extra: extra,
      ).toList();
      if (subRouteMatchStacks.isEmpty) continue;

      // add the match to each of the sub-route match stacks and return them
      for (final stack in subRouteMatchStacks) {
        yield [match, ...stack];
      }
    }
  }

  GoRouteMatch? _getNameRouteMatch(
    String name, {
    Map<String, String> params = const {},
    Map<String, String> queryParams = const {},
    Object? extra,
  }) {
    final partialMatch = _namedMatches[name];
    return partialMatch == null
        ? null
        : GoRouteMatch.matchNamed(
            name: name,
            route: partialMatch.route,
            fullpath: partialMatch.fullpath,
            params: params,
            queryParams: queryParams,
            extra: extra,
          );
  }

  // e.g.
  // parentFullLoc: '',          path =>                  '/'
  // parentFullLoc: '/',         path => 'family/:fid' => '/family/:fid'
  // parentFullLoc: '/',         path => 'family/f2' =>   '/family/f2'
  // parentFullLoc: '/family/f2', path => 'parent/p1' =>   '/family/f2/person/p1'
  // ignore: public_member_api_docs
  static String fullLocFor(String parentFullLoc, String path) {
    // at the root, just return the path
    if (parentFullLoc.isEmpty) {
      assert(path.startsWith('/'));
      assert(path == '/' || !path.endsWith('/'));
      return path;
    }

    // not at the root, so append the parent path
    assert(path.isNotEmpty);
    assert(!path.startsWith('/'));
    assert(!path.endsWith('/'));
    return '${parentFullLoc == '/' ? '' : parentFullLoc}/$path';
  }

  Widget _builder(BuildContext context, Iterable<GoRouteMatch> matches) {
    List<Page<dynamic>>? pages;
    Exception? error;

    try {
      // build the stack of pages
      if (routerNeglect) {
        Router.neglect(
          context,
          () => pages = getPages(context, matches.toList()).toList(),
        );
      } else {
        pages = getPages(context, matches.toList()).toList();
      }

      // note that we need to catch it this way to get all the info, e.g. the
      // file/line info for an error in an inline function impl, e.g. an inline
      // `redirect` impl
      // ignore: avoid_catches_without_on_clauses
    } catch (err, stack) {
      log.severe('Exception during GoRouter navigation', err, stack);

      // if there's an error, show an error page
      error = err is Exception ? err : Exception(err);
      final uri = Uri.parse(location);
      pages = [
        _errorPageBuilder(
          context,
          GoRouterState(
            this,
            location: location,
            subloc: uri.path,
            name: null,
            queryParams: uri.queryParameters,
            error: error,
          ),
        ),
      ];
    }

    // we should've set pages to something by now
    assert(pages != null);

    // pass either the match error or the build error along to the navigator
    // builder, preferring the match error
    if (matches.length == 1 && matches.first.error != null) {
      error = matches.first.error;
    }

    // wrap the returned Navigator to enable GoRouter.of(context).go()
    final uri = Uri.parse(location);
    return builderWithNav(
      context,
      GoRouterState(
        this,
        location: location,
        name: null, // no name available at the top level
        // trim the query params off the subloc to match route.redirect
        subloc: uri.path,
        // pass along the query params 'cuz that's all we have right now
        queryParams: uri.queryParameters,
        // pass along the error, if there is one
        error: error,
      ),
      Navigator(
        restorationScopeId: restorationScopeId,
        key: _key, // needed to enable Android system Back button
        pages: pages!,
        observers: observers,
        onPopPage: (route, dynamic result) {
          if (!route.didPop(result)) return false;
          pop();
          return true;
        },
      ),
    );
  }

  /// Get the stack of sub-routes that matches the location and turn it into a
  /// stack of pages, e.g.
  /// routes: [
  ///   /
  ///     family/:fid
  ///       person/:pid
  ///   /login
  /// ]
  ///
  /// loc: /
  /// pages: [ HomePage()]
  ///
  /// loc: /login
  /// pages: [ LoginPage() ]
  ///
  /// loc: /family/f2
  /// pages: [ HomePage(), FamilyPage(f2) ]
  ///
  /// loc: /family/f2/person/p1
  /// pages: [ HomePage(), FamilyPage(f2), PersonPage(f2, p1) ]
  @visibleForTesting
  Iterable<Page<dynamic>> getPages(
    BuildContext context,
    List<GoRouteMatch> matches,
  ) sync* {
    assert(matches.isNotEmpty);

    var params = <String, String>{};
    for (final match in matches) {
      // merge new params to keep params from previously matched paths, e.g.
      // /family/:fid/person/:pid provides fid and pid to person/:pid
      params = {...params, ...match.decodedParams};

      // get a page from the builder and associate it with a sub-location
      final state = GoRouterState(
        this,
        location: location,
        subloc: match.subloc,
        name: match.route.name,
        path: match.route.path,
        fullpath: match.fullpath,
        params: params,
        queryParams: match.queryParams,
        extra: match.extra,
        pageKey: match.pageKey, // push() remaps the page key for uniqueness
      );

      yield match.route.pageBuilder != null
          ? match.route.pageBuilder!(context, state)
          : _pageBuilder(context, state, match.route.builder);
    }
  }

  Page<void> Function({
    required LocalKey key,
    required String? name,
    required Object? arguments,
    required String restorationId,
    required Widget child,
  })? _pageBuilderForAppType;

  Widget Function(
    BuildContext context,
    GoRouterState state,
  )? _errorBuilderForAppType;

  void _cacheAppType(BuildContext context) {
    // cache app type-specific page and error builders
    if (_pageBuilderForAppType == null) {
      assert(_errorBuilderForAppType == null);

      // can be null during testing
      final elem = context is Element ? context : null;

      if (elem != null && isMaterialApp(elem)) {
        log.info('MaterialApp found');
        _pageBuilderForAppType = pageBuilderForMaterialApp;
        _errorBuilderForAppType =
            (c, s) => GoRouterMaterialErrorScreen(s.error);
      } else if (elem != null && isCupertinoApp(elem)) {
        log.info('CupertinoApp found');
        _pageBuilderForAppType = pageBuilderForCupertinoApp;
        _errorBuilderForAppType =
            (c, s) => GoRouterCupertinoErrorScreen(s.error);
      } else {
        log.info('WidgetsApp assumed');
        _pageBuilderForAppType = pageBuilderForWidgetApp;
        _errorBuilderForAppType = (c, s) => GoRouterErrorScreen(s.error);
      }
    }

    assert(_pageBuilderForAppType != null);
    assert(_errorBuilderForAppType != null);
  }

  // builds the page based on app type, i.e. MaterialApp vs. CupertinoApp
  Page<dynamic> _pageBuilder(
    BuildContext context,
    GoRouterState state,
    GoRouterWidgetBuilder builder,
  ) {
    // build the page based on app type
    _cacheAppType(context);
    return _pageBuilderForAppType!(
      key: state.pageKey,
      name: state.name ?? state.fullpath,
      arguments: {...state.params, ...state.queryParams},
      restorationId: state.pageKey.value,
      child: builder(context, state),
    );
  }

  /// Builds a page without any transitions.
  Page<void> pageBuilderForWidgetApp({
    required LocalKey key,
    required String? name,
    required Object? arguments,
    required String restorationId,
    required Widget child,
  }) =>
      NoTransitionPage<void>(
        name: name,
        arguments: arguments,
        key: key,
        restorationId: restorationId,
        child: child,
      );

  Page<void> _errorPageBuilder(
    BuildContext context,
    GoRouterState state,
  ) {
    // if the error page builder is provided, use that; otherwise, if the error
    // builder is provided, wrap that in an app-specific page, e.g.
    // MaterialPage; finally, if nothing is provided, use a default error page
    // wrapped in the app-specific page, e.g.
    // MaterialPage(GoRouterMaterialErrorPage(...))
    _cacheAppType(context);
    return errorPageBuilder != null
        ? errorPageBuilder!(context, state)
        : _pageBuilder(
            context,
            state,
            errorBuilder ?? _errorBuilderForAppType!,
          );
  }

  void _outputKnownRoutes() {
    log.info('known full paths for routes:');
    _outputFullPathsFor(routes, '', 0);

    if (_namedMatches.isNotEmpty) {
      log.info('known full paths for route names:');
      for (final e in _namedMatches.entries) {
        log.info('  ${e.key} => ${e.value.fullpath}');
      }
    }
  }

  void _outputFullPathsFor(
    List<GoRoute> routes,
    String parentFullpath,
    int depth,
  ) {
    for (final route in routes) {
      final fullpath = fullLocFor(parentFullpath, route.path);
      log.info('  => ${''.padLeft(depth * 2)}$fullpath');
      _outputFullPathsFor(route.routes, fullpath, depth + 1);
    }
  }

  static String _canonicalUri(String loc) {
    var canon = Uri.parse(loc).toString();
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

  static String _addQueryParams(String loc, Map<String, String> queryParams) {
    final uri = Uri.parse(loc);
    assert(uri.queryParameters.isEmpty);
    return _canonicalUri(
        Uri(path: uri.path, queryParameters: queryParams).toString());
  }
}
