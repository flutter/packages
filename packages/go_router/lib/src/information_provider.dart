// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// The [RouteInformationProvider] created by go_router.
class GoRouteInformationProvider extends RouteInformationProvider
    with WidgetsBindingObserver, ChangeNotifier {
  /// Creates a [GoRouteInformationProvider].
  GoRouteInformationProvider({
    required RouteInformation initialRouteInformation,
    Listenable? refreshListenable,
  })  : _refreshListenable = refreshListenable,
        _value = initialRouteInformation {
    _refreshListenable?.addListener(notifyListeners);
  }

  final Listenable? _refreshListenable;

  static WidgetsBinding get _binding => WidgetsBinding.instance;

  @override
  void routerReportsNewRouteInformation(RouteInformation routeInformation,
      {RouteInformationReportingType type =
          RouteInformationReportingType.none}) {
    // Avoid adding a new history entry if the route is the same as before.
    final bool replace = type == RouteInformationReportingType.neglect ||
        (type == RouteInformationReportingType.none &&
            // TODO(chunhtai): remove this ignore and migrate the code
            // https://github.com/flutter/flutter/issues/124045.
            // ignore: deprecated_member_use
            _valueInEngine.location == routeInformation.location);
    SystemNavigator.selectMultiEntryHistory();
    // TODO(chunhtai): report extra to browser through state if possible
    // See https://github.com/flutter/flutter/issues/108142
    SystemNavigator.routeInformationUpdated(
      // TODO(chunhtai): remove this ignore and migrate the code
      // https://github.com/flutter/flutter/issues/124045.
      // ignore: deprecated_member_use, unnecessary_null_checks, unnecessary_non_null_assertion
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
        // TODO(chunhtai): remove this ignore and migrate the code
        // https://github.com/flutter/flutter/issues/124045.
        // ignore: deprecated_member_use
        _value.location != other.location || _value.state != other.state;
    _value = other;
    if (shouldNotify) {
      notifyListeners();
    }
  }

  RouteInformation _valueInEngine =
      // TODO(chunhtai): remove this ignore and migrate the code
      // https://github.com/flutter/flutter/issues/124045.
      // ignore: deprecated_member_use
      RouteInformation(location: _binding.platformDispatcher.defaultRouteName);

  void _platformReportsNewRouteInformation(RouteInformation routeInformation) {
    if (_value == routeInformation) {
      return;
    }
    _value = routeInformation;
    _valueInEngine = routeInformation;
    notifyListeners();
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

  @override
  Future<bool> didPushRoute(String route) {
    assert(hasListeners);
    // TODO(chunhtai): remove this ignore and migrate the code
    // https://github.com/flutter/flutter/issues/124045.
    // ignore: deprecated_member_use
    _platformReportsNewRouteInformation(RouteInformation(location: route));
    return SynchronousFuture<bool>(true);
  }
}
