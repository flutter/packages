// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import '../router.dart';

/// Dart extension to add navigation function to a BuildContext object, e.g.
/// context.go('/');
extension GoRouterHelper on BuildContext {
  /// Get a location from route name and parameters.
  String namedLocation(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
  }) =>
      GoRouter.of(this)
          .namedLocation(name, params: params, queryParams: queryParams);

  /// Navigate to a location.
  void go(String location, {Object? extra}) =>
      GoRouter.of(this).go(location, extra: extra);

  /// Navigate to a named route.
  void goNamed(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) =>
      GoRouter.of(this).goNamed(
        name,
        params: params,
        queryParams: queryParams,
        extra: extra,
      );

  /// Push a location onto the page stack.
  void push(String location, {Object? extra}) =>
      GoRouter.of(this).push(location, extra: extra);

  /// Navigate to a named route onto the page stack.
  void pushNamed(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) =>
      GoRouter.of(this).pushNamed(
        name,
        params: params,
        queryParams: queryParams,
        extra: extra,
      );

  /// Returns `true` if there is more than 1 page on the stack.
  bool canPop() => GoRouter.of(this).canPop();

  /// Pop the top page off the Navigator's page stack by calling
  /// [Navigator.pop].
  void pop() => GoRouter.of(this).pop();

  /// Replaces the top-most page of the page stack with the given URL location
  /// w/ optional query parameters, e.g. `/family/f2/person/p1?color=blue`.
  ///
  /// See also:
  /// * [go] which navigates to the location.
  /// * [push] which pushes the location onto the page stack.
  void pushReplacement(String location, {Object? extra}) =>
      GoRouter.of(this).pushReplacement(location, extra: extra);

  /// Replaces the top-most page of the page stack with the named route w/
  /// optional parameters, e.g. `name='person', params={'fid': 'f2', 'pid':
  /// 'p1'}`.
  ///
  /// See also:
  /// * [goNamed] which navigates a named route.
  /// * [pushNamed] which pushes a named route onto the page stack.
  void pushReplacementNamed(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) =>
      GoRouter.of(this).pushReplacementNamed(
        name,
        params: params,
        queryParams: queryParams,
        extra: extra,
      );

  /// Returns true if the route is registered within the [GoRouter].
  bool hasRoute(String name) => GoRouter.of(this).hasRoute(name);
}
