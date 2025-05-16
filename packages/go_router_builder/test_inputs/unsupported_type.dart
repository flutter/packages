// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

mixin _$UnsupportedType {}

@TypedGoRoute<UnsupportedType>(path: 'bob/:id')
class UnsupportedType extends GoRouteData with _$UnsupportedType {
  UnsupportedType({required this.id});
  final Stopwatch id;
}
