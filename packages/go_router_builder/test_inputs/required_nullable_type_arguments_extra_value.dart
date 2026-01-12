// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

mixin $RequiredNullableTypeArgumentsExtraValueRoute {}

@TypedGoRoute<RequiredNullableTypeArgumentsExtraValueRoute>(
  path: '/default-value-route',
)
class RequiredNullableTypeArgumentsExtraValueRoute extends GoRouteData
    with $RequiredNullableTypeArgumentsExtraValueRoute {
  RequiredNullableTypeArgumentsExtraValueRoute({required this.$extra});
  final List<int?> $extra;
}
