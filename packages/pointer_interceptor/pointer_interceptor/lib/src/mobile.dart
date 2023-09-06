// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

/// The no-op iOS implementation of the [PointerInterceptorPlatform]
class PointerInterceptorPlugin extends PointerInterceptorPlatform {
  /// Register for the web plugin.
  static void registerWith(Registrar registrar) {
    PointerInterceptorPlatform.instance = PointerInterceptorPlugin();
  }

  @override
  Widget buildWidget(
      {required Widget child,
      bool intercepting = true,
      bool debug = false,
      Key? key}) {
    return child;
  }
}


