// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

mixin $HasNotOverriddenOnExitRoute {}

@TypedGoRoute<HasNotOverriddenOnExitRoute>(path: '/has-not-overridden-on-exit-route')
class HasNotOverriddenOnExitRoute extends GoRouteData
    with $HasNotOverriddenOnExitRoute {}
