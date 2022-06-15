// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:meta/meta_meta.dart';

abstract class GoRouteData {
  const GoRouteData();

  static String $location(String path, {Map<String, String>? queryParams}) =>
      throw UnimplementedError();
  static GoRoute $route({
    required String path,
    required GoRouteData Function(GoRouterState) factory,
    List<GoRoute> routes = const <GoRoute>[],
  }) =>
      throw UnimplementedError();
}

abstract class GoRoute {}

@Target(<TargetKind>{TargetKind.library, TargetKind.classType})
class TypedGoRoute<T extends GoRouteData> {
  const TypedGoRoute({
    required this.path,
    this.routes = const <TypedGoRoute<GoRouteData>>[],
  });

  final String path;
  final List<TypedGoRoute<GoRouteData>> routes;
}

abstract class GoRouterState {
  Object? get extra;
  Map<String, String> get params;
  Map<String, String> get queryParams;
}
