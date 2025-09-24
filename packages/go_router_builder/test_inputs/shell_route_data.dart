// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

@TypedShellRoute<ShellRouteNoConstConstructor>()
class ShellRouteNoConstConstructor extends ShellRouteData {}

@TypedShellRoute<ShellRouteWithConstConstructor>()
class ShellRouteWithConstConstructor extends ShellRouteData {
  const ShellRouteWithConstConstructor();
}

@TypedShellRoute<ShellRouteWithRestorationScopeId>()
class ShellRouteWithRestorationScopeId extends ShellRouteData {
  const ShellRouteWithRestorationScopeId();

  static const String $restorationScopeId = 'shellRouteWithRestorationScopeId';
}
