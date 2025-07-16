// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

mixin _$ExtraValueRoute {}

@TypedGoRoute<ExtraValueRoute>(path: '/default-value-route')
class ExtraValueRoute extends GoRouteData with _$ExtraValueRoute {
  ExtraValueRoute({this.param = 0, this.$extra});
  final int param;
  final int? $extra;
}
