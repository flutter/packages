// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'configuration.dart';

/// The signature of the widget builder callback for a matched GoRoute.
typedef GoRouterWidgetBuilder = Widget Function(
  BuildContext context,
  GoRouterState state,
);

/// The signature of the page builder callback for a matched GoRoute.
typedef GoRouterPageBuilder = Page<void> Function(
  BuildContext context,
  GoRouterState state,
);

/// The signature of the navigatorBuilder callback.
typedef GoRouterNavigatorBuilder = Widget Function(
  BuildContext context,
  GoRouterState state,
  Widget child,
);

/// Signature of a go router builder function with navigator.
typedef GoRouterBuilderWithNav = Widget Function(
  BuildContext context,
  GoRouterState state,
  Navigator navigator,
);

/// The signature of the redirect callback.
typedef GoRouterRedirect = String? Function(GoRouterState state);
