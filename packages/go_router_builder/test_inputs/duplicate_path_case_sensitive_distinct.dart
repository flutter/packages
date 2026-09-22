// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Case sensitive routes are the default, and two of them differing in case
// match different URLs, so they must not be reported.

import 'package:go_router/go_router.dart';

mixin $HomeRoute {}
mixin $LowerRoute {}
mixin $UpperRoute {}

@TypedGoRoute<HomeRoute>(
  path: '/home',
  routes: <TypedGoRoute<GoRouteData>>[
    TypedGoRoute<LowerRoute>(path: 'details'),
    TypedGoRoute<UpperRoute>(path: 'Details'),
  ],
)
class HomeRoute extends GoRouteData with $HomeRoute {}

class LowerRoute extends GoRouteData with $LowerRoute {}

class UpperRoute extends GoRouteData with $UpperRoute {}
