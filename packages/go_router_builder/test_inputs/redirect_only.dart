// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

mixin $RedirectRoute {}

mixin $InheritedRedirectRoute {}

mixin $InheritedBuildRoute {}

mixin $MixinPageRoute {}

mixin $MixinRedirectRoute {}

mixin $RelativeRedirectRoute {}

@TypedGoRoute<RedirectRoute>(path: '/redirect')
class RedirectRoute extends GoRouteData with $RedirectRoute {
  @override
  String? redirect(BuildContext context, GoRouterState state) => null;
}

@TypedGoRoute<InheritedRedirectRoute>(path: '/inherited-redirect')
class InheritedRedirectRoute extends RedirectRoute with $InheritedRedirectRoute {}

class BuildRoute extends RedirectRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) => const SizedBox();
}

@TypedGoRoute<InheritedBuildRoute>(path: '/inherited-build')
class InheritedBuildRoute extends BuildRoute with $InheritedBuildRoute {}

mixin PageBuilder on GoRouteData {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const NoTransitionPage<void>(child: SizedBox());
}

@TypedGoRoute<MixinPageRoute>(path: '/mixin-page')
class MixinPageRoute extends RedirectRoute with PageBuilder, $MixinPageRoute {}

mixin Redirect on GoRouteData {
  @override
  String? redirect(BuildContext context, GoRouterState state) => null;
}

@TypedGoRoute<MixinRedirectRoute>(path: '/mixin-redirect')
class MixinRedirectRoute extends GoRouteData with Redirect, $MixinRedirectRoute {}

@TypedRelativeGoRoute<RelativeRedirectRoute>(path: 'relative-redirect')
class RelativeRedirectRoute extends RelativeGoRouteData with $RelativeRedirectRoute {
  @override
  String? redirect(BuildContext context, GoRouterState state) => null;
}
