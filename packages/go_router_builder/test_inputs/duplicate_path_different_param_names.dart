// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

mixin $HomeRoute {}
mixin $MealRoute {}
mixin $DrinkRoute {}

@TypedGoRoute<HomeRoute>(
  path: '/home',
  routes: <TypedGoRoute<GoRouteData>>[
    TypedGoRoute<MealRoute>(path: 'item/:mealId'),
    TypedGoRoute<DrinkRoute>(path: 'item/:drinkId'),
  ],
)
class HomeRoute extends GoRouteData with $HomeRoute {}

class MealRoute extends GoRouteData with $MealRoute {
  const MealRoute({required this.mealId});
  final String mealId;
}

class DrinkRoute extends GoRouteData with $DrinkRoute {
  const DrinkRoute({required this.drinkId});
  final String drinkId;
}
