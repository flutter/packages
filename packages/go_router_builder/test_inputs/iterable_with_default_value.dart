// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

mixin _$IterableDefaultValueRoute {}

@TypedGoRoute<IterableDefaultValueRoute>(path: '/iterable-default-value-route')
class IterableDefaultValueRoute extends GoRouteData
    with _$IterableDefaultValueRoute {
  IterableDefaultValueRoute({this.param = const <int>[0]});
  final Iterable<int> param;
}
