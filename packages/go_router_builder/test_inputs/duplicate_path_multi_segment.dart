// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// A multi-segment path resolves to the same URL as the equivalent nesting, even
// though the two routes sit at different depths.

import 'package:go_router/go_router.dart';

mixin $HomeRoute {}
mixin $SectionRoute {}
mixin $NestedRoute {}
mixin $MultiSegmentRoute {}

@TypedGoRoute<HomeRoute>(
  path: '/home',
  routes: <TypedGoRoute<GoRouteData>>[
    TypedGoRoute<SectionRoute>(
      path: 'section',
      routes: <TypedGoRoute<GoRouteData>>[TypedGoRoute<NestedRoute>(path: 'detail')],
    ),
    TypedGoRoute<MultiSegmentRoute>(path: 'section/detail'),
  ],
)
class HomeRoute extends GoRouteData with $HomeRoute {}

class SectionRoute extends GoRouteData with $SectionRoute {}

class NestedRoute extends GoRouteData with $NestedRoute {}

class MultiSegmentRoute extends GoRouteData with $MultiSegmentRoute {}
