// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

mixin $ProfileRoute {}

mixin $SettingRoute {}

// A child path that starts with `/` is still nested under its parent at
// runtime, so its location must include the parent path.
@TypedGoRoute<ProfileRoute>(
  path: '/profile',
  routes: <TypedRoute<RouteData>>[TypedGoRoute<SettingRoute>(path: '/setting')],
)
class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();
}

class SettingRoute extends GoRouteData with $SettingRoute {
  const SettingRoute();
}
