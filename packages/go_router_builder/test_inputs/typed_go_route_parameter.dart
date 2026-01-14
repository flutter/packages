// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

mixin $OverriddenParameterNameRoute {}

@TypedGoRoute<OverriddenParameterNameRoute>(path: '/typed-go-route-parameter')
class OverriddenParameterNameRoute extends GoRouteData
    with $OverriddenParameterNameRoute {
  OverriddenParameterNameRoute({
    @TypedGoRouteParameter(name: 'parameterNameOverride') this.withAnnotation,
  });
  final int? withAnnotation;
}
