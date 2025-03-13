// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:pointer_interceptor_platform_interface/pointer_interceptor_platform_interface.dart';

/// A [Widget] that prevents clicks from being swallowed by PlatformViews.
class PointerInterceptor extends StatelessWidget {
  /// Create a `PointerInterceptor` wrapping a `child`.
  // ignore: prefer_const_constructors_in_immutables
  PointerInterceptor({
    required this.child,
    this.intercepting = true,
    this.debug = false,
    super.key,
  });

  /// The `Widget` that is being wrapped by this `PointerInterceptor`.
  final Widget child;

  /// Whether or not this `PointerInterceptor` should intercept pointer events.
  final bool intercepting;

  /// When true, the widget renders with a semi-transparent red background, for debug purposes.
  ///
  /// This is useful when rendering this as a "layout" widget, like the root child
  /// of a `Drawer`.
  final bool debug;

  @override
  Widget build(BuildContext context) {
    if (!intercepting) {
      return child;
    }
    return PointerInterceptorPlatform.instance
        .buildWidget(child: child, debug: debug, key: key);
  }
}
