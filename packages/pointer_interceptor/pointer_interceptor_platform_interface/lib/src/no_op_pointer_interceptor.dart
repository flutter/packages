// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'package:flutter/widgets.dart';

import 'pointer_interceptor_platform.dart';

/// A default implementation of [PointerInterceptorPlatform].
class NoOpPointerInterceptor extends PointerInterceptorPlatform {
  @override
  Widget buildWidget({
    required Widget child,
    bool intercepting = true,
    bool debug = false,
    Key? key,
  }) {
    print('Please note this no-op behavior is being deprecated soon, '
        'so developers should remove the widget from mobile. '
        'If you wish to instead opt-in to the new iOS implementation, '
        'please include both pointer_interceptor_ios '
        'and pointer_interceptor in your pubspec.yaml');
    return child;
  }
}
