// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'pointer_interceptor_platform.dart';

/// A defailt implementation of [PointerInterceptorPlatform].
class PlaceholderPointerInterceptor extends PointerInterceptorPlatform {
  @override
  Widget buildWidget(
      {required Widget child, bool intercepting = true, bool debug = false, Key? key}) {
    throw UnimplementedError('buildWidget() has not been implemented.');
  }
}
