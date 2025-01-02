// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'match.dart';
import 'path_utils.dart';

/// The type of the navigation.
///
/// This enum is used by [RouteInformationState] to denote the navigation
/// operations.
enum NavigatingType {
  /// Push new location on top of the [RouteInformationState.baseRouteMatchList].
  push,

  /// Push new location and remove top-most [RouteMatch] of the
  /// [RouteInformationState.baseRouteMatchList].
  pushReplacement,

  /// Push new location and replace top-most [RouteMatch] of the
  /// [RouteInformationState.baseRouteMatchList].
  replace,

  /// Replace the entire [RouteMatchList] with the new location.
  go,

  /// Restore the current match list with
  /// [RouteInformationState.baseRouteMatchList].
  restore,
}

/// The data class to be stored in [RouteInformation.state] to be used by
/// [GoRouteInformationParser].
///
/// This state class is used internally in go_router and will not be sent to
/// the engine.
class RouteInformationState<T> {
  /// Creates an InternalRouteInformationState.
  @visibleForTesting
  RouteInformationState({
    this.extra,
    this.completer,
    this.baseRouteMatchList,
    required this.type,
  })  : assert((type == NavigatingType.go || type == NavigatingType.restore) ==
            (completer == null)),
        assert((type != NavigatingType.go) == (baseRouteMatchList != null));

  /// The extra object used when navigating with [GoRouter].
  final Object? extra;

  /// The completer that needs to be completed when the newly added route is
  /// popped off the screen.
  ///
  /// This is only null if [type] is [NavigatingType.go] or
  /// [NavigatingType.restore].
  final Completer<T?>? completer;

  /// The base route match list to push on top to.
  ///
  /// This is only null if [type] is [NavigatingType.go].
  final RouteMatchList? baseRouteMatchList;

  /// The type of navigation.
  final NavigatingType type;
}

/// The [RouteInformationProvider] created by go_router.
class GoRouteInformationProvider extends RouteInformationProvider
    with WidgetsBindingObserver, ChangeNotifier {
  /// Creates a [GoRouteInformationProvider].
  GoRouteInformationProvider({
    required String initialLocation,
    required Object? initialExtra,
    Listenable? refreshListenable,
    bool routerNeglect = false,
  })  : _refreshListenable = refreshListenable,
        _value = RouteInformation(
          uri: Uri.parse(initialLocation),
          state: RouteInformationState<void>(
              extra: initialExtra, type: NavigatingType.go),
        ),
        _valueInEngine = _kEmptyRouteInformation,
        _routerNeglect = routerNeglect {
    _refreshListenable?.addListener(notifyListeners);
  }

  final Listenable? _refreshListenable;

  final bool _routerNeglect;

  static WidgetsBinding get _binding => WidgetsBinding.instance;
  static final RouteInformation _kEmptyRouteInformation =
      RouteInformation(uri: Uri.parse(''));

  @override
  void routerReportsNewRouteInformation(RouteInformation routeInformation,
      {RouteInformationReportingType type =
          RouteInformationReportingType.none}) {
    // GoRouteInformationParser should always report encoded route match list
    // in the state.
    assert(routeInformation.state != null);
    final bool replace;
    switch (type) {
      case RouteInformationReportingType.none:
        if (!_valueHasChanged(
            newLocationUri: routeInformation.uri,
            newState: routeInformation.state)) {
          return;
        }
        replace = _valueInEngine == _kEmptyRouteInformation;
      case RouteInformationReportingType.neglect:
        replace = true;
      case RouteInformationReportingType.navigate:
        replace = false;
    }
    SystemNavigator.selectMultiEntryHistory();
    SystemNavigator.routeInformationUpdated(
      uri: routeInformation.uri,
      state: routeInformation.state,
      replace: _routerNeglect || replace,
    );
    _value = _valueInEngine = routeInformation;
  }

  @override
  RouteInformation get value => _value;
  RouteInformation _value;

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

  void _setValue(String location, Object state) {
    Uri uri = Uri.parse(location);

    // Check for relative location
    if (location.startsWith('./')) {
      uri = concatenateUris(_value.uri, uri);
    }

    final bool shouldNotify =
        _valueHasChanged(newLocationUri: uri, newState: state);
    _value = RouteInformation(uri: uri, state: state);
    if (shouldNotify) {
      notifyListeners();
    }
  }

  /// Pushes the `location` as a new route on top of `base`.
  Future<T?> push<T>(String location,
      {required RouteMatchList base, Object? extra}) {
    final Completer<T?> completer = Completer<T?>();
    _setValue(
      location,
      RouteInformationState<T>(
        extra: extra,
        baseRouteMatchList: base,
        completer: completer,
        type: NavigatingType.push,
      ),
    );
    return completer.future;
  }

  /// Replace the current route matches with the `location`.
  void go(String location, {Object? extra}) {
    _setValue(
      location,
      RouteInformationState<void>(
        extra: extra,
        type: NavigatingType.go,
      ),
    );
  }

  /// Restores the current route matches with the `matchList`.
  void restore(String location, {required RouteMatchList matchList}) {
    _setValue(
      matchList.uri.toString(),
      RouteInformationState<void>(
        extra: matchList.extra,
        baseRouteMatchList: matchList,
        type: NavigatingType.restore,
      ),
    );
  }

  /// Removes the top-most route match from `base` and pushes the `location` as a
  /// new route on top.
  Future<T?> pushReplacement<T>(String location,
      {required RouteMatchList base, Object? extra}) {
    final Completer<T?> completer = Completer<T?>();
    _setValue(
      location,
      RouteInformationState<T>(
        extra: extra,
        baseRouteMatchList: base,
        completer: completer,
        type: NavigatingType.pushReplacement,
      ),
    );
    return completer.future;
  }

  /// Replaces the top-most route match from `base` with the `location`.
  Future<T?> replace<T>(String location,
      {required RouteMatchList base, Object? extra}) {
    final Completer<T?> completer = Completer<T?>();
    _setValue(
      location,
      RouteInformationState<T>(
        extra: extra,
        baseRouteMatchList: base,
        completer: completer,
        type: NavigatingType.replace,
      ),
    );
    return completer.future;
  }

  RouteInformation _valueInEngine;

  void _platformReportsNewRouteInformation(RouteInformation routeInformation) {
    if (_value == routeInformation) {
      return;
    }
    if (routeInformation.state != null) {
      _value = _valueInEngine = routeInformation;
    } else {
      _value = RouteInformation(
        uri: routeInformation.uri,
        state: RouteInformationState<void>(type: NavigatingType.go),
      );
      _valueInEngine = _kEmptyRouteInformation;
    }
    notifyListeners();
  }

  bool _valueHasChanged(
      {required Uri newLocationUri, required Object? newState}) {
    const DeepCollectionEquality deepCollectionEquality =
        DeepCollectionEquality();
    return !deepCollectionEquality.equals(
            _value.uri.path, newLocationUri.path) ||
        !deepCollectionEquality.equals(
            _value.uri.queryParameters, newLocationUri.queryParameters) ||
        !deepCollectionEquality.equals(
            _value.uri.fragment, newLocationUri.fragment) ||
        !deepCollectionEquality.equals(_value.state, newState);
  }

  @override
  void addListener(VoidCallback listener) {
    if (!hasListeners) {
      _binding.addObserver(this);
    }
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) {
      _binding.removeObserver(this);
    }
  }

  @override
  void dispose() {
    if (hasListeners) {
      _binding.removeObserver(this);
    }
    _refreshListenable?.removeListener(notifyListeners);
    super.dispose();
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) {
    assert(hasListeners);
    _platformReportsNewRouteInformation(routeInformation);
    return SynchronousFuture<bool>(true);
  }
}
