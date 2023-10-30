// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'pointer_interceptor_method_channel.dart';

abstract class PointerInterceptorPlatform extends PlatformInterface {
  /// Constructs a PointerInterceptorPlatform.
  PointerInterceptorPlatform() : super(token: _token);

  static final Object _token = Object();

  /// The default instance of [PointerInterceptorPlatform] to use.
  ///
  /// Defaults to [PlaceholderPointerInterceptor].
  static PointerInterceptorPlatform _instance = PlaceholderPointerInterceptor();

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PointerInterceptorPlatform] when
  /// they register themselves.
  static set instance(PointerInterceptorPlatform? instance) {
    if (instance == null) {
      throw AssertionError(
          'Platform interfaces can only be set to a non-null instance');
    }

    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  static PointerInterceptorPlatform get instance => _instance;

  Widget buildWidget({
    required Widget child,
    bool intercepting = true,
    bool debug = false,
    Key? key,
  }) {
    throw UnimplementedError('buildWidget() has not been implemented.');
  }
}