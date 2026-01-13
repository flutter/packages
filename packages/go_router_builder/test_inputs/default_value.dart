// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

mixin $DefaultValueRoute {}

@TypedGoRoute<DefaultValueRoute>(path: '/default-value-route')
class DefaultValueRoute extends GoRouteData with $DefaultValueRoute {
  DefaultValueRoute({this.param = 0});
  final int param;
}
