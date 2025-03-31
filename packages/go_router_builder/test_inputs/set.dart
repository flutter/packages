// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

@TypedGoRoute<SetRoute>(path: '/set-route')
class SetRoute extends GoRouteData {
  SetRoute({
    required this.ids,
    this.nullableIds,
    this.idsWithDefaultValue = const <int>{0},
  });
  final Set<int> ids;
  final Set<int>? nullableIds;
  final Set<int> idsWithDefaultValue;
}
