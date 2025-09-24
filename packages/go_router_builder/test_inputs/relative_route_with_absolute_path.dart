// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

mixin $RelativeRoute {}

@TypedRelativeGoRoute<RelativeRoute>(path: '/relative-route')
class RelativeRoute extends RelativeGoRouteData with $RelativeRoute {
  const RelativeRoute();
}
