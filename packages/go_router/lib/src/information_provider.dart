// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// The decision on how to handle the route
/// when host tells the application to push a new one.
enum PushRouteDecision {
  /// Delegate the route information to [WidgetsBindingObserver.didPushRoute],
  /// in registration order, until one returns true.
  delegate,

  /// Prevent the route information from being addressed by [GoRouter].
  prevent,

  /// Delegate the route information to the [GoRouter].
  navigate,
}

/// Signature for callbacks that report a pushed route information.
typedef PushRouteCallback = FutureOr<PushRouteDecision> Function(
  RouteInformation routeInformation,
);

/// The [RouteInformationProvider] created by go_router.
class GoRouteInformationProvider extends RouteInformationProvider
    with WidgetsBindingObserver, ChangeNotifier {
  /// Creates a [GoRouteInformationProvider].
  GoRouteInformationProvider({
    required RouteInformation initialRouteInformation,
    PushRouteCallback? onPushRoute,
    Listenable? refreshListenable,
  })  : _refreshListenable = refreshListenable,
        _onPushRoute = onPushRoute,
        _value = initialRouteInformation {
    _refreshListenable?.addListener(notifyListeners);
  }

  final Listenable? _refreshListenable;
  final PushRouteCallback? _onPushRoute;

  // ignore: unnecessary_non_null_assertion
  static WidgetsBinding get _binding => WidgetsBinding.instance;

  @override
  void routerReportsNewRouteInformation(RouteInformation routeInformation,
      {RouteInformationReportingType type =
          RouteInformationReportingType.none}) {
    // Avoid adding a new history entry if the route is the same as before.
    final bool replace = type == RouteInformationReportingType.neglect ||
        (type == RouteInformationReportingType.none &&
            _valueInEngine.location == routeInformation.location);
    SystemNavigator.selectMultiEntryHistory();
    // TODO(chunhtai): report extra to browser through state if possible
    // See https://github.com/flutter/flutter/issues/108142
    SystemNavigator.routeInformationUpdated(
      location: routeInformation.location!,
      replace: replace,
    );
    _value = routeInformation;
    _valueInEngine = routeInformation;
  }

  @override
  RouteInformation get value => _value;
  RouteInformation _value;

  set value(RouteInformation other) {
    final bool shouldNotify =
        _value.location != other.location || _value.state != other.state;
    _value = other;
    if (shouldNotify) {
      notifyListeners();
    }
  }

  RouteInformation _valueInEngine =
      RouteInformation(location: _binding.platformDispatcher.defaultRouteName);

  Future<bool> _platformReportsNewRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final PushRouteDecision decision =
        await _onPushRoute?.call(routeInformation) ??
            PushRouteDecision.navigate;

    switch (decision) {
      case PushRouteDecision.delegate:
        return false;
      case PushRouteDecision.prevent:
        return true;
      case PushRouteDecision.navigate:
        assert(hasListeners);
        if (_value != routeInformation) {
          _value = routeInformation;
          _valueInEngine = routeInformation;
          notifyListeners();
        }
        return true;
    }
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
    return _platformReportsNewRouteInformation(routeInformation);
  }

  @override
  Future<bool> didPushRoute(String route) {
    final RouteInformation routeInformation = RouteInformation(location: route);
    return _platformReportsNewRouteInformation(routeInformation);
  }
}
