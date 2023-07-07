// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

@TypedGoRoute<NullableDefaultValueRoute>(path: '/nullable-default-value-route')
class NullableDefaultValueRoute extends GoRouteData {
  NullableDefaultValueRoute({this.param = 0});
  final int? param;
}
