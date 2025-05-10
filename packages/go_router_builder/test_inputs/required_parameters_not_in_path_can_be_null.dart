// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

mixin _$NullableRequiredParamNotInPath {}

@TypedGoRoute<NullableRequiredParamNotInPath>(path: 'bob')
class NullableRequiredParamNotInPath extends GoRouteData
    with _$NullableRequiredParamNotInPath {
  NullableRequiredParamNotInPath({required this.id});
  final int? id;
}
