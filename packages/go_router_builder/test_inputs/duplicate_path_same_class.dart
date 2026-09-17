// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Declaring one route class twice, so its children can be grouped by feature
// area, works at runtime. It is still reported, because the builder cannot tell
// a deliberate grouping from an accidental duplicate. Use the `ignore` severity
// to opt out.

import 'package:go_router/go_router.dart';

mixin $HomeRoute {}
mixin $DetailsRoute {}
mixin $InvoicesRoute {}
mixin $ShipmentsRoute {}

@TypedGoRoute<HomeRoute>(
  path: '/home',
  routes: <TypedGoRoute<GoRouteData>>[
    TypedGoRoute<DetailsRoute>(
      path: 'details',
      routes: <TypedGoRoute<GoRouteData>>[TypedGoRoute<InvoicesRoute>(path: 'invoices')],
    ),
    TypedGoRoute<DetailsRoute>(
      path: 'details',
      routes: <TypedGoRoute<GoRouteData>>[TypedGoRoute<ShipmentsRoute>(path: 'shipments')],
    ),
  ],
)
class HomeRoute extends GoRouteData with $HomeRoute {}

class DetailsRoute extends GoRouteData with $DetailsRoute {}

class InvoicesRoute extends GoRouteData with $InvoicesRoute {}

class ShipmentsRoute extends GoRouteData with $ShipmentsRoute {}
