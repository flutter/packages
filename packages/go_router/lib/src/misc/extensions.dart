// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import '../router.dart';

/// Dart extension to add navigation function to a BuildContext object, e.g.
/// context.go('/');
extension GoRouterHelper on BuildContext {
  /// Get a location from route name and parameters.
  ///
  /// This method can't be called during redirects.
  String namedLocation(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    String? fragment,
  }) =>
      GoRouter.of(this).namedLocation(name,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
          fragment: fragment);

  /// Navigate to a location.
  void go(String location, {Object? extra}) =>
      GoRouter.of(this).go(location, extra: extra);

  /// Navigate to a named route.
  void goNamed(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
    String? fragment,
  }) =>
      GoRouter.of(this).goNamed(name,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
          extra: extra,
          fragment: fragment);

  /// Push a location onto the page stack.
  ///
  /// See also:
  /// * [pushReplacement] which replaces the top-most page of the page stack and
  ///   always uses a new page key.
  /// * [replace] which replaces the top-most page of the page stack but treats
  ///   it as the same page. The page key will be reused. This will preserve the
  ///   state and not run any page animation.
  Future<T?> push<T extends Object?>(String location, {Object? extra}) =>
      GoRouter.of(this).push<T>(location, extra: extra);

  /// Navigate to a named route onto the page stack.
  Future<T?> pushNamed<T extends Object?>(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) =>
      GoRouter.of(this).pushNamed<T>(
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        extra: extra,
      );

  /// Returns `true` if there is more than 1 page on the stack.
  bool canPop() => GoRouter.of(this).canPop();

  /// Pop the top page off the Navigator's page stack by calling
  /// [Navigator.pop].
  void pop<T extends Object?>([T? result]) => GoRouter.of(this).pop(result);

  /// Replaces the top-most page of the page stack with the given URL location
  /// w/ optional query parameters, e.g. `/family/f2/person/p1?color=blue`.
  ///
  /// See also:
  /// * [go] which navigates to the location.
  /// * [push] which pushes the given location onto the page stack.
  /// * [replace] which replaces the top-most page of the page stack but treats
  ///   it as the same page. The page key will be reused. This will preserve the
  ///   state and not run any page animation.
  void pushReplacement(String location, {Object? extra}) =>
      GoRouter.of(this).pushReplacement(location, extra: extra);

  /// Replaces the top-most page of the page stack with the named route w/
  /// optional parameters, e.g. `name='person', pathParameters={'fid': 'f2', 'pid':
  /// 'p1'}`.
  ///
  /// See also:
  /// * [goNamed] which navigates a named route.
  /// * [pushNamed] which pushes a named route onto the page stack.
  void pushReplacementNamed(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) =>
      GoRouter.of(this).pushReplacementNamed(
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        extra: extra,
      );

  /// Replaces the top-most page of the page stack with the given one but treats
  /// it as the same page.
  ///
  /// The page key will be reused. This will preserve the state and not run any
  /// page animation.
  ///
  /// See also:
  /// * [push] which pushes the given location onto the page stack.
  /// * [pushReplacement] which replaces the top-most page of the page stack but
  ///   always uses a new page key.
  void replace(String location, {Object? extra}) =>
      GoRouter.of(this).replace<Object?>(location, extra: extra);

  /// Replaces the top-most page with the named route and optional parameters,
  /// preserving the page key.
  ///
  /// This will preserve the state and not run any page animation. Optional
  /// parameters can be provided to the named route, e.g. `name='person',
  /// pathParameters={'fid': 'f2', 'pid': 'p1'}`.
  ///
  /// See also:
  /// * [pushNamed] which pushes the given location onto the page stack.
  /// * [pushReplacementNamed] which replaces the top-most page of the page
  ///   stack but always uses a new page key.
  void replaceNamed(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) =>
      GoRouter.of(this).replaceNamed<Object?>(name,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
          extra: extra);
}
