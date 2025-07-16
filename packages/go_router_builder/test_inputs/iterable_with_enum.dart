// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

mixin _$IterableWithEnumRoute {}

@TypedGoRoute<IterableWithEnumRoute>(path: '/iterable-with-enum')
class IterableWithEnumRoute extends GoRouteData with _$IterableWithEnumRoute {
  IterableWithEnumRoute({this.param});

  final Iterable<EnumOnlyUsedInIterable>? param;
}

enum EnumOnlyUsedInIterable {
  a,
  b,
  c,
}
