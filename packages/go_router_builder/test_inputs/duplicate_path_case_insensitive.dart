// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// A route that is not case sensitive matches any casing of its path, so it
// shadows a later route whose path differs from it only in case.

import 'package:go_router/go_router.dart';

mixin $HomeRoute {}
mixin $LowerRoute {}
mixin $UpperRoute {}

@TypedGoRoute<HomeRoute>(
  path: '/home',
  routes: <TypedGoRoute<GoRouteData>>[
    TypedGoRoute<LowerRoute>(path: 'details', caseSensitive: false),
    TypedGoRoute<UpperRoute>(path: 'Details', caseSensitive: false),
  ],
)
class HomeRoute extends GoRouteData with $HomeRoute {}

class LowerRoute extends GoRouteData with $LowerRoute {}

class UpperRoute extends GoRouteData with $UpperRoute {}
