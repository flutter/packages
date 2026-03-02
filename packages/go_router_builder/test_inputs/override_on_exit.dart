// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

mixin $OverrideOnExitRoute {}
mixin $NotOverrideOnExitRoute {}

@TypedGoRoute<OverrideOnExitRoute>(
  path: '/override-on-exit-route',
  overrideOnExit: true,
)
class OverrideOnExitRoute extends GoRouteData with $OverrideOnExitRoute {}

@TypedGoRoute<NotOverrideOnExitRoute>(
  path: '/not-override-on-exit-route',
)
class NotOverrideOnExitRoute extends GoRouteData with $NotOverrideOnExitRoute {}
