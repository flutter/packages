// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

mixin _$CaseSensitiveRoute {}
mixin _$NotCaseSensitiveRoute {}

@TypedGoRoute<CaseSensitiveRoute>(path: '/case-sensitive-route')
class CaseSensitiveRoute extends GoRouteData with _$CaseSensitiveRoute {}

@TypedGoRoute<NotCaseSensitiveRoute>(
  path: '/not-case-sensitive-route',
  caseSensitive: false,
)
class NotCaseSensitiveRoute extends GoRouteData with _$NotCaseSensitiveRoute {}
