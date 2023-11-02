// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import '../pointer_interceptor.dart';

/// A [Widget] that prevents clicks from being swallowed by [HtmlElementView]s.
class PointerInterceptorIOSLegacy extends PointerInterceptorPlatform {
  static void registerWith() {
    PointerInterceptorPlatform.instance = PointerInterceptorIOSLegacy();
  }

  @override
  Widget buildWidget(
      {required Widget child,
        bool intercepting = false,
        bool debug = false,
        Key? key}) {
    return child;
  }
}
