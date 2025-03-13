// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

@TypedGoRoute<ListRoute>(path: '/list-route')
class ListRoute extends GoRouteData {
  ListRoute({
    required this.ids,
    this.nullableIds,
    this.idsWithDefaultValue = const <int>[0],
  });
  final List<int> ids;
  final List<int>? nullableIds;
  final List<int> idsWithDefaultValue;
}
