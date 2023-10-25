// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

@TypedGoRoute<RequiredNullableTypeArgumentsExtraValueRoute>(
    path: '/default-value-route')
class RequiredNullableTypeArgumentsExtraValueRoute extends GoRouteData {
  RequiredNullableTypeArgumentsExtraValueRoute({required this.$extra});
  final List<int?> $extra;
}
