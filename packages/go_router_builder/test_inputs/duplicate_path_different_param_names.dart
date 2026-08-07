// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

mixin $HomeRoute {}
mixin $ProductRoute {}
mixin $VariantRoute {}

@TypedGoRoute<HomeRoute>(
  path: '/home',
  routes: <TypedGoRoute<GoRouteData>>[
    TypedGoRoute<ProductRoute>(path: 'item/:productId'),
    TypedGoRoute<VariantRoute>(path: 'item/:variantId'),
  ],
)
class HomeRoute extends GoRouteData with $HomeRoute {}

class ProductRoute extends GoRouteData with $ProductRoute {
  const ProductRoute({required this.productId});
  final String productId;
}

class VariantRoute extends GoRouteData with $VariantRoute {
  const VariantRoute({required this.variantId});
  final String variantId;
}
