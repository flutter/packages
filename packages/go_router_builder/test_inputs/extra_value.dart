// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

mixin $ExtraValueRoute {}

@TypedGoRoute<ExtraValueRoute>(path: '/default-value-route')
class ExtraValueRoute extends GoRouteData with $ExtraValueRoute {
  ExtraValueRoute({this.param = 0, this.$extra});
  final int param;
  final int? $extra;
}
