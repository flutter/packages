// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

mixin _$EnumParam {}

@TypedGoRoute<EnumParam>(path: '/:y')
class EnumParam extends GoRouteData with _$EnumParam {
  EnumParam({required this.y});
  final EnumTest y;
}

enum EnumTest {
  a(1),
  b(3),
  c(5);

  const EnumTest(this.x);
  final int x;
}
