// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../go_router.dart';
import 'configuration.dart';
import 'matching.dart';
import 'misc/errors.dart';

/// The route state during routing.
///
/// The state contains parsed artifacts of the current URI.
@immutable
class GoRouterState {
  /// Default constructor for creating route state during routing.
  const GoRouterState(
    this._configuration, {
    required this.location,
    required this.subloc,
    required this.name,
    this.path,
    this.fullpath,
    this.params = const <String, String>{},
    this.queryParams = const <String, String>{},
    this.queryParametersAll = const <String, List<String>>{},
    this.extra,
    this.error,
    required this.pageKey,
  });

  // TODO(johnpryan): remove once namedLocation is removed from go_router.
  // See https://github.com/flutter/flutter/issues/107729
  final RouteConfiguration _configuration;

  /// The full location of the route, e.g. /family/f2/person/p1
  final String location;

  /// The location of this sub-route, e.g. /family/f2
  final String subloc;

  /// The optional name of the route.
  final String? name;

  /// The path to this sub-route, e.g. family/:fid
  final String? path;

  /// The full path to this sub-route, e.g. /family/:fid
  final String? fullpath;

  /// The parameters for this sub-route, e.g. {'fid': 'f2'}
  final Map<String, String> params;

  /// The query parameters for the location, e.g. {'from': '/family/f2'}
  final Map<String, String> queryParams;

  /// The query parameters for the location,
  /// e.g. `{'q1': ['v1'], 'q2': ['v2', 'v3']}`
  final Map<String, List<String>> queryParametersAll;

  /// An extra object to pass along with the navigation.
  final Object? extra;

  /// The error associated with this sub-route.
  final Exception? error;

  /// A unique string key for this sub-route, e.g. ValueKey('/family/:fid')
  final ValueKey<String> pageKey;

  /// Gets the [GoRouterState] from context.
  ///
  /// The returned [GoRouterState] will depends on which [GoRoute] or
  /// [ShellRoute] the input `context` is in.
  ///
  /// This method only supports [GoRoute] and [ShellRoute] that generate
  /// [ModalRoute]s. This is typically the case if one uses [GoRoute.builder],
  /// [ShellRoute.builder], [CupertinoPage], [MaterialPage],
  /// [CustomTransitionPage], or [NoTransitionPage].
  ///
  /// This method is fine to be called during [GoRoute.builder] or
  /// [ShellRoute.builder].
  ///
  /// This method cannot be called during [GoRoute.pageBuilder] or
  /// [ShellRoute.pageBuilder] since there is no [GoRouterState] to be
  /// associated with.
  ///
  /// To access GoRouterState from a widget.
  ///
  /// ```
  /// GoRoute(
  ///   path: '/:id'
  ///   builder: (_, __) => MyWidget(),
  /// );
  ///
  /// class MyWidget extends StatelessWidget {
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return Text('${GoRouterState.of(context).params['id']}');
  ///   }
  /// }
  /// ```
  static GoRouterState of(BuildContext context) {
    final ModalRoute<Object?>? route = ModalRoute.of(context);
    if (route == null) {
      throw GoError('There is no modal route above the current context.');
    }
    final RouteSettings settings = route.settings;
    if (settings is! Page<Object?>) {
      throw GoError(
          'The parent route must be a page route to have a GoRouterState');
    }
    final GoRouterStateRegistryScope? scope = context
        .dependOnInheritedWidgetOfExactType<GoRouterStateRegistryScope>();
    if (scope == null) {
      throw GoError(
          'There is no GoRouterStateRegistryScope above the current context.');
    }
    final GoRouterState state =
        scope.notifier!._createPageRouteAssociation(settings, route);
    return state;
  }

  /// Get a location from route name and parameters.
  /// This is useful for redirecting to a named location.
  @Deprecated(
      'Uses GoRouter.of(context).routeInformationParser.namedLocation instead')
  String namedLocation(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, String> queryParams = const <String, String>{},
  }) {
    return _configuration.namedLocation(name,
        params: params, queryParams: queryParams);
  }

  @override
  bool operator ==(Object other) {
    return other is GoRouterState &&
        other.location == location &&
        other.subloc == subloc &&
        other.name == name &&
        other.path == path &&
        other.fullpath == fullpath &&
        other.params == params &&
        other.queryParams == queryParams &&
        other.queryParametersAll == queryParametersAll &&
        other.extra == extra &&
        other.error == error &&
        other.pageKey == pageKey;
  }

  @override
  int get hashCode => Object.hash(location, subloc, name, path, fullpath,
      params, queryParams, queryParametersAll, extra, error, pageKey);
}

/// An inherited widget to host a [GoRouterStateRegistry] for the subtree.
///
/// Should not be used directly, consider using [GoRouterState.of] to access
/// [GoRouterState] from the context.
class GoRouterStateRegistryScope
    extends InheritedNotifier<GoRouterStateRegistry> {
  /// Creates a GoRouterStateRegistryScope.
  const GoRouterStateRegistryScope({
    super.key,
    required GoRouterStateRegistry registry,
    required super.child,
  }) : super(notifier: registry);
}

/// A registry to record [GoRouterState] to [Page] relation.
///
/// Should not be used directly, consider using [GoRouterState.of] to access
/// [GoRouterState] from the context.
class GoRouterStateRegistry extends ChangeNotifier {
  /// creates a [GoRouterStateRegistry].
  GoRouterStateRegistry();

  /// A [Map] that maps a [Page] to a [GoRouterState].
  @visibleForTesting
  final Map<Page<Object?>, GoRouterState> registry =
      <Page<Object?>, GoRouterState>{};

  final Map<Route<Object?>, Page<Object?>> _routePageAssociation =
      <ModalRoute<Object?>, Page<Object?>>{};

  GoRouterState _createPageRouteAssociation(
      Page<Object?> page, ModalRoute<Object?> route) {
    assert(route.settings == page);
    assert(registry.containsKey(page));
    final Page<Object?>? oldPage = _routePageAssociation[route];
    if (oldPage == null) {
      // This is a new association.
      _routePageAssociation[route] = page;
      // If there is an association, the registry relies on the route to remove
      // entry from registry because it wants to preserve the GoRouterState
      // until the route finishes the popping animations.
      route.completed.then<void>((Object? result) {
        // Can't use `page` directly because Route.settings may have changed during
        // the lifetime of this route.
        final Page<Object?> associatedPage =
            _routePageAssociation.remove(route)!;
        assert(registry.containsKey(associatedPage));
        registry.remove(associatedPage);
      });
    } else if (oldPage != page) {
      // Need to update the association to avoid memory leak.
      _routePageAssociation[route] = page;
      assert(registry.containsKey(oldPage));
      registry.remove(oldPage);
    }
    assert(_routePageAssociation[route] == page);
    return registry[page]!;
  }

  /// Updates this registry with new records.
  void updateRegistry(Map<Page<Object?>, GoRouterState> newRegistry) {
    bool shouldNotify = false;
    final Set<Page<Object?>> pagesWithAssociation =
        _routePageAssociation.values.toSet();
    for (final MapEntry<Page<Object?>, GoRouterState> entry
        in newRegistry.entries) {
      final GoRouterState? existingState = registry[entry.key];
      if (existingState != null) {
        if (existingState != entry.value) {
          shouldNotify =
              shouldNotify || pagesWithAssociation.contains(entry.key);
          registry[entry.key] = entry.value;
        }
        continue;
      }
      // Not in the _registry.
      registry[entry.key] = entry.value;
      // Adding or removing registry does not need to notify the listen since
      // no one should be depending on them.
    }
    registry.removeWhere((Page<Object?> key, GoRouterState value) {
      if (newRegistry.containsKey(key)) {
        return false;
      }
      // For those that have page route association, it will be removed by the
      // route future. Need to notify the listener so they can update the page
      // route association if its page has changed.
      if (pagesWithAssociation.contains(key)) {
        shouldNotify = true;
        return false;
      }
      return true;
    });
    if (shouldNotify) {
      notifyListeners();
    }
  }
}

/// The snapshot of the current state of a [StatefulShellRoute].
///
/// Note that this an immutable class, that represents the snapshot of the state
/// of a StatefulShellRoute at a given point in time. Therefore, instances of
/// this object should not be stored, but instead fetched fresh when needed,
/// using the method [StatefulShellRoute.of].
@immutable
class StatefulShellRouteState {
  /// Constructs a [StatefulShellRouteState].
  const StatefulShellRouteState({
    required this.route,
    required this.branchStates,
    required this.currentIndex,
    required void Function(StatefulShellBranchState, RouteMatchList?)
        switchActiveBranch,
    required void Function() resetState,
  })  : _switchActiveBranch = switchActiveBranch,
        _resetState = resetState;

  /// Constructs a copy of this [StatefulShellRouteState], with updated values
  /// for some of the fields.
  StatefulShellRouteState copy(
      {List<StatefulShellBranchState>? branchStates, int? currentIndex}) {
    return StatefulShellRouteState(
      route: route,
      branchStates: branchStates ?? this.branchStates,
      currentIndex: currentIndex ?? this.currentIndex,
      switchActiveBranch: _switchActiveBranch,
      resetState: _resetState,
    );
  }

  /// The associated [StatefulShellRoute]
  final StatefulShellRoute route;

  /// The state for all separate route branches associated with a
  /// [StatefulShellRoute].
  final List<StatefulShellBranchState> branchStates;

  /// The state associated with the current [StatefulShellBranch].
  StatefulShellBranchState get currentBranchState => branchStates[currentIndex];

  /// The index of the currently active [StatefulShellBranch].
  ///
  /// Corresponds to the index of the branch in the List returned from
  /// branchBuilder of [StatefulShellRoute].
  final int currentIndex;

  /// The Navigator key of the current navigator.
  GlobalKey<NavigatorState> get currentNavigatorKey =>
      currentBranchState.branch.navigatorKey;

  final void Function(StatefulShellBranchState, RouteMatchList?)
      _switchActiveBranch;

  final void Function() _resetState;

  /// Gets the [Widget]s representing each of the shell branches.
  ///
  /// The Widget returned from this method contains the [Navigator]s of the
  /// branches. Note that the Widgets returned by this method should only be
  /// added to the widget tree if using a custom branch container Widget
  /// implementation, where the child parameter in the [ShellRouteBuilder] of
  /// the [StatefulShellRoute] is ignored (i.e. not added to the widget tree).
  /// See [StatefulShellBranchState.child].
  List<Widget> get children =>
      branchStates.map((StatefulShellBranchState e) => e.child).toList();

  /// Navigate to the current location of the shell navigator with the provided
  /// Navigator key, name or index.
  ///
  /// This method will switch the currently active [Navigator] for the
  /// [StatefulShellRoute] by replacing the current navigation stack with the
  /// one of the route branch identified by the provided Navigator key, name or
  /// index. If resetLocation is true, the branch will be reset to its default
  /// location (see [StatefulShellBranch.defaultLocation]).
  void goBranch({
    GlobalKey<NavigatorState>? navigatorKey,
    String? name,
    int? index,
    bool resetLocation = false,
  }) {
    assert(navigatorKey != null || name != null || index != null);
    assert(<dynamic>[navigatorKey, name, index].whereNotNull().length == 1);

    final StatefulShellBranchState? state;
    if (navigatorKey != null) {
      state = branchStates.firstWhereOrNull((StatefulShellBranchState e) =>
          e.branch.navigatorKey == navigatorKey);
      if (state == null) {
        throw GoError('Unable to find branch with key $navigatorKey');
      }
    } else if (name != null) {
      state = branchStates.firstWhereOrNull(
          (StatefulShellBranchState e) => e.branch.name == name);
      if (state == null) {
        throw GoError('Unable to find branch with name "$name"');
      }
    } else {
      state = branchStates[index!];
    }

    _switchActiveBranch(state, resetLocation ? null : state._matchList);
  }

  /// Refreshes this StatefulShellRouteState by rebuilding the state for the
  /// current location.
  void refresh() {
    _switchActiveBranch(currentBranchState, currentBranchState._matchList);
  }

  /// Resets this StatefulShellRouteState by clearing all navigation state of
  /// the branches, and returning the current branch to its default location.
  void reset() {
    _resetState();
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other is! StatefulShellRouteState) {
      return false;
    }
    return other.route == route &&
        listEquals(other.branchStates, branchStates) &&
        other.currentIndex == currentIndex;
  }

  @override
  int get hashCode => Object.hash(route, currentIndex, currentIndex);
}

/// The snapshot of the current state for a particular route branch
/// ([StatefulShellBranch]) in a [StatefulShellRoute].
///
/// Note that this an immutable class, that represents the snapshot of the state
/// of a StatefulShellBranchState at a given point in time. Therefore, instances of
/// this object should not be stored, but instead fetched fresh when needed,
/// via the [StatefulShellRouteState] returned by the method
/// [StatefulShellRoute.of].
@immutable
class StatefulShellBranchState {
  /// Constructs a [StatefulShellBranchState].
  const StatefulShellBranchState({
    required this.branch,
    required this.child,
    RouteMatchList? matchList,
  }) : _matchList = matchList;

  /// Constructs a copy of this [StatefulShellBranchState], with updated values for
  /// some of the fields.
  StatefulShellBranchState copy({Widget? child, RouteMatchList? matchList}) {
    return StatefulShellBranchState(
      branch: branch,
      child: child ?? this.child,
      matchList: matchList ?? _matchList,
    );
  }

  /// The associated [StatefulShellBranch]
  final StatefulShellBranch branch;

  /// The [Widget] representing this route branch in a [StatefulShellRoute].
  ///
  /// The Widget returned from this method contains the [Navigator] of the
  /// branch. Note that the Widget returned by this method should only
  /// be added to the widget tree if using a custom branch container Widget
  /// implementation, where the child parameter in the [ShellRouteBuilder] of
  /// the [StatefulShellRoute] is ignored (i.e. not added to the widget tree).
  final Widget child;

  /// The current navigation stack for the branch.
  final RouteMatchList? _matchList;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other is! StatefulShellBranchState) {
      return false;
    }
    return other.branch == branch &&
        other.child == child &&
        other._matchList == _matchList;
  }

  @override
  int get hashCode => Object.hash(branch, child, _matchList);
}

/// Helper extension on [StatefulShellBranchState], for internal use.
extension StatefulShellBranchStateHelper on StatefulShellBranchState {
  /// The current navigation stack for the branch.
  RouteMatchList? get matchList => _matchList;
}
