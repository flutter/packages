// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'parser.dart';

/// A data class that can be serialized and stored into browser history entry.
///
/// Passing an instance of this class into the `extra` parameter makes the
/// browser store to memorize data in this instance when handling browser
/// backward and forward button, e.g pressing backward button in a browser will
/// send back the BrowserState that associated with the URL.
///
/// {@tool snippet}
/// To create a [BrowserState] with the data, the data must be encoded through
/// JSON codec.
///
/// ```dart
/// ElevatedButton(
///   child: const Text('button'),
///   onPressed: () {
///     final Map<String, String> data = <String, String>{
///       'id': '123',
///     };
///     final BrowserState extra = BrowserState(
///       jsonString: const JsonEncoder.convert(data),
///     );
///     context.go('/user', extra);
///   }
/// )
/// {@end-tool}
/// ```
class BrowserState {
  /// Creates an [BrowserState] with a JSON encoded string.
  const BrowserState({required this.jsonString});

  /// A JSON encoded string for the data.
  final String jsonString;
}

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
    Object? effectiveState;
    if (routeInformation.state != null &&
        routeInformation.state is BrowserState) {
      effectiveState = (routeInformation.state! as BrowserState).jsonString;
    }
    SystemNavigator.routeInformationUpdated(
      location: routeInformation.location!,
      state: effectiveState,
      replace: replace,
    );
    _value = routeInformation;
    _valueInEngine = routeInformation;
  }

  @override
  RouteInformation get value => DebugGoRouteInformation(
        location: _value.location,
        state: _value.state,
      );
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
  Future<bool> didPushRouteInformation(
      RouteInformation routeInformation) async {
    assert(hasListeners);
    Object? effectiveState;
    if (routeInformation.state != null && routeInformation.state is String) {
      effectiveState =
          BrowserState(jsonString: routeInformation.state! as String);
    }
    _platformReportsNewRouteInformation(RouteInformation(
      location: routeInformation.location,
      state: effectiveState,
    ));
    return true;
  }

  @override
  Future<bool> didPushRoute(String route) async {
    assert(hasListeners);
    _platformReportsNewRouteInformation(RouteInformation(location: route));
    return true;
  }
}

/// A debug class that is used for asserting the [GoRouteInformationProvider] is
/// in use with the [GoRouteInformationParser].
class DebugGoRouteInformation extends RouteInformation {
  /// Creates a [DebugGoRouteInformation].
  DebugGoRouteInformation({String? location, Object? state})
      : super(location: location, state: state);
}
